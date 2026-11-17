classdef fmt_target
    %fmt_target - Internal implementation of the FMT Coder target
    %   fmt_target provides shared services for the public configuration and
    %   build commands and the native Coder hook.
    %
    %   fmt_target functions:
    %       catalog - Locate vehicle source models
    %       options - Validate applied build settings
    %       modules - Select BSP modules in MATLAB
    %       select  - Apply Coder target defaults
    %       build   - Invoke the original SCons build
    %       sync    - Publish generated code transactionally
    %
    %   See also fmt_configure_models, fmt_build_all

    methods (Static)
        function catalog = catalog(vehicle)
            %CATALOG - Map existing vehicle models to Firmware modules
            %   CATALOG = fmt_target.catalog(VEHICLE) locates the source models.
            if nargin < 1, vehicle = 'Multicopter'; end
            rootDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            vehicles = {'Multicopter','Fixwing','VTOL','Car','Boat'};
            folders = {'MC','FW','VTOL','Car','Boat'};
            plants = {'multicopter','fixwing','vtol','','boat'};
            index = find(strcmp(vehicle, vehicles), 1);
            assert(~isempty(index), 'FMT:UnsupportedVehicle', ...
                'No Simulink source catalog is available for vehicle %s.', vehicle);
            folder = folders{index};
            names = {'Controller', 'FMS', 'INS', 'Plant'};
            modules = {['control/' lower(folder) '_controller'], ...
                ['fms/' lower(folder) '_fms'], 'ins/cf_ins', ['plant/' plants{index}]};
            sources = {['model/Controller/' folder '-Controller/Controller.slx'], ...
                ['model/FMS/' folder '-FMS/FMS.slx'], 'model/INS/CF-INS/INS.slx', ...
                ['model/Plant/' folder '-Plant/Plant.slx']};
            prefixes = {'CONTROL', 'FMS', 'INS', 'PLANT'};
            count = 4 - strcmp(vehicle, 'Car');
            catalog = repmat(struct('name','','module','','source','','prefix',''), 1, count);
            for k = 1:count
                catalog(k).name = names{k};
                catalog(k).module = modules{k};
                catalog(k).source = fullfile(rootDir, sources{k});
                catalog(k).prefix = prefixes{k};
            end
        end

        function options = options(modelName)
            %OPTIONS - Read and validate the applied FMT configuration
            %   OPTIONS = fmt_target.options(modelName) reads target and local paths.
            assert(ispref('FMT', 'FirmwareRoot'), 'FMT:MissingFirmwareRoot', ...
                'Set the FMT/FirmwareRoot MATLAB preference before building.');
            root = char(getpref('FMT', 'FirmwareRoot'));
            assert(isfolder(root) && isempty(regexp(root, '["%!\r\n]', 'once')), ...
                'FMT:InvalidFirmwareRoot', 'FirmwareRoot must be an existing, shell-safe directory.');
            options.firmwareRoot = char(java.io.File(root).getCanonicalPath());
            options.board = char(get_param(modelName, 'FMTBoard'));
            options.board = strrep(options.board, '\', '/');
            options.vehicle = char(get_param(modelName, 'FMTVehicle'));
            options.airframe = str2double(string(get_param(modelName, 'FMTAirframe')));
            options.sim = char(get_param(modelName, 'FMTSimMode'));
            assert(~isempty(regexp(options.board, '^[A-Za-z0-9_+-]+(/[A-Za-z0-9_+-]+)*$', 'once')), ...
                'FMT:InvalidBoard', ...
                'Board must be a relative directory inside Firmware/target.');
            fmt_target.catalog(options.vehicle);
            assert(isfinite(options.airframe) && options.airframe >= 1 && ...
                options.airframe == fix(options.airframe), 'FMT:InvalidAirframe', ...
                'Airframe must be a positive integer.');
            assert(any(strcmp(options.sim, {'None','SIH','HIL','VR','Plant'})), ...
                'FMT:InvalidSimulationMode', 'Unknown FMT simulation mode.');
            targetRoot = char(java.io.File(fullfile(options.firmwareRoot, 'target')).getCanonicalPath());
            options.boardDir = char(java.io.File(fullfile(targetRoot, options.board)).getCanonicalPath());
            assert(startsWith([options.boardDir filesep], [targetRoot filesep], 'IgnoreCase', ispc) && ...
                ~strcmpi(options.boardDir, targetRoot), 'FMT:InvalidBoard', ...
                'Board must be a relative directory inside Firmware/target.');
            assert(isfile(fullfile(options.boardDir, 'SConstruct')), ...
                'FMT:MissingBoard', 'Board SConstruct not found: %s', options.boardDir);
        end

        function modules = modules(options)
            %MODULES - Select modules using the existing BSP configuration rules
            %   MODULES = fmt_target.modules(OPTIONS) returns native SCons module order.
            %   Current BSP module lists do not branch on the airframe number.
            board = lower(strrep(char(options.board), '\', '/'));
            vehicle = char(options.vehicle);
            sim = char(options.sim);
            switch board
                case {'sieon/s1','pixhawk/fmu-v6c','cuav/x7_plus','yundrone/x1', ...
                        'qemu/qemu-vexpress-a9','infineon/edge-e83/m33', ...
                        'infineon/edge-e83/m55'}
                    profile = 'full';
                    allowed = {'Multicopter','Fixwing','VTOL','Boat','Car','Template'};
                case {'amov/icf5','cuav/7_nano','cuav/v5_nano', ...
                        'cuav/v5_plus','pixhawk/fmu-v5'}
                    profile = 'standard';
                    allowed = {'Multicopter','Fixwing','Boat','Car','Template'};
                case 'minimum/cuav/v5_plus'
                    profile = 'minimum';
                    allowed = {'Multicopter','Fixwing','Template'};
                otherwise
                    error('FMT:UnsupportedBSP', 'No MATLAB module rules exist for BSP %s.', board);
            end
            if ~any(strcmp(vehicle, allowed))
                error('FMT:UnsupportedVehicle', 'BSP %s does not support vehicle %s.', board, vehicle);
            end
            if strcmp(vehicle, 'Template')
                modules = {'plant/template_plant','ins/template_ins', ...
                    'fms/template_fms','control/template_controller'};
            else
                vehicles = {'Multicopter','Fixwing','VTOL','Boat','Car'};
                tags = {'mc','fw','vtol','boat','car'};
                plants = {'multicopter','fixwing','vtol','boat','template_plant'};
                index = find(strcmp(vehicle, vehicles), 1);
                plant = plants{index};
                ins = 'cf_ins';
                if strcmp(profile, 'minimum')
                    % The minimum BSP ignores --sim and uses the fixed-wing
                    % template plant.
                    if strcmp(vehicle, 'Fixwing'), plant = 'template_plant'; end
                elseif strcmp(sim, 'HIL')
                    plant = 'template_plant';
                    ins = 'external_ins';
                end
                modules = {['plant/' plant], ['ins/' ins], ...
                    ['fms/' tags{index} '_fms'], ['control/' tags{index} '_controller']};
            end
            for k = 1:numel(modules)
                file = fullfile(options.firmwareRoot, 'src', 'model', modules{k}, 'SConscript');
                assert(isfile(file), 'FMT:MissingModule', 'Model SConscript not found: %s', file);
            end
        end

        function select(hDlg, hSrc)
            %SELECT - Apply the FMT system target defaults
            %   fmt_target.select(hDlg,hSrc) initializes the Coder settings.
            slConfigUISetVal(hDlg, hSrc, 'GenCodeOnly', 'off');
            slConfigUISetVal(hDlg, hSrc, 'GenerateMakefile', 'off');
            slConfigUISetVal(hDlg, hSrc, 'GenerateSampleERTMain', 'off');
            slConfigUISetVal(hDlg, hSrc, 'CodeReplacementLibrary', 'STM32 DSP LIB');
            slConfigUISetVal(hDlg, hSrc, 'UtilityFuncGeneration', 'Auto');
            slConfigUISetVal(hDlg, hSrc, 'ProdIntDivRoundTo', 'Zero');
            slConfigUISetVal(hDlg, hSrc, 'TargetIntDivRoundTo', 'Zero');
        end

        function binPath = build(modelName)
            %BUILD - Compile with native SCons and return the firmware image
            %   binPath = fmt_target.build(modelName) compiles synchronized modules.
            options = fmt_target.options(modelName);
            boardDir = options.boardDir;

            cmd = sprintf(['scons -C "%s" -j4 --vehicle=%s ' ...
                '--airframe=%d --sim=%s'], ...
                boardDir, options.vehicle, options.airframe, options.sim);

            [status, cmdout] = system(cmd, '-echo');
            assert(status == 0 && contains(cmdout, 'scons: done building targets.'), ...
                'Firmware compilation did not finish successfully. See the build output.');

            bins = dir(fullfile(boardDir, 'build', 'fmt_*.bin'));
            assert(isscalar(bins) && bins(1).bytes > 0, ...
                'Expected exactly one nonempty fmt_*.bin firmware image.');

            binPath = fullfile(bins(1).folder, bins(1).name);
            fprintf('Firmware output: %s\n', binPath);
        end

        function sync(modelNames, configModel)
            %SYNC - Replace each selected library with its generated C/H files
            %   fmt_target.sync(modelNames,configModel) validates and stages all exports
            %   before updating Firmware libraries. Unchanged exports are skipped.
            modelNames = cellstr(string(modelNames));
            options = fmt_target.options(configModel);
            modules = fmt_target.modules(options);
            catalog = fmt_target.catalog(options.vehicle);
            selected = catalog(ismember({catalog.module}, modules));
            assert(all(ismember(modelNames, {selected.name})), 'FMT:UnselectedModel', ...
                'A requested model is not selected by the MATLAB BSP rules.');
            assert(~isempty(selected) && ~isempty(modelNames) && ...
                numel(unique(modelNames)) == numel(modelNames), 'FMT:InvalidModelSet', ...
                'Select at least one model, without duplicate names.');
            workRoot = fullfile(options.firmwareRoot, 'build', 'model_sync');
            if ~isfolder(workRoot), mkdir(workRoot); end
            stageRoot = tempname(workRoot);
            mkdir(stageRoot);
            cleanup = onCleanup(@() cleanupStageRoot(stageRoot, workRoot));
            records = struct('stage', {}, 'destination', {}, 'backup', {}, 'touched', {});

            for k = 1:numel(modelNames)
                entry = catalog(strcmp({catalog.name}, modelNames{k}));
                assert(strcmpi(get_param(entry.name, 'FileName'), entry.source), ...
                    'FMT:WrongModel', 'Unexpected source model: %s', entry.name);
                assert(strcmp(get_param(entry.name, 'SystemTargetFile'), 'fmt_ert.tlc'), ...
                    'FMT:WrongTarget', 'Configure %s with fmt_ert.tlc first.', entry.name);
                info = RTW.getBuildDir(entry.name);
                src = info.BuildDirectory;
                assert(isfile(fullfile(src, [entry.name '.c'])) && ...
                    isfile(fullfile(src, [entry.name '.h'])), 'FMT:MissingCode', ...
                    'Generate %s successfully before synchronization.', entry.name);
                destination = fullfile(options.firmwareRoot, 'src', 'model', entry.module, 'lib');
                assert(isfolder(destination), 'FMT:MissingModule', ...
                    'Firmware model library not found: %s', destination);
                validateInterface(entry, src, fileparts(destination), options.airframe);
                stage = cloneLibrary(destination, stageRoot);
                previous = sourceFiles(stage);
                for f = 1:numel(previous)
                    delete(fullfile(stage, previous(f).name));
                end
                marker = fullfile(stage, '_fmt_shared.manifest');
                if isfile(marker), delete(marker); end
                files = sourceFiles(src);
                for f = 1:numel(files)
                    name = files(f).name;
                    copyfile(fullfile(src, name), fullfile(stage, name));
                end
                records(end + 1) = makeRecord(stage, destination); %#ok<AGROW>
            end

            try
                for k = 1:numel(records)
                    dst = records(k).destination;
                    if isfolder(dst) && sameFolder(records(k).stage, dst)
                        fprintf('FMT unchanged: %s\n', dst);
                        continue;
                    end
                    if ~isfolder(fileparts(dst)), mkdir(fileparts(dst)); end
                    if isfolder(dst)
                        [~, label] = fileparts(fileparts(dst));
                        [~, uniquePart] = fileparts(tempname(workRoot));
                        records(k).backup = fullfile(workRoot, [label '_' uniquePart]);
                        movefile(dst, records(k).backup);
                    end
                    records(k).touched = true;
                    movefile(records(k).stage, dst);
                    fprintf('FMT synchronized: %s\n', dst);
                    if ~isempty(records(k).backup)
                        fprintf('Previous code backup: %s\n', records(k).backup);
                    end
                end
            catch err
                for k = numel(records):-1:1
                    if ~records(k).touched, continue; end
                    if isfolder(records(k).destination)
                        movefile(records(k).destination, tempname(workRoot));
                    end
                    if ~isempty(records(k).backup) && isfolder(records(k).backup)
                        movefile(records(k).backup, records(k).destination);
                    end
                end
                rethrow(err);
            end
            clear cleanup;

        end
    end
end

function cleanupStageRoot(location, workRoot)
% Only remove the transaction directory created by this call.
assert(strcmp(fileparts(location), workRoot), ...
    'FMT:UnsafeCleanup', 'Staging folder escaped the synchronization root.');
if isfolder(location), rmdir(location, 's'); end
end

function record = makeRecord(stage, destination)
record = struct('stage', stage, 'destination', destination, ...
    'backup', '', 'touched', false);
end

function files = sourceFiles(folder)
files = [dir(fullfile(folder, '*.c')); dir(fullfile(folder, '*.h'))];
end

function stage = cloneLibrary(source, workRoot)
stage = tempname(workRoot);
mkdir(stage);
files = dir(source);
for k = 1:numel(files)
    if any(strcmp(files(k).name, {'.','..'})), continue; end
    assert(~files(k).isdir, 'FMT:UnexpectedLibraryDirectory', ...
        'Generated libraries must not contain custom subdirectories: %s', source);
    copyfile(fullfile(source, files(k).name), fullfile(stage, files(k).name));
end
end

function text = canonicalSource(file)
text = strrep(fileread(file), sprintf('\r\n'), newline);
% A timestamp or model revision banner alone does not require a backup.
text = regexprep(text, ['(?m)^\s*\* (Model version\s*:|' ...
    'C/C\+\+ source code generated on\s*:)[^\n]*\n'], '');
end

function result = sameFolder(first, second)
a = dir(first); a = a(~[a.isdir]);
b = dir(second); b = b(~[b.isdir]);
[aNames, orderA] = sort({a.name});
[bNames, orderB] = sort({b.name});
result = isequal(aNames, bNames);
if ~result, return; end
for k = 1:numel(aNames)
    result = strcmp(canonicalSource(fullfile(first, a(orderA(k)).name)), ...
        canonicalSource(fullfile(second, b(orderB(k)).name)));
    if ~result, return; end
end
end

function validateInterface(entry, source, moduleRoot, airframe)
headers = dir(fullfile(source, '*.h'));
generated = '';
for k = 1:numel(headers)
    generated = [generated newline fileread(fullfile(source, headers(k).name))]; %#ok<AGROW>
end
if strcmp(entry.name, 'Controller')
    tokens = regexp(generated, 'AIRFRAME\s*==\s*(\d+)', 'tokens');
    frames = unique(cellfun(@(token) str2double(token{1}), tokens));
    assert(isempty(frames) || any(airframe == frames), 'FMT:UnsupportedAirframe', ...
        'Airframe %d is absent from the generated Controller variants.', airframe);
end
if strcmp(entry.name, 'Controller'), stem = 'control'; else, stem = lower(entry.name); end
interface = fileread(fullfile(moduleRoot, [stem '_interface.c']));
tokens = regexp(interface, [entry.prefix '_PARAM\.(\w+)'], 'tokens');
required = unique(cellfun(@(token) token{1}, tokens, 'UniformOutput', false));
for k = 1:numel(required)
    field = required{k};
    assert(~isempty(regexp(generated, ['\<' field '\>'], 'once')), ...
        'FMT:InterfaceMismatch', '%s exports no parameter field %s.', entry.name, field);
end
for suffix = {'init', 'step'}
    symbol = [entry.name '_' suffix{1}];
    assert(~isempty(regexp(generated, ['\<' symbol '\s*\('], 'once')), ...
        'FMT:InterfaceMismatch', '%s exports no function %s.', entry.name, symbol);
end
end
