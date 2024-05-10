model_version = 'v0.0.1';
model_name = 'Car FMS';

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
FMS_PARAM_VALUE.DISARM_OUT = single([1500 1500, zeros(1, 14)]);
FMS_PARAM_VALUE.STANDBY_OUT = single([1500 1500, zeros(1, 14)]);

FMS_PARAM_VALUE.L1 = single(10);
FMS_PARAM_VALUE.CRUISE_SPEED = single(3);
FMS_PARAM_VALUE.ACCEPT_R = single(5);
FMS_PARAM_VALUE.MAX_VEL = single(4);
FMS_PARAM_VALUE.MAX_R = single(pi/6);
FMS_PARAM_VALUE.ACC2RATE = single(0.5);

%TODO, remove it
FMS_PARAM_VALUE.VEL_XY_LIM = single(5);

FMS_PARAM = Simulink.Parameter(FMS_PARAM_VALUE);
FMS_PARAM.CoderInfo.StorageClass = 'ExportedGlobal';