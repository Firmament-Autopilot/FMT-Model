

FMS_Out = get(logsout, 'FMS_Out');

%% plot rate controller data
rate_cmd_B = get(logsout, 'rate_cmd_B_radPs');
rate_est_B = get(logsout, 'rate_est_B_radPs');
rate_error_B = get(logsout, 'rate_error_B_radPs');

rate_cmd_B_x = rate_cmd_B.Values;
rate_cmd_B_x.Data = rate_cmd_B_x.Data(:, 1);
rate_cmd_B_y = rate_cmd_B.Values;
rate_cmd_B_y.Data = rate_cmd_B_y.Data(:, 2);
rate_cmd_B_z = rate_cmd_B.Values;
rate_cmd_B_z.Data = rate_cmd_B_z.Data(:, 3);

rate_est_B_x = rate_est_B.Values;
rate_est_B_x.Data = rate_est_B_x.Data(:, 1);
rate_est_B_y = rate_est_B.Values;
rate_est_B_y.Data = rate_est_B_y.Data(:, 2);
rate_est_B_z = rate_est_B.Values;
rate_est_B_z.Data = rate_est_B_z.Data(:, 3);

rate_error_B_x = rate_error_B.Values;
rate_error_B_x.Data = rate_error_B_x.Data(:, 1);
rate_error_B_y = rate_error_B.Values;
rate_error_B_y.Data = rate_error_B_y.Data(:, 2);
rate_error_B_z = rate_error_B.Values;
rate_error_B_z.Data = rate_error_B_z.Data(:, 3);

figure;

ax1 = subplot(3,2,1);
hold on;
grid on;
plot(rate_est_B_x, 'Color', 'b');
plot(rate_cmd_B_x, 'Color', 'r');
colorAxes(ax1, findLogicalArea(FMS_Out.Values.status.Time, FMS_Out.Values.status.Data == VehicleStatus.Arm), 'green');
legend('p_{est}', 'p_{cmd}');

ax2 = subplot(3,2,3);
hold on;
grid on;
plot(rate_est_B_y, 'Color', 'b');
plot(rate_cmd_B_y, 'Color', 'r');
colorAxes(ax2, findLogicalArea(FMS_Out.Values.status.Time, FMS_Out.Values.status.Data == VehicleStatus.Arm), 'green');
legend('q_{est}', 'q_{cmd}');

ax3 = subplot(3,2,5);
hold on;
grid on;
plot(rate_est_B_z, 'Color', 'b');
plot(rate_cmd_B_z, 'Color', 'r');
colorAxes(ax3, findLogicalArea(FMS_Out.Values.status.Time, FMS_Out.Values.status.Data == VehicleStatus.Arm), 'green');
legend('r_{est}', 'r_{cmd}');

ax4 = subplot(3,2,2);
hold on;
grid on;
plot(rate_error_B_x, 'Color', 'b');
colorAxes(ax4, findLogicalArea(FMS_Out.Values.status.Time, FMS_Out.Values.status.Data == VehicleStatus.Arm), 'green');
legend('p_{error}');

ax5 = subplot(3,2,4);
hold on;
grid on;
plot(rate_error_B_y, 'Color', 'b');
colorAxes(ax5, findLogicalArea(FMS_Out.Values.status.Time, FMS_Out.Values.status.Data == VehicleStatus.Arm), 'green');
legend('q_{error}');

ax6 = subplot(3,2,6);
hold on;
grid on;
plot(rate_error_B_z, 'Color', 'b');
colorAxes(ax6, findLogicalArea(FMS_Out.Values.status.Time, FMS_Out.Values.status.Data == VehicleStatus.Arm), 'green');
legend('r_{error}');

%% plot attitude control data
att_cmd_B = get(logsout, 'att_cmd_B_rad');
att_est_B = get(logsout, 'att_est_B_rad');
att_error_B = get(logsout, 'att_error_B_rad');

att_cmd_B_x = att_cmd_B.Values;
att_cmd_B_x.Data = att_cmd_B_x.Data(:, 1);
att_cmd_B_y = att_cmd_B.Values;
att_cmd_B_y.Data = att_cmd_B_y.Data(:, 2);

att_est_B_x = att_est_B.Values;
att_est_B_x.Data = att_est_B_x.Data(:, 1);
att_est_B_y = att_est_B.Values;
att_est_B_y.Data = att_est_B_y.Data(:, 2);

att_error_B_x = att_error_B.Values;
att_error_B_x.Data = att_error_B_x.Data(:, 1);
att_error_B_y = att_error_B.Values;
att_error_B_y.Data = att_error_B_y.Data(:, 2);

figure;

ax1 = subplot(2,2,1);
hold on;
grid on;
plot(att_est_B_x, 'Color', 'b');
plot(att_cmd_B_x, 'Color', 'r');
colorAxes(ax1, findLogicalArea(FMS_Out.Values.status.Time, FMS_Out.Values.status.Data == VehicleStatus.Arm), 'green');
legend('\phi_{est}', '\phi_{cmd}');

ax2 = subplot(2,2,3);
hold on;
grid on;
plot(att_est_B_y, 'Color', 'b');
plot(att_cmd_B_y, 'Color', 'r');
colorAxes(ax2, findLogicalArea(FMS_Out.Values.status.Time, FMS_Out.Values.status.Data == VehicleStatus.Arm), 'green');
legend('\theta_{est}', '\theta_{cmd}');

ax3 = subplot(2,2,2);
hold on;
grid on;
plot(att_error_B_x, 'Color', 'b');
colorAxes(ax3, findLogicalArea(FMS_Out.Values.status.Time, FMS_Out.Values.status.Data == VehicleStatus.Arm), 'green');
legend('\phi_{error}');

ax4 = subplot(2,2,4);
hold on;
grid on;
plot(att_error_B_y, 'Color', 'b');
colorAxes(ax4, findLogicalArea(FMS_Out.Values.status.Time, FMS_Out.Values.status.Data == VehicleStatus.Arm), 'green');
legend('\theta_{error}');

%% plot height control data
w_cmd_C = get(logsout, 'w_cmd_C_mPs');
w_est_C = get(logsout, 'w_est_C_mPs');
w_err_C = get(logsout, 'w_error_C_mPs');

figure;

ax1 = subplot(2,1,1);
hold on;
grid on;
plot(w_cmd_C.Values, 'Color', 'b');
plot(w_est_C.Values, 'Color', 'r');
colorAxes(ax1, findLogicalArea(FMS_Out.Values.status.Time, FMS_Out.Values.status.Data == VehicleStatus.Arm), 'green');
legend('w_{est}', 'w_{cmd}');

ax2 = subplot(2,1,2);
hold on;
grid on;
plot(w_err_C.Values, 'Color', 'b');
colorAxes(ax2, findLogicalArea(FMS_Out.Values.status.Time, FMS_Out.Values.status.Data == VehicleStatus.Arm), 'green');
legend('w_{error}');