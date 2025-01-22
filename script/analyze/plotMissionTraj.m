% ��ȡ����
ref_INS_Out = get(logsout, 'INS_Out_Ref');
ref_Mission_data = get(logsout, 'Mission_Data');

llax = ref_Mission_data.Values.x * 1e-7;
llay = ref_Mission_data.Values.y * 1e-7;
datax = llax.data;
datay = llay.data;

% ��ȡ��һ���еķ�������
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
sp_waypoint_x = [sp_waypoint(:, 1); x_R(1, 1)];%������Ϸ�����
sp_waypoint_y = [sp_waypoint(:, 2); y_R(1, 1)];%������Ϸ�����
%sp_waypoint_x = sp_waypoint(:, 1);%������
%sp_waypoint_y = sp_waypoint(:, 2);%������
% ����ͼ��
figure;

% �� x_R Ϊ�����꣬y_R Ϊ�������������
plot(y_R, x_R, 'b', 'LineWidth', 2); % ԭ�е�ͼ��
hold on; % ����ͼ�񣬼��������µ�����

% �� llax Ϊ�����꣬llay Ϊ������������ݣ�����˳����ֱ������
plot(sp_waypoint_y, sp_waypoint_x, 'r', 'LineWidth', 1); % �µ����ݣ��Ժ�ɫֱ������

% ��ÿ�� sp_waypoint ������ӱ��
plot(sp_waypoint_y, sp_waypoint_x, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8); % ��ɫԲ���ǣ���СΪ8

% ��ӱ���ͱ�ǩ
title('Plot of x_R vs. y_R and llax vs. llay');
xlabel('y_R / llay');
ylabel('x_R / llax');
grid on;

% ���ͼ��
legend('INS Position (x_R vs. y_R)', 'Mission Trajectory (llax vs. llay)', 'Waypoint Markers', 'Location', 'best');
