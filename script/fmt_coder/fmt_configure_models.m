function fmt_configure_models(varargin)
%fmt_configure_models - Configure existing models for native Coder builds
%   fmt_configure_models configures and saves the current vehicle models.
%
%   fmt_configure_models(...,Vehicle=VEHICLE,Board=BOARD,Airframe=AIRFRAME)
%   selects existing source models and applies the requested target.
%
%   fmt_configure_models(...,Save=false) applies settings without saving.
%
%   See also fmt_build_all, slbuild
vehicle = 'Multicopter';
if evalin('base', 'exist(''Vehicle'', ''var'')')
    vehicle = evalin('base', 'Vehicle');
end
p = inputParser;
p.PartialMatching = false;
p.addParameter('Save', true, @(x) islogical(x) && isscalar(x));
p.addParameter('FirmwareRoot', '');
p.addParameter('Board', '');
p.addParameter('Vehicle', vehicle);
p.addParameter('Airframe', [], @(x) isempty(x) || ...
    (isnumeric(x) && isscalar(x) && isfinite(x) && x >= 1 && x == fix(x)));
p.addParameter('SimulationMode', '');
p.parse(varargin{:});
settings = p.Results;
settings.Vehicle = char(settings.Vehicle);
catalog = fmt_target.catalog(settings.Vehicle);

needsInit = ~evalin('base', 'exist(''control_config'', ''var'')') || ...
    ~strcmp(vehicle, settings.Vehicle) || ...
    ~isappdata(0, 'FMTInitializedVehicle') || ...
    ~strcmp(getappdata(0, 'FMTInitializedVehicle'), settings.Vehicle);
for k = 1:numel(catalog)
    mdl = catalog(k).name;
    if bdIsLoaded(mdl) && ~strcmpi(get_param(mdl, 'FileName'), catalog(k).source)
        assert(strcmp(get_param(mdl, 'Dirty'), 'off'), 'FMT:UnsavedModel', ...
            'Save or close %s before switching vehicle.', mdl);
        close_system(mdl, 0);
        needsInit = true;
    end
end
rootDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
if needsInit
    previousDir = pwd;
    restoreDir = onCleanup(@() cd(previousDir));
    cd(rootDir);
    oldPaths = strsplit(genpath(fullfile(rootDir, 'model')), pathsep);
    currentPaths = strsplit(path, pathsep);
    oldPaths = oldPaths(ismember(oldPaths, currentPaths) & ~cellfun('isempty', oldPaths));
    if ~isempty(oldPaths), rmpath(oldPaths{:}); end
    addpath(fullfile(rootDir, 'model'), fullfile(rootDir, 'model', 'Controller'), ...
        fullfile(rootDir, 'model', 'FMS'), fullfile(rootDir, 'model', 'INS'), ...
        fullfile(rootDir, 'model', 'Plant'));
    % Init scripts assign individual struct fields; start a clean vehicle schema.
    evalin('base', ['clear CONTROL_CONST CONTROL_PARAM_VALUE CONTROL_EXPORT_VALUE ' ...
        'FMS_CONST FMS_PARAM_VALUE FMS_EXPORT_VALUE ' ...
        'INS_CONST INS_PARAM_VALUE INS_EXPORT_VALUE ' ...
        'PLANT_CONST PLANT_PARAM_VALUE PLANT_EXPORT_VALUE ' ...
        'plant_model ground_force Sensor_Model']);
    assignin('base', 'Vehicle', settings.Vehicle);
    initFile = strrep(fullfile(rootDir, 'FMT_Model_Init.m'), '''', '''''');
    evalin('base', sprintf('run(''%s'');', initFile));
    clear restoreDir;
end
if ~isempty(settings.FirmwareRoot)
    assert(isfolder(settings.FirmwareRoot), 'FMT:MissingFirmwareRoot', ...
        'FirmwareRoot does not exist.');
    setpref('FMT', 'FirmwareRoot', char(settings.FirmwareRoot));
end
codegenDir = fullfile(rootDir, 'build', 'fmt', ['R' version('-release')], settings.Vehicle);
Simulink.fileGenControl('set', 'CodeGenFolder', codegenDir, ...
    'CacheFolder', codegenDir, ...
    'CodeGenFolderStructure', Simulink.filegen.CodeGenFolderStructure.ModelSpecific, ...
    'createDir', true);

for k = 1:numel(catalog)
    mdl = catalog(k).name;
    if ~bdIsLoaded(mdl), load_system(catalog(k).source); end
    configName = ['FMT_' mdl];
    if any(strcmp(getConfigSets(mdl), configName))
        config = getConfigSet(mdl, configName);
    else
        original = getActiveConfigSet(mdl);
        while isa(original, 'Simulink.ConfigSetRef')
            original = getRefConfigSet(original);
        end
        config = copy(original);
        set_param(config, 'Name', configName);
        attachConfigSet(mdl, config);
    end
    setActiveConfigSet(mdl, configName);
    if ~strcmp(get_param(config, 'SystemTargetFile'), 'fmt_ert.tlc')
        tunabilityDiagnostic = get_param(config, 'ParameterTunabilityLossMsg');
        switchTarget(config, 'fmt_ert.tlc', []);
        % switchTarget resets this diagnostic; preserve the owning model's policy.
        set_param(config, 'ParameterTunabilityLossMsg', tunabilityDiagnostic);
    end
    set_param(config, 'GenCodeOnly', 'off', 'GenerateMakefile', 'off', ...
        'GenerateSampleERTMain', 'off', 'TargetLang', 'C', ...
        'ProdIntDivRoundTo', 'Zero', 'TargetIntDivRoundTo', 'Zero', ...
        'CodeReplacementLibrary', 'STM32 DSP LIB', ...
        'UtilityFuncGeneration', 'Shared location', 'FMTVehicle', settings.Vehicle);
    if ~isempty(settings.Board), set_param(config, 'FMTBoard', char(settings.Board)); end
    if ~isempty(settings.Airframe)
        set_param(config, 'FMTAirframe', settings.Airframe);
    end
    if ~isempty(settings.SimulationMode)
        set_param(config, 'FMTSimMode', char(settings.SimulationMode));
    end
    if k == 1
        settings.Board = get_param(config, 'FMTBoard');
        settings.Airframe = str2double(string(get_param(config, 'FMTAirframe')));
        settings.SimulationMode = get_param(config, 'FMTSimMode');
    end
    fprintf('FMT configured: %s (%s)\n', mdl, settings.Vehicle);
end
if ispref('FMT', 'FirmwareRoot')
    options = fmt_target.options('Controller');
    modules = fmt_target.modules(options);
    assert(~isempty(modules), 'FMT:UnsupportedVehicle', ...
        'BSP %s selects no modules for vehicle %s.', options.board, options.vehicle);
end
if settings.Save
    for k = 1:numel(catalog), save_system(catalog(k).name); end
end
end
