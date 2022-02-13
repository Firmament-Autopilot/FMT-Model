function colorAxes(ax, x, lgx, color)
%COLOREDAXES Summary of this function goes here
%   Detailed explanation goes here

start_idx = [];
stop_idx = [];
find_start = 0;

for n = 1:numel(x)
    if lgx(n) > 0
        if find_start == 0
            start_idx = n;
            find_start = 1;
        end
        if n == numel(x)
            stop_idx = n;
        end
    elseif find_start == 1
        stop_idx = n;
    end
    
    if ~isempty(start_idx) && ~isempty(stop_idx)
        x1 = x(start_idx);
        x2 = x(stop_idx);
        y1 = 0;
        y2 = 100;
        
        fill(ax, [x1, x1, x2, x2], [y1, y2, y2, y1] ,color, 'EdgeColor', 'none');
        hold(ax,'off');
        alpha(0.1);
        hold(ax,'on');
        
        start_idx = [];
        stop_idx = [];
        find_start = 0;
    end
end

end

