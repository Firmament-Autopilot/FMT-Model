classdef FMS_Cmd < Simulink.IntEnumType
  enumeration
    CMD_None(0)
    CMD_PreArm(1000)
    CMD_Arm(1001)
    CMD_Disarm(1002)
    CMD_Takeoff(1003)
    CMD_Land(1004)
    CMD_Return(1005)
    CMD_Pause(1006)
    CMD_Continue(1007)
  end
end 