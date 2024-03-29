function cellInfo = mavlink_fmt_environment_info_t(varargin) 
% MAVLINK_FMT_ENVIRONMENT_INFO_T returns a cell array containing bus object information 
% 
% Optional Input: 'false' will suppress a call to Simulink.Bus.cellToObject 
%                 when the MATLAB file is executed. 
% The order of bus element attributes is as follows:
%   ElementName, Dimensions, DataType, SampleTime, Complexity, SamplingMode, DimensionsMode, Min, Max, DocUnits, Description 

suppressObject = false; 
if nargin == 1 && islogical(varargin{1}) && varargin{1} == false 
    suppressObject = true; 
elseif nargin > 1 
    error('Invalid input argument(s) encountered'); 
end 

cellInfo = { ... 
  { ... 
    'mavlink_fmt_environment_info_t', ... 
    '', ... 
    '', ... 
    'Auto', ... 
    '-1', {... 
{'hit_point', 3, 'single', -1, 'real', 'Sample', 'Fixed', [], [], '', sprintf('[m] Hit point in global frame')}; ...
{'hit_normal', 3, 'single', -1, 'real', 'Sample', 'Fixed', [], [], '', sprintf('Hit normal in global frame')}; ...
{'hit_location', 3, 'single', -1, 'real', 'Sample', 'Fixed', [], [], '', sprintf('[m] Hit location in global frame')}; ...
    } ...
  } ...
}'; 

if ~suppressObject 
    % Create bus objects in the MATLAB base workspace 
    Simulink.Bus.cellToObject(cellInfo) 
end 
