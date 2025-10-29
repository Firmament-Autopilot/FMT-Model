%% Load model parameters from log header

% Load INS parameters
fieldname = fieldnames(INS_PARAM.Value);
[row, ~] = size(fieldname);
for k = 1:row
    val = get_param_val(LogHeader.param_group_list, 'INS', fieldname{k});
    if isnan(val)
        fprintf("Can't find INS pararameter %s\n", fieldname{k});
    else
        INS_PARAM.Value.(fieldname{k}) = val;
    end
end

% Load FMS parameters
fieldname = fieldnames(FMS_PARAM.Value);
[row, ~] = size(fieldname);
for k = 1:row
    val = get_param_val(LogHeader.param_group_list, 'FMS', fieldname{k});
    if isnan(val)
        fprintf("Can't find FMS pararameter %s\n", fieldname{k});
    else
        FMS_PARAM.Value.(fieldname{k}) = val;
    end
end

% Load CONTROL parameters
fieldname = fieldnames(CONTROL_PARAM.Value);
[row, ~] = size(fieldname);
for k = 1:row
    val = get_param_val(LogHeader.param_group_list, 'CONTROL', fieldname{k});
    if isnan(val)
        fprintf("Can't find CONTROL pararameter %s\n", fieldname{k});
    else
        CONTROL_PARAM.Value.(fieldname{k}) = val;
    end
end

% Load Airframe parameter
AIRFRAME = get_param_val(LogHeader.param_group_list, 'CONTROL', 'AIRFRAME');