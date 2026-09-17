model_version = 'v1.0.0';
model_name = 'MC FMS';

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
FMS_PARAM_VALUE.MC_THROTTLE_DZ = single(0.15);
FMS_PARAM_VALUE.MC_YAW_DZ = single(0.15);
FMS_PARAM_VALUE.MC_ROLL_DZ = single(0.1);
FMS_PARAM_VALUE.MC_PITCH_DZ = single(0.1);
FMS_PARAM_VALUE.MC_XY_P = single(1.2);
FMS_PARAM_VALUE.MC_Z_P = single(1.5);
FMS_PARAM_VALUE.MC_VEL_XY_LIM = single(5);
FMS_PARAM_VALUE.MC_VEL_Z_LIM = single(2.5);
FMS_PARAM_VALUE.MC_YAW_P = single(2.5);
FMS_PARAM_VALUE.MC_YAWRATE_LIM = single(pi/2);
FMS_PARAM_VALUE.MC_ATT_LIM = single(pi/6);
FMS_PARAM_VALUE.MC_L1_GAIN = single(2);
FMS_PARAM_VALUE.MC_CRUISE_SPEED = single(5);
FMS_PARAM_VALUE.MC_CRUISE_ACC = single(5);
FMS_PARAM_VALUE.MC_TAKEOFF_H = single(1.2);
FMS_PARAM_VALUE.MC_TAKEOFF_SPEED = single(1.0);
FMS_PARAM_VALUE.MC_ACCEPT_R = single(0.5);
FMS_PARAM_VALUE.MC_ASSIST_LAND_H = single(0.3);
FMS_PARAM_VALUE.MC_LAND_SPEED = single(0.6);
FMS_PARAM_VALUE.MC_LOST_RETURN_TIME = uint16(120);
FMS_PARAM_VALUE.MC_LOST_RETURN_EN = uint8(1);
FMS_PARAM_VALUE.MC_LAND_LOCK_THRO = uint16(1300);
FMS_PARAM_VALUE.MC_STICK_SENS = single(0.5);

FMS_PARAM = Simulink.Parameter(FMS_PARAM_VALUE);
FMS_PARAM.CoderInfo.StorageClass = 'ExportedGlobal';