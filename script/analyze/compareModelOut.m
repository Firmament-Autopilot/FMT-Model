% Plot Simulation and On-board Model Output

sim_INS_Out = get(logsout, 'INS_Out');
ref_INS_Out = get(logsout, 'INS_Out_Ref');

sim_FMS_Out = get(logsout, 'FMS_Out');
ref_FMS_Out = get(logsout, 'FMS_Out_Ref');

sim_Control_Out = get(logsout, 'Control_Out');
ref_Control_Out = get(logsout, 'Control_Out_Ref');

%% Euler
figure;
ax1 = subplot(3,1,1);
plot(sim_INS_Out.Values.phi, 'Color', 'r');
hold on;
plot(ref_INS_Out.Values.phi, 'Color', 'b');
grid on;
legend('\phi', '\phi_r')

ax2 = subplot(3,1,2);
plot(sim_INS_Out.Values.theta, 'Color', 'r');
hold on;
plot(ref_INS_Out.Values.theta, 'Color', 'b');
grid on;
legend('\theta', '\theta_r')

ax3 = subplot(3,1,3);
plot(sim_INS_Out.Values.psi, 'Color', 'r');
hold on;
plot(ref_INS_Out.Values.psi, 'Color', 'b');
grid on;
legend('\psi', '\psi_r')

linkaxes([ax1,ax2,ax3], 'x');

%% Velocity
figure;
ax1 = subplot(3,1,1);
plot(sim_INS_Out.Values.vn, 'Color', 'r');
hold on;
plot(ref_INS_Out.Values.vn, 'Color', 'b');
grid on;
legend('vn', 'vn_r')

ax2 = subplot(3,1,2);
plot(sim_INS_Out.Values.ve, 'Color', 'r');
hold on;
plot(ref_INS_Out.Values.ve, 'Color', 'b');
grid on;
legend('ve', 've_r')

ax3 = subplot(3,1,3);
plot(sim_INS_Out.Values.vd, 'Color', 'r');
hold on;
plot(ref_INS_Out.Values.vd, 'Color', 'b');
grid on;
legend('vd', 'vd_r')

linkaxes([ax1,ax2,ax3], 'x');

%% Position
figure;
ax1 = subplot(3,1,1);
plot(sim_INS_Out.Values.x_R, 'Color', 'r');
hold on;
plot(ref_INS_Out.Values.x_R, 'Color', 'b');
grid on;
legend('x', 'x_r')

ax2 = subplot(3,1,2);
plot(sim_INS_Out.Values.y_R, 'Color', 'r');
hold on;
plot(ref_INS_Out.Values.y_R, 'Color', 'b');
grid on;
legend('y', 'y_r')

ax3 = subplot(3,1,3);
plot(sim_INS_Out.Values.h_R, 'Color', 'r');
hold on;
plot(ref_INS_Out.Values.h_R, 'Color', 'b');
grid on;
legend('h', 'h_r')

linkaxes([ax1,ax2,ax3], 'x');

%% FMS Output
figure;
ax1 = subplot(3,1,1);
plot(sim_FMS_Out.Values.u_cmd, 'Color', 'r');
hold on;
plot(ref_FMS_Out.Values.u_cmd, 'Color', 'b');
grid on;
legend('u\_cmd', 'u\_cmd_r')
ax2 = subplot(3,1,2);
plot(sim_FMS_Out.Values.v_cmd, 'Color', 'r');
hold on;
plot(ref_FMS_Out.Values.v_cmd, 'Color', 'b');
grid on;
legend('v\_cmd', 'v\_cmd_r')
ax3 = subplot(3,1,3);
plot(sim_FMS_Out.Values.w_cmd, 'Color', 'r');
hold on;
plot(ref_FMS_Out.Values.w_cmd, 'Color', 'b');
grid on;
legend('w\_cmd', 'w\_cmd_r')
linkaxes([ax1,ax2,ax3], 'x');

figure;
ax1 = subplot(3,1,1);
plot(sim_FMS_Out.Values.phi_cmd, 'Color', 'r');
hold on;
plot(ref_FMS_Out.Values.phi_cmd, 'Color', 'b');
grid on;
legend('\phi\_cmd', '\phi\_cmd_r')
ax2 = subplot(3,1,2);
plot(sim_FMS_Out.Values.theta_cmd, 'Color', 'r');
hold on;
plot(ref_FMS_Out.Values.theta_cmd, 'Color', 'b');
grid on;
legend('\theta\_cmd', '\theta\_cmd_r')
ax3 = subplot(3,1,3);
plot(sim_FMS_Out.Values.psi_rate_cmd, 'Color', 'r');
hold on;
plot(ref_FMS_Out.Values.psi_rate_cmd, 'Color', 'b');
grid on;
legend('\psi\_rate\_cmd', '\psi\_rate\_cmd_r')
linkaxes([ax1,ax2,ax3], 'x');

%% Control Output
figure;

ax1 = subplot(4,1,1);
plot(sim_Control_Out.Values.actuator_cmd.Time, sim_Control_Out.Values.actuator_cmd.Data(:,1), 'Color', 'r');
hold on;
plot(ref_Control_Out.Values.actuator_cmd.Time, ref_Control_Out.Values.actuator_cmd.Data(:,1), 'Color', 'b');
grid on;
legend('motor1', 'motor1_r')

ax2 = subplot(4,1,2);
plot(sim_Control_Out.Values.actuator_cmd.Time, sim_Control_Out.Values.actuator_cmd.Data(:,2), 'Color', 'r');
hold on;
plot(ref_Control_Out.Values.actuator_cmd.Time, ref_Control_Out.Values.actuator_cmd.Data(:,2), 'Color', 'b');
grid on;
legend('motor2', 'motor2_r')

ax3 = subplot(4,1,3);
plot(sim_Control_Out.Values.actuator_cmd.Time, sim_Control_Out.Values.actuator_cmd.Data(:,3), 'Color', 'r');
hold on;
plot(ref_Control_Out.Values.actuator_cmd.Time, ref_Control_Out.Values.actuator_cmd.Data(:,3), 'Color', 'b');
grid on;
legend('motor3', 'motor3_r')

ax4 = subplot(4,1,4);
plot(sim_Control_Out.Values.actuator_cmd.Time, sim_Control_Out.Values.actuator_cmd.Data(:,4), 'Color', 'r');
hold on;
plot(ref_Control_Out.Values.actuator_cmd.Time, ref_Control_Out.Values.actuator_cmd.Data(:,4), 'Color', 'b');
grid on;
legend('motor4', 'motor4_r')

linkaxes([ax1,ax2,ax3,ax4], 'x');