# MC-FMS
Multicopter Flight Management System.

Maintainer: Josh Z, zoujiachi666@163.com

## Environment

- MATLAB 2018b or higher

## Required Toolbox

- Embedded Coder (7.1)
- MATLAB (9.5)
- Simulink (9.2)
- Simulink Coder (9.0)
- Stateflow (9.2)

## Supported Mode
- Auto
  - Mission
  - Offboard
- Assist
  - Position
  - Altitude
  - Stabilize
  - Acro
- Submode
  - Takeoff
  - Return
  - Land
  - Hold
 
## Parameter
| Name        | Type   | Default | Description                          |
| ------------| -------| ------- | ------------------------------------ |
| THROTTLE_DZ    | FLOAT  | 0.15    | Throttle stick deadzone |
| YAW_DZ    | FLOAT  | 0.15    | Yaw stick deadzone |
| ROLL_DZ    | FLOAT  | 0.15    | Roll stick deadzone |
| PITCH_DZ    | FLOAT  | 0.15    | Pitch stick deadzone |
| XY_P    | FLOAT  | 1.2    | Position xy controller P gain |
| Z_P    | FLOAT  | 1.5    | Position z controller P gain |
| VEL_XY_LIM    | FLOAT  | 5.0    | Limitation of velocity xy in m/s |
| VEL_Z_LIM    | FLOAT  | 1.5    | Limitation of velocity z in m/s |
| YAW_P    | FLOAT  | 2.5    | Yaw heading controller P gain |
| YAW_RATE_LIM    | FLOAT  | PI / 3    | Limitation of yaw rate in rad/s |
| ROLL_PITCH_LIM    | FLOAT  | PI / 6    | Limitation of roll/pitch in rad |
| L1    | FLOAT  | 15    | L1 guidance value |
| CRUISE_SPEED    | FLOAT  | 5.0    | Cruise speed for mission in m/s |
| CRUISE_ACC    | FLOAT  | 5.0    | Cruise speed acceleration in m/s |
| TAKEOFF_H    | FLOAT  | 1.5    | Takeoff height in m |
| TAKEOFF_SPEED    | FLOAT  | 1.0    | Takeoff speed in m/s |
| ACCEPT_R    | FLOAT  | 0.5    | Accept waypoint arrival radius in m   |
| ASSIST_LAND_H    | FLOAT  | 0.7    | Deceleration landing height in m when hAGL is valid    |
| LAND_SPEED    | FLOAT  | 0.6    | Landing speed in m/s    |
| LOST_RETURN_TIME    | UINT16  | 120    | If signal lost (both RC and GroundStation/OnboardComputer lost), the time to trigger return command in second   |
| LOST_RETURN_EN    | UINT8  | 1    | Enable lost return. 1:enable 0:disable    |
| LAND_LOCK_THRO    | UINT16  | 1300    | If vehicle is landed and motors average throttle lower than this value, the vehicle will be disarmed automatically  |
| STICK_SENS    | FLOAT  | 0.5    | Sticks sensitive, range in [0 1]    |
