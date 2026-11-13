function tests = test_model_export
%test_model_export - Check real generated exports in isolated Firmware fixtures
%   Run after fmt_build_all has generated the multicopter models.
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(root, 'script', 'fmt_coder'));
fmt_configure_models(false, 'Vehicle', 'Multicopter', ...
    'Board', 'sieon/s1', 'Airframe', 1, 'SimulationMode', 'None');
testCase.TestData.originalRoot = getpref('FMT', 'FirmwareRoot');
catalog = fmt_model_catalog('Multicopter');
for k = 1:numel(catalog)
    info = RTW.getBuildDir(catalog(k).name);
    assert(isfile(fullfile(info.BuildDirectory, [catalog(k).name '.c'])), ...
        'Generate all models with fmt_build_all before running export tests.');
end
testCase.TestData.catalog = catalog;
testCase.TestData.fixtureParent = fullfile(root, 'build', 'fmt_export_tests');
if ~isfolder(testCase.TestData.fixtureParent), mkdir(testCase.TestData.fixtureParent); end
end

function setup(testCase)
root = tempname(testCase.TestData.fixtureParent);
mkdir(root);
testCase.TestData.fixture = root;
testCase.addTeardown(@() restoreFixture(testCase.TestData));
sourceRoot = testCase.TestData.originalRoot;
board = fullfile(root, 'target', 'sieon', 's1');
mkdir(fullfile(board, 'config'));
copyfile(fullfile(sourceRoot, 'target', 'sieon', 's1', 'SConstruct'), board);
copyfile(fullfile(sourceRoot, 'target', 'sieon', 's1', 'config', 'model.py'), ...
    fullfile(board, 'config'));
catalog = testCase.TestData.catalog;
for k = 1:numel(catalog)
    module = fullfile('src', 'model', catalog(k).module);
    mkdir(fullfile(root, module));
    copyfile(fullfile(sourceRoot, module, 'lib'), fullfile(root, module, 'lib'));
    copyfile(fullfile(sourceRoot, module, '*interface.c'), fullfile(root, module));
    copyfile(fullfile(sourceRoot, module, 'SConscript'), fullfile(root, module));
end
setpref('FMT', 'FirmwareRoot', root);
end

function testRepeatedExportCreatesNoBackup(testCase)
names = {testCase.TestData.catalog.name};
fmt_sync_models(names, 'Controller');
folder = fullfile(testCase.TestData.fixture, 'build', 'model_sync');
entries = dir(folder);
before = {entries.name};
fmt_sync_models(names, 'Controller');
entries = dir(folder);
testCase.verifyEqual({entries.name}, before);
end

function testOriginalTunabilityPoliciesRemainInEffect(testCase)
names = {'Controller','FMS','INS','Plant'};
configs = {'control_config','fms_config','ins_config','plant_config'};
for k = 1:numel(names)
    original = evalin('base', configs{k});
    testCase.verifyEqual(get_param(names{k}, 'ParameterTunabilityLossMsg'), ...
        get_param(original, 'ParameterTunabilityLossMsg'));
end
end

function testInterfaceFailureLeavesEveryLibraryUnchanged(testCase)
file = fullfile(testCase.TestData.fixture, 'src', 'model', ...
    'control', 'mc_controller', 'control_interface.c');
writeText(file, [fileread(file) newline '/* CONTROL_PARAM.FMT_MISSING_FIELD */']);
before = snapshotLibraries(testCase.TestData);
testCase.verifyError(@() fmt_sync_models({'Controller','FMS','INS','Plant'}, ...
    'Controller'), 'FMT:InterfaceMismatch');
testCase.verifyEqual(snapshotLibraries(testCase.TestData), before);
end

function testSharedConflictRequiresCompleteRegeneration(testCase)
fmt_sync_models({testCase.TestData.catalog.name}, 'Controller');
file = fullfile(testCase.TestData.fixture, 'src', 'model', ...
    'control', 'mc_controller', 'lib', 'rt_nonfinite.c');
writeText(file, [fileread(file) newline '/* Deliberately incompatible fixture */']);
before = snapshotLibraries(testCase.TestData);
testCase.verifyError(@() fmt_sync_models({'FMS'}, 'Controller'), ...
    'FMT:SharedRebuildRequired');
testCase.verifyEqual(snapshotLibraries(testCase.TestData), before);
end

function testUnsupportedAirframePublishesNothing(testCase)
old = get_param('Controller', 'FMTAirframe');
testCase.addTeardown(@() set_param('Controller', 'FMTAirframe', old));
set_param('Controller', 'FMTAirframe', '999');
before = snapshotLibraries(testCase.TestData);
testCase.verifyError(@() fmt_sync_models({'Controller'}, 'Controller'), ...
    'FMT:UnsupportedAirframe');
testCase.verifyEqual(snapshotLibraries(testCase.TestData), before);
end

function result = snapshotLibraries(data)
result = cell(0, 3);
for k = 1:numel(data.catalog)
    root = fullfile(data.fixture, 'src', 'model', data.catalog(k).module, 'lib');
    files = dir(root);
    files = files(~[files.isdir]);
    for f = 1:numel(files)
        result(end + 1, :) = {data.catalog(k).module, files(f).name, ...
            fileread(fullfile(root, files(f).name))}; %#ok<AGROW>
    end
end
end

function writeText(file, value)
fid = fopen(file, 'wt');
release = onCleanup(@() fclose(fid));
fprintf(fid, '%s', value);
end

function restoreFixture(data)
setpref('FMT', 'FirmwareRoot', data.originalRoot);
assert(strcmp(fileparts(data.fixture), data.fixtureParent));
if isfolder(data.fixture), rmdir(data.fixture, 's'); end
end
