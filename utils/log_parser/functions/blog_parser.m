% Firmament Autopilot
% BLog (Binary Log) Parser
% @brief: parse blog.bin file
function [LogHeader, LogMsg] = blog_parser(logfile)

%% BLog Data Type Definition
BLOG_TYPE = ["int8=>int8", "uint8=>uint8", "int16=>int16", "uint16=>uint16",...
    "int32=>int32", "uint32=>uint32", "float=>float", "double=>double"];
BLOG_BEGIN_MSG1 = hex2dec('92');
BLOG_BEGIN_MSG2 = hex2dec('05');
BLOG_END_MSG = hex2dec('26');

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

fprintf('Blog File:%s\n', logfile);
fprintf('Version:%d\n', LogHeader.version);
fprintf('Timestamp:%d(ms)\n', LogHeader.timestamp);
fprintf('Description:%s\n', LogHeader.description);
fprintf('Model Information:\n%s\n', LogHeader.model_info);

% Read Bus
LogHeader.num_bus = fread(fileID, 1, 'uint8=>uint8');

bus_alligned = 1; % bus_alligned=1 ==> msg_id=bus_index
for n = 1:LogHeader.num_bus
    LogHeader.bus(n).name = fread(fileID, [1 LogHeader.max_name_len], 'uint8=>char');
    LogHeader.bus(n).msg_id = fread(fileID, 1, 'uint8=>uint8');
    LogHeader.bus(n).num_elem = fread(fileID, 1, 'uint8=>uint8');

    for k = 1:LogHeader.bus(n).num_elem
        LogHeader.bus(n).elem_list(k).name = fread(fileID, [1 LogHeader.max_name_len], 'uint8=>char');
        LogHeader.bus(n).elem_list(k).type = fread(fileID, 1, 'uint16=>uint16');
        LogHeader.bus(n).elem_list(k).number = fread(fileID, 1, 'uint16=>uint16');
        
%         LogMsg{LogHeader.bus(n).msg_id}{k}(1:LogHeader.bus(n).elem_list(k).number, 1:1000) = 0;
    end
    
    % init msg count and msg buffer
    % TODO: Can be faster if pre-allocate the memory or not use cell array
    MsgCount{LogHeader.bus(n).msg_id} = 0;
    LogMsg{LogHeader.bus(n).msg_id} = {};
    
    % check if msg id is alligned with bus index 
    if LogHeader.bus(n).msg_id ~= n
        bus_alligned = 0;
    end
end

% Read Parameter
LogHeader.num_param_group = fread(fileID, 1, 'uint8=>uint8');

for n = 1:LogHeader.num_param_group
    LogHeader.param_group_list(n).name = fread(fileID, [1 LogHeader.max_name_len], 'uint8=>char');
    LogHeader.param_group_list(n).num_param = fread(fileID, 1, 'uint32=>uint32');
    LogHeader.param_group_list(n).name = LogHeader.param_group_list(n).name(~isspace(LogHeader.param_group_list(n).name));
    
    for k = 1:LogHeader.param_group_list(n).num_param
        LogHeader.param_group_list(n).param(k).name = fread(fileID, [1 LogHeader.max_name_len], 'uint8=>char');
        LogHeader.param_group_list(n).param(k).type = fread(fileID, 1, 'uint8=>uint8');
        index = LogHeader.param_group_list(n).param(k).type+1;
        LogHeader.param_group_list(n).param(k).val = fread(fileID, 1, BLOG_TYPE(index));
        LogHeader.param_group_list(n).param(k).name = LogHeader.param_group_list(n).param(k).name(~isspace(LogHeader.param_group_list(n).param(k).name));
    end
end

%% Read Log Msg
while ~feof(fileID) && ftell(fileID)<fileDir.bytes

    %%% Read Msg Begin Flag %%%
    begin_state = 0;
    while begin_state < 2
        switch begin_state
            case 0
                % search for BLOG_BEGIN_MSG1
                msg_begin = fread(fileID, 1, 'uint8=>uint8');
                if msg_begin == BLOG_BEGIN_MSG1
                    begin_state = 1;
                end
            case 1
                % search for BLOG_BEGIN_MSG2
                msg_begin = fread(fileID, 1, 'uint8=>uint8');
                if msg_begin == BLOG_BEGIN_MSG2
                    begin_state = 2;
                elseif msg_begin == BLOG_BEGIN_MSG1
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
    
    if bus_alligned
        index = msg_id;
        if index > LogHeader.num_bus
            index = -1; % invalid msg id
        end
    else
        % search bus index
        index = -1;
        for n = 1 : LogHeader.num_bus
            if msg_id == LogHeader.bus(n).msg_id
                index = n;
                break;
            end
        end       
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
        
        [elem_val, rb] = fread(fileID, [len, 1], BLOG_TYPE(type));
        
        if rb < len
            fprintf('%s %s cnt %d read err, delete it\n', LogHeader.bus(index).name, LogHeader.bus(index).elem_list(k).name, MsgCount{msg_id});
            % TODO: handle this error
            break;
        else
            % LogMsg{msg_id}{elem_index}(len:cnt)
            LogMsg{msg_id}{k}(1:len, MsgCount{msg_id}+1) = elem_val;
        end
    end
    
    %%% Read Msg End Flag %%%
    msg_end = fread(fileID, 1, 'uint8=>uint8');
    if msg_end == BLOG_END_MSG
        % valid msg received
        MsgCount{msg_id} = MsgCount{msg_id} + 1;
    else
        fprintf('invalid msg end flag:%d, msg id:%d\r\n', msg_end, msg_id);
        % delete invalid msg
        for k = 1:LogHeader.bus(index).num_elem
            try
                LogMsg{msg_id}{k}(:, MsgCount{msg_id}+1) = [];
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
    BusName = strrep(LogHeader.bus(n).name, '"', '');
    BusName = BusName(~isspace(BusName));
	fprintf('%s: %d msg recorded\n', BusName, MsgCount{LogHeader.bus(n).msg_id});
end

%% Generate .MAT file
generate_MAT(LogHeader, LogMsg, fileDir.folder);
end

function generate_MAT(LogHeader, LogMsg, Path)
%% create Bus variable and save into .mat file
save(strcat(Path, '/LogHeader.mat'), 'LogHeader'); % save log header

for n = 1:LogHeader.num_bus
    msg_id = LogHeader.bus(n).msg_id;
    if isempty(LogMsg{msg_id})
       continue; 
    end
    
    BusName = strrep(LogHeader.bus(n).name, '"', '');
    BusName = BusName(~isspace(BusName));
    
    % find timestamp
    timestamp_id = 0;
    for k = 1:LogHeader.bus(n).num_elem
        ElemName = strrep(LogHeader.bus(n).elem_list(k).name, '"', '');
        ElemName = ElemName(~isspace(ElemName));
        if strcmp(ElemName, "timestamp_ms") || strcmp(ElemName, "timestamp")
            timestamp_id = k;
        end
    end
    
    if timestamp_id <= 0
       fprintf("can't find timestamp element in %s\n", LogHeader.bus(n).name);
       continue;
    else
       time_stamp = double(LogMsg{msg_id}{timestamp_id}-LogMsg{msg_id}{timestamp_id}(1)) * 0.001;   % milli second to second
    end
    
    % construct Bus variable
    for k = 1:LogHeader.bus(n).num_elem
        ElemName = strrep(LogHeader.bus(n).elem_list(k).name, '"', '');
        ElemName = ElemName(~isspace(ElemName));
        
        exp = sprintf('timeseries(LogMsg{msg_id}{k}'', time_stamp);');
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

