function varargout = MarmoView(varargin)
% MARMOVIEW M-file for MarmoView.fig
%
%      THIS IS MARMOVIEW VERSION 1B, THIS CORRESPONDS TO THE VERSION TEXT
%      IN THE MarmoView.fig FILE
%
%      MARMOVIEW, by itself, creates a new MARMOVIEW or raises the existing
%      singleton*.
%
%      H = MARMOVIEW returns the handle to a new MARMOVIEW or the handle to
%      the existing singleton*.
%
%      MARMOVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MARMOVIEW.M with the given input arguments.
%
%      MARMOVIEW('Property','Value',...) creates a new MARMOVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MarmoView_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MarmoView_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MarmoView

% Last Modified by GUIDE v2.5 20-Dec-2016 20:55:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MarmoView_OpeningFcn, ...
                   'gui_OutputFcn',  @MarmoView_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before MarmoView is made visible.
function MarmoView_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MarmoView (see VARARGIN)
% Choose default command line output for MarmoView
handles.output = hObject;

%%%%% IMPORTANT GROUNDWORK FOR THE GUI IS PLACED HERE %%%%%%%%%%%%%%%%%%%%%

% GET SOME CRUCIAL DIRECTORIES -- THESE DIRECTORIES MUST EXIST!!
% Present working directory, location of all GUIs
handles.taskPath = sprintf('%s/',pwd);
handles.settingsPath= sprintf('%s/',pwd);

% CREATE THE STRUCTURES USED BY ALL PROTOCOLS
handles.p = pldaps; % pldaps object
handles.S = struct; % Settings for the protocol, NOT changed while running
handles.A = struct;

% Add in the plot handles to A in case handles isn't available
% e.g. while running protocols)
handles.A.EyeTrace = handles.EyeTrace;
handles.A.DataPlot1 = handles.DataPlot1;
handles.A.DataPlot2 = handles.DataPlot2;
handles.A.DataPlot3 = handles.DataPlot3;

S=struct;
% (re-)position the gui window...
%
% persistent settings are saved in handles.calibFile
if exist('settings','var') && isstruct(settings)
  if isfield(settings,'guiLocation'),
     S.guiLocation = settings.guiLocation; % <-- overrides rig settings!?
  end
end

if isfield(S,'guiLocation'),
  set(hObject,'Position',S.guiLocation);
end
  

% WRITE THE CALIBRATION DATA INTO THE EYE TRACKER PANEL AND GET THE SIZES 
% OF GAIN AND SHIFT CONTROLS FOR CALIBRATING EYE POSITION
% FOR UPDATE EYE TEXT TO RUN PROPPERLY, CALBIRATION MUST ALREADY BE IN
% STRUCTURE 'A'
% UpdateEyeText(handles);

% THESE VARIABLES CONTROL THE RUN LOOP
handles.runTask = false;
handles.stopTask = false;

% SET ACCESS TO GUI CONTROLS
set(handles.Initialize,'Enable','Off');
set(handles.ClearSettings,'Enable','Off');
set(handles.RunTrial,'Enable','Off');
set(handles.PauseTrial,'Enable','Off');
set(handles.FlipFrame,'Enable','Off');
set(handles.ShowBackground,'Enable','Off');
set(handles.ShowBlack,'Enable','Off');
set(handles.ParameterPanel,'Visible','Off');
set(handles.EyeTrackerPanel,'Visible','Off');
set(handles.OutputPanel,'Visible','Off');
set(handles.TaskPerformancePanel,'Visible','Off');
% Initialize is only available if the settings file exists
handles.settingsFile = get(handles.SettingsFile,'String');
if ~exist([handles.settingsPath handles.settingsFile],'file')
    set(handles.Initialize,'Enable','off');
    tstring = 'Please select a settings file...';
else
    set(handles.Initialize,'Enable','on');
    tstring = 'Ready to initialize protocol...';
end
% Update GUI status
set(handles.StatusText,'String',tstring);
% For the protocol title, note that no protocol has been loaded yet
set(handles.ProtocolTitle,'String','No protocol is loaded.');
% The task light is a neutral gray when no protocol is loaded
ChangeLight(handles.TaskLight,[.5 .5 .5]);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = MarmoView_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%% SETTINGS PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHOOSE A SETTINGS FILE
function ChooseSettings_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% Have user select the file
[handles.settingsFile, handles.settingsPath] = uigetfile(handles.taskPath);
% Show the selected outputfile
if handles.settingsFile ~= 0
    set(handles.SettingsFile,'String',handles.settingsFile);
else
% Or no outputfile if cancelled selection
    set(handles.SettingsFile,'String','0');
    handles.settingsFile = '0';
end

% If file exists, then we can get the protocol initialized
if exist(fullfile(handles.settingsPath,handles.settingsFile),'file');
    set(handles.Initialize,'Enable','on');
    tstring = 'Ready to initialize protocol...';
else
    set(handles.Initialize,'Enable','off');
    tstring = 'Please select a settings file...';
end
% Regardless, update status
set(handles.StatusText,'String',tstring);

% Update handles structure
guidata(hObject, handles);


% INITIALIZE A PROTOCOL FROM THE SETTINGS SELECTED
function Initialize_Callback(hObject, eventdata, handles)
% PREPARE THE GUI FOR INITIALIZING THE PROTOCOL
% Update GUI status
set(handles.StatusText,'String','Initializing...');
% The task light is blue only during protocol initialization
ChangeLight(handles.TaskLight,[.2 .2 1]);

% TURN OFF BUTTONS TO PREVENT FIDDLING DURING INITIALIZATION
set(handles.ChooseSettings,'Enable','Off');
set(handles.Initialize,'Enable','Off');
% Effect these changes on the GUI immediately
guidata(hObject, handles); drawnow;

% GET PROTOCOL SETTINGS
addpath(handles.settingsPath)
fname=handles.settingsFile(1:end-2);
[handles.p, handles.S]=eval(fname);


% SHOW THE PROTOCOL TITLE
set(handles.ProtocolTitle,'String',handles.S.protocolTitle);

% INITIALIZE THE PROTOCOL
handles.p.run

% % SET UP THE OUTPUT PANEL
% % Get the output file name components
% handles.outputPrefix = handles.S.protocol;
% set(handles.OutputPrefixEdit,'String',handles.outputPrefix);
% handles.outputSubject = handles.S.subject;
% set(handles.OutputSubjectEdit,'String',handles.outputSubject);
% handles.outputDate = datestr(now,'ddmmyy');
% set(handles.OutputDateEdit,'String',handles.outputDate);
% i = 0; handles.outputSuffix = '00';
% % Generate the file name
% handles.A.outputFile = strcat(handles.outputPrefix,'_',handles.outputSubject,...
%     '_',handles.outputDate,'_',handles.outputSuffix,'.mat');
% % If the file name already exists, iterate the suffix to a nonexistant file
% while exist([handles.outputPath handles.A.outputFile],'file')
%     i = i+1; handles.outputSuffix = num2str(i,'%.2d');
%     handles.A.outputFile = strcat(handles.outputPrefix,'_',handles.outputSubject,...
%         '_',handles.outputDate,'_',handles.outputSuffix,'.mat');
% end
% 
% % Show the file name on the GUI
% set(handles.OutputSuffixEdit,'String',handles.outputSuffix);
% set(handles.OutputFile,'String',handles.A.outputFile);
% % Note that a new output file is being used
% handles.A.newOutput = 1;
% 
% % SET UP THE PARAMETERS PANEL
% % Trial counting section of the parameters
% handles.A.j = 1; handles.A.finish = handles.S.finish;
% set(handles.TrialCountText,'String',['Trial ' num2str(handles.A.j-1)]);
% set(handles.TrialMaxText,'String',num2str(handles.A.finish));
% set(handles.TrialMaxEdit,'String','');
% 
% % Get strings for the parameters list
% handles.pNames = fieldnames(handles.P);         % pNames are the actual parameter names
% handles.pList = cell(size(handles.pNames,1),1); % pList is the list of parameter names with values
% for i = 1:size(handles.pNames,1);
%     pName = handles.pNames{i};
%     tName = sprintf('%s = %2g',pName,handles.P.(pName));
%     handles.pList{i,1} = tName;
% end
% set(handles.Parameters,'String',handles.pList);
% % For the highlighted parameter, provide a description and editable value
% set(handles.Parameters,'Value',1);
% set(handles.ParameterText,'String',handles.S.(handles.pNames{1}));
% set(handles.ParameterEdit,'String',num2str(handles.P.(handles.pNames{1})));
% 
% % UPDATE ACCESS TO CONTROLS
set(handles.RunTrial,'Enable','On');
set(handles.FlipFrame,'Enable','On');
set(handles.ShowBackground,'Enable','On');
set(handles.ShowBlack,'Enable','On');
set(handles.ClearSettings,'Enable','On');
set(handles.ParameterPanel,'Visible','On');
set(handles.EyeTrackerPanel,'Visible','On');
set(handles.OutputPanel,'Visible','On');
set(handles.TaskPerformancePanel,'Visible','On')
% 
% % UPDATE GUI STATUS
% set(handles.StatusText,'String','Protocol is ready to run trials.');
% % Now that a protocol is loaded (but not running), task light is red
% ChangeLight(handles.TaskLight,[1 0 0]);
% 
% % FINALLY, RESET THE JUICE COUNTER WHENEVER A NEW PROTOCOL IS LOADED
% handles.A.juiceCounter = 0;

% UPDATE HANDLES STRUCTURE
guidata(hObject,handles);


% UNLOAD CURRENT PROTOCOL, RESET GUI TO INITIAL STATE
function ClearSettings_Callback(hObject, eventdata, handles)

% DISABLE RUNNING THINGS WHILE CLEARING
set(handles.RunTrial,'Enable','Off');
set(handles.FlipFrame,'Enable','Off');
set(handles.ShowBackground,'Enable','Off');
set(handles.ShowBlack,'Enable','On');
set(handles.ClearSettings,'Enable','Off');
set(handles.OutputPanel,'Visible','Off');
set(handles.ParameterPanel,'Visible','Off');
set(handles.EyeTrackerPanel,'Visible','Off');
set(handles.OutputPanel,'Visible','Off');
set(handles.TaskPerformancePanel,'Visible','Off');

% Clear plots
plot(handles.DataPlot1,0,0,'+k');
plot(handles.DataPlot2,0,0,'+k');
plot(handles.DataPlot3,0,0,'+k');
% Eye trace needs to be treated differently to maintain important
% properties
plot(handles.EyeTrace,0,0,'+k');
set(handles.EyeTrace,'ButtonDownFcn',@(hObject,eventdata)MarmoView('EyeTrace_ButtonDownFcn',hObject,eventdata,handles));
set(handles.EyeTrace,'UserData',15); % 15 degrees of visual arc is default

% Close all screens from ptb
sca;

%%% SC: eye posn data
if handles.S.viewpoint
  % tell ViewPoint to close the eye posn data file
  vpx_SendCommandString('dataFile_Close');
end
%%%

% Save the eye calibration values at closing time to the MarmoViewLastCalib
c = handles.A.c;
dx = handles.A.dx;
dy = handles.A.dy;
% save([handles.supportPath 'MarmoViewLastCalib.mat'],'c','dx','dy');
% Create a structure for A that maintains only basic values required
% outside the protocol
% handles.C.c = c; handles.C.dx = dx; handles.C.dy = dy;
% A = handles.C;
A = struct('c',c,'dx',dx,'dy',dy); % preserve eye calibration settings...
% A.pump = handles.A.pump;
A.EyeTrace = handles.EyeTrace; % HACK! these get added to A so they are available in the endCmd function... nasty!
A.DataPlot1 = handles.DataPlot1;
A.DataPlot2 = handles.DataPlot2;
A.DataPlot3 = handles.DataPlot3;

% Reset structures
handles.A = A;
% handles.S = MarmoViewRigSettings;
handles.P = struct;
handles.D = struct;
% If juicer delivery volume was changed during the previous protocol,
% return it to default. Also add the juice counter for the juice button.
% fprintf(handles.A.pump,['0 VOL ' num2str(handles.S.pumpDefVol)]);
% handles.reward.volume = handles.S.pumpDefVol; % milliliters
handles.A.juiceVolume = handles.reward.volume;
handles.A.juiceCounter = 0;
% set(handles.JuiceVolumeText,'String',[num2str(1000*handles.S.pumpDefVol) ' ul']);
set(handles.JuiceVolumeText,'String',sprintf('%3i ul',handles.A.juiceVolume*1e3));

% RE-ENABLE CONTROLS
set(handles.ChooseSettings,'Enable','On');
% Initialize is only available if the settings file exists
handles.settingsFile = get(handles.SettingsFile,'String');
if ~exist([handles.settingsPath handles.settingsFile],'file')
    set(handles.Initialize,'Enable','off');
    tstring = 'Please select a settings file...';
else
    set(handles.Initialize,'Enable','on');
    tstring = 'Ready to initialize protocol...';
end
% Update GUI status
set(handles.StatusText,'String',tstring);
% For the protocol title, note that no protocol is now loaded
set(handles.ProtocolTitle,'String','No protocol is loaded.');
% The task light is a neutral gray when no protocol is loaded
ChangeLight(handles.TaskLight,[.5 .5 .5]);

% Update handles structure
guidata(hObject, handles);



%%%%% TRIAL CONTROL PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RunTrial_Callback(hObject, eventdata, handles)
% SET THE TASK TO RUN
handles.runTask = true;

% SET TASK LIGHT TO GREEN
ChangeLight(handles.TaskLight,[0 1 0]);

% UPDATE ACCESS TO CONTROLS
set(handles.RunTrial,'Enable','Off');
set(handles.FlipFrame,'Enable','Off');
set(handles.ShowBackground,'Enable','Off');
set(handles.ShowBlack,'Enable','Off');
set(handles.CloseGui,'Enable','Off');
set(handles.ClearSettings,'Enable','Off')
set(handles.PauseTrial,'Enable','On');
set(handles.CenterEye,'Enable','On');
set(handles.OutputPrefixEdit,'Enable','Off');
set(handles.OutputSubjectEdit,'Enable','Off');
set(handles.OutputDateEdit,'Enable','Off');
set(handles.OutputSuffixEdit,'Enable','Off');

% UPDATE GUI STATUS
set(handles.StatusText,'String','Protocol trials are running.');

% RESET THE JUICER COUNTER BEFORE ENTERING THE RUN LOOP
handles.A.juiceCounter = 0;
% UPDATE THE HANDLES 
guidata(hObject,handles); drawnow;

% MOVE TASK RELATED STRUCTURES OUT OF HANDLES FOR THE RUN LOOP -- this way
% if a callback interrupts the run task function, we can update any changes
% the interrupting callback makes to handles without affecting those task
% related structures. E.g. we can run the task using parameters as they 
% were at the start of the trial, while getting ready to cue any changes 
% the user made on the next trial.
A = handles.A;
S = handles.S;
P = handles.P;
D = handles.D;

%%% SC: eye posn data
if S.viewpoint
  % tell ViewPoint to (re-)start recording of eye posn data
  vpx_SendCommandString('dataFile_Pause No');
end
%%%


% RUN TRIALS
while handles.runTask && A.j <= A.finish
    
    % 'pause', 'drawnow', 'figure', 'getframe', or 'waitfor' will allow
    % other callbacks to interrupt this run task callback -- be aware that
    % if handles aren't properly managed then changes either in the run
    % loop or in other parts of the GUI may be out-of-sync. Nothing changes
    % to GUI-wide handles until the local callback puts them there. If
    % other callbacks change handles, and they are not brought into this
    % callback, then those changes are lost when this run loop updates that
    % handles. This concept is explained further right below during the 
    % nextCmd handles management.
    
    % EXECUTE THE NEXT TRIAL COMMAND
    eval(handles.nextCmd);
    % UPDATE IN CASE JUICE VOLUME WAS CHANGED USING A PARAMETER
    if handles.A.juiceVolume ~= A.juiceVolume
%         fprintf(A.pump,['0 VOL ' num2str(A.juiceVolume/1000)]);
        handles.reward.volume = A.juiceVolume; % A.juiceVolume is in milliliters
%         set(handles.JuiceVolumeText,'String',[num2str(A.juiceVolume*1e3) ' ul']); % displayed in microliters!
        set(handles.JuiceVolumeText,'String',sprintf('%3i ul',A.juiceVolume*1e3));
        handles.A.juiceVolume = A.juiceVolume;
    end
    % UPDATE HANDLES FROM ANY CHANGES DURING NEXT TRIAL -- IF THIS ISN'T
    % DONE, THEN THE OTHER CALLBACKS WILL BE USING A DIFFERENT HANDLES
    % STRUCTURE THAN THIS LOOP IS
    guidata(hObject,handles);
    % ALLOW OTHER CALLBACKS INTO THE QUEUE AND UPDATE HANDLES -- 
    % HERE, HAVING UPDATED ANY RUN LOOP CHANGES TO HANDLES, WE LET OTHER
    % CALLBACKS DO THEIR THING. WE THEN GRAB THOSE HANDLES SO THE RUN LOOP
    % IS ON THE SAME PAGE. FORTUNATELY, IF A PARAMETER CHANGES IN HANDLES,
    % THAT WON'T AFFECT THE CURRENT TRIAL WHICH IS USING 'P', NOT handles.P
    pause(.001); handles = guidata(hObject);
    
    % EXECUTE THE RUN TRIAL COMMAND
    eval(handles.runCmd);
    % UPDATE HANDLES FROM ANY CHANGES DURING RUN TRIAL
    guidata(hObject,handles);
    % ALLOW OTHER CALLBACKS INTO THE QUEUE AND UPDATE HANDLES
    pause(.001); handles = guidata(hObject);
    
    % THE END OF THE TRIAL HAS A LOT OF THINGS TO CONSIDER, BUT THIS COULD
    % ALL BE PLACED IN THE END TRIAL COMMAND IF I TRUSTED THE USER TO NOT
    % ACCIDENTALLY LEAVE OUT ONE OF THESE IMPORTANT STEPS
    
    % PRE END COMMAND -- PLACE SOME UNIVERSAL THINGS TO HAVE IN THE DATA,
    % INTO THE DATA STRUCTURE
    D.P(A.j,1) = P; % THE TRIAL PARAMETERS
    D.juiceButtonCount(A.j,1) = handles.A.juiceCounter; % SUPPLEMENTARY JUICE DURING THE TRIAL
    D.juiceVolume(A.j,1) = A.juiceVolume; % THE VOLUME OF JUICE PULSES DURING THE TRIAL
    % NOW ANY PARAMETERS THE USER MAY HAVE CHANGED WHILE RUNNING THIS TRIAL
    % REPLACE 'P' FOR THE NEXT TRIAL. THIS IS DONE BEFORE THE END TRIAL
    % COMMAND, BECAUSE IT MAY VETO CHANGES IF APPLYING A TRIALS LIST
    P = handles.P;
    % EXECUTE THE END TRIAL COMMAND
    eval(handles.endCmd);
    % SAVE THE DATA
    cd(handles.outputPath);             % goto output directory
    save(A.outputFile,'S','D');         % save settings and data to output file
    cd(handles.taskPath);               % return to task directory
    % UPDATE TRIAL COUNT AND FINISH NUMBER
    A.j = A.j+1;
    set(handles.TrialCountText,'String',num2str(A.j-1));
    A.finish = handles.A.finish;
    set(handles.TrialMaxText,'String',num2str(A.finish));
    % UPDATE IN CASE JUICE VOLUME WAS CHANGED DURING END TRIAL
    if handles.A.juiceVolume ~= A.juiceVolume
%         fprintf(A.pump,['0 VOL ' num2str(A.juiceVolume/1000)]);
        handles.reward.volume = A.juiceVolume; % A.juiceVolume is in milliliters
%         set(handles.JuiceVolumeText,'String',[num2str(A.juiceVolume*1e3) ' ul']); % displayed in microliters!
        set(handles.JuiceVolumeText,'String',sprintf('%3i ul',A.juiceVolume*1e3));
        handles.A.juiceVolume = A.juiceVolume;
    end    
    % UPDATE THE TASK RELATED STRUCTURES IN CASE OF LEAVING THE RUN LOOP
    handles.A = A;
    handles.S = S;
    handles.P = P;
    handles.D = D;
    % UPDATE THE PARAMETER LIST TO SHOW THE NEXT TRIAL PARAMETERS
    for i = 1:size(handles.pNames,1);
        pName = handles.pNames{i};
        tName = sprintf('%s = %2g',pName,handles.P.(pName));
        handles.pList{i,1} = tName;
    end
    set(handles.Parameters,'String',handles.pList);
    
    % UPDATE THE HANDLES STRUCTURE FROM ALL OF THESE CHANGES
    guidata(hObject,handles);
    % ALLOW OTHER CALLBACKS INTO THE THE QUEUE. IF PARAMETERS ARE CHANGED
    % BY CHANCE THIS LATE IN THE LOOP, THEY WILL NOT BE CHANGED UNTIL
    % REACHING THE END OF THE NEXT TRIAL, BECAUSE P HAS ALREADY BEEN
    % ESTABLISHED FOR THE NEXT TRIAL. IF YOU EXIT THE LOOP, THOUGH, THEN P
    % WILL BE UPDATED BY ANY CHANGES TO THE HANDLES
    pause(.001); handles = guidata(hObject);
    
    % STOP RUN TASK IF SET TO DO SO
    if handles.stopTask
        handles.runTask = false;
    end
end

%%% SC: eye posn data
if S.viewpoint,
  % tell ViewPoint to pause recording of eye posn data
  vpx_SendCommandString('dataFile_Pause Yes');
end
%%%

% NO TASK RUNNING FLAGS SHOULD BE ON ANYMORE
handles.runTask = false;
handles.stopTask = false;

% UPDATE THE PARAMETERS LIST IN CASE OF ANY CHANGES MADE AFTER RUNNING THE
% END TRIAL COMMAND
for i = 1:size(handles.pNames,1);
    pName = handles.pNames{i};
    tName = sprintf('%s = %2g',pName,handles.P.(pName));
    handles.pList{i,1} = tName;
end
set(handles.Parameters,'String',handles.pList);

% UPDATE ACCESS TO CONTROLS
set(handles.RunTrial,'Enable','On');
set(handles.FlipFrame,'Enable','On');
set(handles.ShowBackground,'Enable','On');
set(handles.ShowBlack,'Enable','On');
set(handles.CloseGui,'Enable','On');
set(handles.ClearSettings,'Enable','On')
set(handles.PauseTrial,'Enable','Off');
set(handles.CenterEye,'Enable','Off');
set(handles.OutputPrefixEdit,'Enable','On');
set(handles.OutputSubjectEdit,'Enable','On');
set(handles.OutputDateEdit,'Enable','On');
set(handles.OutputSuffixEdit,'Enable','On');

% UPDATE GUI STATUS
set(handles.StatusText,'String','Protocol is ready to run trials.');
% SET TASK LIGHT TO RED
ChangeLight(handles.TaskLight,[1 0 0]);

% UPDATE HANDLES STRUCTURE
guidata(hObject,handles);


% STOP THE TRIAL LOOP ONCE THE CURRENT TRIAL HAS COMPLETED
function PauseTrial_Callback(hObject, eventdata, handles)
% Pause button can also act as an unpause button
switch handles.stopTask
    case 0
        handles.stopTask = true;
        % SET TASK LIGHT TO ORANGE
        ChangeLight(handles.TaskLight,[.9 .7 .2]);
    case 1
        handles.stopTask = false;
        % SET TASK LIGHT BACK TO GREEN
        ChangeLight(handles.TaskLight,[0 1 0]);
end

% UPDATE HANDLES STRUCTURE
guidata(hObject,handles);


% GIVE A JUICE REWARD
function GiveJuice_Callback(hObject, eventdata, handles)
% fprintf(handles.A.pump,'0 RUN');
handles.reward.deliver();
handles.A.juiceCounter = handles.A.juiceCounter + 1;
guidata(hObject,handles);


% CHANGE THE SIZE OF THE JUICE REWARD TO BE DELIVERED
function JuiceVolumeEdit_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
function JuiceVolumeEdit_Callback(hObject, eventdata, handles)
vol = get(hObject,'String'); % volume is entered in microliters!!
volML = str2double(vol)/1e3; % milliliters
% fprintf(handles.A.pump,['0 VOL ' volML]);
handles.reward.volume = volML; % milliliters
set(handles.JuiceVolumeText,'String',[vol ' ul']); % displayed in microliters!!
set(hObject,'String',''); % why?
handles.A.juiceVolume = volML; % <-- A.juiceVolume should *always* be in milliliters!
guidata(hObject,handles);


% RESETS THE DISPLAY SCREEN IF IT WAS INTERUPTED (BY E.G. ALT-TAB)
function FlipFrame_Callback(hObject, eventdata, handles)
% If a bkgd parameter exists, flip frame with background color value
if isfield(handles.P,'bkgd')
    Screen('FillRect',handles.A.window,uint8(handles.P.bkgd));
end
Screen('Flip',handles.A.window);




%%%%% PARAMETER CONTROL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Parameters_CreateFcn(hObject, eventdata, handles)
function Parameters_Callback(hObject, eventdata, handles)
% Get the index of the selected field
i = get(hObject,'Value');
% Set the parameter text to a description of the parameter
set(handles.ParameterText,'String',handles.S.(handles.pNames{i}));
% Set the parameter edit to the current value of that parameter
set(handles.ParameterEdit,'String',num2str(handles.P.(handles.pNames{i})));
% Update handles structure
guidata(hObject,handles);

function ParameterEdit_CreateFcn(hObject, eventdata, handles)
function ParameterEdit_Callback(hObject, eventdata, handles)
% Get the new parameter value
pValue = str2double(get(hObject,'String'));
% Get the parameter name
pName = handles.pNames{get(handles.Parameters,'Value')};
% If the parameter value is a number
if ~isnan(pValue)
    % Change the parameter value
    handles.P.(pName) = pValue;
    % Update the parameter list immediately if not in the run loop
    if ~handles.runTask
        tName = sprintf('%s = %2g',pName,handles.P.(pName));
        handles.pList{get(handles.Parameters,'Value')} = tName;
        set(handles.Parameters,'String',handles.pList);
    end
else
    % Revert the parameter text to the previous value
    set(hObject,'String',num2str(handles.P.(pName)));
end

% Update handles structure
guidata(hObject,handles);

function TrialMaxEdit_CreateFcn(hObject, eventdata, handles)
function TrialMaxEdit_Callback(hObject, eventdata, handles)
% Get the new count
newFinal = round(str2double(get(hObject,'String')));
% Make sure the new final trial is a positive integer
if newFinal > 0
    % Update the final trial
    handles.A.finish = newFinal;
    % Set the count
    set(handles.TrialMaxText,'String',get(hObject,'String'));
end
% Clear the edit string
set(hObject,'String','');

% Update handles structure
guidata(hObject,handles);

%%%%% SHIFT EYE POSITION CALLBACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CenterEye_Callback(hObject, eventdata, handles)

[x,y] = vpx_GetGazePoint();

handles.A.c = [x,y];
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

function GainSize_CreateFcn(hObject, eventdata, handles)
function GainSize_Callback(hObject, eventdata, handles)
gainSize = str2double(get(hObject,'String'));
if ~isnan(gainSize)
    handles.gainSize = gainSize;
    guidata(hObject,handles);
else
    set(handles.GainSize,'String',num2str(handles.gainSize));
end

function GainUpX_Callback(hObject, eventdata, handles)
% Note we divide by dx, so reducing dx increases gain
handles.A.dx = (1-handles.gainSize)*handles.A.dx;
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

function GainDownX_Callback(hObject, eventdata, handles)
handles.A.dx = (1+handles.gainSize)*handles.A.dx;
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

function GainUpY_Callback(hObject, eventdata, handles)
handles.A.dy = (1-handles.gainSize)*handles.A.dy;
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

function GainDownY_Callback(hObject, eventdata, handles)
handles.A.dy = (1+handles.gainSize)*handles.A.dy;
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);


function ShiftSize_CreateFcn(hObject, eventdata, handles)
function ShiftSize_Callback(hObject, eventdata, handles)
shiftSize = str2double(get(hObject,'String'));
if ~isnan(shiftSize)
    handles.shiftSize = shiftSize;
    guidata(hObject,handles);
else
    set(handles.ShiftSize,'String',num2str(handles.shiftSize));
end

function ShiftLeft_Callback(hObject, eventdata, handles)
% handles.A.c(1) = handles.A.c(1) + ...
%     handles.shiftSize*handles.A.dx*handles.S.pixPerDeg;
handles.A.c(1) = handles.A.c(1) + ...
    handles.shiftSize*handles.A.dx;
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

function ShiftRight_Callback(hObject, eventdata, handles)
% handles.A.c(1) = handles.A.c(1) - ...
%     handles.shiftSize*handles.A.dx*handles.S.pixPerDeg;
handles.A.c(1) = handles.A.c(1) - ...
    handles.shiftSize*handles.A.dx;
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

function ShiftDown_Callback(hObject, eventdata, handles)
% handles.A.c(2) = handles.A.c(2) + ...
%     handles.shiftSize*handles.A.dy*handles.S.pixPerDeg;
handles.A.c(2) = handles.A.c(2) - ...
    handles.shiftSize*handles.A.dy;
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

function ShiftUp_Callback(hObject, eventdata, handles)
% handles.A.c(2) = handles.A.c(2) - ...
%     handles.shiftSize*handles.A.dy*handles.S.pixPerDeg;
handles.A.c(2) = handles.A.c(2) + ...
    handles.shiftSize*handles.A.dy;
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

function ResetCalibration_Callback(hObject, eventdata, handles)
handles.A.dx = handles.C.dx;
handles.A.dy = handles.C.dy;
handles.A.c = handles.C.c;
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

%%%%% OUTPUT PANEL CALLBACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OutputPrefixEdit_CreateFcn(hObject, eventdata, handles)
function OutputPrefixEdit_Callback(hObject, eventdata, handles)
handles.outputPrefix = get(hObject,'String');
handles = UpdateOutputFilename(handles);
guidata(hObject,handles);

function OutputSubjectEdit_CreateFcn(hObject, eventdata, handles)
function OutputSubjectEdit_Callback(hObject, eventdata, handles)
handles.outputSubject = get(hObject,'String');
handles = UpdateOutputFilename(handles);
guidata(hObject,handles);

function OutputDateEdit_CreateFcn(hObject, eventdata, handles)
function OutputDateEdit_Callback(hObject, eventdata, handles)
handles.outputDate = get(hObject,'String');
handles = UpdateOutputFilename(handles);
guidata(hObject,handles);

function OutputSuffixEdit_CreateFcn(hObject, eventdata, handles)
function OutputSuffixEdit_Callback(hObject, eventdata, handles)
handles.outputSuffix = get(hObject,'String');
handles = UpdateOutputFilename(handles);
guidata(hObject,handles);

%%%%% CLOSE THE GUI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CloseGui_Callback(hObject, eventdata, handles)
% close the gui window
close(handles.gui); % see gui_CloseRequestFcn()

%%%%% AUXILLIARY FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangeLight(h,col)
% THIS FUNCTION CHANGES THE TASK LIGHT
scatter(h,.5,.5,600,'o','MarkerEdgeColor','k','MarkerFaceColor',col);
axis(h,[0 1 0 1]); bkgd = [.931 .931 .931];
set(h,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);

% THIS FUNCTION UPDATES THE RAW EYE CALIBRATION NUMBERS IN THE GUI
function UpdateEyeText(h)
set(h.CenterText,'String',sprintf('[%.2g %.2g]',h.A.c(1),h.A.c(2)));
% dx = 10000*h.A.dx; dy = 10000*h.A.dy; % A LARGE MAGNIFICATION IS USED TO EFFICIENTLY DISPLAY 2 DIGITS
dx = h.A.dx; dy = h.A.dy;
set(h.GainText,'String',sprintf('[%.2g %.2g]',dx,dy));

% THIS FUNCTION UPDATES PLOTS OF THE EYE TRACE
function UpdateEyePlot(handles)
if ~handles.runTask && handles.A.j > 1   % At least 1 trial must be complete in order to plot the trace
    P = handles.D.P(handles.A.j-1); eyeData = handles.D.eyeData{handles.A.j-1}; %#ok<NASGU>
    eval(handles.plotCmd);  % Suppressing editor catches because plotCmd calls P and eyeData
end

function handles = UpdateOutputFilename(handles)
% Generate the file name
handles.A.outputFile = strcat(handles.outputPrefix,'_',handles.outputSubject,...
    '_',handles.outputDate,'_',handles.outputSuffix,'.mat');
set(handles.OutputFile,'String',handles.A.outputFile);
% If the file name already exists, provide a warning that data will be
% overwritten
if exist([handles.outputPath handles.A.outputFile],'file')
    w=warndlg('Data file alread exists, running the trial loop will overwrite.');
    set(w,'Position',[441.75 -183 270.75 75.75]);
end
% Note that a new output file is being used. For example, someone might
% want to be sure the trials list is started over if the output file name
% changes. Currently I don't have any protocols implementing this.
handles.A.newOutput = 1;

% --- Executes on mouse press over axes background ---- ZOOM FOR EYE TRACE
function EyeTrace_ButtonDownFcn(hObject, eventdata, handles)
% Get eyeTraceRadius
eyeTraceRadius = get(handles.EyeTrace,'UserData');
% This property should be 'normal' for left and 'alt' for right click
mouseButton = get(handles.gui,'SelectionType');
% Update the eyeTraceRadius depending on zoom in (left) or zoom out (right)
if strcmp(mouseButton,'normal')
    % Left click zooms in, only if outside of 5 degrees
    if eyeTraceRadius > 2.5
        set(handles.EyeTrace,'UserData',eyeTraceRadius-2.5);
    end
else
    if eyeTraceRadius < 30
        set(handles.EyeTrace,'UserData',eyeTraceRadius+2.5);
    end
end
etr = get(handles.EyeTrace,'UserData');
axis(handles.EyeTrace,[-etr etr -etr etr]);


% --- Executes when user attempts to close gui.
function gui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Close all screens from ptb
sca;

% Close the pump
% fclose(handles.A.pump); delete(handles.A.pump);
handles.reward.report()
delete(handles.reward); handles.reward = NaN;

filename = fullfile(handles.supportPath,handles.calibFile);

%%% SC: eye posn data
if handles.S.viewpoint,
  vpx_Unload(); % unloads the ViewPoint library

  % Save any changes to the calibration
  c = handles.A.c; %#ok<NASGU>    Supressing editor errors because theses
  dx = handles.A.dx; %#ok<NASGU>  variables are being saved
  dy = handles.A.dy; %#ok<NASGU>
  
  save(filename,'c','dx','dy');
end
%%%

% save gui window location... makes it persistent across sessions
guiLocation = get(hObject,'Position');
save(filename,'guiLocation','-append');

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on key press with focus on gui or any of its controls.
function gui_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to gui (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% intercept keyboard events here and look for shortcuts. Known keyboard
% shortcuts are:
%
%   ctrl-j = give juice
%   ctrl-r = run trial
%   ctrl-p = pause trial

if isempty(eventdata.Modifier),
  return
end

if ~any(cellfun(@(x) strcmp(x,'control'), eventdata.Modifier)),
  return
end

switch eventdata.Key,
  case 'j',
    % fake a call to GiveJuice callback()
    GiveJuice_Callback(handles.GiveJuice,[],handles);
    handles.reward.report()
  case 'r',
    % fake a call to RunTrial_callback()
    if strcmp(get(handles.RunTrial,'Enable'),'on'),
      RunTrial_Callback(handles.RunTrial,[],handles);
    end
  case 'p',
    % fake a call to PauseTrial_callback()
    if strcmp(get(handles.PauseTrial,'Enable'),'on'),
      PauseTrial_Callback(handles.RunTrial,[],handles);
    end
end


% --- Executes on button press in ShowBackground.
function ShowBackground_Callback(hObject, eventdata, handles)
% hObject    handle to ShowBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  %******* go to a defined directory, select an .jpg file at random,
  %******* and display it on the screen
  flist = dir('Backgrounds\*.jpg');
  if (~isempty(flist))
    fimo = 1 + floor( (rand * 0.99) * size(flist,1) );
    fname = flist(fimo).name;  % name of an image
    imo = imread(sprintf('Backgrounds\\%s',fname));
    %******* show gray background
    % if isfield(handles.P,'bkgd')
    %   Screen('FillRect',handles.A.window,uint8(handles.P.bkgd));
    % end
    %******* insert image in middle texture
    ImoScreen = Screen('MakeTexture',handles.A.window,imo);
    ImoRect = [0 0 size(imo,2) size(imo,1)];
    %***************
    Screen('DrawTexture',handles.A.window,ImoScreen,ImoRect,handles.S.screenRect);
    %**************************************
    Screen('Flip',handles.A.window);
  end


% --- Executes on button press in ShowBlack.
function ShowBlack_Callback(hObject, eventdata, handles)
% hObject    handle to ShowBlack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If a bkgd parameter exists, flip frame with background color value
Screen('FillRect',handles.A.window,uint8(0));
Screen('Flip',handles.A.window);

