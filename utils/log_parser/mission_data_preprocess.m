
%% mission_data.param4 contains some NaN data, which is invalid for timeserials.
%% so remove it as we are not using param4 yet.

[row, col] = size(Mission_Data.param4.Data);

for i = 1 : row * col
    if isnan(Mission_Data.param4.Data(i))
       Mission_Data.param4.Data(i) = single(0); 
    end
end
