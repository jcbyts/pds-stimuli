function OneInRF(p, sn)
% SETUP create default values for running dotmotion paradigm
%
% 

if nargin < 2
	sn='stimulus';
end

%disp('show existing struct for trial');
%p.trial.sn
%disp('done showing existing struct');

% -------------------------------------------------------------------------
% --- PLDAPS setup
p = defaultBitNames(p);

p=stimuli.setupRandomSeed(p,sn);

defaultColors(p);
p=stimuli.clutColors(p);
p.trial.stimulus.eyeW=8;

p.defaultParameters.pldaps.trialFunction='stimuli.dotselection.runTrial';

% -------------------------------------------------------------------------
% --- Parameters of the dot motion task

% --- Stimulus parameters
p.trial.(sn).bgColour 	   = .5; % pldaps controls this when the screen is opened

if ~isfield(p.trial.(sn), 'RfCenterXy')
    p.trial.(sn).RfCenterXy        = [5, -5];
end

% --- Dot parameters
p.trial.(sn).dotSize           = 0.1; 	% dot size (diameter; deg)
p.trial.(sn).dotSpeed 		   = 8.0; 	% dot speed (deg/sec) 
p.trial.(sn).dotContrast       = -0.5; % -.5 to .5
p.trial.(sn).dotMode           = 1;     % motion sampled from a distribution
p.trial.(sn).dotDist           = 1;     % make it a gaussian distribution
p.trial.(sn).dotBandwidth       = 0.0;
p.trial.(sn).dotDensity 	   = 400;   % dots / deg^2 / sec
p.trial.(sn).dotApertureRadius = norm(p.trial.(sn).RfCenterXy)/3;     % degrees
p.trial.(sn).dotLifetime       = 12;     % frames

p.trial.(sn).maxBandwidth 	   = 0.0;
p.trial.(sn).minBandwidth      = 0.0;
p.trial.(sn).numBandwidths     = 1;

p.trial.(sn).numDirs 		   = 8;

if ~isfield(p.trial.(sn), 'DotCenterAngle')
    p.trial.(sn).DotCenterAngle(1) = 0;
    p.trial.(sn).DotCenterAngle(2) = 180;
end

if ~isfield(p.trial.(sn), 'rewardUpdateFun')
	p.trial.(sn).rewardUpdateFun = @stimuli.dotselection.rewardUpdateSwitchRule;
end
if ~isfield(p.trial.(sn), 'rewardUpdateArgs')
    p.trial.(sn).rewardUpdateArgs = {.1}; % switch rate
end

if ~isfield(p.trial.(sn), 'rewardForFixation')
    p.trial.(sn).rewardForFixation = false;
end


p.trial.(sn).yokeDirections    = false;


% --- Fixation point
p.trial.(sn).fixPointRadius   = 0.3;  % radius of the fixation point
p.trial.(sn).fixPointDim	  = 0.1; % dimming of fixation point (0 invisible)
p.trial.(sn).fixWinRadius 	  = 1.8;
p.trial.(sn).fixFlashCnt 	  = round(0.250*p.trial.display.frate);
p.trial.(sn).fixPointXy       = [0, 0]; % degrees (relative to center of screen)

% --- Reward
if ~isfield(p.trial.(sn), 'rewardDot1Rate')
   disp('Initializing rewardDot1Rate');
   p.trial.(sn).rewardDot1Rate     = 0.1;
end
if ~isfield(p.trial.(sn), 'rewardDot2Rate')
   disp('Initializing rewardDot2Rate');
   p.trial.(sn).rewardDot2Rate     = 0.85;
end

p.trial.(sn).rewardWindow       = 0.0; % buffer around dot aperture
p.trial.(sn).maxRewardCnt       = 2;

% --- Face
p.trial.(sn).faceIndex          = 1;

% --- Timing
p.trial.(sn).fixGracePeriod     = 0.050;
p.trial.(sn).minFixPreStim      = 0.100;
p.trial.(sn).maxFixPreStim      = 0.200;
p.trial.(sn).minFixPostStim     = 0.100;
p.trial.(sn).maxFixPostStim     = 0.2;   % seconds (wrt dot motion onset)
p.trial.(sn).fixHoldTau         = 0.2;   % seconds (time constant of exponential decay)
p.trial.(sn).choiceGracePeriod  = 1.4;   % grace period (aka flight time; sec)
p.trial.(sn).choiceHoldDuration = 0.025; % seconds (minimum choice hold duration)
p.trial.(sn).choiceTimeout 		= 2.0;   % seconds
p.trial.(sn).trialTimeout 		= 1.0;   % seconds

%*********** added by Jude
p.trial.(sn).rewardcount = zeros(1,2);   %two targets, only two states
p.trial.(sn).rewardtravel = 4;   % must choose this many times before move
p.trial.(sn).rewardtransit = 1.0;  %prob to transition reward state
%*********************************

% -------------------------------------------------------------------------
% --- setup stimuli and prepare to run

% --- Fixation   
p.trial.(sn).hFix(1) 	= stimuli.fixation(p.trial.display.ptr);
p.trial.(sn).hFix(2) 	= stimuli.fixation(p.trial.display.ptr);

% --- Face Textures
p.trial.(sn).hFace      = stimuli.face(p);
p.trial.(sn).hFace.id   = p.trial.(sn).faceIndex;

% --- Dots
p.trial.(sn).hDots(1)   = stimuli.dots(p.trial.display.ptr);
p.trial.(sn).hDots(2)   = stimuli.dots(p.trial.display.ptr);

