# MC-Controller
Multicopter controller based on PID.

Maintainer: Josh Z, zoujiachi666@163.com

## Environment

- MATLAB 2018b or higher

## Required Toolbox

- Embedded Coder (7.1)
- MATLAB (9.5)
- Simulink (9.2)
- Simulink Coder (9.0)

## Supported Airframe
| Airframe                        | Build Command                             | Description                          |
| ------------------------------- | ----------------------------------------- | ------------------------------------ |
| Quadcopter x, Airframe=1        | scons --vehicle=Multicopter --airframe=1  | ![quad_x](https://github.com/Firmament-Autopilot/FMT-DOCS/blob/main/docs/figures/quad_x.png)     |
| Quadcopter +, Airframe=2        | scons --vehicle=Multicopter --airframe=2  | ![quad_+](https://github.com/Firmament-Autopilot/FMT-DOCS/blob/main/docs/figures/quad_+.png)     |
| Coxial Quadcopter x, Airframe=3 | scons  --vehicle=Multicopter --airframe=3 | ![quad_+](https://github.com/Firmament-Autopilot/FMT-DOCS/blob/main/docs/figures/cox_quad_x.png) |
| Hexacopter x, Airframe=4        | scons --vehicle=Multicopter --airframe=4  | ![quad_+](https://github.com/Firmament-Autopilot/FMT-DOCS/blob/main/docs/figures/hexa_x.png)     |
| Hexacopter +, Airframe=5        | scons --vehicle=Multicopter --airframe=5  | ![quad_+](https://github.com/Firmament-Autopilot/FMT-DOCS/blob/main/docs/figures/hexa_+.png)     |
| Coxial Hexacopter x, Airframe=6 | scons --vehicle=Multicopter --airframe=6  | ![quad_+](https://github.com/Firmament-Autopilot/FMT-DOCS/blob/main/docs/figures/cox_hexa_x.png) |
| Octocopter x, Airframe=7        | scons --vehicle=Multicopter --airframe=7  | ![quad_+](https://github.com/Firmament-Autopilot/FMT-DOCS/blob/main/docs/figures/octo_x.png)     |
| Octocopter +, Airframe=8        | scons --vehicle=Multicopter --airframe=8  | ![quad_+](https://github.com/Firmament-Autopilot/FMT-DOCS/blob/main/docs/figures/octo_+.png)     |

## Parameter
| Name        | Type   | Default | Description                          |
| ------------| -------| ------- | ------------------------------------ |
| AIRFRAME    | UINT8  | Read only    | Decide which airframe is used, value assigned by --airframe option |
| VEL_XY_P    | FLOAT  | 1.4   | Horizontal velocity P gain  |
| VEL_XY_I    | FLOAT  | 0.2   | Horizontal velocity I gain  |
| VEL_XY_D    | FLOAT  | 0.05   | Horizontal velocity D gain |
| VEL_Z_P    | FLOAT  | 0.5   | Vertical velocity P gain |
| VEL_Z_I    | FLOAT  | 0.12   | Vertical velocity I gain |
| VEL_Z_D    | FLOAT  | 0.0   | Vertical velocity D gain |
| VEL_XY_I_MIN    | FLOAT  | -1.0   | Horizontal velocity minimum integral value |
| VEL_XY_I_MAX    | FLOAT  | 1.0   | Horizontal velocity maximum integral value |
| VEL_XY_D_MIN    | FLOAT  | -1.0   | Horizontal velocity minimum differential value |
| VEL_XY_D_MAX    | FLOAT  | 1.0   | Horizontal velocity maximum differential value |
| VEL_Z_I_MIN    | FLOAT  | -0.2   | Vertical velocity minimum integral value |
| VEL_Z_I_MAX    | FLOAT  | 0.2   | Vertical velocity maximum integral value |
| VEL_Z_D_MIN    | FLOAT  | -0.1   | Vertical velocity minimum differential value |
| VEL_Z_D_MAX    | FLOAT  | 0.1   | Vertical velocity maximum differential value |
| ROLL_P    | FLOAT  | 7.0   | Roll P gain |
| PITCH_P    | FLOAT  | 7.0   | Pitch P gain |
| ROLL_PITCH_CMD_LIM    | FLOAT  | PI/6   | Limitation of roll/pitch command |
| ROLL_RATE_P    | FLOAT  | 0.045   | Roll rate P gain |
| PITCH_RATE_P    | FLOAT  | 0.045   | Pitch rate P gain |
| YAW_RATE_P    | FLOAT  | 0.15   | Yaw rate P gain |
| ROLL_RATE_I    | FLOAT  | 0.05   | Roll rate I gain |
| PITCH_RATE_I    | FLOAT  | 0.05   | Pitch rate I gain |
| YAW_RATE_I    | FLOAT  | 0.15   | Yaw rate I gain |
| ROLL_RATE_D    | FLOAT  | 0.0015   | Roll rate D gain |
| PITCH_RATE_D    | FLOAT  | 0.0015   | Pitch rate D gain |
| YAW_RATE_D    | FLOAT  | 0.001   | Yaw rate D gain |
| ROLL_RATE_FF    | FLOAT  | 0.0   | Roll rate feedforward gain |
| PITCH_RATE_FF    | FLOAT  | 0.0   | Pitch rate feedforward gain |
| RATE_I_MIN    | FLOAT  | -0.1   | Angle rate minimum integral value |
| RATE_I_MAX    | FLOAT  | 0.1   | Angle rate maximum integral value |
| RATE_D_MIN    | FLOAT  | -0.1   | Angle rate minimum differential value |
| RATE_D_MAX    | FLOAT  | 0.1   | Angle rate maximum differential value |
| P_Q_CMD_LIM    | FLOAT  | PI / 2   | Limitation of angle rate xy (p,q) |
| R_CMD_LIM    | FLOAT  | PI   | Limitation of angle rate z (r) |
| HOVER_THRO    | FLOAT  | 0.5   | Hover throttle, range [0, 1] |
