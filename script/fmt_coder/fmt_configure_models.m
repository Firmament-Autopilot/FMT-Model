function fmt_configure_models(varargin)
%fmt_configure_models - Configure existing models for native Coder builds
%   fmt_configure_models('Board','sieon/s1','Vehicle','Multicopter', ...
%       'Airframe',1) saves local FMT configurations. Shared configurations
%   remain available. fmt_configure_models(false,...) leaves files unsaved.
saveChanges = true;
if ~isempty(varargin) && islogical(varargin{1})
    saveChanges = varargin{1};
    varargin(1) = [];
end
vehicle = 'Multicopter';
if evalin('base', 'exist(''Vehicle'', ''var'')')
    vehicle = evalin('base', 'Vehicle');
end
p = inputParser;
p.addParameter('FirmwareRoot', '');
p.addParameter('Board', '');
p.addParameter('Vehicle', vehicle);
p.addParameter('Airframe', []);
p.addParameter('SimulationMode', '');
p.parse(varargin{:});
settings = p.Results;
settings.Vehicle = char(settings.Vehicle);
catalog = fmt_model_catalog(settings.Vehicle);

needsInit = ~evalin('base', 'exist(''control_config'', ''var'')') || ...
    ~strcmp(vehicle, settings.Vehicle);
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
% Let Coder separate incompatible shared-code configurations automatically.
Simulink.fileGenControl('set', 'CodeGenFolderStructure', ...
    Simulink.filegen.CodeGenFolderStructure.TargetEnvironmentSubfolder);

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
        switchTarget(config, 'fmt_ert.tlc', []);
    end
    set_param(config, 'GenCodeOnly', 'off', 'GenerateMakefile', 'off', ...
        'GenerateSampleERTMain', 'off', 'TargetLang', 'C', ...
        'CodeReplacementLibrary', 'STM32 DSP LIB', ...
        'UtilityFuncGeneration', 'Shared location', 'FMTVehicle', settings.Vehicle);
    if ~isempty(settings.Board), set_param(config, 'FMTBoard', char(settings.Board)); end
    if ~isempty(settings.Airframe)
        set_param(config, 'FMTAirframe', num2str(settings.Airframe));
    end
    if ~isempty(settings.SimulationMode)
        set_param(config, 'FMTSimMode', char(settings.SimulationMode));
    end
    if saveChanges, save_system(mdl); end
    fprintf('FMT configured: %s (%s)\n', mdl, settings.Vehicle);
end
end
