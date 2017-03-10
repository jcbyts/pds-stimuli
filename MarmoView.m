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

% Last Modified by GUIDE v2.5 19-Jan-2017 12:24:46

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


% ------------------------------------------------------------------------
% --- OPENING AND OUTPUT FUNCTIONS ---------------------------------------

% --- Executes just before MarmoView is made visible.
function MarmoView_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MarmoView (see VARARGIN)
% Choose default command line output for MarmoView
handles.output = hObject;
if nargin>3 && varargin{1}
    return
end

% GET SOME CRUCIAL DIRECTORIES -- THESE DIRECTORIES MUST EXIST!!
% Present working directory, location of all GUIs
mprefs=getpref('marmoview');
if ~isempty(mprefs) && isfield(mprefs, 'taskPath')
    handles.taskPath=mprefs.taskPath;
else
    handles.taskPath = sprintf('%s/',pwd);
end
handles.settingsPath= sprintf('%s/',pwd);

% CREATE THE STRUCTURES USED BY ALL PROTOCOLS
handles.p = pldaps; % pldaps object
handles.S = struct; % Settings for the protocol, NOT changed while running
handles.A = struct; % plot

% Add in the plot handles to A in case handles isn't available
% e.g. while running protocols)
handles.A.EyeTrace  = handles.EyeTrace;
handles.A.DataPlot1 = handles.DataPlot1;
handles.A.DataPlot2 = handles.DataPlot2;
handles.A.DataPlot3 = handles.DataPlot3;

handles.A.hplot=plot(handles.EyeTrace,0,0,'.');
handles.EyeTrace.ButtonDownFcn = @(hObject,eventdata)MarmoView('EyeTrace_ButtonDownFcn',hObject,eventdata,handles);
handles.EyeTrace.UserData=25;

handles.calibratePressed=false;
S=struct;

% (re-)position the gui window...
Settings=getpref('marmoview');
if isfield(Settings, 'gui')
    if isfield(Settings.gui, 'Location')
        S.guiLocation=Settings.gui.Location;
    end
end

if isfield(S,'guiLocation')
  set(hObject,'Position',S.guiLocation);
end

% THESE VARIABLES CONTROL THE RUN LOOP - % TODO: do they still?
handles.runTask = false;
handles.stopTask = false;

% TURN OFF GUI CONTROLS EXCEPT FOR PROTOCOL MANAGEMENT
handles.Initialize.Enable            = 'Off';
handles.ClearSettings.Enable         = 'Off';
handles.RunTrial.Enable              = 'Off';
handles.PauseTrial.Enable            = 'Off';
handles.FlipFrame.Enable             = 'Off';
handles.ShowBackground.Enable        = 'Off';
handles.ShowBlack.Enable             = 'Off';
handles.ParameterPanel.Visible       = 'Off';
handles.EyeTrackerPanel.Visible      = 'Off';
handles.OutputPanel.Visible          = 'Off';
handles.TaskPerformancePanel.Visible = 'Off';

% Initialize is only available if the settings file exists
handles.settingsFile = handles.SettingsFile.String;

if ~exist([handles.settingsPath handles.settingsFile],'file')
    handles.Initialize.Enable = 'off';
    tstring = 'Please select a settings file...';
else
    handles.Initialize.Enable = 'on';
    tstring = 'Ready to initialize protocol...';
end

% Update GUI status
handles.StatusText.String = tstring;
handles.ProtocolTitle.String = 'No protocol is loaded.';
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


% ------------------------------------------------------------------------
% --- SETTINGS PANEL FUNCTIONS -------------------------------------------

% --- CHOOSE A SETTINGS FILE
function ChooseSettings_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% Have user select the file
[handles.settingsFile, handles.settingsPath] = uigetfile(handles.taskPath);
% Show the selected outputfile
if handles.settingsFile ~= 0
    handles.SettingsFile.String = handles.settingsFile;
else
% Or no outputfile if cancelled selection
    handles.SettingsFile.String = '0';
    handles.settingsFile = '0';
end

% If file exists, then we can get the protocol initialized
if exist(fullfile(handles.settingsPath,handles.settingsFile),'file')
    handles.Initialize.Enable = 'on';
    tstring = 'Ready to initialize protocol...';
else
    handles.Initialize.Enable = 'off';
    tstring = 'Please select a settings file...';
end

% Update status
handles.StatusText.String = tstring;
guidata(hObject, handles);


% --- INITIALIZE A PROTOCOL FROM THE SELECTED SETTINGS
function Initialize_Callback(hObject, eventdata, handles)
% PREPARE THE GUI FOR INITIALIZING THE PROTOCOL

% Update GUI status
handles.StatusText.String = 'Initializing...';
ChangeLight(handles.TaskLight,[.2 .2 1]); % blue task light

% Turn off buttons during initialization
handles.ChooseSettings.Enable   = 'Off';
handles.Initialize.Enable       = 'Off';

setpref('marmoview', 'taskPath', handles.settingsPath)
% Effect these changes on the GUI immediately
guidata(hObject, handles); drawnow;

% Add Marmoview specific modules to PLDAPS settings struct
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.marmoview.stateFunction.name='marmoview.afterTrialFunction';
settingsStruct.marmoview.use=true;
settingsStruct.marmoview.stateFunction.acceptsLocationInput=true;
settingsStruct.marmoview.stateFunction.order=inf;
settingsStruct.marmoview.stateFunction.requestedStates.experimentPostOpenScreen=true;
settingsStruct.marmoview.stateFunction.requestedStates.trialSetup=true;
% settingsStruct.marmoview.stateFunction.requestedStates.frameUpdate=true;
settingsStruct.marmoview.stateFunction.requestedStates.trialCleanUpandSave=true;

% load PLDAPS opject
fname=handles.settingsFile(1:end-2);
[handles.p, handles.S]=eval([fname '(settingsStruct)']);

% Show protocol title in the GUI
handles.ProtocolTitle.String = handles.S.protocolTitle;

% Initialize the protocol
handles.RunTrial.Enable              = 'On';
handles.FlipFrame.Enable             = 'On';
handles.ShowBackground.Enable        = 'On';
handles.ShowBlack.Enable             = 'On';
handles.ClearSettings.Enable         = 'On';
handles.ParameterPanel.Visible       = 'On';
handles.EyeTrackerPanel.Visible      = 'On';
handles.OutputPanel.Visible          = 'On';
handles.TaskPerformancePanel.Visible = 'On';

% calibration options are not available until calibrate is pressed
handles.CTargFix.Enable         = 'Off';
handles.CTargVert.Enable        = 'Off';
handles.CTargHoriz.Enable       = 'Off';
handles.CTargGrid.Enable        = 'Off';
handles.CTargCorners.Enable     = 'Off';
handles.CTargRandom.Enable      = 'Off';
handles.CTargCornersDown.Enable = 'Off';
handles.calibratePressed=0;

% % UPDATE GUI STATUS
handles.StatusText.String = 'Protocol is ready to run trials.';
% % Now that a protocol is loaded (but not running), task light is red
ChangeLight(handles.TaskLight,[1 0 0]);

guidata(hObject, handles); drawnow;

handles.p.trial.pldaps.pause.type=2; % pauseLoop mode
handles.p.trial.pldaps.pause.preExperiment=1; % pause before experiment


% Show filename in the gui
handles.OutputFile.String=handles.p.trial.session.experimentFile;

% EYE CALIBRATION STUFF HERE
cm=getCalibrationPref(handles.p,1);
% marmoview specific preferences override pldaps
if handles.p.trial.eyelink.use && handles.p.trial.eyelink.useAsEyepos
    handles.p.trial.eyelink.useRawData=true;
    handles.p.trial.eyelink.calibration_matrix=[];
    for i = 1:2 % loop over eye index
        % get subject specific calibration matrix
        cm=getCalibrationPref(handles.p,1);
        handles.p.trial.eyelink.calibration_matrix(:,:,i) = cm';
    end
        
end

% this is temporary, need to query eye index to get the right calibration
% matrix
handles.A.cm=cm;
handles.shiftSize = .5;
handles.gainSize  = .01;



% % SET UP THE PARAMETERS PANEL
% % Trial counting section of the parameters
% handles.A.j = 1; handles.A.finish = handles.S.finish;

handles.TrialCountText.String = sprintf('Trial %d', handles.p.trial.pldaps.iTrial);
% set(handles.TrialMaxText,'String',num2str(handles.A.finish));
% set(handles.TrialMaxEdit,'String','');
% 
% % Get strings for the parameters list
handles.pNames = fieldnames(handles.S.paramValues);         % pNames are the actual parameter names
handles.pList = cell(size(handles.pNames,1),1); % pList is the list of parameter names with values
for i = 1:size(handles.pNames,1)
    pName = handles.pNames{i};
    tName = sprintf('%s = %2g',pName,handles.S.paramValues.(pName));
    handles.pList{i} = tName;
end

handles.Parameters.String       = handles.pList;
% % For the highlighted parameter, provide a description and editable value
handles.Parameters.Value        = 1;
handles.ParameterText.String    = handles.S.paramDesc.(handles.pNames{1});
handles.ParameterEdit.String    = num2str(evalc(sprintf('handles.p.%s',handles.S.paramPldaps.(handles.pNames{1}))));

% Update parameters
for iParam = 1:numel(handles.pNames(:))
    pName = handles.pNames{iParam};
    pValue = handles.S.paramValues.(pName);
    if isnumeric(pValue)
        evalc(sprintf('handles.p.%s = %d', handles.S.paramPldaps.(pName), pValue));
    elseif ischar(pValue)
        evalc(sprintf('handles.p.%s = %s', handles.S.paramPldaps.(pName), pValue));
    end
end


% FINALLY, RESET THE JUICE COUNTER WHENEVER A NEW PROTOCOL IS LOADED
handles.A.juiceCounter = 0;

% --- juice volume set to default pldaps amount
vol = handles.p.trial.behavior.reward.defaultAmount*1e3;
handles.JuiceVolumeText.String=[vol ' ul']; % displayed in microliters!!

% UPDATE HANDLES STRUCTURE
guidata(hObject,handles);
handles.p.run % open PTB window and pause

% UNLOAD CURRENT PROTOCOL, RESET GUI TO INITIAL STATE
function ClearSettings_Callback(hObject, eventdata, handles)

handles.p.trial.pldaps.quit=0; % pldaps is running (quit = 0)
handles.p.trial.pldaps.quit=2;

% DISABLE RUNNING THINGS WHILE CLEARING
handles.RunTrial.Enable              = 'Off';
handles.FlipFrame.Enable             = 'Off';
handles.ShowBackground.Enable        = 'Off';
handles.ShowBlack.Enable             = 'On';
handles.ClearSettings.Enable         = 'Off';
handles.OutputPanel.Visible          = 'Off';
handles.ParameterPanel.Visible       = 'Off';
handles.EyeTrackerPanel.Visible      = 'Off';
handles.OutputPanel.Visible          = 'Off';
handles.TaskPerformancePanel.Visible = 'Off';

% Clear plots
plot(handles.DataPlot1,0,0,'+k');
plot(handles.DataPlot2,0,0,'+k');
plot(handles.DataPlot3,0,0,'+k');

% Eye trace needs to be treated differently to maintain important
% properties
handles.A.hplot=plot(handles.EyeTrace,0,0,'.');
handles.EyeTrace.ButtonDownFcn = @(hObject,eventdata)MarmoView('EyeTrace_ButtonDownFcn',hObject,eventdata,handles);
handles.EyeTrace.UserData = 25; % 15 degrees of visual arc is default
% 
% % handles.S = MarmoViewRigSettings;
% handles.P = struct;
% handles.D = struct;
% % If juicer delivery volume was changed during the previous protocol,
% % return it to default. Also add the juice counter for the juice button.
% % fprintf(handles.A.pump,['0 VOL ' num2str(handles.S.pumpDefVol)]);
% % handles.reward.volume = handles.S.pumpDefVol; % milliliters
% handles.A.juiceVolume = handles.reward.volume;
% handles.A.juiceCounter = 0;
% handles.JuiceVolumeText.String = sprintf('%3i ul',handles.A.juiceVolume*1e3);

% RE-ENABLE CONTROLS
handles.ChooseSettings.Enable = 'On';
% Initialize is only available if the settings file exists
handles.settingsFile = handles.SettingsFile.String;
if ~exist([handles.settingsPath handles.settingsFile],'file')
    handles.Initialize.Enable = 'off';
    tstring = 'Please select a settings file...';
else
    handles.Initialize.Enable = 'on';
    tstring = 'Ready to initialize protocol...';
end
% Update GUI status
handles.StatusText.String = tstring;
% For the protocol title, note that no protocol is now loaded
handles.ProtocolTitle.String = 'No protocol is loaded.';
% The task light is a neutral gray when no protocol is loaded
ChangeLight(handles.TaskLight,[.5 .5 .5]);

% Update handles structure
guidata(hObject, handles);



%%%%% TRIAL CONTROL PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RunTrial_Callback(hObject, eventdata, handles)

% UPDATE ACCESS TO CONTROLS
handles.RunTrial.Enable         = 'Off';
handles.FlipFrame.Enable        = 'Off';
handles.ShowBackground.Enable   = 'Off';
handles.ShowBlack.Enable        = 'Off';
handles.CloseGui.Enable         = 'On';
handles.ClearSettings.Enable    = 'Off';
handles.PauseTrial.Enable       = 'On';
handles.CenterEye.Enable        = 'Off';
handles.CTargFix.Enable         = 'Off';
handles.CTargVert.Enable        = 'Off';
handles.CTargHoriz.Enable       = 'Off';
handles.CTargGrid.Enable        = 'Off';
handles.CTargCorners.Enable     = 'Off';
handles.CTargRandom.Enable      = 'Off';

% SET TASK LIGHT TO GREEN
ChangeLight(handles.TaskLight,[0 1 0]);

% UPDATE GUI STATUS
handles.StatusText.String       = 'Press P to Pause.';

guidata(hObject,handles); drawnow

handles.p.trial.pldaps.quit=0; % pldaps is running (quit = 0)


%--- STOP THE TRIAL LOOP ONCE THE CURRENT TRIAL HAS COMPLETED
function PauseTrial_Callback(hObject, eventdata, handles)
% doesn't work while pldaps is running

if handles.p.trial.pldaps.quit==0
    handles.p.trial.pldaps.quit=1;
    % UPDATE ACCESS TO CONTROLS
    handles.RunTrial.Enable         = 'On';
    handles.FlipFrame.Enable        = 'On';
    handles.PauseTrial.Enable       = 'Off';
    handles.EyeTrackerPanel.Visible = 'On';
    handles.CenterEye.Enable        = 'On';
    handles.GainDownX.Enable        = 'On';
    handles.GainDownY.Enable        = 'On';
    handles.GainUpX.Enable          = 'On';
    handles.GainUpY.Enable          = 'On';
    handles.ShiftDown.Enable        = 'On';
    handles.ShiftUp.Enable          = 'On';
    handles.ShiftLeft.Enable        = 'On';
    handles.ShiftRight.Enable       = 'On';
    handles.ShowBackground.Enable   = 'On';
    handles.ShowBlack.Enable        = 'On';
    handles.GiveJuice.Enable        = 'On';
    handles.StatusText.String       = 'PLDAPS Paused';
    
    % calibration options
    handles.CTargFix.Enable         = 'Off';
    handles.CTargVert.Enable        = 'Off';
    handles.CTargHoriz.Enable       = 'Off';
    handles.CTargGrid.Enable        = 'Off';
    handles.CTargCorners.Enable     = 'Off';
    handles.CTargRandom.Enable      = 'Off';
    
    % SET TASK LIGHT TO RED
    ChangeLight(handles.TaskLight,[1 0 0]);
    
    guidata(hObject,handles); drawnow
else
    % UPDATE ACCESS TO CONTROLS
    handles.RunTrial.Enable         = 'On';
    handles.FlipFrame.Enable        = 'On';
    handles.PauseTrial.Enable       = 'Off';
    handles.EyeTrackerPanel.Visible = 'On';
    handles.CenterEye.Enable        = 'On';
    handles.GainDownX.Enable        = 'On';
    handles.GainDownY.Enable        = 'On';
    handles.GainUpX.Enable          = 'On';
    handles.GainUpY.Enable          = 'On';
    handles.ShiftDown.Enable        = 'On';
    handles.ShiftUp.Enable          = 'On';
    handles.ShiftLeft.Enable        = 'On';
    handles.ShiftRight.Enable       = 'On';
    handles.ShowBackground.Enable   = 'On';
    handles.ShowBlack.Enable        = 'On';
    handles.GiveJuice.Enable        = 'On';
    handles.StatusText.String       = 'PLDAPS Paused';
    ChangeLight(handles.TaskLight,[1 0 0]);
    
    guidata(hObject,handles); drawnow
end


% GIVE A JUICE REWARD
function GiveJuice_Callback(hObject, eventdata, handles)
pds.behavior.reward.give(handles.p);


% CHANGE THE SIZE OF THE JUICE REWARD TO BE DELIVERED
function JuiceVolumeEdit_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
function JuiceVolumeEdit_Callback(hObject, eventdata, handles)
vol = hObject.String; % volume is entered in microliters!!
volML = str2double(vol)/1e3; % milliliters
% fprintf(handles.A.pump,['0 VOL ' volML]);
handles.p.trial.behavior.reward.defaultAmount=volML;
handles.JuiceVolumeText.String=[vol ' ul']; % displayed in microliters!!
hObject.String=''; % reset
guidata(hObject,handles); % update gui data


% RESETS THE DISPLAY SCREEN IF IT WAS INTERUPTED (BY E.G. ALT-TAB)
function FlipFrame_Callback(hObject, eventdata, handles)
Screen('FillRect', handles.p.trial.display.ptr,handles.p.trial.display.bgColor);
Screen('Flip', handles.p.trial.display.ptr, 0);


%%%%% PARAMETER CONTROL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Parameters_CreateFcn(hObject, eventdata, handles)
function Parameters_Callback(hObject, eventdata, handles)
% Get the index of the selected field
i = get(hObject,'Value');
% Set the parameter text to a description of the parameter
handles.ParameterText.String = handles.S.paramDesc.(handles.pNames{i});
% Set the parameter edit to the current value of that parameter
handles.ParameterEdit.String = num2str(handles.S.paramValues.(handles.pNames{i}));
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
    evalc(sprintf('handles.p.%s = %d', handles.S.paramPldaps.(pName), pValue));
%     handles.P.(pName) = pValue;
    % Update the parameter list immediately if not in the run loop
    if handles.p.trial.pldaps.quit ~= 0
        tName = sprintf('%s = %2g',pName,pValue);
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
    handles.p.trial.pldaps.finish = newFinal;
    % Set the count
    set(handles.TrialMaxText,'String',get(hObject,'String'));
end
% Clear the edit string
set(hObject,'String','');

% Update handles structure
guidata(hObject,handles);


%%%%% CLOSE THE GUI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CloseGui_Callback(hObject, eventdata, handles)

if isfield(handles, 'p')
    if handles.p.trial.pldaps.quit~=2
        handles.p.trial.pldaps.quit=2;
    end
end
% close the gui window
close(handles.gui, 'force');

%%%%% AUXILLIARY FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangeLight(h,col)
% THIS FUNCTION CHANGES THE TASK LIGHT
scatter(h,.5,.5,600,'o','MarkerEdgeColor','k','MarkerFaceColor',col);
axis(h,[0 1 0 1]); bkgd = [.931 .931 .931];
set(h,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);

function handles = UpdateOutputFilename(handles)
handles.OutputFile.String=handles.p.trial.session.experimentFile;

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

% filename = fullfile(handles.supportPath,handles.calibFile);

% save gui window location... makes it persistent across sessions
gl.Location = hObject.Position;
setpref('marmoview', 'gui', gl)

delete(hObject); % delete(hObject) closes the figure


% % % --- Executes on key press with focus on gui or any of its controls.
function gui_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to gui (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if isempty(eventdata.Modifier)
  return
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
    ImoScreen = Screen('MakeTexture',handles.p.trial.display.ptr,imo);
    ImoRect = [0 0 size(imo,2) size(imo,1)];
    %***************
    Screen('DrawTexture',handles.p.trial.display.ptr,ImoScreen,ImoRect,handles.p.trial.display.winRect);
    %**************************************
    Screen('Flip',handles.p.trial.display.ptr);
    Screen('Close', ImoScreen); % clean up textures
  end


% --- Executes on button press in ShowBlack.
function ShowBlack_Callback(hObject, eventdata, handles)
% hObject    handle to ShowBlack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If a bkgd parameter exists, flip frame with background color value
Screen('FillRect',handles.p.trial.display.ptr,0);
Screen('Flip',handles.p.trial.display.ptr);


% ------------------------------------------------------------------------
% --- FUNCTIONS THAT PERTAIN TO EYE CALIBRATION --------------------------

% --- THIS FUNCTION UPDATES THE RAW EYE CALIBRATION NUMBERS IN THE GUI
function UpdateEyeText(h)
set(h.CenterText,'String',sprintf('[%.2g %.2g]',h.A.c(1),h.A.c(2)));
dx = h.A.dx; dy = h.A.dy;
set(h.GainText,'String',sprintf('[%.2g %.2g]',dx,dy));

% --- THIS FUNCTION UPDATES PLOTS OF THE EYE TRACE
function UpdateEyePlot(handles)
% handles.A.cm
if isfield(handles.A, 'hplot')
% if handles.p.trial.pldaps.quit && handles.p.trial.pldaps.iTrial > 0  % At least 1 trial must be complete in order to plot the trace
    eye=[handles.A.rawxy; ones(1,size(handles.A.rawxy,2))]'*handles.A.cm;
    eye=eye';
    ctr=handles.p.trial.display.ctr;
    eye=bsxfun(@minus, eye, ctr(1:2)');
    eye=pds.px2deg(eye, handles.p.trial.display.viewdist, handles.p.trial.display.px2w);
    eye=bsxfun(@times, eye, [1; -1]);
    handles.A.hplot.XData=eye(1,:);
    handles.A.hplot.YData=eye(2,:);
    etr = get(handles.EyeTrace,'UserData');
    axis(handles.EyeTrace,[-etr etr -etr etr]);
    drawnow
end


% --- Executes on button press in CalibrateButton.
function CalibrateButton_Callback(hObject, eventdata, handles)
% toggle options
disp('pressed')
if handles.calibratePressed
   disp('switch off')
    handles.CTargFix.Enable         = 'Off';
    handles.CTargVert.Enable        = 'Off';
    handles.CTargHoriz.Enable       = 'Off';
    handles.CTargGrid.Enable        = 'Off';
    handles.CTargCorners.Enable     = 'Off';
    handles.CTargCornersDown.Enable     = 'Off';
    handles.CTargRandom.Enable      = 'Off';
    handles.calibratePressed=0;
    
    handles=cleanupMarmosetTextures(handles);
    
    handles.RunTrial.Enable         = 'On';
else
    disp('switch on')
    handles.calibratePressed=1;
    % calibration options
    handles.CTargFix.Enable         = 'On';
    handles.CTargVert.Enable        = 'On';
    handles.CTargHoriz.Enable       = 'On';
    handles.CTargGrid.Enable        = 'On';
    handles.CTargCorners.Enable     = 'On';
    handles.CTargRandom.Enable      = 'On';
    
    handles=loadMarmosetTextures(handles); % build Marmoset Face Textures
    
    handles.RunTrial.Enable         = 'Off';
end
guidata(hObject, handles)
% hObject    handle to CalibrateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Cleanup marmoset face textures
function handles=cleanupMarmosetTextures(handles)
if isfield(handles.A, 'Marmotex')
    for i=1:numel(handles.A.Marmotex)
        Screen('Close', handles.A.Marmotex(i));
    end
    handles.A=rmfield(handles.A, 'Marmotex');
    handles.A=rmfield(handles.A, 'MarmotexSize');
end

% --- load up marmoset face textures
function handles=loadMarmosetTextures(handles)
MFL=load(fullfile(marmoview.supportDataDir,'MarmosetFaceLibrary.mat'));
MFL = struct2cell(MFL);
MFL = MFL([7,10,13,17:20,24,25,27]); % these faces seem most centered

for id = 1:length(MFL)
  img = MFL{id};
  
  sz = size(img);
  % gaussian envelope...
  x = [1:sz(1)]-sz(1)/2; y = [1:sz(2)]-sz(2)/2;
  [x,y] = meshgrid(x,y);
  g = exp(-(x.^2+y.^2)/(2*(max(sz(1:2))/6)^2));
  g = g - min(g(:));
  g = g./max(g(:));
  img(:,:,4) = uint8(255.*g); % alpha channel: 0 = transparent, 255 = opaque
    
  handles.A.Marmotex(id)=Screen('MakeTexture',handles.p.trial.display.ptr,img);
  handles.A.MarmotexSize(1,id)=sz(1);
  handles.A.MarmotexSize(2,id)=sz(2);
end

% --- get recent eye position values
function [eye, raw]=getEye(p)
if p.trial.eyelink.use
    sample=Eyelink('NewestFloatSample');
    eyeIdx=p.trial.eyelink.eyeIdx;
    if p.trial.eyelink.useRawData
        raw=[sample.px(eyeIdx); sample.py(eyeIdx)];
        eye=p.trial.eyelink.calibration_matrix(:,:,eyeIdx)*[raw; 1];
    else
        eye=[p.trial.eyelink.gx(eyeIdx); p.trial.eyelink.gy(eyeIdx)];
        raw=eye;
    end
else
    [x,y]=GetMouse;
    eye=[x; y];
    raw=eye;
end

% --- Draw specified calibration targets
function handles=drawCalibrationTargets(handles, xy, nFrames)
% clear frame
% Screen('FillRect', handles.p.trial.display.overlayptr,handles.p.trial.display.bgColor);
Screen('FillRect', handles.p.trial.display.overlayptr,0);

nTargs=size(xy,1);
texids=handles.A.Marmotex(randi(numel(handles.A.Marmotex), nTargs,1));

xypx=pds.deg2px(xy', handles.p.trial.display.viewdist, handles.p.trial.display.w2px, false);

ctr=handles.p.trial.display.ctr;
xypx=bsxfun(@times, xypx, [1; -1]);
xypx=bsxfun(@plus, xypx, ctr(1:2)')';


sz=3;
szpx=pds.deg2px(sz, handles.p.trial.display.viewdist, handles.p.trial.display.w2px, false);

dstRects=CenterRectOnPoint([0 0 szpx(1) szpx(2)], xypx(:,1), xypx(:,2))';
handles.A.rawXY=nan(2,nFrames);

pds.behavior.reward.give(handles.p);

for k=1:nFrames
    [eye, raw]=getEye(handles.p);
    handles.A.rawxy(:,k)=raw;
    Screen('DrawTextures', handles.p.trial.display.ptr, texids, [], dstRects);
    Screen('DrawDots', handles.p.trial.display.overlayptr, eye', 4, handles.p.trial.display.clut.eyepos, [], 0);
    Screen('Flip', handles.p.trial.display.ptr, 0);
end
Screen('Flip', handles.p.trial.display.ptr, 0);

% update eye plot
ah=handles.EyeTrace;
hold(ah, 'on')

if isfield(handles.A, 'htargs')
    handles.A.htargs.XData=xy(:,1);
    handles.A.htargs.YData=xy(:,2);
else
    handles.A.htargs = plot(ah, xy(:,1), xy(:,2), 's', 'Color', .5*[1 1 1], 'MarkerSize', 20);
end
grid(ah, 'on')

cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles, cm);
updateCalibrationMatrix(handles);

UpdateEyePlot(handles)
UpdateEyeText(handles)

% --- Refine Calibration
function RefineCalibrationButton_Callback(hObject, eventdata, handles)

cm=marmoview.refineCalibration(handles);
handles=updateGains(handles, cm);
handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);

% clear overlay pointer
Screen('FillRect', handles.p.trial.display.overlayptr,0);
Screen('Flip', handles.p.trial.display.ptr, 0);

% --- Executes on button press in CTargFix.
function CTargFix_Callback(hObject, eventdata, handles)
nFrames=400;
xy=[0 0];
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)


% --- Executes on button press in CTargHoriz.
function CTargHoriz_Callback(hObject, eventdata, handles)
nFrames=400;
xy=[0 0; -5 0; 5 0];
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)


% --- Executes on button press in CTargVert.
function CTargVert_Callback(hObject, eventdata, handles)
nFrames=400;
xy=[0 0; 0 -5; 0 5];
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)


% --- Executes on button press in CTargCorners.
function CTargCorners_Callback(hObject, eventdata, handles)
nFrames=400;
xy=[5 8; 8 5];
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)

% --- Executes on button press in CTargCornersDown.
function CTargCornersDown_Callback(hObject, eventdata, handles)
nFrames=400;
xy=[-8 -5; -5 -8];
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)

% --- Executes on button press in CTargRandom.
function CTargRandom_Callback(hObject, eventdata, handles)
nFrames=400;
xy=rand(4, 2)*20-10;
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)

% --- full grid of targets
function CTargGrid_Callback(hObject, eventdata, handles)
nFrames=400;
xy=[0 0; 0 -5; 0 5; -5 0; 5 0; 10 0; 0 10; -10 0; 0 -10];
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)

% -------------------------------------------------------------------------
% --- SHIFT EYE POSITION CALLBACKS ----------------------------------------

% --- Center eye position
function CenterEye_Callback(hObject, eventdata, handles)

cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles, cm);
handles.A.c = median(handles.A.rawxy,2)';
handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

% --- Enter Gain adjustment step size
function GainSize_CreateFcn(hObject, eventdata, handles)
function GainSize_Callback(hObject, eventdata, handles)
gainSize = str2double(get(hObject,'String'));
if ~isnan(gainSize)
    handles.gainSize = gainSize;
    guidata(hObject,handles);
else
    set(handles.GainSize,'String',num2str(handles.gainSize));
end

% --- X Gain Up
function GainUpX_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles, cm);
% Note we divide by dx, so reducing dx increases gain
% handles.A.dx = (1+handles.gainSize)*handles.A.dx;
handles.A.dx = handles.A.dx+handles.gainSize;
handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

% --- X Gain Down
function GainDownX_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles, cm);
% handles.A.dx = (1-handles.gainSize)*handles.A.dx;
handles.A.dx = handles.A.dx-handles.gainSize;
handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

% --- Y Gain Up
function GainUpY_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles, cm);
% handles.A.dy = (1+handles.gainSize)*handles.A.dy;
handles.A.dy = handles.A.dy+handles.gainSize;
handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

% --- Y Gain Down
function GainDownY_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles, cm);
% handles.A.dy = (1-handles.gainSize)*handles.A.dy;
handles.A.dy = handles.A.dy-handles.gainSize;
handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

% --- Shift Eye Adjustment size
function ShiftSize_CreateFcn(hObject, eventdata, handles)
function ShiftSize_Callback(hObject, eventdata, handles)
shiftSize = str2double(get(hObject,'String'));
if ~isnan(shiftSize)
    handles.shiftSize = shiftSize;
    guidata(hObject,handles);
else
    set(handles.ShiftSize,'String',num2str(handles.shiftSize));
end

% --- Shift Left
function ShiftLeft_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles, cm);

handles.A.c(1) = handles.A.c(1) - ...
    handles.shiftSize*handles.p.trial.display.ppd;

handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

% --- Shift Right
function ShiftRight_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles,cm);

handles.A.c(1) = handles.A.c(1) + ...
    handles.shiftSize*handles.p.trial.display.ppd;

handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

% --- Shift Down
function ShiftDown_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles,cm);

handles.A.c(2) = handles.A.c(2) + ...
    handles.shiftSize*handles.p.trial.display.ppd;

handles=updateCalibrationMatrix(handles);

guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

% --- Shift Up
function ShiftUp_Callback(hObject, eventdata, handles)

cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles,cm);

handles.A.c(2) = handles.A.c(2) - ...
    handles.shiftSize*handles.p.trial.display.ppd;

handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
UpdateEyeText(handles);
UpdateEyePlot(handles);

% --- Update the current MarmoView Gains from a calibration matrix
function handles=updateGains(handles, cm)
[g,r,c]=calibrationMatrixToGains(cm, handles.p.trial.display.ctr(1:2));
handles.A.dx=g(1);
handles.A.dy=g(2);
handles.A.rx=r(1);
handles.A.ry=r(2);
handles.A.c=c;

% --- Reset Calibration to current rig preferences
function ResetCalibration_Callback(hObject, eventdata, handles)

% pull calibration matrix from preferences
cm=getCalibrationPref(p);

% convert to marmoview style gains and offsets
[g,r,c]=calibrationMatrixToGains(cm, handles.p.trial.display.ctr(1:2));

% store calibration info in gui
handles.A.dx=g(1);
handles.A.dy=g(2);
handles.A.c=c;
handles.A.rxy=r;

guidata(hObject,handles);
updateCalibrationMatrix(handles)
UpdateEyeText(handles);
UpdateEyePlot(handles);

% --- Get the current eye calibration matrix
function cm=getCurrentCalibrationMatrix(p)
cm=[];
if p.trial.eyelink.use && p.trial.eyelink.useAsEyepos
	% marmoview only has one eye
    cm=p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx)';
end

% --- Save the current eye calibration to rig preferences
function saveCalibrationAsRigPref(p,c)
subj=p.trial.session.subject;

% get previous calibration matrix
cm = getpref('marmoview_calibration', subj);

% update the calibration matrix depending on which eye is tracked
if isempty(cm)
    cm = c;
    cm(:,:,2) = c;
elseif p.trial.eyelink.use && p.trial.eyelink.useAsEyepos
    cm(:,:,p.trial.eyelink.eyeIdx) = c;
end

setpref('marmoview_calibration', subj, cm)
disp('saved new calibration matrix.')

% --- Get the current calibration from rig preferences
function c=getCalibrationPref(p, eyeIdx)
% Get calibration matrix from rig preferences
% cm = getCalibrationPref(p, eyeIdx)
% Input:
%   p     [pldaps] - pldaps object
%   eyeIdx [1 x 1] - index for eye (1 or 2; optional)
% Output:
%   cm     [3 x 2] - calibration matrix

% get subject name
subj=p.trial.session.subject;

% if no index is passed in, query the eyelink to get the proper index
if nargin < 2
    useEyelink = p.trial.eyelink.use & p.trial.eyelink.useAsEyepos;
    if useEyelink
        if isfield(p.trial.eyelink, 'eyeIdx')
            eyeIdx = p.trial.eyelink.eyeIdx;
        else
            eyeIdx = 1;
        end
    else
        eyeIdx = 1;
    end
end

% if rig preferences do not exist, make the identity matrix
if ~ispref('marmoview_calibration')
    c=[1 0; 0 1; 0 0]; % assume default calibration
    return
end

% check if this subject has a calibration matrix already
m=getpref('marmoview_calibration');
if isfield(m, subj)
    c = m.(subj);
    c = c(:,:,eyeIdx);
else
    c=[1 0; 0 1; 0 0]; % assume default calibration
end
    
% --- Convert calibration matrix to Marmoview Gains and Offsets
function [g,r,o]=calibrationMatrixToGains(c,ctr)

% gains
g(1)=c(1,1); % xx gain
g(2)=c(2,2); % yy gain

% rotations
r(1)=c(2,1); % xy gain
r(2)=c(1,2); % yx gain

% calculate offset
ox=c(3,1);
oy=c(3,2);

cx = ( -g(2)*(ox - ctr(1)) + r(1)*(oy-ctr(2) ) ) / (g(1)*g(2) - r(1)*r(2));
cy = ( -g(1)*(oy - ctr(2)) + r(2)*(ox-ctr(1) ) ) / (g(1)*g(2) - r(1)*r(2));

o(1)=cx;
o(2)=cy;

% --- Convert Marmoview Gains and Offsets to a Calibration Matrix
function c=gainsToCalibrationMatrix(g,r,o,ctr)
% convert to calibration matrix
ox=-g(1)*o(1) - r(1)*o(2) + ctr(1);
oy=-g(2)*o(2) - r(2)*o(1) + ctr(2);

c(1,1)=g(1);
c(2,2)=g(2);
c(1,2)=r(2);
c(2,1)=r(1);
c=[c; ox oy];

% --- update calibraiton matrix using current Gains    
function  handles=updateCalibrationMatrix(handles)
ctr=handles.p.trial.display.ctr;
cm=gainsToCalibrationMatrix([handles.A.dx handles.A.dy],[handles.A.rx handles.A.ry],handles.A.c,ctr(1:2));
handles.A.cm=cm;
    
if handles.p.trial.eyelink.use && handles.p.trial.eyelink.useAsEyepos
    handles.p.trial.eyelink.calibration_matrix(:,:,handles.p.trial.eyelink.eyeIdx)=cm';
end


% --- Executes on button press in SaveCalibration.
function SaveCalibration_Callback(hObject, eventdata, handles)
saveCalibrationAsRigPref(handles.p, handles.A.cm)
