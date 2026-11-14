function fmt_ert_make_rtw_hook(hookMethod, modelName, ~, ~, ~, ~, ~)
%fmt_ert_make_rtw_hook - Connect successful Coder generation to native SCons
if strcmp(hookMethod, 'entry')
    assert(strcmp(get_param(modelName, 'GenerateMakefile'), 'off') && ...
        strcmp(get_param(modelName, 'GenerateSampleERTMain'), 'off'), ...
        'FMT:InvalidCodegenSettings', ...
        'Disable GenerateMakefile and GenerateSampleERTMain for native FMT builds.');
    if strcmp(get_param(modelName, 'FMTBuildAction'), 'CodeOnly'), return; end
    options = fmt_target.options(modelName);
    catalog = fmt_target.catalog(options.vehicle);
    entry = catalog(strcmp(modelName, {catalog.name}));
    assert(~isempty(entry) && strcmpi(get_param(modelName, 'FileName'), entry.source), ...
        'FMT:WrongVehicleModel', ...
        'Model source does not match FMTVehicle. Run fmt_configure_models first.');
    modules = fmt_target.modules(options);
    assert(any(strcmp(entry.module, modules)), 'FMT:UnselectedModel', ...
        '%s is not selected by this board, vehicle and simulation mode.', modelName);
end
if ~strcmp(hookMethod, 'exit') || isappdata(0, 'FMTCodegenBatch')
    return;
end
action = get_param(modelName, 'FMTBuildAction');
if strcmp(action, 'CodeOnly')
    return;
end

assert(strcmp(action, 'Build'), 'FMT:InvalidBuildAction', ...
    'Build action must be CodeOnly or Build.');

fmt_target.sync({modelName}, modelName);
fmt_target.build(modelName);
end
