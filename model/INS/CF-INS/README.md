# CF-INS
Inertial Navigation System based on complementary filter. 

Maintainer: Josh Z, zoujiachi666@163.com

## Environment

- MATLAB 2018b or higher

## Required Toolbox

- MATLAB (9.5)
- Simulink (9.2)
- Simulink Coder (9.0)

## Supported Sensors
- IMU
- MAG
- Barometer
- Rangefinder
- GPS/RTK
- Optical Flow
- Airspeed
- External Position Sensor
  - UWB
  - VINS
  - MOCAP
 
## Parameter
| Name        | Type   | Default | Description                          |
| ------------| -------| ------- | ------------------------------------ |
| ATT_GAIN    | FLOAT  | 0.2    | IMU attitude fusion gain |
| HEADING_GAIN    | FLOAT  | 0.05   | GNSS heading fusion gain  |
| MAG_GAIN    | FLOAT  | 0.3   | MAG heading fusion gain  |
| MAG_FLY_EN    | UINT8  | 0   | Whether enable MAG fusion when vehicle is armed. 0:disable 1:enable |
| BIAS_G_GAIN    | FLOAT  | 0.25   | Gyro bias estimation gain  |
| GPS_HOR_Q_BIAS    | FLOAT  | 2.5   | GPS horizontal quality bias. horizon_quality = (GPS_HOR_Q_BIAS - hAcc) *  GPS_HOR_Q_SCALE |
| GPS_HOR_Q_SCALE    | FLOAT  | 0.5   | GPS horizontal quality scale  |
| GPS_VER_Q_BIAS    | FLOAT  | 4.5   | GPS vertical quality bias. vertical_quality = (GPS_VER_Q_BIAS - hAcc) *  GPS_VER_Q_SCALE |
| GPS_VER_Q_SCALE    | FLOAT  | 0.25   | GPS vertical quality scale  |
| GPS_VEL_Q_BIAS    | FLOAT  | 1.0   | GPS velocity quality bias. velocity_quality = (GPS_VEL_Q_BIAS - hAcc) *  GPS_VEL_Q_SCALE |
| GPS_VEL_Q_SCALE    | FLOAT  | 1.0   | GPS velocity quality scale  |
| GPS_POS_GAIN    | FLOAT  | 0.0   | GPS position fusion gain  |
| GPS_ALT_GAIN    | FLOAT  | 0.0   | GPS altitude fusion gain  |
| GPS_VEL_GAIN    | FLOAT  | 2.0   | GPS velocity fusion gain  |
| GPS_BIAS_A_GAIN    | FLOAT  | 1.0   | Acceleration bias estimation gain by GPS  |
| GPS_POS_DELAY    | UINT32  | 100   | GPS position delay in ms  |
| GPS_VEL_DELAY    | UINT32  | 100   | GPS velocity delay in ms  |
| GPS_X_OFFSET    | FLOAT  | 0.0   | GPS x direction install offset in meter  |
| GPS_Y_OFFSET    | FLOAT  | 0.0   | GPS y direction install offset in meter  |
| GPS_Z_OFFSET    | FLOAT  | 0.0   | GPS z direction install offset in meter  |
| RTK_POS_GAIN    | FLOAT  | 0.4   | RTK position fusion gain  |
| RTK_ALT_GAIN    | FLOAT  | 0.2   | RTK altitude fusion gain  |
| RTK_VEL_GAIN    | FLOAT  | 1.5   | RTK velocity fusion gain  |
| RTK_BIAS_A_GAIN    | FLOAT  | 0.5   | Acceleration bias estimation gain by RTK  |
| OPF_VEL_GAIN    | FLOAT  | 2.0   | Optical flow velocity fusion gain  |
| OPF_BIAS_A_GAIN    | FLOAT  | 1.0   | Acceleration bias estimation gain by optical flow  |
| OPF_VEL_DELAY    | UINT32  | 10   | Optical flow velocity delay in ms  |
| OPF_FIX_GAIN    | FLOAT  | 0.0   |   |
| BARO_H_GAIN    | FLOAT  | 2.0   | Barometer height fusion gain |
| BARO_VZ_GAIN    | FLOAT  | 1.0   | Barometer velocity z fusion gain |
| BARO_BIAS_AZ_GAIN    | FLOAT  | 0.2   | Acceleration z bias estimation gain by optical barometer  |
| BARO_H_DELAY    | UINT32  | 10   | Barometer height delay in ms  |
| RF_H_GAIN    | FLOAT  | 3.0   | Rangefinder height fusion gain |
| RF_VZ_GAIN    | FLOAT  | 5.0   | Rangefinder velocity z fusion gain |
| RF_BIAS_AZ_GAIN    | FLOAT  | 0.2   | Acceleration z bias estimation gain by optical rangefinder  |
| RF_H_DELAY    | UINT32  | 10   | Rangefinder height delay in ms  |
| EXTPOS_POS_GAIN    | FLOAT  | 2.0   | External sensor position fusion gain |
| EXTPOS_VEL_GAIN    | FLOAT  | 1.5   | External sensor velocity fusion gain |
| EXTPOS_BIAS_A_GAIN    | FLOAT  | 0.1   | Acceleration bias estimation gain by external sensor  |
| EXTPOS_POS_DELAY    | UINT32  | 20   | External sensor position delay in ms  |
| EXTPOS_PSI_MODE    | UINT8  | 3   | External sensor frame mode  |
| EXTPOS_PSI    | FLOAT  | 0.0   | External sensor frame heading  |
