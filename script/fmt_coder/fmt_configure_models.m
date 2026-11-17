function fmt_configure_models(varargin)
%fmt_configure_models - Configure existing models for native Coder builds
%   fmt_configure_models configures and saves the current vehicle models.
%
%   fmt_configure_models(...,Board=BOARD,Airframe=AIRFRAME) applies the
%   requested target to the vehicle initialized in the base workspace.
%
%   fmt_configure_models(...,Save=false) applies settings without saving.
%
%   Firmware availability is checked by Sync and Build, not configuration.
%
%   See also fmt_build_all, slbuild
vehicle = fmt_target.vehicle;
p = inputParser;
p.PartialMatching = false;
p.addParameter('Save', true, @(x) islogical(x) && isscalar(x));
p.addParameter('FirmwareRoot', '');
p.addParameter('Board', '');
p.addParameter('Airframe', [], @(x) isempty(x) || ...
    (isnumeric(x) && isscalar(x) && isfinite(x) && x >= 1 && x == fix(x)));
p.addParameter('SimulationMode', '');
p.parse(varargin{:});
settings = p.Results;
catalog = fmt_target.catalog(vehicle);
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
    fullfile(rootDir, 'build', 'fmt', vehicle), ...
    'CacheFolder', fullfile(rootDir, 'build', 'fmt', vehicle), ...
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
        'UtilityFuncGeneration', 'Auto');
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
    fprintf('FMT configured: %s (%s)\n', mdl, vehicle);
end
if settings.Save
    for k = 1:numel(catalog), save_system(catalog(k).name); end
end
end
