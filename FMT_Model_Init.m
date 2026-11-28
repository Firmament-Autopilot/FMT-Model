%% Firmament Autopilot
%% brief: run this script to init FMT Model

% Vehicle type: Multicopter | Fixwing | VTOL | Car | Boat
VEHICLE = 'VTOL';
% Airframe id
AIRFRAME = 1;

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

if strcmp(VEHICLE, 'Multicopter')
    addpath(genpath('model/Controller/MC_Controller'));
    addpath(genpath('model/FMS/MC_FMS'));
    addpath(genpath('model/INS/CF_INS'));
    addpath(genpath('model/Plant/Multicopter'));
elseif strcmp(VEHICLE, 'Fixwing')
    addpath(genpath('model/Controller/FW_Controller'));
    addpath(genpath('model/FMS/FW_FMS'));
    addpath(genpath('model/INS/CF_INS'));
    addpath(genpath('model/Plant/Fixwing'));
elseif strcmp(VEHICLE, 'VTOL')
    addpath(genpath('model/Controller/VTOL_Controller'));
    addpath(genpath('model/FMS/VTOL_FMS'));
    addpath(genpath('model/INS/CF_INS'));
    addpath(genpath('model/Plant/VTOL'));
elseif strcmp(VEHICLE, 'Car')
    addpath(genpath('model/Controller/Car_Controller'));
    addpath(genpath('model/FMS/Car_FMS'));
    addpath(genpath('model/INS/CF_INS'));
    addpath(genpath('model/Plant/Multicopter'));
elseif strcmp(VEHICLE, 'Boat')
    addpath(genpath('model/Controller/Boat_Controller'));
    addpath(genpath('model/FMS/Boat_FMS'));
    addpath(genpath('model/INS/CF_INS'));
    addpath(genpath('model/Plant/Boat'));
else
    error('Invalid vehicle type: %s', VEHICLE);
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