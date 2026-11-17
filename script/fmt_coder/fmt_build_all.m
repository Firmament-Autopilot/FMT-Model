function binPath = fmt_build_all(varargin)
%fmt_build_all - Generate all selected models and compile firmware once
%   binPath = fmt_build_all builds the vehicle selected in the base workspace.
%
%   binPath = fmt_build_all(...,Board=BOARD,Vehicle=VEHICLE,Airframe=AIRFRAME)
%   applies target settings in memory and builds the selected models.
%
%   See also fmt_configure_models, slbuild
assert(~isappdata(0, 'FMTCodegenBatch'), 'FMT:RecursiveBuild', ...
    'Another FMT batch build is already active.');
assert(isempty(varargin) || ~any(strcmpi(string(varargin(1:2:end)), 'Save')), ...
    'FMT:InvalidBuildOption', 'Save is an option of fmt_configure_models only.');
fmt_configure_models('Save', false, varargin{:});
options = fmt_target.options('Controller');
modules = fmt_target.modules(options);
catalog = fmt_target.catalog(options.vehicle);
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
    slbuild(selected(k).name);
end
clear releaseBatch;
fmt_target.sync({selected.name}, 'Controller');
binPath = fmt_target.build('Controller');
end
