function colorAxes(ax, border, color)
%COLOREDAXES Summary of this function goes here
%   Detailed explanation goes here

num = numel(border)/2;
if num == 0
    return;
end

for n = 0:num-1
    x1 = border(n*2 + 1);
    x2 = border(n*2 + 2);
    ylim = get(ax,'YLim');
    y1 = ylim(1);
    y2 = ylim(2);
    
    fill(ax, [x1, x1, x2, x2], [y1, y2, y2, y1] ,color, 'EdgeColor', 'none');
    hold(ax,'off');
    alpha(0.1);
    hold(ax,'on');
end

end

