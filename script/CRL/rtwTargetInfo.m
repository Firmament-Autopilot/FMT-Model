function rtwTargetInfo(cm)

cm.registerTargetInfo(@loc_register_crl);

function this = loc_register_crl

this(1) = RTW.TflRegistry;
this(1).Name = 'STM32 DSP LIB';
this(1).TableList = {'crl_sin_cos_cmsis'};
this(1).BaseTfl = 'GNU C99 extensions';
this(1).TargetHWDeviceType = {'*'};
this(1).Description = '';
