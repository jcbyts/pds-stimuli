function defaultParameters(p, sn)

if nargin < 2
    sn='targetselection';
end


% --- Stimulus parameters
defaultArgs.bgColour 	   = .5; % pldaps controls this when the screen is opened

% --- Dot parameters
defaultArgs.size			     = 0.2; 	 % dot size (diameter; deg)
defaultArgs.speed 			   = 8.0; 	 % dot speed (deg/sec) 
defaultArgs.numDots 		   = 35;    % TODO: should this be density?
defaultArgs.contrast 	     = -0.15;
defaultArgs.mode 			     = 1; % motion sampled from a distribution
defaultArgs.dist 			     = 1; % make it a gaussian distribution
defaultArgs.bandwdth 		   = 0.0;
defaultArgs.maxBandwidth 	 = 0.0;
defaultArgs.minBandwidth 	 = 0.0;
defaultArgs.numBandwidths  = 1;
defaultArgs.lifetime 		   = 5; % frames
defaultArgs.stimWinRadius  = 3.5;
defaultArgs.numDirs 		   = 16;
defaultArgs.xDeg 			     = 0.0; % Aperture x position (degrees)
defaultArgs.yDeg 			     = 0.0; % Aperture y position (degrees)

% --- Fixation point
defaultArgs.fixPointRadius  = 0.3;  % radius of the fixation point
defaultArgs.fixPointDim	    = 0.1; % dimming of fixation point (0 invisible)
defaultArgs.fixWinRadius 	  = 1.8;
defaultArgs.fixFlashCnt 	  = round(0.250*p.trial.display.frate);

% --- Reward
defaultArgs.rewardWindow   = 30.0; % angular width (at half-height)
defaultArgs.maxRewardCnt   = 4;
defaultArgs.bonusDirection = 0;
defaultArgs.bonusWindow    = 100.0;
defaultArgs.bonusRewardCnt = 0;

% --- Cue / Targets / Feedback
defaultArgs.cueApertureRadius        = 1;
defaultArgs.cueApertureContrast      = -0.25;

defaultArgs.feedbackApertureRadius   = 1.8; % radius of the feedback aperture shown on incorrect trials (deg.)
defaultArgs.feedbackApertureContrast = -0.5;  

defaultArgs.choiceTargetRadius       = 0.3; % deg
defaultArgs.choiceTargetContrast     = 0.075;
defaultArgs.choiceCueWidth           = 6;    % deprecated 
defaultArgs.choiceErrWidth           = 12;   % width of circle that shows where correct choice was
defaultArgs.choiceWinMinRadius       = 3.5;
defaultArgs.choiceWinMaxRadius       = 7;

defaultArgs.faceIndex                = 1;

% --- Timing
defaultArgs.fixGracePeriod     = 0.050;
defaultArgs.minFixDuration     = 0.200;
defaultArgs.maxFixDuration     = 0.400;
defaultArgs.stimDuration       = 0.600; % Dots max duration
defaultArgs.holdDuration       = 0.1;   % seconds (wrt dot motion onset)
defaultArgs.minCueDelay 			 = 0.30;  % wrt to dot motion onset (seconds)
defaultArgs.maxCueDelay 			 = 0.70;  % wrt to dot motion onset (seconds)
defaultArgs.choiceTargetDelay  = 0;     % wrt to XX
defaultArgs.choiceGracePeriod  = 1.4;   % grace period (aka flight time; sec)
defaultArgs.choiceDuration 		 = 0.025; % seconds (minimum choice hold duration)
defaultArgs.choiceTimeout 		 = 1.0;  % seconds
defaultArgs.trialTimeout 		   = 4.0;  % seconds

% NEEDS  dots, fix , face, cue
argfields = fieldnames(defaultArgs);

for iArg = 1:numel(argfields)
    
    field = argfields{iArg};
    val   = defaultArgs.(argfields);
    
    if ~isfield(p.trial.(sn), field)
        p.trial.(sn).(field) = val;
    end
end
