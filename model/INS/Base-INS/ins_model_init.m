model_version = 'v1.0.0';
model_name = 'Base INS';

%% Load configuration
load('ins_default_config');
wmm = load('wmmgrid_2021.mat');

%% Constant Variable (for internal use)
INS_CONST.dt = 0.002;   % step time in s
INS_CONST.g = single(9.8055);   % gravity constant
INS_CONST.wmm_mag = wmm.wmmgrid_mag;
INS_CONST.wmm_dec = wmm.wmmgrid_dec;
INS_CONST.wmm_inc = wmm.wmmgrid_inc;

%% Exported Value
INS_EXPORT_VALUE.period = uint32(INS_CONST.dt*1e3); 
INS_EXPORT_VALUE.model_info = int8([model_name, ' ', model_version, 0]); % 0 for end of string

INS_EXPORT = Simulink.Parameter(INS_EXPORT_VALUE);
INS_EXPORT.CoderInfo.StorageClass = 'ExportedGlobal';

%% Paramaters
INS_PARAM_VALUE.GPS_HOR_Q_BIAS = single(2.5);
INS_PARAM_VALUE.GPS_HOR_Q_SCALE = single(0.4);
INS_PARAM_VALUE.GPS_VER_Q_BIAS = single(4.5);
INS_PARAM_VALUE.GPS_VER_Q_SCALE = single(0.25);
INS_PARAM_VALUE.GPS_VEL_Q_BIAS = single(1);
INS_PARAM_VALUE.GPS_VEL_Q_SCALE = single(1);
INS_PARAM_VALUE.ATT_GAIN = single(0.2);
INS_PARAM_VALUE.HEADING_GAIN = single(0.05);
INS_PARAM_VALUE.MAG_GAIN = single(0.3);
% INS_PARAM_VALUE.HOVER_MAG_GAIN = single(0.3);
INS_PARAM_VALUE.MAG_AIR_EN = uint8(0);
INS_PARAM_VALUE.BIAS_G_GAIN = single(0.25);
INS_PARAM_VALUE.GPS_POS_GAIN = single(0.02);
INS_PARAM_VALUE.GPS_ALT_GAIN = single(0.01);
INS_PARAM_VALUE.GPS_VEL_GAIN = single(2);
INS_PARAM_VALUE.GPS_BIAS_A_GAIN = single(1);
INS_PARAM_VALUE.GPS_POS_DELAY = uint32(150);
INS_PARAM_VALUE.GPS_VEL_DELAY = uint32(100);
INS_PARAM_VALUE.OPF_VEL_GAIN = single(2);
INS_PARAM_VALUE.OPF_BIAS_A_GAIN = single(1);
INS_PARAM_VALUE.OPF_VEL_DELAY = uint32(5);
INS_PARAM_VALUE.BARO_H_GAIN = single(2);
INS_PARAM_VALUE.BARO_VZ_GAIN = single(1);
INS_PARAM_VALUE.BARO_BIAS_AZ_GAIN = single(0.2);
INS_PARAM_VALUE.BARO_H_DELAY = uint32(10);
INS_PARAM_VALUE.RF_H_GAIN = single(2);
INS_PARAM_VALUE.RF_VZ_GAIN = single(1);
INS_PARAM_VALUE.RF_BIAS_AZ_GAIN = single(0.2);
INS_PARAM_VALUE.RF_H_DELAY = uint32(5);
INS_PARAM_VALUE.EXTPOS_POS_GAIN = single(5);
INS_PARAM_VALUE.EXTPOS_VEL_GAIN = single(2);
INS_PARAM_VALUE.EXTPOS_BIAS_A_GAIN = single(0.2);
INS_PARAM_VALUE.EXTPOS_POS_DELAY = uint32(50);

INS_PARAM = Simulink.Parameter(INS_PARAM_VALUE);
INS_PARAM.CoderInfo.StorageClass = 'ExportedGlobal';
