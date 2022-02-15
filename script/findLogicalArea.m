function border = findLogicalArea(x, lg)
%FINDAXESAREA Summary of this function goes here
%   Detailed explanation goes here

num = numel(x);
border = zeros(1, num * 2);
find_start = 0;
cnt = 0;

for n = 1:num
    if lg(n) > 0
        if find_start == 0
            border(cnt*2+1) = x(n);
            find_start = 1;
        end
        if find_start && n == num
            border(cnt*2+2) = x(n);
            
            cnt = cnt + 1;
            find_start = 0;
        end
    elseif find_start
        border(cnt*2+2) = x(n - 1);
            
        cnt = cnt + 1;
        find_start = 0;
    end
end

border = border(1:cnt*2);

end

