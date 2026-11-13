function fmt_sync_models(modelNames, ownerModel)
%fmt_sync_models - Stage generated modules and shared support code together
modelNames = cellstr(string(modelNames));
if nargin < 2, ownerModel = modelNames{1}; end
options = fmt_build_options(ownerModel);
modules = fmt_firmware_modules(ownerModel);
catalog = fmt_model_catalog(options.vehicle);
selected = catalog(ismember({catalog.module}, modules));
assert(all(ismember(modelNames, {selected.name})), 'FMT:UnselectedModel', ...
    'A requested model is not selected by the board config/model.py.');
completeSet = all(ismember({selected.name}, modelNames));
assert(~isempty(selected) && ~isempty(modelNames) && ...
    numel(unique(modelNames)) == numel(modelNames), 'FMT:InvalidModelSet', ...
    'Select at least one model, without duplicate names.');
workRoot = fullfile(options.firmwareRoot, 'build', 'model_sync');
if ~isfolder(workRoot), mkdir(workRoot); end
sharedOwner = selected(1);
ownerDst = fullfile(options.firmwareRoot, 'src', 'model', sharedOwner.module, 'lib');
stageRoot = tempname(workRoot);
mkdir(stageRoot);
cleanup = onCleanup(@() cleanupStageRoot(stageRoot, workRoot));
sharedStage = fullfile(stageRoot, 'shared');
mkdir(sharedStage);
seedShared(ownerDst, sharedStage);
sharedImports = containers.Map('KeyType', 'char', 'ValueType', 'char');
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
    stage = tempname(stageRoot);
    mkdir(stage);
    files = sourceFiles(src);
    for f = 1:numel(files)
        name = files(f).name;
        source = fullfile(src, name);
        % Fixed-name generated runtime routines must be compiled only once.
        if ~isempty(regexp(name, '^rt[A-Z_].*\.[ch]$', 'once'))
            importShared(source, name);
        else
            copyfile(source, fullfile(stage, name));
        end
    end
    if isfile(fullfile(src, 'rtwtypes.h'))
        importShared(fullfile(src, 'rtwtypes.h'), 'rtwtypes.h');
    end
    sharedDir = info.SharedUtilsTgtDir;
    if ~isfolder(sharedDir), sharedDir = fullfile(info.CodeGenFolder, sharedDir); end
    if isfolder(sharedDir)
        files = sourceFiles(sharedDir);
        for f = 1:numel(files)
            importShared(fullfile(sharedDir, files(f).name), files(f).name);
        end
    end
    records(end + 1) = makeRecord(stage, destination); %#ok<AGROW>
end

% The first selected source module owns the shared runtime. Its existing
% SConscript already compiles lib/*.c and publishes lib's include directory.
ownerIndex = find(strcmp({records.destination}, ownerDst), 1);
if isempty(ownerIndex)
    ownerStage = cloneLibrary(ownerDst, stageRoot);
    records(end + 1) = makeRecord(ownerStage, ownerDst);
    ownerIndex = numel(records);
end
ownerStage = records(ownerIndex).stage;
removeOldShared(ownerDst, ownerStage);
commonFiles = sourceFiles(sharedStage);
for f = 1:numel(commonFiles)
    name = commonFiles(f).name;
    target = fullfile(ownerStage, name);
    source = fullfile(sharedStage, name);
    if isfile(target)
        assert(strcmp(canonicalSource(target, true), canonicalSource(source, true)), ...
            'FMT:SharedOwnerConflict', 'Shared support conflicts with owner file %s.', name);
    else
        copyfile(source, target);
    end
end
writeSharedManifest(ownerStage, {commonFiles.name});

% Remove duplicate support sources from other selected libraries only when
% their implementations match. All updates are staged before publication.
commonSources = dir(fullfile(sharedStage, '*.c'));
for k = 1:numel(selected)
    if strcmp(selected(k).name, sharedOwner.name), continue; end
    otherLib = fullfile(options.firmwareRoot, 'src', 'model', selected(k).module, 'lib');
    recordIndex = find(strcmp({records.destination}, otherLib), 1);
    for f = 1:numel(commonSources)
        name = commonSources(f).name;
        if isempty(recordIndex), candidate = fullfile(otherLib, name);
        else, candidate = fullfile(records(recordIndex).stage, name); end
        if ~isfile(candidate), continue; end
        assert(strcmp(canonicalSource(candidate, true), ...
            canonicalSource(fullfile(sharedStage, name), true)), ...
            'FMT:SharedMigrationRequired', ...
            'Runtime file %s differs. Run fmt_build_all to regenerate the selected models.', name);
        if isempty(recordIndex)
            stage = cloneLibrary(otherLib, stageRoot);
            records(end + 1) = makeRecord(stage, otherLib); %#ok<AGROW>
            recordIndex = numel(records);
        end
        delete(fullfile(records(recordIndex).stage, name));
    end
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

    function importShared(source, name)
        body = canonicalSource(source, true);
        if isKey(sharedImports, name)
            assert(strcmp(sharedImports(name), body), 'FMT:SharedCodeConflict', ...
                'Conflicting shared file %s. Use consistent code generation settings.', name);
        elseif isfile(fullfile(sharedStage, name)) && ~completeSet
            assert(strcmp(canonicalSource(fullfile(sharedStage, name), true), body), ...
                'FMT:SharedRebuildRequired', ...
                'Shared file %s changed. Run fmt_build_all to rebuild all selected models.', name);
        end
        sharedImports(name) = body;
        copyfile(source, fullfile(sharedStage, name), 'f');
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

function seedShared(owner, destination)
names = sharedManifest(owner);
if isempty(names)
    files = sourceFiles(owner);
    names = {files.name};
    names = names(~cellfun('isempty', regexp(names, '^rt[A-Z_].*\.[ch]$')));
    if isfile(fullfile(owner, 'rtwtypes.h')), names{end + 1} = 'rtwtypes.h'; end
end
for k = 1:numel(names)
    assert(isfile(fullfile(owner, names{k})), 'FMT:MissingSharedFile', ...
        'A shared export file is missing: %s', names{k});
    copyfile(fullfile(owner, names{k}), fullfile(destination, names{k}));
end
end

function names = sharedManifest(folder)
file = fullfile(folder, '_fmt_shared.manifest');
if ~isfile(file), names = {}; return; end
names = cellstr(splitlines(strtrim(string(fileread(file)))));
names = names(~cellfun('isempty', names));
for k = 1:numel(names)
    assert(~isempty(regexp(names{k}, '^[A-Za-z0-9_]+\.[ch]$', 'once')), ...
        'FMT:InvalidSharedManifest', 'Invalid shared export file name.');
end
end

function removeOldShared(previous, stage)
names = sharedManifest(previous);
for k = 1:numel(names)
    file = fullfile(stage, names{k});
    if isfile(file) && ~strcmp(names{k}, 'rtwtypes.h'), delete(file); end
end
end

function writeSharedManifest(folder, names)
fid = fopen(fullfile(folder, '_fmt_shared.manifest'), 'wt');
assert(fid ~= -1, 'FMT:ManifestWrite', 'Cannot write the shared export marker.');
release = onCleanup(@() fclose(fid));
fprintf(fid, '%s\n', names{:});
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

function text = canonicalSource(file, removeBanner)
text = strrep(fileread(file), sprintf('\r\n'), newline);
if removeBanner
    text = regexprep(text, '\A/\*[\s\S]*?\*/\s*', '');
else
    % A timestamp or model revision banner alone does not require a backup.
    text = regexprep(text, ['(?m)^\s*\* (Model version\s*:|' ...
        'C/C\+\+ source code generated on\s*:)[^\n]*\n'], '');
end
end

function result = sameFolder(first, second)
a = dir(first); a = a(~[a.isdir]);
b = dir(second); b = b(~[b.isdir]);
[aNames, orderA] = sort({a.name});
[bNames, orderB] = sort({b.name});
result = isequal(aNames, bNames);
if ~result, return; end
for k = 1:numel(aNames)
    result = strcmp(canonicalSource(fullfile(first, a(orderA(k)).name), false), ...
        canonicalSource(fullfile(second, b(orderB(k)).name), false));
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
