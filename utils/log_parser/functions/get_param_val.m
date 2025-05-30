function val = get_param_val(param_list, group_name,param_name)

[col, row] = size(param_list);

for i = 1:row
   if strcmp(param_list(i).name, group_name)
      for j = 1:param_list(i).num_param
          if strcmp(param_list(i).param(j).name, param_name)
              val = param_list(i).param(j).val;
              return;
          end
      end
   end
end
% do not find parameter, return nan
val = NaN;

end

