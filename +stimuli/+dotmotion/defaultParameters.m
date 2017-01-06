function setup(p, sn)
% SETUP create default values for running dotmotion paradigm
%
% 

if nargin < 2
	sn='stimulus';
end

% -------------------------------------------------------------------------
% --- PLDAPS setup
p=stimuli.setupRandomSeed(p,sn);

defaultColors(p);
p=stimuli.clutColors(p);
p.trial.stimulus.eyeW=8;

p.defaultParameters.pldaps.trialFunction='stimuli.dotmotion.runTrial';

% -------------------------------------------------------------------------
% --- Parameters of the dot motion task

p.trial.(sn).bgColour 		= .5;
p.trial.(sn).size			= 0.2; 	 % dot size (diameter; deg)
p.trial.(sn).speed 			= 8.0; 	 % dot speed (deg/sec) 
p.trial.(sn).numDots 		= 35;    % TODO: should this be density?
p.trial.(sn).contrast 		= -0.15;
p.trial.(sn).mode 			= 1; % motion sampled from a distribution
p.trial.(sn).dist 			= 1; % make it a gaussian distribution
p.trial.(sn).bandwdth 		= 0.0;
p.trial.(sn).maxBandwidth 	= 0.0;
p.trial.(sn).minBandwidth 	= 0.0;
p.trial.(sn).numBandwidths  = 1;
p.trial.(sn).lifetime 		= 5; % frames
p.trial.(sn).stimWinRadius  = 3.5;
p.trial.(sn).numDirs 		= 16;
p.trial.(sn).xDeg 			= 0.0;
p.trial.(sn).yDeg 			= 0.0;
p.trial.(sn).fixPointRadius = 0.3;  % radius of the fixation point
p.trial.(sn).fixPointDim	= -0.1; % dimming of fixation point (0 invisible)
p.trial.(sn).fixWinRadius 	= 1.8;
p.trial.(sn).fixFlashCnt 	= round(0.250*p.trial.display.frate);
p.trial.(sn).fixGracePeriod = 0.050;
p.trial.(sn).minFixDuration = 0.200;
p.trial.(sn).maxFixDuration = 0.400;
p.trial.(sn).stimDuration   = 0.600;
p.trial.(sn).holdDuration   = 0.1; % seconds (wrt dot motion onset)
p.trial.(sn).bonusDirection = 0;
p.trial.(sn).bonusWindow    = 100.0;
p.trial.(sn).bonusRewardCnt = 0;

p.trial.(sn).cueApertureRadius 			= 1;
p.trial.(sn).cueApertureContrast 		= -0.25;
p.trial.(sn).minCueDelay 				= 0.30; % wrt to dot motion onset (seconds)
p.trial.(sn).maxCueDelay 				= 0.70; % wrt to dot motion onset (seconds)
p.trial.(sn).feedbackApertureRadius 	= 1.8; % radius of the feedback aperture shown on incorrect trials (deg.)
p.trial.(sn).feedbackApertureContrast 	= -0.5;	 
p.trial.(sn).choiceTargetRadius			= 0.3; % deg
p.trial.(sn).choiceTargetContrast 		= 0.075;
p.trial.(sn).choiceCueWidth 			= 6;    % deprecated 
p.trial.(sn).choiceErrWidth				= 12;   % width of circle that shows where correct choice was
p.trial.(sn).choiceTargetDelay 			= 0;    
p.trial.(sn).choiceWinMinRadius 		= 3.5;
p.trial.(sn).choiceWinMaxRadius 		= 7;
p.trial.(sn).choiceGracePeriod 			= 1.4;   % grace period (aka flight time; sec)
p.trial.(sn).choiceDuration 			= 0.025; % seconds (minimum choice hold duration)

p.trial.(sn).rewardWindow 		= 30.0; % angular width (at half-height)
p.trial.(sn).choiceTimeout 		= 1.0;  % seconds
p.trial.(sn).trialTimeout 		= 4.0;  % seconds
p.trial.(sn).maxRewardCnt 		= 4;
p.trial.(sn).faceIndex 			= 1;

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
p.trial.(sn).hFace.id = 1;

% --- Dots
p.trial.(sn).hDots = stimuli.dots(p.trial.display.ptr);

% --- Choice Targets
p.trial.(sn).hChoice = stimuli.circles(p.trial.display.ptr);
p.trial.(sn).hCue    = stimuli.textures(p.trial.display.ptr); % gabor patch
p.trial.(sn).hFbk  	 = stimuli.circles(p.trial.display.ptr); % big bold circle

% -------------------------------------------------------------------------
% --- Update Conditions
stimuli.dotmotion.updateConditions(p)
