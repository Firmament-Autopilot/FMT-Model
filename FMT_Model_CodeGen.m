function FMT_Model_CodeGen
%FMT_MODEL_CODEGEN Build selected FMT Simulink models and deploy their code.
% Uses classic MATLAB UI and Java APIs compatible with R2018b and newer releases.

root = fileparts(mfilename('fullpath'));
settings = loadSettings(root);
if ~strcmpi(pwd, root)
    % Keep model-relative initialization scripts and project paths predictable.
    addpath(root);
end

modelNames={'Plant','INS','FMS','Controller'};
models=struct('name',{},'category',{},'path',{},'target',{},'check',{});
for k=1:numel(modelNames)
    modelPath=which([modelNames{k} '.slx']);
    if isempty(modelPath), modelPath=which(modelNames{k}); end
    map=inferVariant(modelPath,modelNames{k});
    item.name=modelNames{k};
    item.category=map{1};
    item.path=modelPath;
    item.target=map;
    item.check=[];
    models(end+1)=item; %#ok<AGROW>
end

fig = figure('Name','FMT Model Code Generation','NumberTitle','off', ...
    'MenuBar','none','ToolBar','none','Resize','on','Units','normalized', ...
    'Position',[0.04 0.05 0.55 0.50],'CloseRequestFcn',@closeWindow);
set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
uicontrol(fig,'Style','text','String','FMT-Model Code Generation Tool', ...
    'FontSize',14,'FontWeight','bold','HorizontalAlignment','left', ...
    'Units','normalized','Position',[0.025 0.94 0.43 0.045]);

vehicle = readWorkspaceValue('VEHICLE');
airframe = readWorkspaceValue('AIRFRAME');

uicontrol(fig,'Style','text','String','VEHICLE', ...
    'HorizontalAlignment','left','Units','normalized','Position',[0.025 0.89 0.25 0.035]);
vehicleText = uicontrol(fig,'Style','text','String',vehicle,'HorizontalAlignment','left', ...
    'Units','normalized','Position',[0.28 0.89 0.18 0.035]);
uicontrol(fig,'Style','text','String','AIRFRAME', ...
    'HorizontalAlignment','left','Units','normalized','Position',[0.025 0.865 0.25 0.035]);
airframeText = uicontrol(fig,'Style','text','String',airframe,'HorizontalAlignment','left', ...
    'Units','normalized','Position',[0.28 0.865 0.18 0.035]);

uicontrol(fig,'Style','text','String','Select Models','FontWeight','bold', ...
    'HorizontalAlignment','left','Units','normalized','Position',[0.025 0.83 0.43 0.035]);
for k=1:numel(models)
    y=0.77-(k-1)*0.075;
    models(k).check=uicontrol(fig,'Style','checkbox','Value',~isempty(models(k).path), ...
        'Units','normalized','Position',[0.035 y 0.045 0.045], ...
        'Enable',onOff(~isempty(models(k).path)));
    uicontrol(fig,'Style','text','String',models(k).name,'HorizontalAlignment','left', ...
        'Units','normalized','Position',[0.085 y 0.12 0.045]);
    if isempty(models(k).path), shown='Not found on MATLAB path'; else, shown=models(k).path; end
    uicontrol(fig,'Style','text','String',shown,'HorizontalAlignment','left', ...
        'Units','normalized','Position',[0.21 y 0.245 0.045]);
end

uicontrol(fig,'Style','text','String','Code Generation and Deployment', 'FontWeight','bold', ...
    'HorizontalAlignment','left','Units','normalized','Position',[0.025 0.44 0.43 0.035]);
copyCheck = uicontrol(fig,'Style','checkbox','String','Copy generated code to FMT-Firmware', ...
    'Value',settings.copyEnabled,'Units','normalized','Position',[0.035 0.39 0.40 0.04], ...
    'Callback',@toggleDeploy);
uicontrol(fig,'Style','text','String','FMT-Firmware root','HorizontalAlignment','left', ...
    'Units','normalized','Position',[0.035 0.34 0.16 0.035]);
firmwareEdit = uicontrol(fig,'Style','edit','String',settings.firmware, ...
    'HorizontalAlignment','left','Units','normalized','Position',[0.20 0.34 0.21 0.04],'Enable','off');
uicontrol(fig,'Style','pushbutton','String','Browse...','Units','normalized', ...
    'Position',[0.415 0.34 0.065 0.04], ...
    'Enable','off','Callback',@browseFirmware);
targetLabel = uicontrol(fig,'Style','text','String','BSP Target folder', ...
    'HorizontalAlignment','left','Units','normalized','Position',[0.035 0.28 0.16 0.035], ...
    'Enable','off');
targetEdit = uicontrol(fig,'Style','edit','String',settings.target, ...
    'HorizontalAlignment','left','Units','normalized','Position',[0.20 0.28 0.28 0.04], ...
    'Enable','off');
uicontrol(fig,'Style','text','String','Relative to firmware root; must contain SConstruct', ...
    'HorizontalAlignment','left','Units','normalized','Position',[0.20 0.25 0.28 0.025], ...
    'Enable','off');
uicontrol(fig,'Style','text','String','SIM Mode','HorizontalAlignment','left', ...
    'Units','normalized','Position',[0.035 0.15 0.10 0.035],'Enable','off');
simEdit = uicontrol(fig,'Style','edit','String',settings.simMode,'HorizontalAlignment','left', ...
    'Units','normalized','Position',[0.14 0.15 0.10 0.04],'Enable','off');
uicontrol(fig,'Style','text','String','Parallel jobs','HorizontalAlignment','left', ...
    'Units','normalized','Position',[0.27 0.15 0.12 0.035],'Enable','off');
jobsEdit = uicontrol(fig,'Style','edit','String',settings.jobs,'HorizontalAlignment','left', ...
    'Units','normalized','Position',[0.39 0.15 0.09 0.04],'Enable','off');
compileCheck = uicontrol(fig,'Style','checkbox','String','Build firmware after copying', ...
    'Value',settings.compileEnabled,'Units','normalized','Position',[0.035 0.09 0.38 0.04], ...
    'Enable','off','Callback',@showCompile);
uicontrol(fig,'Style','text','String','Build output','FontWeight','bold', ...
    'HorizontalAlignment','left','Units','normalized','Position',[0.51 0.94 0.45 0.04]);
logBox = uicontrol(fig,'Style','listbox','String',{'Ready. Verify the resolved models before building.'}, ...
    'Units','normalized','Position',[0.51 0.07 0.46 0.86],'Max',2,'Min',0);
runButton = uicontrol(fig,'Style','pushbutton','String','Build', ...
    'FontWeight','bold','Units','normalized','Position',[0.27 0.025 0.10 0.045], ...
    'Callback',@runTask);
uicontrol(fig,'Style','pushbutton','String','Close','Units','normalized', ...
    'Position',[0.38 0.025 0.10 0.045], ...
    'Callback',@closeWindow);
if settings.copyEnabled, toggleDeploy(copyCheck,[]); end

    function toggleDeploy(src,~)
        enabled = onOff(get(src,'Value'));
        set(firmwareEdit,'Enable',enabled);
        browseButton = findobj(fig,'Style','pushbutton','String','Browse...');
        set(browseButton,'Enable',enabled);
        set(targetLabel,'Enable',enabled); set(targetEdit,'Enable',enabled);
        texts=findobj(fig,'Style','text');
        for q=1:numel(texts)
            if any(strcmp(get(texts(q),'String'),{'Relative to firmware root; must contain SConstruct', ...
                    'AIRFRAME (read-only, from MATLAB workspace)','SIM_Mode','Parallel jobs'}))
                set(texts(q),'Enable',enabled);
            end
        end
        set(airframeText,'Enable',enabled); set(simEdit,'Enable',enabled);
        set(jobsEdit,'Enable',enabled); set(compileCheck,'Enable',enabled);
        refreshAirframe([],[]);
    end
    function showCompile(src,~)
        % Compile is only meaningful when firmware synchronization is enabled.
        if nargin>0 && get(src,'Value'), refreshAirframe([],[]); end
    end
    function refreshAirframe(~,~)
        value=readWorkspaceValue('AIRFRAME');
        set(airframeText,'String',value);
    end
    function browseFirmware(~,~)
        selected=uigetdir(get(firmwareEdit,'String'),'Select FMT-Firmware root');
        if ~isequal(selected,0), set(firmwareEdit,'String',selected); end
    end
    function runTask(~,~)
        vehicle=readWorkspaceValue('VEHICLE');
        airframe=readWorkspaceValue('AIRFRAME');
        set(vehicleText,'String',vehicle);
        set(airframeText,'String',airframe);
        selected=[];
        for modelIndex=1:numel(models)
            if get(models(modelIndex).check,'Value'), selected(end+1)=modelIndex; end %#ok<AGROW>
        end
        if isempty(selected), errordlg('Select at least one model.','FMT Model'); return; end
        for q=selected(:)'
            if isempty(models(q).path) || ~exist(models(q).path,'file')
                errordlg(['Selected model is not on the current MATLAB path: ' models(q).name],'FMT Model'); return;
            end
        end
        doCopy=get(copyCheck,'Value')~=0;
        fwRoot=strtrim(get(firmwareEdit,'String'));
        doCompile=get(compileCheck,'Value')~=0;
        if doCopy && ~exist(fullfile(fwRoot,'src','model'),'dir')
            errordlg('Invalid FMT-Firmware path: src/model not found.','FMT Model'); return;
        end
        if doCopy
            for q=selected(:)'
                map=models(q).target;
                mappedDir=fullfile(fwRoot,'src','model',map{1},map{2},'lib');
                if ~exist(mappedDir,'dir')
                    errordlg(['No matching model directory in the firmware checkout: ' mappedDir], ...
                        'FMT Model'); return;
                end
            end
        end
        if doCompile
            target=strtrim(get(targetEdit,'String'));
            simMode=strtrim(get(simEdit,'String'));
            jobs=strtrim(get(jobsEdit,'String'));
            if isempty(regexp(target,'^[A-Za-z0-9_./\\-]+$','once')) || ...
                    isempty(regexp(simMode,'^[A-Za-z0-9_-]+$','once')) || ...
                    isempty(regexp(jobs,'^[1-9][0-9]*$','once')) || strcmp(airframe,'Not available')
                errordlg('Target, SIM_Mode, job count, or AIRFRAME is invalid.','FMT Model'); return;
            end
            if isempty(regexp(vehicle,'^[A-Za-z][A-Za-z0-9_-]*$','once'))
                errordlg('Could not read a valid VEHICLE variable from the MATLAB workspace.','FMT Model'); return;
            end
            targetPath=fullfile(fwRoot,strrep(target,'/',filesep));
            firmwareCanonical=char(java.io.File(fwRoot).getCanonicalPath());
            targetCanonical=char(java.io.File(targetPath).getCanonicalPath());
            if ispc
                targetIsInsideFirmware=strncmpi(targetCanonical, ...
                    [firmwareCanonical filesep],length(firmwareCanonical)+1);
            else
                targetIsInsideFirmware=strncmp(targetCanonical, ...
                    [firmwareCanonical filesep],length(firmwareCanonical)+1);
            end
            if ~targetIsInsideFirmware
                errordlg('Target must be a relative path inside the FMT-Firmware root.','FMT Model'); return;
            end
            if ~exist(fullfile(targetPath,'SConstruct'),'file')
                errordlg('SConstruct was not found in the selected target directory.','FMT Model'); return;
            end
        end
        set(runButton,'Enable','off'); drawnow;
        cleanup=onCleanup(@()set(runButton,'Enable','on')); %#ok<NASGU>
        try
            buildRoot=fullfile(root,'build');
            if ~exist(buildRoot,'dir'), mkdir(buildRoot); end
            set_param(0,'CodeGenFolder',buildRoot); set_param(0,'CacheFolder',buildRoot);
            for q=selected(:)'
                appendLog(['Building ' models(q).name ': ' models(q).path]); drawnow;
                [~,mdl]=fileparts(models(q).path);
                if ~bdIsLoaded(mdl), load_system(models(q).path); end
                slbuild(mdl);
                appendLog([models(q).name ' code generation complete.']); drawnow;
                if doCopy
                    source=findCodeDirectory(buildRoot,mdl);
                    if isempty(source), error('Generated code directory not found for %s.',mdl); end
                    map=models(q).target;
                    destination=fullfile(fwRoot,'src','model',map{1},map{2},'lib');
                    copyGeneratedCode(source,destination);
                    appendLog(['Copied to ' destination]); drawnow;
                end
            end
            if doCompile
                args={['-j' jobs],['--vehicle=' vehicle],['--airframe=' airframe],['--sim=' simMode]};
                appendLog(['Running scons ' strjoin(args,' ') ' in ' targetPath]); drawnow;
                runScons(targetPath,args,@appendLog);
                appendLog('SCons build succeeded.');
            end
            appendLog('All selected tasks completed.');
            msgbox('Selected tasks completed successfully.','FMT Model');
        catch err
            appendLog(['Failed: ' err.message]);
            errordlg(err.message,'FMT Model execution failed');
        end
    end
    function appendLog(message)
        old=get(logBox,'String'); if ischar(old), old={old}; end
        old{end+1}=message; set(logBox,'String',old,'Value',numel(old)); drawnow;
    end
    function closeWindow(~,~)
        saveSettings(root,get(firmwareEdit,'String'),get(targetEdit,'String'), ...
            get(simEdit,'String'),get(jobsEdit,'String'),get(copyCheck,'Value'), ...
            get(compileCheck,'Value'));
        if ishghandle(fig), delete(fig); end
    end
end

function value=readWorkspaceValue(variableName)
value='Not available';
existsInBase=evalin('base',['exist(''' variableName ''',''var'')']);
if ~existsInBase, return; end
rawValue=evalin('base',variableName);
if ischar(rawValue)
    value=strtrim(rawValue);
elseif isnumeric(rawValue) && isscalar(rawValue)
    value=num2str(rawValue);
elseif isstring(rawValue) && isscalar(rawValue)
    value=char(rawValue);
end
if isempty(value), value='Not available'; end
end

function variant=inferVariant(modelPath,kind)
category=lower(kind);
if strcmpi(kind,'Controller'), category='control'; end
variant={category,['template_' lower(kind)]};
if isempty(modelPath), return; end
modelDirectory=fileparts(modelPath);
[categoryDirectory,variantName]=fileparts(modelDirectory);
[~,categoryName]=fileparts(categoryDirectory);
if strcmpi(categoryName,'Controller')
    category='control';
else
    category=lower(categoryName);
end
variantName=lower(regexprep(variantName,'[^A-Za-z0-9]+','_'));

% Firmware Plant paths use vehicle names for these two model folders.
if strcmpi(categoryName,'Plant')
    if strcmpi(variantName,'mc_plant'), variantName='multicopter'; end
    if strcmpi(variantName,'fw_plant'), variantName='fixwing'; end
end
variant={category,variantName};
end

function settings=loadSettings(root)
settings=struct('firmware','','target','target/cuav/v5_nano','simMode','None', ...
    'jobs','16','copyEnabled',0,'compileEnabled',0);
path=fullfile(root,'build','FMT_Model_CodeGen_Config.mat');
if exist(path,'file')
    try
        saved=load(path,'settings');
        if isfield(saved,'settings')
            fields=fieldnames(settings);
            for k=1:numel(fields)
                if isfield(saved.settings,fields{k}), settings.(fields{k})=saved.settings.(fields{k}); end
            end
        end
    catch
    end
end
if isempty(settings.firmware)
    candidate=fullfile(fileparts(root),'FMT-Firmware');
    if exist(fullfile(candidate,'src','model'),'dir'), settings.firmware=candidate; end
end
end

function saveSettings(root,firmware,target,simMode,jobs,copyEnabled,compileEnabled)
settings=struct('firmware',firmware,'target',target,'simMode',simMode,'jobs',jobs, ...
    'copyEnabled',copyEnabled,'compileEnabled',compileEnabled);
try
    configDir=fullfile(root,'build');
    if ~exist(configDir,'dir'), mkdir(configDir); end
    save(fullfile(configDir,'FMT_Model_CodeGen_Config.mat'),'settings');
catch
    warning('FMT:CodeGen:SettingsSave','Unable to save code generation settings.');
end
end

function value=onOff(condition)
if condition, value='on'; else, value='off'; end
end

function codeDir=findCodeDirectory(buildRoot,modelName)
codeDir=''; candidates=dir(fullfile(buildRoot,[modelName '*_rtw']));
for k=1:numel(candidates)
    if candidates(k).isdir && ~isempty(regexp(candidates(k).name,'_(ert|grt|autosar)_rtw$','once'))
        codeDir=fullfile(buildRoot,candidates(k).name); return;
    end
end
end

function copyGeneratedCode(source,destination)
files=[dir(fullfile(source,'*.c'));dir(fullfile(source,'*.h')); ...
    dir(fullfile(source,'*.cpp'));dir(fullfile(source,'*.hpp'))];
if isempty(files), error('No generated C/C++ source or header files in %s',source); end
if ~exist(destination,'dir'), mkdir(destination); end
for k=1:numel(files)
    copyfile(fullfile(source,files(k).name),fullfile(destination,files(k).name),'f');
end
end

function runScons(workingDirectory,args,logFunction)
% Use cmd.exe for Windows batch launchers; use SCons directly on Unix systems.
if ispc
    commandParts={'cmd.exe','/d','/c',['scons ' strjoin(args,' ')]};
else
    commandParts=[{'scons'},args];
end
command=javaArray('java.lang.String',numel(commandParts));
for k=1:numel(commandParts), command(k)=java.lang.String(commandParts{k}); end
builder=java.lang.ProcessBuilder(command);
builder.directory(java.io.File(workingDirectory)); builder.redirectErrorStream(true);
try
    process=builder.start();
catch err
    error('Could not launch scons. Ensure SCons is installed and on PATH. %s',err.message);
end
reader=java.io.BufferedReader(java.io.InputStreamReader(process.getInputStream()));
while true
    line=reader.readLine();
    if isempty(line), break; end
    logFunction(char(line));
end
status=process.waitFor();
if status~=0, error('SCons exited with code %d.',status); end
end
