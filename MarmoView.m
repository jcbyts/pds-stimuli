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

% Last Modified by GUIDE v2.5 22-Dec-2016 16:20:47

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
handles.taskPath = sprintf('%s/',pwd);
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

% % UPDATE GUI STATUS
handles.StatusText.String = 'Protocol is ready to run trials.';
% % Now that a protocol is loaded (but not running), task light is red
ChangeLight(handles.TaskLight,[1 0 0]);

guidata(hObject, handles); drawnow;

handles.p.trial.pldaps.pause.type=2; % pauseLoop mode
handles.p.trial.pldaps.pause.preExperiment=1; % pause before experiment
handles.p.run % open PTB window and pause

% Show filename in the gui
handles.OutputFile.String=handles.p.trial.session.experimentFile;

% EYE CALIBRATION STUFF HERE

% get subject specific calibration matrix
cm=getCalibrationPref(handles.p);
% convert to marmoview style gains and offsets
[g,r,c]=calibrationMatrixToGains(cm, handles.p.trial.display.ctr(1:2));

% store calibration info in gui
handles.A.dx=g(1);
handles.A.dy=g(2);
handles.A.c=c;
handles.A.rxy=r;


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

% 

% 
% % FINALLY, RESET THE JUICE COUNTER WHENEVER A NEW PROTOCOL IS LOADED
% handles.A.juiceCounter = 0;

% UPDATE HANDLES STRUCTURE
guidata(hObject,handles);


% UNLOAD CURRENT PROTOCOL, RESET GUI TO INITIAL STATE
function ClearSettings_Callback(hObject, eventdata, handles)

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
plot(handles.EyeTrace,0,0,'+k');
handles.EyeTrace.ButtonDownFcn = @(hObject,eventdata)MarmoView('EyeTrace_ButtonDownFcn',hObject,eventdata,handles);
handles.EyeTrace.UserData = 15; % 15 degrees of visual arc is default

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
handles.JuiceVolumeText.String = sprintf('%3i ul',handles.A.juiceVolume*1e3);

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
handles.CloseGui.Enable         = 'Off';
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
Screen('Flip', handles.p.trial.display.ptr, 0);


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


%%%%% CLOSE THE GUI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CloseGui_Callback(hObject, eventdata, handles)
% close the gui window
try
    close(handles.gui); % see gui_CloseRequestFcn()
catch
    close(handles.gui, 'force');
end

%%%%% AUXILLIARY FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangeLight(h,col)
% THIS FUNCTION CHANGES THE TASK LIGHT
scatter(h,.5,.5,600,'o','MarkerEdgeColor','k','MarkerFaceColor',col);
axis(h,[0 1 0 1]); bkgd = [.931 .931 .931];
set(h,'XColor',bkgd,'YColor',bkgd,'Color',bkgd);

% THIS FUNCTION UPDATES THE RAW EYE CALIBRATION NUMBERS IN THE GUI
function UpdateEyeText(h)
set(h.CenterText,'String',sprintf('[%.2g %.2g]',h.A.c(1),h.A.c(2)));
dx = h.A.dx; dy = h.A.dy;
set(h.GainText,'String',sprintf('[%.2g %.2g]',dx,dy));

% THIS FUNCTION UPDATES PLOTS OF THE EYE TRACE
function UpdateEyePlot(handles)
if ~handles.runTask && handles.A.j > 1   % At least 1 trial must be complete in order to plot the trace
    P = handles.D.P(handles.A.j-1); eyeData = handles.D.eyeData{handles.A.j-1}; %#ok<NASGU>
    eval(handles.plotCmd);  % Suppressing editor catches because plotCmd calls P and eyeData
end

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
% % function gui_WindowKeyPressFcn(hObject, eventdata, handles)
% % % hObject    handle to gui (see GCBO)
% % % eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
% % %	Key: name of the key that was pressed, in lower case
% % %	Character: character interpretation of the key(s) that was pressed
% % %	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% % % handles    structure with handles and user data (see GUIDATA)
% % 
% % % intercept keyboard events here and look for shortcuts. Known keyboard
% % % shortcuts are:
% % %
% % %   ctrl-j = give juice
% % %   ctrl-r = run trial
% % %   ctrl-p = pause trial
% % 
% % if isempty(eventdata.Modifier)
% %   return
% % end
% % 
% % if ~any(cellfun(@(x) strcmp(x,'control'), eventdata.Modifier)),
% %   return
% % end
% % 
% % switch eventdata.Key
% %   case 'j'
% %     % fake a call to GiveJuice callback()
% %     GiveJuice_Callback(handles.GiveJuice,[],handles);
% %     handles.reward.report()
% %   case 'r'
% %     % fake a call to RunTrial_callback()
% %     if strcmp(get(handles.RunTrial,'Enable'),'on')
% %       RunTrial_Callback(handles.RunTrial,[],handles);
% %     end
% %   case 'p'
% %     % fake a call to PauseTrial_callback()
% %     if strcmp(get(handles.PauseTrial,'Enable'),'on')
% %       PauseTrial_Callback(handles.RunTrial,[],handles);
% %     end
% % end


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
    handles.CTargRandom.Enable      = 'Off';
    handles.calibratePressed=0;
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
end
guidata(hObject, handles)
% hObject    handle to CalibrateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function eye=getEye(p)

if p.trial.eyelink.use
    eyeIdx=p.trial.eyelink.eyeIdx;
    if p.trial.eyelink.useRawData
        eyeIdx=eyeIdx - 10; %the raw data is 10 fields prior to calibrated data
    end
    eye = p.trial.eyelink.samples(eyeIdx+[13 15],1:50:p.trial.eyelink.sampleNum);
else
    [x,y]=GetMouse;
    eye=[x; y];
end


% --- Executes on button press in CTargFix.
function CTargFix_Callback(hObject, eventdata, handles)
m=stimuli.MotionObject(handles.p,'speed', 0);
m.setup
m.xy=[0 0];
% m.move;
for k=1:100
    eye=getEye(handles.p);
    m.draw
    Screen('DrawDots', handles.p.trial.display.ptr, eye, 2, handles.p.trial.display.clut.eyepos, [], 2)
    Screen('Flip', handles.p.trial.display.ptr, 0)
    
end
eye=getEye(handles.p);
ah=handles.EyeTrace;
h=plot(ah, eye(1,:), eye(2,:), 'o');
% while handles.calibratePressed
%     eye=getEye(handles.p);
%     h.XData=eye(1);
%     h.YData=eye(2);
%     drawnow
%     
% end
% hObject    handle to CTargFix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CTargHoriz.
function CTargHoriz_Callback(hObject, eventdata, handles)
m=stimuli.MotionObject(handles.p, 'speed', 0);
m.setup
m.xy=[0 0];
m.move;
m.draw
eye=getEye(handles.p);
ah=handles.EyeTrace;
h=plot(ah, eye(1,:), eye(2,:), 'o');
% hObject    handle to CTargHoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CTargVert.
function CTargVert_Callback(hObject, eventdata, handles)
% hObject    handle to CTargVert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CTargCorners.
function CTargCorners_Callback(hObject, eventdata, handles)
% hObject    handle to CTargCorners (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CTargRandom.
function CTargRandom_Callback(hObject, eventdata, handles)
% hObject    handle to CTargRandom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%% SHIFT EYE POSITION CALLBACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CenterEye_Callback(hObject, eventdata, handles)

handles.A.c = getEye();
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

% --- Save the current eye calibration to rig preferences
function saveCalibrationAsRigPref(p,c)

    if p.trial.eyelink.use
        a=getpref('pldaps','eyelink');
        a.calibration_matrix = c;
        setpref('pldaps','eyelink',a); %set new
        disp('saved new calibration matrix.')
    end
    
    subj=p.trial.session.subject;
    setpref('marmoview_calibration', subj, c)

% --- Get the current calibration from rig preferences
function c=getCalibrationPref(p)

    subj=p.trial.session.subject;
    if ~ispref('marmoview_calibration')
        c=[1 0; 0 1; 0 0]; % assume default calibration
        return
    end
    
    m=getpref('marmoview_calibration');
    if isfield(m, subj)
        c=m.(subj);
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

    

