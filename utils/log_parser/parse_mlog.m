
%% open log file
[file, folder] = uigetfile({'*.bin'; '*.log'});

if isequal(file,0)
    % click cancel
    return;    
end

logfile = strcat(folder, file);

[header, log_msg] = mlog_parser(logfile);

clear file;
clear folder;
clear logfile;
