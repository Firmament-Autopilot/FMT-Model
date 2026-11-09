%% Firmament Autopilot
%% brief: run this script to init FMT Model

% Select vehicle type: Multicopter | Fixwing | VTOL | Car | Boat
Vehicle = 'Multicopter';

start_time = 0;
end_time = 1000;

%% init path
filepath = which(mfilename);
filefolder = fileparts(filepath);
rootpath = fullfile(filefolder,'.');

%% set build path
buildpath = fullfile(rootpath, 'build');
if(~exist(buildpath, 'dir'))
   mkdir(buildpath); 
end
set_param(0, 'CodeGenFolder', buildpath);
set_param(0, 'CacheFolder', buildpath);

%% add path
addpath(genpath('build'));

if strcmp(Vehicle, 'Multicopter')
    addpath(genpath('model/Controller/MC-Controller'));
    addpath(genpath('model/FMS/MC-FMS'));
    addpath(genpath('model/INS/CF-INS'));
    addpath(genpath('model/Plant/MC-Plant'));
elseif strcmp(Vehicle, 'Fixwing')
    addpath(genpath('model/Controller/FW-Controller'));
    addpath(genpath('model/FMS/FW-FMS'));
    addpath(genpath('model/INS/CF-INS'));
    addpath(genpath('model/Plant/FW-Plant'));
elseif strcmp(Vehicle, 'VTOL')
    addpath(genpath('model/Controller/VTOL-Controller'));
    addpath(genpath('model/FMS/VTOL-FMS'));
    addpath(genpath('model/INS/CF-INS'));
    addpath(genpath('model/Plant/VTOL-Plant'));
elseif strcmp(Vehicle, 'Car')
    addpath(genpath('model/Controller/Car-Controller'));
    addpath(genpath('model/FMS/Car-FMS'));
    addpath(genpath('model/INS/CF-INS'));
    addpath(genpath('model/Plant/MC-Plant'));
elseif strcmp(Vehicle, 'Boat')
    addpath(genpath('model/Controller/Boat-Controller'));
    addpath(genpath('model/FMS/Boat-FMS'));
    addpath(genpath('model/INS/CF-INS'));
    addpath(genpath('model/Plant/Boat-Plant'));
else
    error('Invalid vehicle type: %s', Vehicle);
end

%% register code replacement library
run('register_crl.m');

%% load bus
load_bus(rootpath);

%% init models
run('plant_init.m');
run('ins_init.m');
run('control_init.m');
run('fms_init.m');

sl_refresh_customizations;