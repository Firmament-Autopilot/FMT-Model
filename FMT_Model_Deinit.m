%% Firmament Autopilot
%% brief: run this script to deinit FMT Model

warning('off', 'MATLAB:rmpath:DirNotFound');
rmpath(genpath('build'));
rmpath(genpath('model'));
warning('on', 'MATLAB:rmpath:DirNotFound');

close_system('Plant', 0)
close_system('INS', 0)
close_system('FMS', 0)
close_system('Controller', 0)

clear;