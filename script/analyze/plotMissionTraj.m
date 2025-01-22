% 获取数据
ref_INS_Out = get(logsout, 'INS_Out_Ref');
ref_Mission_data = get(logsout, 'Mission_Data');

llax = ref_Mission_data.Values.x * 1e-7;
llay = ref_Mission_data.Values.y * 1e-7;
datax = llax.data;
datay = llay.data;

% 提取第一行中的非零数据
llax = datax(1, datax(1,:) ~= 0);
llay = datay(1, datay(1,:) ~= 0);

x_R = ref_INS_Out.Values.x_R.data;
y_R = ref_INS_Out.Values.y_R.data;
lat0 = ref_INS_Out.Values.lat_0.data;
lon0 = ref_INS_Out.Values.lon_0.data;
lat0 = unique(lat0(lat0 ~= 0)) * 180 / pi;
lon0 = unique(lon0(lon0 ~= 0)) * 180 / pi;

lla = [llax(:), llay(:), zeros(size(llax(:)))];
llo = [lat0, lon0];
psi0 = 0;
href = 0;
sp_waypoint = lla2flat(lla, llo, psi0, href);
sp_waypoint_x = [sp_waypoint(:, 1); x_R(1, 1)];%航点加上反航点
sp_waypoint_y = [sp_waypoint(:, 2); y_R(1, 1)];%航点加上反航点
%sp_waypoint_x = sp_waypoint(:, 1);%纯航点
%sp_waypoint_y = sp_waypoint(:, 2);%纯航点
% 创建图形
figure;

% 以 x_R 为纵坐标，y_R 为横坐标绘制数据
plot(y_R, x_R, 'b', 'LineWidth', 2); % 原有的图像
hold on; % 保持图像，继续绘制新的数据

% 以 llax 为纵坐标，llay 为横坐标绘制数据，并按顺序以直线连接
plot(sp_waypoint_y, sp_waypoint_x, 'r', 'LineWidth', 1); % 新的数据，以红色直线连接

% 在每个 sp_waypoint 点上添加标记
plot(sp_waypoint_y, sp_waypoint_x, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8); % 红色圆点标记，大小为8

% 添加标题和标签
title('Plot of x_R vs. y_R and llax vs. llay');
xlabel('y_R / llay');
ylabel('x_R / llax');
grid on;

% 添加图例
legend('INS Position (x_R vs. y_R)', 'Mission Trajectory (llax vs. llay)', 'Waypoint Markers', 'Location', 'best');
