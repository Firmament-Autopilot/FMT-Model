function modules = fmt_firmware_modules(modelName)
%fmt_firmware_modules - Query the board's existing SCons module selection
options = fmt_build_options(modelName);
helper = fullfile(fileparts(mfilename('fullpath')), 'fmt_resolve_modules.py');
command = sprintf(['python "%s" --firmware-root "%s" --board "%s" ' ...
    '--vehicle "%s" --sim "%s" --airframe %d'], helper, options.firmwareRoot, ...
    options.board, options.vehicle, options.sim, options.airframe);
[status, output] = system(command);
assert(status == 0, 'FMT:ModelSelectionFailed', ...
    'Cannot read the board model selection: %s', output);
% Board configuration diagnostics may precede the final JSON result.
lines = splitlines(strtrim(string(output)));
modules = cellstr(string(jsondecode(lines(end))));
end
