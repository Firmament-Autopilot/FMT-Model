% For more details about this multicopter plant model, please refer to:
% https://pure.tue.nl/ws/portalfiles/portal/110035542/Jiachi_Zou_Thesis.pdf

model_version = 'v1.0.0';
model_name = 'Boat';

%% load configuration
load('plant_default_config.mat');

%% Constant Variable (for internal use)
PLANT_CONST.dt = 0.002;

%% init plant model parameter
plant_model.mass = 1.0;     % kg
plant_model.Jxx = 2.1512;	% moment of inertia in body x axis
plant_model.Jyy = 3.4418;	% moment of inertia in body y axis
plant_model.Jzz = 0.3475;	% moment of inertia in body z axis

%% Exported Value
PLANT_EXPORT_VALUE.period = uint32(PLANT_CONST.dt*1e3); 
PLANT_EXPORT_VALUE.model_info = int8([model_name, ' ', model_version, 0]); % 0 for end of string

PLANT_EXPORT = Simulink.Parameter(PLANT_EXPORT_VALUE);
PLANT_EXPORT.CoderInfo.StorageClass = 'ExportedGlobal';

%% Parameter
PLANT_PARAM_VALUE.LAT_0 = double(0.6578);
PLANT_PARAM_VALUE.LON_0 = double(-2.1347);
PLANT_PARAM_VALUE.ALT_0 = double(0);

% Export to firmware
PLANT_PARAM = Simulink.Parameter(PLANT_PARAM_VALUE);
PLANT_PARAM.CoderInfo.StorageClass = 'ExportedGlobal';

%% init sensor model
run('sensor_model_init.m');