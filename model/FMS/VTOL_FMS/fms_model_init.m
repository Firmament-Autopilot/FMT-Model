model_version = 'v0.0.1';
model_name = 'VTOL FMS';

%% load model configuration
% load('fms_default_config_arover.mat');
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
FMS_PARAM_VALUE.XY_P = single(1.2);
FMS_PARAM_VALUE.Z_P = single(1.5);
FMS_PARAM_VALUE.VEL_XY_LIM = single(5);
FMS_PARAM_VALUE.VEL_Z_LIM = single(2.0);
FMS_PARAM_VALUE.YAW_P = single(2.5);
FMS_PARAM_VALUE.YAW_RATE_LIM = single(pi/3);
FMS_PARAM_VALUE.ROLL_PITCH_LIM = single(pi/6);
FMS_PARAM_VALUE.L1 = single(15);
FMS_PARAM_VALUE.MC_ACCEPT_R = single(1.0);
FMS_PARAM_VALUE.CRUISE_SPEED = single(5);
FMS_PARAM_VALUE.CRUISE_ACC = single(5);
FMS_PARAM_VALUE.TAKEOFF_H = single(2.0);
FMS_PARAM_VALUE.TAKEOFF_SPEED = single(1.0);
FMS_PARAM_VALUE.ASSIST_LAND_H = single(0.5);
FMS_PARAM_VALUE.LAND_SPEED = single(0.6);
FMS_PARAM_VALUE.LOST_RETURN_TIME = uint16(120);
FMS_PARAM_VALUE.LOST_RETURN_EN = uint8(1);
FMS_PARAM_VALUE.LAND_LOCK_THRO = uint16(1300);

FMS_PARAM_VALUE.FW_L1 = single(50);
FMS_PARAM_VALUE.FW_CRUISE_SPEED = single(18.0);
FMS_PARAM_VALUE.FW_SPEED_MAX = single(22.0);
FMS_PARAM_VALUE.FW_SPEED_MIN = single(14.0);
FMS_PARAM_VALUE.FW_STALL_SPEED = single(10);
FMS_PARAM_VALUE.FW_Z_P = single(1);
FMS_PARAM_VALUE.FW_VEL_Z_LIM = single(10);
FMS_PARAM_VALUE.FW_ACC_Y_LIM = single(8);
FMS_PARAM_VALUE.FW_ROLL_LIM = single(pi/4);
FMS_PARAM_VALUE.FW_PITCH_LIM = single(pi/6);
FMS_PARAM_VALUE.FW_YAW_RATE_LIM = single(pi/6);
FMS_PARAM_VALUE.FW_LOITER_R = single(50.0);
FMS_PARAM_VALUE.FW_ACCEPT_R = single(100.0);

FMS_PARAM = Simulink.Parameter(FMS_PARAM_VALUE);
FMS_PARAM.CoderInfo.StorageClass = 'ExportedGlobal';