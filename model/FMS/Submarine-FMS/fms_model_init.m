model_version = 'v0.0.1';
model_name = 'Submarine FMS';

%% load model configuration
load('fms_default_config.mat');

%% Constant Variable
FMS_CONST.dt = 0.004;

%% Exported Value 
FMS_EXPORT_VALUE.period = uint32(FMS_CONST.dt*1e3);
FMS_EXPORT_VALUE.model_info = int8([model_name, ' ', model_version, 0]); % 0 for end of string

FMS_EXPORT = Simulink.Parameter(FMS_EXPORT_VALUE);
FMS_EXPORT.CoderInfo.StorageClass = 'ExportedGlobal';

%% Paramaters
FMS_PARAM_VALUE.THROTTLE_DZ = single(0.15);
FMS_PARAM_VALUE.YAW_DZ = single(0.15);
FMS_PARAM_VALUE.ROLL_DZ = single(0.1);
FMS_PARAM_VALUE.PITCH_DZ = single(0.1);
FMS_PARAM_VALUE.X_P = single(0.95);
% FMS_PARAM_VALUE.XY_P = single(0.95);
FMS_PARAM_VALUE.Z_P = single(1);
FMS_PARAM_VALUE.VEL_X_LIM = single(6);
FMS_PARAM_VALUE.VEL_Z_LIM = single(2.5);
FMS_PARAM_VALUE.L1 = single(30);
FMS_PARAM_VALUE.CRUISE_SPEED = single(5);
FMS_PARAM_VALUE.ACCEPT_R = single(50);
FMS_PARAM_VALUE.ACC2RATE = single(0.25);
FMS_PARAM_VALUE.MAX_R = single(pi/6);

FMS_PARAM = Simulink.Parameter(FMS_PARAM_VALUE);
FMS_PARAM.CoderInfo.StorageClass = 'ExportedGlobal';