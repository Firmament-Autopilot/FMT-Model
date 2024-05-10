model_version = 'v0.0.1';
model_name = 'Submarine Controller';

%% load configuration
load('control_default_config.mat');

%% Constant Variable
CONTROL_CONST.dt = 0.002;   % model execution period

%% Exported Value
CONTROL_EXPORT_VALUE.period = uint32(CONTROL_CONST.dt*1e3);
CONTROL_EXPORT_VALUE.model_info = int8([model_name, ' ', model_version, 0]); % 0 for end of string
% Export to firmware
CONTROL_EXPORT = Simulink.Parameter(CONTROL_EXPORT_VALUE);
CONTROL_EXPORT.CoderInfo.StorageClass = 'ExportedGlobal';

% Airframe id
AIRFRAME = 1;

%% Paramaters
CONTROL_PARAM_VALUE.VEL_X_P = single(1.4);
CONTROL_PARAM_VALUE.VEL_X_I = single(0.2);
CONTROL_PARAM_VALUE.VEL_X_D = single(0.2);
CONTROL_PARAM_VALUE.VEL_Z_P = single(0.6);
CONTROL_PARAM_VALUE.VEL_Z_I = single(0.1);
CONTROL_PARAM_VALUE.VEL_Z_D = single(0);
CONTROL_PARAM_VALUE.VEL_X_I_MIN = single(-1);
CONTROL_PARAM_VALUE.VEL_X_I_MAX = single(1);
CONTROL_PARAM_VALUE.VEL_X_D_MIN = single(-1);
CONTROL_PARAM_VALUE.VEL_X_D_MAX = single(1);
CONTROL_PARAM_VALUE.VEL_Z_I_MIN = single(-0.15);
CONTROL_PARAM_VALUE.VEL_Z_I_MAX = single(0.15);
CONTROL_PARAM_VALUE.VEL_Z_D_MIN = single(-0.1);
CONTROL_PARAM_VALUE.VEL_Z_D_MAX = single(0.1);

CONTROL_PARAM_VALUE.PITCH_P = single(5);
CONTROL_PARAM_VALUE.PITCH_CMD_LIM = single(pi/6);

CONTROL_PARAM_VALUE.PITCH_RATE_P = single(0.1);
CONTROL_PARAM_VALUE.PITCH_RATE_I = single(0.1);
CONTROL_PARAM_VALUE.PITCH_RATE_D = single(0.003);
CONTROL_PARAM_VALUE.YAW_RATE_P = single(2);
CONTROL_PARAM_VALUE.YAW_RATE_I = single(2);
CONTROL_PARAM_VALUE.YAW_RATE_D = single(0);
CONTROL_PARAM_VALUE.RATE_I_MIN = single(-0.1);
CONTROL_PARAM_VALUE.RATE_I_MAX = single(0.1);
CONTROL_PARAM_VALUE.RATE_D_MIN = single(-0.1);
CONTROL_PARAM_VALUE.RATE_D_MAX = single(0.1);
CONTROL_PARAM_VALUE.Q_CMD_LIM = single(pi/2);
CONTROL_PARAM_VALUE.R_CMD_LIM = single(pi/3);
% Export to firmware
CONTROL_PARAM = Simulink.Parameter(CONTROL_PARAM_VALUE);
CONTROL_PARAM.CoderInfo.StorageClass = 'ExportedGlobal';