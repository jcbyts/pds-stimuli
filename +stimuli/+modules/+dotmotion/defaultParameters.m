function defaultParameters(p, sn)

if nargin < 2
    sn='dotmotion';
end


% --- Motion parameters
defaultArgs.motion.priorType        = 'default';
defaultArgs.motion.stimulusType     = 'default';
defaultArgs.motion.dotSize          = 0.2; 	 % dot size (diameter; deg)
defaultArgs.motion.speed 		    = 8.0; 	 % speed (deg/sec) 
defaultArgs.motion.density          = 35;    % dots / deg^2 / sec
defaultArgs.motion.contrast 	    = -0.15;
defaultArgs.motion.lifetime         = 5; % frames
defaultArgs.motion.bandwidth 		= 0.0;
defaultArgs.motion.maxBandwidth 	= 0.0;
defaultArgs.motion.minBandwidth 	= 0.0;
defaultArgs.motion.numBandwidths    = 1;
defaultArgs.motion.numDirs          = 16;
defaultArgs.motion.radius           = 3.5;
defaultArgs.motion.xPos             = 0.0; % Aperture x position (degrees)
defaultArgs.motion.yPos             = 0.0; % Aperture y position (degrees)
defaultArgs.motion.hMot             = stimuli.objects.dotsUniform(); % default motion is uniform range dots

% --- Fixation point
defaultArgs.fixation.radius     = 0.3;  % radius of the fixation point
defaultArgs.fixation.dim        = 0.1; % dimming of fixation point (0 invisible)
defaultArgs.fixation.ctrColor   = [1 1 1]; % ctr color
defaultArgs.fixation.winRadius  = 1.8;
defaultArgs.fixation.flashCnt 	= round(0.250*p.trial.display.frate);
defaultArgs.fixation.hFix       = stimuli.objects.fixation('position', p.trial.display.ctr(1:2));
defaultArgs.fixation.rewardForFixation = false;
% --- Reward
defaultArgs.reward.windowWidth  = 30.0; % angular width (at half-height)
defaultArgs.reward.maxNumber    = 4;
defaultArgs.reward.amount       = p.trial.behavior.reward.defaultAmount;
defaultArgs.reward.function     = @(err, widthParam, maxNumber) round( maxNumber * exp( -err.^2/2/widthParam^2));

% --- Cue / Targets / Feedback
defaultArgs.cue.show            = true;
defaultArgs.cue.radius          = .5;
defaultArgs.cue.contrast        = 0.25;
defaultArgs.cue.hCue            = stimuli.objects.gaborTarget('track', false);

% --- trial feedback
defaultArgs.feedback.show       = true; % show feedback
defaultArgs.feedback.radius     = 0.5;  % radius of the feedback aperture shown on incorrect trials (deg.)
defaultArgs.feedback.contrast   = -0.5;
defaultArgs.feedback.weight     = 5; % pixels
defaultArgs.feedback.faceIndex  = 1;
defaultArgs.feedback.hFace      = stimuli.objects.face(p);
defaultArgs.feedback.hErr       = stimuli.objects.circles();

% --- Choice targets
defaultArgs.targets.radius       = 0.3;    % radius of the choice targets (if individual circles, 1/2 width if a ring)
defaultArgs.targets.contrast     = 0.25;   % contrast of the targets
defaultArgs.targets.windowMinEcc = 3.5;    % minimum saccade length for acceptence
defaultArgs.targets.windowMaxEcc = 7;      % maximum saccade length for acceptence
defaultArgs.targets.hTargs       = stimuli.objects.circles('position', p.trial.display.ctr(1:2));

% --- Timing
defaultArgs.timing.fixGracePeriod     = 0.050;
defaultArgs.timing.fixPreStimTau      = 0.05; % wrt fixation obtained
defaultArgs.timing.fixPostStimTau     = 0.1;  % wrt fixation obtained
defaultArgs.timing.maxFixPreStim      = 0.2;  % wrt fixation obtained
defaultArgs.timing.maxFixPostStim     = 0.4;  % wrt fixation obtained
defaultArgs.timing.stimDurationTau    = inf;  % wrt motion onset (seconds)
defaultArgs.timing.maxStimDuration    = 0.600; % Dots max duration
defaultArgs.timing.holdDuration       = 0.1;   % seconds (wrt dot motion onset)
defaultArgs.timing.minCueOnset        = 0.30;  % wrt motion onset (seconds)
defaultArgs.timing.maxCueOnset        = 0.70;  % wrt motion onset (seconds)
defaultArgs.timing.choiceTargetOnsetTau = 0;   % wrt fixation obtained
defaultArgs.timing.maxChoiceTargetOnset = .2;  % wrt fixation obtained
defaultArgs.timing.choiceGracePeriod  = 0.02;   % grace period (aka flight time; sec)
defaultArgs.timing.choiceHold 		  = 0.025; % seconds (minimum choice hold duration)
defaultArgs.timing.choiceWaitTimeout  = 1.0;  % seconds
defaultArgs.timing.trialTimeout       = 4.0;  % seconds
defaultArgs.timing.iti                = 1.0;

requiredFields = {'motion', 'fixation', 'reward', 'cue', 'feedback', 'targets', 'timing'};

for iReq = 1:numel(requiredFields)    
    reqField = requiredFields{iReq};
    if ~isfield(p.trial.(sn), reqField)
        p.trial.(sn).(reqField) = defaultArgs.(reqField);
    else
        p.trial.(sn).(reqField) = dvmergefield(p.trial.(sn).(reqField), defaultArgs.(reqField), true);
    end
end

% --- Parameters that are contingent on other parameters

% eccentricity of the targets
if ~isfield(p.trial.(sn).targets, 'eccentricity')
    p.trial.(sn).targets.eccentricity = p.trial.(sn).motion.radius + (0.25 * p.trial.(sn).motion.radius);
end
        
% direction prior
if ~isfield(p.trial.(sn).motion, 'directionprior')
    p.trial.(sn).motion.directionprior = stimuli.modules.dotmotion.directionprior(p.trial.(sn).motion.numDirs, p.trial.(sn).motion.priorType);
end
