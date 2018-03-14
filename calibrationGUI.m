function varargout = calibrationGUI(varargin)
% CALIBRATIONGUI MATLAB code for calibrationGUI.fig
%      CALIBRATIONGUI, by itself, creates a new CALIBRATIONGUI or raises the existing
%      singleton*.
%
%      H = CALIBRATIONGUI returns the handle to a new CALIBRATIONGUI or the handle to
%      the existing singleton*.
%
%      CALIBRATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRATIONGUI.M with the given input arguments.
%
%      CALIBRATIONGUI('Property','Value',...) creates a new CALIBRATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before calibrationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to calibrationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help calibrationGUI

% Last Modified by GUIDE v2.5 04-Aug-2017 10:36:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calibrationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @calibrationGUI_OutputFcn, ...
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


% --- Executes just before calibrationGUI is made visible.
function calibrationGUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to calibrationGUI (see VARARGIN)

% Choose default command line output for calibrationGUI
handles.output = hObject;
handles.p = varargin{1}; % pointer to pldaps object

Screen('BlendFunction', handles.p.trial.display.ptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
handles.S = struct; % Settings for the protocol, NOT changed while running
handles.A = struct; % plot

% Add in the plot handles to A in case handles isn't available
% e.g. while running protocols)
handles.A.EyeTrace  = handles.EyeTrace;

handles.A.hplot=plot(handles.EyeTrace,0,0,'.');
handles.EyeTrace.ButtonDownFcn = @(hObject,eventdata)calibrationGUI('EyeTrace_ButtonDownFcn',hObject,eventdata,handles);
handles.EyeTrace.UserData=25;

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

% -------------------------------------------------------------------------
% --- Check if calibration matrix exists
% EYE CALIBRATION STUFF HERE
cm=getCalibrationPref(handles.p,1);
% marmoview specific preferences override pldaps
if handles.p.trial.eyelink.use && handles.p.trial.eyelink.useAsEyepos
    if handles.p.trial.eyelink.useRawData && ~isempty(handles.p.trial.eyelink.calibration_matrix)
        cm = handles.p.trial.eyelink.calibration_matrix(:,:,handles.p.trial.eyelink.eyeIdx)';
    else
        handles.p.trial.eyelink.useRawData=true;
        handles.p.trial.eyelink.calibration_matrix=[];
        for i = 1:2 % loop over eye index
            % get subject specific calibration matrix
            cm=getCalibrationPref(handles.p,1);
            handles.p.trial.eyelink.calibration_matrix(:,:,i) = cm';
        end
    end
        
end

% this is temporary, need to query eye index to get the right calibration
% matrix
handles.A.cm=cm;
handles.shiftSize = .5;
handles.gainSize  = .01;

handles=loadMarmosetTextures(handles); % build Marmoset Face Textures
 
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes calibrationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = calibrationGUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in OffsetLeft.
function OffsetLeft_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles, cm);

handles.A.c(1) = handles.A.c(1) + ...
    handles.shiftSize*handles.p.trial.display.ppd;

handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
% UpdateEyeText(handles);
UpdateEyePlot(handles);



% --- Executes on button press in OffsetRight.
function OffsetRight_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles,cm);

handles.A.c(1) = handles.A.c(1) - ...
    handles.shiftSize*handles.p.trial.display.ppd;

handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
% UpdateEyeText(handles);
UpdateEyePlot(handles);


% --- Executes on button press in OffsetUp.
function OffsetUp_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles,cm);

handles.A.c(2) = handles.A.c(2) - ...
    handles.shiftSize*handles.p.trial.display.ppd;

handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
% UpdateEyeText(handles);
UpdateEyePlot(handles);


% --- Executes on button press in OffsetDown.
function OffsetDown_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles,cm);

handles.A.c(2) = handles.A.c(2) + ...
    handles.shiftSize*handles.p.trial.display.ppd;

handles=updateCalibrationMatrix(handles);

guidata(hObject,handles);
% UpdateEyeText(handles);
UpdateEyePlot(handles);


% --- Shift Eye Adjustment size
function OffsetStep_CreateFcn(hObject, eventdata, handles)
function OffsetStep_Callback(hObject, eventdata, handles)
shiftSize = str2double(get(hObject,'String'));
if ~isnan(shiftSize)
    handles.shiftSize = shiftSize;
    guidata(hObject,handles);
else
    set(handles.ShiftSize,'String',num2str(handles.shiftSize));
end


% --- Executes on button press in GainLeft.
function GainLeft_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles, cm);
% handles.A.dx = (1-handles.gainSize)*handles.A.dx;
handles.A.dx = handles.A.dx-handles.gainSize;
handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
% UpdateEyeText(handles);
UpdateEyePlot(handles);


% --- Executes on button press in GainRight.
function GainRight_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles, cm);
% Note we divide by dx, so reducing dx increases gain
% handles.A.dx = (1+handles.gainSize)*handles.A.dx;
handles.A.dx = handles.A.dx+handles.gainSize;
handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
% UpdateEyeText(handles);
UpdateEyePlot(handles);


% --- Executes on button press in GainUp.
function GainUp_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles, cm);
% handles.A.dy = (1+handles.gainSize)*handles.A.dy;
handles.A.dy = handles.A.dy+handles.gainSize;
handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
% UpdateEyeText(handles);
UpdateEyePlot(handles);


% --- Executes on button press in GainDown.
function GainDown_Callback(hObject, eventdata, handles)
cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles, cm);
% handles.A.dy = (1-handles.gainSize)*handles.A.dy;
handles.A.dy = handles.A.dy-handles.gainSize;
handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
% UpdateEyeText(handles);
UpdateEyePlot(handles);


% --- Enter Gain adjustment step size
function GainStep_CreateFcn(hObject, eventdata, handles)
function GainStep_Callback(hObject, eventdata, handles)
gainSize = str2double(get(hObject,'String'));
if ~isnan(gainSize)
    handles.gainSize = gainSize;
    guidata(hObject,handles);
else
    set(handles.GainSize,'String',num2str(handles.gainSize));
end


% --- Executes on button press in TargetGrid.
function TargetGrid_Callback(hObject, eventdata, handles)
nFrames=100;
xy=[0 0; 0 -5; 0 5; -5 0; 5 0; 10 0; 0 10; -10 0; 0 -10];
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)


% --- Executes on button press in TargetU.
function TargetU_Callback(hObject, eventdata, handles)
nFrames=100;
xy=[0 0; 0 5];
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)


% --- Executes on button press in TargetD.
function TargetD_Callback(hObject, eventdata, handles)
nFrames=100;
xy=[0 0; 0 -5];
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)


% --- Executes on button press in TargetL.
function TargetL_Callback(hObject, eventdata, handles)
nFrames=100;
xy=[0 0; -5 0];
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)


% --- Executes on button press in TargetR.
function TargetR_Callback(hObject, eventdata, handles)
nFrames=100;
xy=[0 0; 5 0; 10 0];
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)


% --- Executes on button press in TargetRandom.
function TargetRandom_Callback(hObject, eventdata, handles)
nFrames=100;
xy=rand(4, 2)*20-10;
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)


% --- Executes on button press in TargetFix.
function TargetFix_Callback(hObject, eventdata, handles)
nFrames=100;
xy=[0 0];
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)


% --- Executes on button press in TargetCorners.
function TargetCorners_Callback(hObject, eventdata, handles)
nFrames=100;
xy=[5 8; 8 5];
handles=drawCalibrationTargets(handles, xy, nFrames);
guidata(hObject, handles)


% --- Executes on button press in CenterButton.
function CenterButton_Callback(hObject, eventdata, handles)

cm=getCurrentCalibrationMatrix(handles.p);
handles=updateGains(handles, cm);
handles.A.c = median(handles.A.rawxy,2)';
handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);
% UpdateEyeText(handles);
UpdateEyePlot(handles);


% ------------------------------------------------------------------------
% --- Drawing / Calibration Support Functions
% --- Draw specified calibration targets
function handles=drawCalibrationTargets(handles, xy, nFrames)
% clear frame
Screen('FillRect', handles.p.trial.display.overlayptr,handles.p.trial.display.bgColor);
% Screen('FillRect', handles.p.trial.display.overlayptr,0);

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
    if rand < .0025
        pds.behavior.reward.give(handles.p);
    end
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
% UpdateEyeText(handles)

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
saveCalibrationAsRigPref(handles.p, handles.A.cm)


% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)

handles=cleanupMarmosetTextures(handles);

Screen('BlendFunction', handles.p.trial.display.ptr, handles.p.trial.display.sourceFactorNew, handles.p.trial.display.destinationFactorNew);

close(handles.figure1, 'force');


% --- Executes on button press in refineButton.
function refineButton_Callback(hObject, eventdata, handles)

cm=marmoview.refineCalibration(handles);
handles=updateGains(handles, cm);
handles=updateCalibrationMatrix(handles);
guidata(hObject,handles);

% clear overlay pointer
Screen('FillRect', handles.p.trial.display.overlayptr,0);
Screen('Flip', handles.p.trial.display.ptr, 0);


% --- Executes on button press in marmosetFaceCheckbox.
function marmosetFaceCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to marmosetFaceCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of marmosetFaceCheckbox


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

% --- Cleanup marmoset face textures
function handles=cleanupMarmosetTextures(handles)
if isfield(handles.A, 'Marmotex')
    for i=1:numel(handles.A.Marmotex)
        Screen('Close', handles.A.Marmotex(i));
    end
    handles.A=rmfield(handles.A, 'Marmotex');
    handles.A=rmfield(handles.A, 'MarmotexSize');
end

% --- Executes on mouse press over axes background ---- ZOOM FOR EYE TRACE
function EyeTrace_ButtonDownFcn(hObject, eventdata, handles) %#ok<*INUSL>
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

% --- Update the plots of the eye trace
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

% --- Updates text in gui
function UpdateEyeText(h)
set(h.CenterText,'String',sprintf('[%.2g %.2g]',h.A.c(1),h.A.c(2)));
dx = h.A.dx; dy = h.A.dy;
set(h.GainText,'String',sprintf('[%.2g %.2g]',dx,dy));

% -------------------------------------------------------------------------
% Support functions for calibration
% --- update calibraiton matrix using current Gains    
function  handles=updateCalibrationMatrix(handles)
ctr=handles.p.trial.display.ctr;
cm=gainsToCalibrationMatrix([handles.A.dx handles.A.dy],[handles.A.rx handles.A.ry],handles.A.c,ctr(1:2));
handles.A.cm=cm;
    
if handles.p.trial.eyelink.use && handles.p.trial.eyelink.useAsEyepos
    handles.p.trial.eyelink.calibration_matrix(:,:,handles.p.trial.eyelink.eyeIdx)=cm';
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
else % if not
    c=[1 0; 0 1; 0 0]; % assume default calibration
    % initialize a calibration matrix
    cm = c;
    cm(:,:,2)=c;
    setpref('marmoview_calibration', subj, cm);
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

% --- Get the current eye calibration matrix
function cm=getCurrentCalibrationMatrix(p)
cm=[];
if p.trial.eyelink.use && p.trial.eyelink.useAsEyepos
	% marmoview only has one eye
    cm=p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx)';
end

% --- Update the current MarmoView Gains from a calibration matrix
function handles=updateGains(handles, cm)
[g,r,c]=calibrationMatrixToGains(cm, handles.p.trial.display.ctr(1:2));
handles.A.dx=g(1);
handles.A.dy=g(2);
handles.A.rx=r(1);
handles.A.ry=r(2);
handles.A.c=c;
