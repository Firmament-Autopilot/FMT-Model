% Firmament Autopilot
% MLog (Mat Log) Parser
% @brief: parse mlog.bin file
function [LogHeader, LogMsg] = mlog_parser(logfile)

%% BLog Data Type Definition
TYPE_CAST = ["int8=>int8", "uint8=>uint8", "int16=>int16", "uint16=>uint16",...
    "int32=>int32", "uint32=>uint32", "float=>float", "double=>double"];

% mlog message start/end flag
MLOG_BEGIN_MSG1 = hex2dec('92');
MLOG_BEGIN_MSG2 = hex2dec('05');
MLOG_END_MSG = hex2dec('26');

%% Open Log File
fileID = fopen(logfile, 'r');
fileDir = dir(logfile);
if ~fileID
    disp('log file open fail');
    return;
end

%% Read Log Header
% Read Log Information
LogHeader.version = fread(fileID, 1, 'uint16=>uint16');
LogHeader.timestamp = fread(fileID, 1, 'uint32=>uint32');
LogHeader.max_name_len = fread(fileID, 1, 'uint16=>uint16');
LogHeader.max_desc_len = fread(fileID, 1, 'uint16=>uint16');
LogHeader.max_model_info_len = fread(fileID, 1, 'uint16=>uint16');
LogHeader.description = fread(fileID, LogHeader.max_desc_len, 'char=>char');
LogHeader.model_info = fread(fileID, LogHeader.max_model_info_len, 'char=>char');

fprintf('MLog File:%s\n', logfile);
fprintf('Version:%d\n', LogHeader.version);
fprintf('Timestamp:%d(ms)\n', LogHeader.timestamp);
fprintf('Description:%s\n', LogHeader.description);
fprintf('Model Information:\n%s\n', LogHeader.model_info);

% Read bus number
LogHeader.num_bus = fread(fileID, 1, 'uint8=>uint8');
% Preallocate memory
MsgCount = zeros(1, LogHeader.num_bus);
LogMsg = cell(1, LogHeader.num_bus);
% Read bus data
for n = 1:LogHeader.num_bus
    LogHeader.bus(n).name = fread(fileID, [1 LogHeader.max_name_len], 'uint8=>char');
    LogHeader.bus(n).msg_id = fread(fileID, 1, 'uint8=>uint8');
    LogHeader.bus(n).num_elem = fread(fileID, 1, 'uint8=>uint8');
    % Read bus elements
    for k = 1:LogHeader.bus(n).num_elem
        LogHeader.bus(n).elem_list(k).name = fread(fileID, [1 LogHeader.max_name_len], 'uint8=>char');
        LogHeader.bus(n).elem_list(k).type = fread(fileID, 1, 'uint16=>uint16');
        LogHeader.bus(n).elem_list(k).number = fread(fileID, 1, 'uint16=>uint16');
    end
    % Preallocate memory
    LogMsg{n} = cell(1, LogHeader.bus(n).num_elem);
end

% Read Parameter
LogHeader.num_param_group = fread(fileID, 1, 'uint8=>uint8');

for n = 1:LogHeader.num_param_group
    LogHeader.param_group_list(n).name = fread(fileID, [1 LogHeader.max_name_len], 'uint8=>char');
    LogHeader.param_group_list(n).num_param = fread(fileID, 1, 'uint32=>uint32');
    LogHeader.param_group_list(n).name = deblank(LogHeader.param_group_list(n).name);
    
    for k = 1:LogHeader.param_group_list(n).num_param
        LogHeader.param_group_list(n).param(k).name = fread(fileID, [1 LogHeader.max_name_len], 'uint8=>char');
        LogHeader.param_group_list(n).param(k).type = fread(fileID, 1, 'uint8=>uint8');
        index = LogHeader.param_group_list(n).param(k).type+1;
        LogHeader.param_group_list(n).param(k).val = fread(fileID, 1, TYPE_CAST(index));
        LogHeader.param_group_list(n).param(k).name = deblank(LogHeader.param_group_list(n).param(k).name);
    end
end

%% Read Log Msg
while ~feof(fileID) && ftell(fileID)<fileDir.bytes

    %%% Read Msg Begin Flag %%%
    begin_state = 0;
    while begin_state < 2
        switch begin_state
            case 0
                % search for MLOG_BEGIN_MSG1
                msg_begin = fread(fileID, 1, 'uint8=>uint8');
                if msg_begin == MLOG_BEGIN_MSG1
                    begin_state = 1;
                end
            case 1
                % search for MLOG_BEGIN_MSG2
                msg_begin = fread(fileID, 1, 'uint8=>uint8');
                if msg_begin == MLOG_BEGIN_MSG2
                    begin_state = 2;
                elseif msg_begin == MLOG_BEGIN_MSG1
                    begin_state = 1;
                else
                    begin_state = 0;
                end
            otherwise
                break;
        end
    end
    
    %%% Read Msg ID %%%
    msg_id = fread(fileID, 1, 'uint8=>uint8');
    
    % msg_id start from 0 and index start from 1
    index = msg_id + 1;
    if index > LogHeader.num_bus
        index = -1; % invalid msg id
    end

    if index < 0
        fprintf('invalid msg id:%d\r\n', msg_id);
        % continue to search next msg
        continue;
    end

    %%% Read Msg Payload %%%
    
    % read bus elements
    for k = 1:LogHeader.bus(index).num_elem
        type = LogHeader.bus(index).elem_list(k).type+1;
        len = LogHeader.bus(index).elem_list(k).number;
        
        [elem_val, rb] = fread(fileID, [len, 1], TYPE_CAST(type));
        
        if rb < len
            fprintf('%s %s cnt %d read err, delete it\n', LogHeader.bus(index).name, LogHeader.bus(index).elem_list(k).name, MsgCount(index));
            % TODO: handle this error
            break;
        else
            % LogMsg{msg_id}{elem_index}(len:cnt)
            LogMsg{index}{k}(1:len, MsgCount(index)+1) = elem_val;
        end
    end
    
    %%% Read Msg End Flag %%%
    msg_end = fread(fileID, 1, 'uint8=>uint8');
    if msg_end == MLOG_END_MSG
        % valid msg received
        MsgCount(index) = MsgCount(index) + 1;
    else
        fprintf('invalid msg end flag:%d, msg id:%d\r\n', msg_end, msg_id);
        % delete invalid msg
        for k = 1:LogHeader.bus(index).num_elem
            try
                LogMsg{index}{k}(:, MsgCount(index)+1) = [];
            catch
                continue
            end
        end
    end
end
fclose(fileID);

%% Output Parsed Information
fprintf('\nLog parse finish!\n');
% fprintf('log elapsed time: %f(s)\n', )
for n = 1:LogHeader.num_bus
    % remove 0
    BusName = deblank(LogHeader.bus(n).name);
	fprintf('%s: %d msg recorded\n', BusName, MsgCount(n));
end

%% Generate .MAT file
generate_MAT(LogHeader, LogMsg, fileDir.folder);
end

function generate_MAT(LogHeader, LogMsg, Path)
%% create Bus variable and save into .mat file
save(strcat(Path, '/LogHeader.mat'), 'LogHeader'); % save log header

for n = 1:LogHeader.num_bus
    msg_id = LogHeader.bus(n).msg_id;
    index = msg_id + 1;
    if isempty(LogMsg{index})
       continue; 
    end
    
    BusName = deblank(LogHeader.bus(n).name);
    
    % find timestamp
    timestamp_id = 0;
    for k = 1:LogHeader.bus(n).num_elem
        ElemName = deblank(LogHeader.bus(n).elem_list(k).name);
        if strcmp(ElemName, "timestamp_ms") || strcmp(ElemName, "timestamp")
            timestamp_id = k;
        end
    end
    
    if timestamp_id <= 0
       fprintf("can't find timestamp element in %s\n", LogHeader.bus(n).name);
       continue;
    else
       time_stamp = double(LogMsg{index}{timestamp_id}-LogMsg{index}{timestamp_id}(1)) * 0.001;   % milli second to second
    end
    
    % construct Bus variable
    for k = 1:LogHeader.bus(n).num_elem
        ElemName = deblank(LogHeader.bus(n).elem_list(k).name);
        
        exp = sprintf('timeseries(LogMsg{index}{k}'', time_stamp);');
        if ~isempty(ElemName)
            eval([BusName, '.', ElemName, '=', exp]);
        else
            eval([BusName, '=', exp]);
        end

    end
    
    % save as .mat file
    out_file = strcat(Path, ['/', BusName, '.mat']);
    save(out_file, BusName);
    fprintf("Save to path:%s\n", out_file);
end    
end

