function defaultParameters(p, sn)
% SETUP create default values for running fixflash paradigm

if nargin < 2
    sn='stimulus';
end

% -------------------------------------------------------------------------
% --- PLDAPS setup
p = defaultBitNames(p);

p=stimuli.setupRandomSeed(p,sn);

defaultColors(p);
p=stimuli.clutColors(p);
p.trial.stimulus.eyeW=8;

p.defaultParameters.pldaps.useModularStateFunctions = true;

p.defaultParameters.pldaps.trialFunction='stimuli.fixflash.runTrial';

% -------------------------------------------------------------------------
% --- Parameters of the dot motion task

% --- Stimulus parameters
p.trial.(sn).bgColour 	   = .5; % pldaps controls this when the screen is opened

% --- Fixation point
if ~isfield(p.trial.(sn), 'fixPointRadius')
    p.trial.(sn).fixPointRadius = 0.3;  % radius of the fixation point
end

if ~isfield(p.trial.(sn), 'fixPointDim')
    p.trial.(sn).fixPointDim	  = 0.1; % dimming of fixation point (0 invisible)
end

if ~isfield(p.trial.(sn), 'fixWinRadius')
    p.trial.(sn).fixWinRadius 	= 1.8;
end

if ~isfield(p.trial.(sn), 'fixFlashCnt')
    p.trial.(sn).fixFlashCnt 	  = round(0.250*p.trial.display.frate);
end

% --- Cue / Targets / Feedback / Reward
if ~isfield(p.trial.(sn), 'feedbackApertureRadius')
    p.trial.(sn).feedbackApertureRadius   = 1.8; % radius of the feedback aperture shown on incorrect trials (deg.)
end

if ~isfield(p.trial.(sn), 'feedbackApertureContrast')
    p.trial.(sn).feedbackApertureContrast = -0.5;
end

if ~isfield(p.trial.(sn), 'maxRewardCnt')
    p.trial.(sn).maxRewardCnt   = 4;
end

if ~isfield(p.trial.(sn), 'faceRadius')
    p.trial.(sn).faceRadius     = 1; % degrees
end

if ~isfield(p.trial.(sn), 'faceIndex')
    p.trial.(sn).faceIndex                = 1;
end

if ~isfield(p.trial.(sn), 'iti')
    p.trial.(sn).iti               = 1;
end

if ~isfield(p.trial.(sn), 'fixationJitter')
    p.trial.(sn).fixationJitter = false;
end

if ~isfield(p.trial.(sn), 'fixationJitterSize')
    p.trial.(sn).fixationJitterSize = 1;
end

if ~isfield(p.trial.(sn), 'fixationX')
    p.trial.(sn).fixationX = 0;
end

if ~isfield(p.trial.(sn), 'fixationY')
    p.trial.(sn).fixationY = 0;
end

% --- Timing
if ~isfield(p.trial.(sn), 'fixGracePeriod')
    p.trial.(sn).fixGracePeriod     = 0.050;
end

if ~isfield(p.trial.(sn), 'minFixDuration')
    p.trial.(sn).minFixDuration     = 0.200;
end

if ~isfield(p.trial.(sn), 'maxFixDuration')
    p.trial.(sn).maxFixDuration     = 0.400;
end

if ~isfield(p.trial.(sn), 'holdDuration')
    p.trial.(sn).holdDuration       = 0.1;   % seconds (wrt dot motion onset)
end

if ~isfield(p.trial.(sn), 'choiceTimeout')
    p.trial.(sn).choiceTimeout 		= 1.0;  % seconds
end

if ~isfield(p.trial.(sn), 'trialTimeout')
    p.trial.(sn).trialTimeout 		= 4.0;  % seconds
end

if ~isfield(p.trial.(sn), 'staircaseOn')
    p.trial.(sn).staircaseOn = true;
end

if ~isfield(p.trial.(sn), 'staircaseMax')
    p.trial.(sn).staircaseMax = 1;
end

if ~isfield(p.trial.(sn), 'staircaseStep')
    p.trial.(sn).staircaseStep = .05; % seconds
end

% -------------------------------------------------------------------------
% --- setup stimuli and prepare to run

% --- Fixation
p.trial.(sn).hFix(1) 	= stimuli.fixation(p.trial.display.ptr);
p.trial.(sn).hFix(2) 	= stimuli.fixation(p.trial.display.ptr);

% --- Face Textures
hFace = stimuli.textures(p.trial.display.ptr);

% load marmoset face textures
MFL=load(fullfile(marmoview.supportDataDir,'MarmosetFaceLibrary.mat'));
MFL = struct2cell(MFL);
MFL = MFL([7,10,13,17:20,24,25,27]); % these faces seem most centered

for id = 1:length(MFL)
    img = MFL{id};
    
    sz = size(img);
    % gaussian envelope...
    x = (1:sz(1))-sz(1)/2; y = (1:sz(2))-sz(2)/2;
    [x,y] = meshgrid(x,y);
    g = exp(-(x.^2+y.^2)/(2*(max(sz(1:2))/6)^2));
    g = g - min(g(:));
    g = g./max(g(:));
    img(:,:,4) = uint8(255.*g); % alpha channel: 0 = transparent, 255 = opaque
    
    hFace.addTexture(id, img);
end
p.trial.(sn).hFace = hFace;

% --- Choice Targets
p.trial.(sn).hFbk  	 = stimuli.circles(p.trial.display.ptr); % big bold circle

% -------------------------------------------------------------------------
% --- Plotting
p.functionHandles.fixFlashPlot = stimuli.fixflash.fixFlashPlot;


% -------------------------------------------------------------------------
% --- Update Conditions
stimuli.fixflash.updateConditions(p)
