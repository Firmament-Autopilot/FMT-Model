function binPath = fmt_build_all(ownerModel, varargin)
%fmt_build_all - Generate all selected models and compile firmware once
%   binPath = fmt_build_all builds the target configured on Controller.
%   fmt_build_all('Board','sieon/s1','Vehicle','Multicopter','Airframe',1)
%   configures the requested target in memory and builds it in one call.
if nargin < 1, ownerModel = 'Controller'; end
if ~any(strcmp(ownerModel, {'Controller','FMS','INS','Plant'}))
    varargin = [{ownerModel}, varargin];
    ownerModel = 'Controller';
end
assert(~isappdata(0, 'FMTCodegenBatch'), 'FMT:RecursiveBuild', ...
    'Another FMT batch build is already active.');
if ~bdIsLoaded(ownerModel) || ~isempty(varargin)
    fmt_configure_models(false, varargin{:});
end
options = fmt_build_options(ownerModel);
fmt_configure_models(false, 'Board', options.board, 'Vehicle', options.vehicle, ...
    'Airframe', options.airframe, 'SimulationMode', options.sim);
modules = fmt_firmware_modules(ownerModel);
catalog = fmt_model_catalog(options.vehicle);
selected = catalog(ismember({catalog.module}, modules));
assert(~isempty(selected), 'FMT:NoModels', 'No supported source models were selected.');
fprintf('FMT target: %s | %s | airframe %d | %s\n', ...
    options.board, options.vehicle, options.airframe, options.sim);
existing = setdiff(modules, {selected.module}, 'stable');
for k = 1:numel(existing)
    fprintf('FMT using existing Firmware module: %s\n', existing{k});
end

% All slbuild calls run outside the target's build hook.
setappdata(0, 'FMTCodegenBatch', true);
releaseBatch = onCleanup(@() rmappdata(0, 'FMTCodegenBatch'));
for k = 1:numel(selected)
    fprintf('FMT generating: %s\n', selected(k).name);
    slbuild(selected(k).name, 'GenerateCodeOnly', true);
end
clear releaseBatch;
fmt_sync_models({selected.name}, ownerModel);
binPath = fmt_build_firmware(ownerModel);
end
