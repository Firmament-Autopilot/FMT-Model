
Rotation_Data = get(logsout, 'Rotation_Data');
Translation_Data = get(logsout, 'Translation_Data');
INS_Out = get(logsout, 'INS_Out');

acc_meas_O = get(logsout, 'acc_meas_O_mPs2');
acc_est_O = get(logsout, 'acc_est_O_mPs2');

mag_enable = get(logsout, 'mag_enable');
acc_meas_valid = get(logsout, 'acc_meas_valid');

%% plot attitude data
phi_deg = INS_Out.Values.phi;
phi_deg.Data = single(phi_deg.Data)*2^-12*180/pi;
theta_deg = INS_Out.Values.theta;
theta_deg.Data = single(theta_deg.Data)*2^-12*180/pi;
psi_deg = INS_Out.Values.psi;
psi_deg.Data = single(psi_deg.Data)*2^-12*180/pi;

acc_O_meas_x = acc_meas_O.Values;
acc_O_meas_x.Data = acc_O_meas_x.Data(1,:);
acc_O_meas_y = acc_meas_O.Values;
acc_O_meas_y.Data = acc_O_meas_y.Data(2,:);
acc_O_meas_z = acc_meas_O.Values;
acc_O_meas_z.Data = acc_O_meas_z.Data(3,:);
acc_O_est_x = acc_est_O.Values;
acc_O_est_x.Data = acc_O_est_x.Data(1,:);
acc_O_est_y = acc_est_O.Values;
acc_O_est_y.Data = acc_O_est_y.Data(2,:);
acc_O_est_z = acc_est_O.Values;
acc_O_est_z.Data = acc_O_est_z.Data(3,:);

figure;
ax1 = subplot(3,2,1);
plot(phi_deg, 'Color', 'r');
hold on;
grid on;
legend('\phi')

ax2 = subplot(3,2,3);
plot(theta_deg, 'Color', 'r');
hold on;
grid on;
legend('\theta')

ax3 = subplot(3,2,5);
plot(psi_deg, 'Color', 'r');
hold on;
grid on;
colorAxes(ax3, findLogicalArea(mag_enable.Values.Time, mag_enable.Values.Data > 0), 'green');
colorAxes(ax3, findLogicalArea(acc_meas_valid.Values.Time, acc_meas_valid.Values.Data > 0), 'blue');
legend('\psi')

ax4 = subplot(3,2,2);
plot(acc_O_est_x, 'Color', 'r');
hold on;
plot(acc_O_meas_x, 'Color', 'b');
grid on;
legend('acc\_est\_x', 'acc\_meas\_x')

ax5 = subplot(3,2,4);
plot(acc_O_est_y, 'Color', 'r');
hold on;
plot(acc_O_meas_y, 'Color', 'b');
grid on;
legend('acc\_est\_y', 'acc\_meas\_y')

ax6 = subplot(3,2,6);
plot(acc_O_est_z, 'Color', 'r');
hold on;
plot(acc_O_meas_z, 'Color', 'b');
grid on;
legend('acc\_est\_z', 'acc\_meas\_z')

linkaxes([ax1,ax2,ax3,ax4,ax5,ax6], 'x');