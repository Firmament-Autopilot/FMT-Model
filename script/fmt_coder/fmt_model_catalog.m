function catalog = fmt_model_catalog(vehicle)
%fmt_model_catalog - Map existing source models to Firmware module names
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
