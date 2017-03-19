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

% Last Modified by GUIDE v2.5 17-Mar-2017 10:42:18

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

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes calibrationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = calibrationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in OffsetLeft.
function OffsetLeft_Callback(hObject, eventdata, handles)
% hObject    handle to OffsetLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in OffsetRight.
function OffsetRight_Callback(hObject, eventdata, handles)
% hObject    handle to OffsetRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in OffsetUp.
function OffsetUp_Callback(hObject, eventdata, handles)
% hObject    handle to OffsetUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in OffsetDown.
function OffsetDown_Callback(hObject, eventdata, handles)
% hObject    handle to OffsetDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function OffsetStep_Callback(hObject, eventdata, handles)
% hObject    handle to OffsetStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OffsetStep as text
%        str2double(get(hObject,'String')) returns contents of OffsetStep as a double


% --- Executes during object creation, after setting all properties.
function OffsetStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OffsetStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GainLeft.
function GainLeft_Callback(hObject, eventdata, handles)
% hObject    handle to GainLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in GainRight.
function GainRight_Callback(hObject, eventdata, handles)
% hObject    handle to GainRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in GainUp.
function GainUp_Callback(hObject, eventdata, handles)
% hObject    handle to GainUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in GainDown.
function GainDown_Callback(hObject, eventdata, handles)
% hObject    handle to GainDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function GainStep_Callback(hObject, eventdata, handles)
% hObject    handle to GainStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GainStep as text
%        str2double(get(hObject,'String')) returns contents of GainStep as a double


% --- Executes during object creation, after setting all properties.
function GainStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GainStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TargetGrid.
function TargetGrid_Callback(hObject, eventdata, handles)
% hObject    handle to TargetGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TargetU.
function TargetU_Callback(hObject, eventdata, handles)
% hObject    handle to TargetU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TargetD.
function TargetD_Callback(hObject, eventdata, handles)
% hObject    handle to TargetD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TargetL.
function TargetL_Callback(hObject, eventdata, handles)
% hObject    handle to TargetL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TargetR.
function TargetR_Callback(hObject, eventdata, handles)
% hObject    handle to TargetR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TargetRandom.
function TargetRandom_Callback(hObject, eventdata, handles)
% hObject    handle to TargetRandom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TargetFix.
function TargetFix_Callback(hObject, eventdata, handles)
% hObject    handle to TargetFix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TargetCorners.
function TargetCorners_Callback(hObject, eventdata, handles)
% hObject    handle to TargetCorners (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ------------------------------------------------------------------------
% --- Drawing / Calibration Support Functions

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


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in refineButton.
function refineButton_Callback(hObject, eventdata, handles)
% hObject    handle to refineButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in marmosetFaceCheckbox.
function marmosetFaceCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to marmosetFaceCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of marmosetFaceCheckbox
