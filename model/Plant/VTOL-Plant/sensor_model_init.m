%% Sensor Model Initialize Script
wmm = load('wmmgrid_2021.mat');
Sensor_Model.g = 9.80665;
Sensor_Model.IMU.Sampletime = 0.002;

%% Gyroscope Model Parameter
Sensor_Model.Gyro.Vibration.Gain = [0.5;0.5;0.5];
Sensor_Model.Gyro.Bias = [0;0;0];
Sensor_Model.Gyro.Scalefactor_Error = zeros(3);
Sensor_Model.Gyro.Range = 2000*pi/180; % 2000dps
Sensor_Model.Gyro.Cutoff_frequency_Hz = 50; % TODO, 256 don't work
Sensor_Model.Gyro.Variance = [0.005;0.005;0.005].^2;
Sensor_Model.Gyro.Seed = [2123;2234;2345];

%% Accelerometer Model Parameter
Sensor_Model.Acc.Vibration.Gain = [20; 20; 15];
Sensor_Model.Acc.Bias = [0;0;0];
Sensor_Model.Acc.Scalefactor_Error = zeros(3);
Sensor_Model.Acc.Upper_limit = 8*9.80665;   % +-8g
Sensor_Model.Acc.Lower_limit = -8*9.80665;
Sensor_Model.Acc.Cutoff_frequency_Hz = 50;
Sensor_Model.Acc.Variance = [0.05;0.05;0.05].^2;
Sensor_Model.Acc.Seed = [1123;1234;1345];

%% Magnetometer Model Parameter
Sensor_Model.Mag.Bias = [0;0;0];
Sensor_Model.Mag.Scalefactor_Error = zeros(3);
Sensor_Model.Mag.Upper_limit = 4; % +-4 Gauss
Sensor_Model.Mag.Lower_limit = -4; 
Sensor_Model.Mag.Cutoff_frequency_Hz = 100;
Sensor_Model.Mag.Variance = [0.001;0.001;0.001].^2;
Sensor_Model.Mag.Seed = [3123;3234;3345];
Sensor_Model.Mag.Sampletime = 0.01;
Sensor_Model.Mag.WMM_Mag = wmm.wmmgrid_mag;
Sensor_Model.Mag.WMM_Dec = wmm.wmmgrid_dec;
Sensor_Model.Mag.WMM_Inc = wmm.wmmgrid_inc;

%% Barometer Model Parameter
Sensor_Model.Baro.Bias = 0;
Sensor_Model.Baro.Upper_limit = 115e3;
Sensor_Model.Baro.Lower_limit = -15e3;
Sensor_Model.Baro.Variance = 4^2;
Sensor_Model.Baro.Seed = 4123;
Sensor_Model.Baro.Sampletime = 0.01;