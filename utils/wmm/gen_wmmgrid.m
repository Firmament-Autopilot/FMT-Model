function [wmm_grid] = gen_wmmgrid(file, row, col)

grid_data = load(file);
wmm_grid = zeros(row,col);

for r = 1:row
   for c = 1:col
       % data is in column 5
       wmm_grid(r,c) = grid_data((r-1)*col+c, 5);
   end
end

end