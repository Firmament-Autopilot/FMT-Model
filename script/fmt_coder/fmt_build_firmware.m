function binPath = fmt_build_firmware(modelName)
%fmt_build_firmware - Run the board's original SCons build and return its bin
options = fmt_build_options(modelName);
boardDir = options.boardDir;

cmd = sprintf(['scons -C "%s" -j4 --vehicle=%s ' ...
    '--airframe=%d --sim=%s'], ...
    boardDir, options.vehicle, options.airframe, options.sim);

[status, cmdout] = system(cmd, '-echo');
assert(status == 0 && contains(cmdout, 'scons: done building targets.'), ...
    'Firmware compilation did not finish successfully. See the build output.');

bins = dir(fullfile(boardDir, 'build', 'fmt_*.bin'));
assert(isscalar(bins) && bins(1).bytes > 0, ...
    'Expected exactly one nonempty fmt_*.bin firmware image.');

binPath = fullfile(bins(1).folder, bins(1).name);
fprintf('Firmware output: %s\n', binPath);
end
