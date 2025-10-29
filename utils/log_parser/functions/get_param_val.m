function val = get_param_val(param_list, group_name,param_name)

[col, row] = size(param_list);

for i = 1:row
   if strcmp(param_list(i).name, group_name)
      for j = 1:param_list(i).num_param
          if strcmp(param_list(i).param(j).name, param_name)
              switch param_list(i).param(j).type
                  case 0
                      val = int8(param_list(i).param(j).val);
                  case 1
                      val = uint8(param_list(i).param(j).val);
                  case 2
                      val = int16(param_list(i).param(j).val);
                  case 3
                      val = uint16(param_list(i).param(j).val);
                  case 4
                      val = int32(param_list(i).param(j).val);
                  case 5
                      val = uint32(param_list(i).param(j).val);
                  case 6
                      val = single(param_list(i).param(j).val);
                  case 7
                      val = double(param_list(i).param(j).val);
                  otherwise
                      val = param_list(i).param(j).val;
              end
              return;
          end
      end
   end
end
% do not find parameter, return nan
val = NaN;

end

