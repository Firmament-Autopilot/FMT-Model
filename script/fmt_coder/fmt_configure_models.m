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
assert(evalin('base', 'exist(''Vehicle'', ''var'')') == 1, ...
    'FMT:MissingVehicle', 'Open FMT_Model.prj before configuring models.');
vehicle = char(evalin('base', 'Vehicle'));
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

assert(evalin('base', 'exist(''control_config'', ''var'')') == 1 && ...
    strcmp(vehicle, settings.Vehicle) && ...
    isappdata(0, 'FMTInitializedVehicle') && ...
    strcmp(getappdata(0, 'FMTInitializedVehicle'), vehicle), ...
    'FMT:ProjectNotInitialized', ...
    'Change Vehicle in FMT_Model_Init.m and reopen the project before configuring models.');
for k = 1:numel(catalog)
    mdl = catalog(k).name;
    assert(~bdIsLoaded(mdl) || strcmpi(get_param(mdl, 'FileName'), catalog(k).source), ...
        'FMT:WrongVehicleModel', ...
        'Reopen the project after changing Vehicle in FMT_Model_Init.m.');
end
rootDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
if ~isempty(settings.FirmwareRoot)
    fmt_target.firmwareRoot(settings.FirmwareRoot);
end
Simulink.fileGenControl('set', 'CodeGenFolder', ...
    fullfile(rootDir, 'build', 'fmt', settings.Vehicle), ...
    'CacheFolder', fullfile(rootDir, 'build', 'fmt', settings.Vehicle), ...
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
        'UtilityFuncGeneration', 'Auto', 'FMTVehicle', settings.Vehicle);
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
