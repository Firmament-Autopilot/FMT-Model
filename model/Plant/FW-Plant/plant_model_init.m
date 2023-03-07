% For more details about this multicopter plant model, please refer to:
% https://pure.tue.nl/ws/portalfiles/portal/110035542/Jiachi_Zou_Thesis.pdf

model_version = 'v0.2.2';
model_name = 'Multicopter';

%% load configuration
load('plant_default_config.mat');
load('acdata.mat');
load('ap_ini.mat');

%% Constant Variable (for internal use)
PLANT_CONST.dt = 0.002;

%% init plant model parameter
plant_model.mass = 6;     % kg
plant_model.Jxx = 0.2944;	% moment of inertia in body x axis
plant_model.Jyy = 0.4589;	% moment of inertia in body y axis
plant_model.Jzz = 0.6979;	% moment of inertia in body z axis

plant_model.Cm = 1.982e-07;	% Rotor torque coefficient(kg.m^2)
plant_model.Ct = 2.478e-05;	% Rotor thrust coefficient(kg.m^2)
plant_model.R = 0.225; % Body radius(m)

plant_model.motorCr = 718.078; %Motor throttle-speed curve slope(rad/s)
plant_model.motorWb = 88.448;  %Motor speed-throttle curve constant term(rad/s)
plant_model.motorT = 0.02;  %Motor inertia time constant(s)
plant_model.motorJm = 0.0001287;    %Moment of inertia of motor rotor + propeller(kg.m^2)



plant_model.aero_b = 1.31;  % wingspan
plant_model.aero_c = 0.175; % main chord of the wing

plant_model.aeroCd_basic = [0.02612 0.2615 0.02705 0.2890 0.03168 0.03544 0.04017 0.04599 0.05291 0.06097 0.07022 0.08072 0.09255 0.11490 0.13790 0.15980 0.17540 0.17630 0.15880 0.09811];

plant_model.aeroCd_elevator = [0.0035 0.0017 0.0005 0.0001 0.0000 0.0000 0.0000 0.0007 0.0020;
0.0031 0.0014 0.0004 0.0000 0.0000 0.0000 0.0002 0.0009 0.0024;
0.0027 0.0011 0.0003 0.0000 0.0000 0.0000 0.0003 0.0012 0.0028;
0.0024 0.0009 0.0002 0.0000 0.0000 0.0000 0.0004 0.0014 0.0032;
0.0020 0.0006 0.0000 0.0000 0.0000 0.0001 0.0006 0.0017 0.0036;
0.0016 0.0004 -0.0001 -0.0001 0.0000 0.0001 0.0007 0.0019 0.0040;
0.0012 0.0001 -0.0002 -0.0001 0.0000 0.0001 0.0008 0.0022 0.0044;
0.0008 -0.0001 -0.0004 -0.0001 0.0000 0.0001 0.0009 0.0024 0.0047;
0.0004 -0.0004 -0.0005 -0.0001 0.0000 0.0002 0.0011 0.0027 0.0051;
0.0000 -0.0006 -0.0006 -0.0002 0.0000 0.0002 0.0012 0.0030 0.0055;
-0.0004 -0.0009 -0.0007 -0.0002 0.0000 0.0002 0.0013 0.0032 0.0059;
-0.0008 -0.0012 -0.0009 -0.0002 0.0000 0.0002 0.0014 0.0035 0.0063;
-0.0012 -0.0014 -0.0010 -0.0002 0.0000 0.0003 0.0016 0.0037 0.0068;
-0.0021 -0.0020 -0.0013 -0.0003 0.0000 0.0003 0.0019 0.0043 0.0077;
-0.0032 -0.0027 -0.0016 -0.0004 0.0000 0.0004 0.0022 0.0050 0.0088;
-0.0044 -0.0035 -0.0020 -0.0005 0.0000 0.0005 0.0026 0.0058 0.0099;
-0.0058 -0.0044 -0.0025 -0.0005 0.0000 0.0006 0.0030 0.0067 0.0113;
-0.0066 -0.0049 -0.0027 -0.0006 0.0000 0.0006 0.0033 0.0072 0.0122;
-0.0076 -0.0056 -0.0031 -0.0007 0.0000 0.0007 0.0037 0.0079 0.0132;
-0.0148 -0.0102 -0.0054 -0.0011 0.0000 0.0011 0.0060 0.0125 0.0203];

plant_model.aeroCl_basic = [-0.0381 0.0516 0.1432 0.2372 0.3338 0.4327 0.5335 0.6360 0.7399 0.8451 0.9515 1.0590 1.1680 1.3480 1.5050 1.6320 1.6990 1.6810 1.5210 0.0707];
plant_model.areoCl_q = 7.9520;
plant_model.aeroCl_elevator = [-0.0924 -0.0598 -0.0299 -0.0060 0.0001 0.0060 0.0299 0.0598 0.0924];

plant_model.aeroCy_beta = -0.3073;
plant_model.aeroCy_p = [-0.0059 -0.0042 -0.0026 -0.0010 0.0006 0.0022 0.0038 0.0054 0.0070 0.0085 0.0101 0.0116 0.0130 0.0163 0.0200 0.0239 0.0268 0.0512 0.0434 0.0806];

plant_model.aeroCl_beta = [-0.0397 -0.0415 -0.0434 -0.0454 -0.0474 -0.0495 -0.0517 -0.0540 -0.0563 -0.0586 -0.0610 -0.0634 -0.0659 -0.0694 -0.0718 -0.0729 -0.0715 -0.0688 -0.0609 0.0015];

plant_model.aeroCl_aileron = [0.0000 0.0043 0.0130 0.0217 0.0348 0.0435 0.0636 0.0706 0.0740];

%% Exported Value
PLANT_EXPORT_VALUE.period = uint32(PLANT_CONST.dt*1e3); 
PLANT_EXPORT_VALUE.model_info = int8([model_name, ' ', model_version, 0]); % 0 for end of string

PLANT_EXPORT = Simulink.Parameter(PLANT_EXPORT_VALUE);
PLANT_EXPORT.CoderInfo.StorageClass = 'ExportedGlobal';

%% init sensor model
run('sensor_model_init.m');