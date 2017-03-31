function varargout = fixFlashPlot(varargin)
% FIXFLASHPLOT MATLAB code for fixFlashPlot.fig
%      FIXFLASHPLOT, by itself, creates a new FIXFLASHPLOT or raises the existing
%      singleton*.
%
%      H = FIXFLASHPLOT returns the handle to a new FIXFLASHPLOT or the handle to
%      the existing singleton*.
%
%      FIXFLASHPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIXFLASHPLOT.M with the given input arguments.
%
%      FIXFLASHPLOT('Property','Value',...) creates a new FIXFLASHPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fixFlashPlot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fixFlashPlot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fixFlashPlot

% Last Modified by GUIDE v2.5 22-Mar-2017 12:58:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fixFlashPlot_OpeningFcn, ...
                   'gui_OutputFcn',  @fixFlashPlot_OutputFcn, ...
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


% --- Executes just before fixFlashPlot is made visible.
function fixFlashPlot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fixFlashPlot (see VARARGIN)

% Choose default command line output for fixFlashPlot
handles.output = hObject;

if nargin>3 && varargin{1}
    return
end

% --- Plot
handles.plots.outcomeBar  = bar(handles.TrialOutcomes, [0 1 2], [0 0 0], 'FaceColor', .5*[1 1 1]);
handles.plots.holdDurHist = histogram(handles.HoldTime, 1, 'BinMethod', 'auto', 'FaceColor', .5*[1 1 1]);
handles.plots.fixScatter  = plot(handles.Space, 0, 0, '.');
handles.plots.textOutcome0 = text(handles.TrialOutcomes,0,0,'');
handles.plots.textOutcome1 = text(handles.TrialOutcomes,0,0,'');
handles.plots.textOutcome2 = text(handles.TrialOutcomes,0,0,'');
cla(handles.StairCasePlot)
handles.plots.staircaseMax    = plot(handles.StairCasePlot, 0,0,'.r');
hold(handles.StairCasePlot, 'on')
handles.plots.staircaseMin    = plot(handles.StairCasePlot, 0,0,'--k');

handles.plots.textOutcome0.HorizontalAlignment = 'center';
handles.plots.textOutcome1.HorizontalAlignment = 'center';
handles.plots.textOutcome2.HorizontalAlignment = 'center';

% --- Axes Titles and labels
handles.text.spacexlabel = xlabel(handles.Space, 'Degrees');
handles.text.spaceTitle  = title(handles.Space, 'Space');
handles.text.spaceylabel = ylabel(handles.Space, 'Degrees');

handles.Space.XLim = [-2 2];
handles.Space.YLim = [-2 2];
handles.Space.XGrid = 'on';
handles.Space.YGrid = 'on';

handles.text.outcomeTitle  = title(handles.TrialOutcomes, 'Trial Outcomes');
handles.text.outcomeylabel = ylabel(handles.TrialOutcomes, '# Trials');

handles.text.holdTitle  = title(handles.HoldTime, 'Hold Duration');
handles.text.holdylabel = ylabel(handles.HoldTime, '# Trials');
handles.text.holdxlabel = xlabel(handles.HoldTime, 'Seconds');

handles.text.StaircaseTitle  = title(handles.StairCasePlot, 'Staircase');
handles.text.Staircaseylabel = ylabel(handles.StairCasePlot, 'Trial');
handles.text.Staircasexlabel = xlabel(handles.StairCasePlot, 'Seconds');

handles.TrialOutcomes.XTick = [0 1 2];
handles.TrialOutcomes.XTickLabel = {'Good', 'No Fix', 'Break Fix'};
handles.TrialOutcomes.XTickLabelRotation = -45;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fixFlashPlot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fixFlashPlot_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
