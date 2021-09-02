function hLib = crl_sin_cos_cmsis


hLib = RTW.TflTable;
%---------- entry: cos ----------- 
hEnt = createCRLEntry(hLib, ...
    'single y1 = cos( single u1 )', ...
    'single y1 = arm_cos_f32( single u1 )');
hEnt.setTflCFunctionEntryParameters( ...
          'Priority', 100, ...
          'ImplementationHeaderFile', 'arm_math.h');

hEnt.EntryInfo.Algorithm = 'RTW_UNSPECIFIED';


hLib.addEntry( hEnt ); 

%---------- entry: cos ----------- 
hEnt = createCRLEntry(hLib, ...
    'int16 y1 = cos( int16 u1 )', ...
    'int16 y1 = arm_cos_q15( int16 u1 )');
hEnt.setTflCFunctionEntryParameters( ...
          'Priority', 100, ...
          'ImplementationHeaderFile', 'arm_math.h');

hEnt.EntryInfo.Algorithm = 'RTW_UNSPECIFIED';


hLib.addEntry( hEnt ); 

%---------- entry: cos ----------- 
hEnt = createCRLEntry(hLib, ...
    'int32 y1 = cos( int32 u1 )', ...
    'int32 y1 = arm_cos_q31( int32 u1 )');
hEnt.setTflCFunctionEntryParameters( ...
          'Priority', 100, ...
          'ImplementationHeaderFile', 'arm_math.h');

hEnt.EntryInfo.Algorithm = 'RTW_UNSPECIFIED';


hLib.addEntry( hEnt ); 

%---------- entry: sin ----------- 
hEnt = createCRLEntry(hLib, ...
    'single y1 = sin( single u1 )', ...
    'single y1 = arm_sin_f32( single u1 )');
hEnt.setTflCFunctionEntryParameters( ...
          'Priority', 100, ...
          'ImplementationHeaderFile', 'arm_math.h');

hEnt.EntryInfo.Algorithm = 'RTW_UNSPECIFIED';


hLib.addEntry( hEnt ); 

%---------- entry: sin ----------- 
hEnt = createCRLEntry(hLib, ...
    'int16 y1 = sin( int16 u1 )', ...
    'int16 y1 = arm_sin_q15( int16 u1 )');
hEnt.setTflCFunctionEntryParameters( ...
          'Priority', 100, ...
          'ImplementationHeaderFile', 'arm_math.h');

hEnt.EntryInfo.Algorithm = 'RTW_UNSPECIFIED';


hLib.addEntry( hEnt ); 

%---------- entry: sin ----------- 
hEnt = createCRLEntry(hLib, ...
    'int32 y1 = sin( int32 u1 )', ...
    'int32 y1 = arm_sin_q31( int32 u1 )');
hEnt.setTflCFunctionEntryParameters( ...
          'Priority', 100, ...
          'ImplementationHeaderFile', 'arm_math.h');

hEnt.EntryInfo.Algorithm = 'RTW_UNSPECIFIED';


hLib.addEntry( hEnt ); 

