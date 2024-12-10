model_version = 'v0.0.1';
model_name = 'Boat FMS';

%% load model configuration
load('fms_default_config.mat');

%% Constant Variable
FMS_CONST.dt = 0.01;

%% Exported Value 
FMS_EXPORT_VALUE.period = uint32(FMS_CONST.dt*1e3);
FMS_EXPORT_VALUE.model_info = int8([model_name, ' ', model_version, 0]); % 0 for end of string

FMS_EXPORT = Simulink.Parameter(FMS_EXPORT_VALUE);
FMS_EXPORT.CoderInfo.StorageClass = 'ExportedGlobal';

%% Paramaters
FMS_PARAM_VALUE.DISARM_OUT = single([1500 1500 1500 1500, zeros(1, 12)]);
FMS_PARAM_VALUE.STANDBY_OUT = single([1550 1550 1500 1500, zeros(1, 12)]);

FMS_PARAM_VALUE.L1 = single(10);
FMS_PARAM_VALUE.CRUISE_SPEED = single(3);
FMS_PARAM_VALUE.ACCEPT_R = single(5);
FMS_PARAM_VALUE.MAX_VEL = single(4);
% FMS_PARAM_VALUE.MAX_R = single(pi/6);
FMS_PARAM_VALUE.AY_P = single(0.7);
% FMS_PARAM_VALUE.AY_I = single(0.1);
FMS_PARAM_VALUE.LOST_RETURN_TIME = uint16(10);
FMS_PARAM_VALUE.LOST_RETURN_EN = uint8(1);

FMS_PARAM_VALUE.THROTTLE_SCALE = single(500);
FMS_PARAM_VALUE.THROTTLE_BIAS = uint16(1500);
FMS_PARAM_VALUE.SERVO_SCALE = single(250);
FMS_PARAM_VALUE.SERVO_BIAS = uint16(1500);

%TODO, remove it
% FMS_PARAM_VALUE.VEL_XY_LIM = single(5);

FMS_PARAM = Simulink.Parameter(FMS_PARAM_VALUE);
FMS_PARAM.CoderInfo.StorageClass = 'ExportedGlobal';