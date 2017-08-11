function OneInRF(p, sn)
% SETUP create default values for running dotmotion paradigm
%
% 

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

p.defaultParameters.pldaps.trialFunction='stimuli.dotselection.runTrial';

% -------------------------------------------------------------------------
% --- Parameters of the dot motion task

% --- Stimulus parameters
p.trial.(sn).bgColour 	   = .5; % pldaps controls this when the screen is opened

% --- Dot parameters
p.trial.(sn).dotSize           = 0.1; 	% dot size (diameter; deg)
p.trial.(sn).dotSpeed 		   = 8.0; 	% dot speed (deg/sec) 
p.trial.(sn).dotContrast       = -0.15;
p.trial.(sn).dotMode           = 1;     % motion sampled from a distribution
p.trial.(sn).dotDist           = 1;     % make it a gaussian distribution
p.trial.(sn).dotBandwidth       = 0.0;
p.trial.(sn).dotDensity 	   = 100;   % dots / deg^2 / sec
p.trial.(sn).dotApertureRadius = 2;     % degrees
p.trial.(sn).dotLifetime       = 5;     % frames

p.trial.(sn).maxBandwidth 	   = 0.0;
p.trial.(sn).minBandwidth      = 0.0;
p.trial.(sn).numBandwidths     = 1;

p.trial.(sn).numDirs 		   = 8;
p.trial.(sn).RfCenterXy        = [5, -5];
p.trial.(sn).DotCenterAngle(1) = 0;
p.trial.(sn).DotCenterAngle(2) = 180;
p.trial.(sn).yokeDirections    = false;


% --- Fixation point
p.trial.(sn).fixPointRadius   = 0.3;  % radius of the fixation point
p.trial.(sn).fixPointDim	  = 0.1; % dimming of fixation point (0 invisible)
p.trial.(sn).fixWinRadius 	  = 1.8;
p.trial.(sn).fixFlashCnt 	  = round(0.250*p.trial.display.frate);
p.trial.(sn).fixPointXy       = [0, 0]; % degrees (relative to center of screen)

% --- Reward
p.trial.(sn).rewardDot1Rate     = .85;
p.trial.(sn).rewardDot2Rate     = .85;

p.trial.(sn).rewardWindow       = 0.0; % buffer around dot aperture
p.trial.(sn).maxRewardCnt       = 4;

% --- Face
p.trial.(sn).faceIndex          = 1;

% --- Timing
p.trial.(sn).fixGracePeriod     = 0.050;
p.trial.(sn).minFixPreStim      = 0.200;
p.trial.(sn).maxFixPreStim      = 0.400;
p.trial.(sn).minFixPostStim     = 0.100; % Dots max duration
p.trial.(sn).maxFixPostStim     = 0.6;   % seconds (wrt dot motion onset)
p.trial.(sn).fixHoldTau         = 0.2;   % seconds (time constant of exponential decay)
p.trial.(sn).choiceGracePeriod  = 1.4;   % grace period (aka flight time; sec)
p.trial.(sn).choiceHoldDuration = 0.025; % seconds (minimum choice hold duration)
p.trial.(sn).choiceTimeout 		= 1.0;   % seconds
p.trial.(sn).trialTimeout 		= 1.0;   % seconds


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


% -------------------------------------------------------------------------
% --- Update Conditions
stimuli.dotselection.updateConditions(p)
