function trialSetup(p, sn)

	if nargin < 2
		sn = 'targetselection';
	end

p.trial.pldaps.goodtrial = 0; % trial initializes as bad

% --- Useful constants
ppd   = p.trial.display.ppd;        % pixels per degree (linear approximation)
fps   = p.trial.display.frate;      % frames per second
ctr   = p.trial.display.ctr(1:2);   % center of the screen (pixels)

% --- Random seed
p.trial.(sn).rngs.conditionerRNG = RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
setupRNG = p.trial.(sn).rngs.conditionerRNG;


% -------------------------------------------------------------------------
% FIXATION POINT TIMING / PROPERTIES

% Fixation position
if p.trial.(sn).fixationJitter
    xpos = p.trial.(sn).fixationJitterSize * randn(setupRNG) + p.trial.(sn).fixationX;
    ypos = p.trial.(sn).fixationJitterSize * randn(setupRNG) + p.trial.(sn).fixationY;
else
    xpos = p.trial.(sn).fixationX;
    ypos = p.trial.(sn).fixationY;
end

% fixation point radius
p.trial.(sn).hFix.radius     = p.trial.(sn).fixPointRadius * ppd;
if isfield(p.trial.(sn), 'fixShrinkTimeConstant') % does the fixation point shrink to its final radius? 0 if no
    p.trial.(sn).hFix.shrinkTimeConstant = p.trial.(sn).fixShrinkTimeConstant;
end
    
% set color
if p.trial.display.useOverlay % if using pldaps overlay, use clut index
    p.trial.(sn).hFix.color    = p.trial.display.clut.black;
    p.trial.(sn).hFix.ctrColor = p.trial.display.clut.bg;
else
    p.trial.(sn).hFix.color    = -ones(1,3);
    p.trial.(sn).hFix.ctrColor = zeros(1,3);
end

% assign position to the fixation object
p.trial.(sn).hFix.position      = [xpos ypos] * ppd + ctr;
% assign the radius of the window (for detecting fixation behavior)
p.trial.(sn).hFix.winRadius  = p.trial.(sn).fixWinRadius * ppd;
p.trial.(sn).hFix.wincolor   = p.trial.display.clut.bg_white;


% --- Pre-Stim Fixation duration (uniform distribution)
rnd=rand(setupRNG);
p.trial.(sn).fixPreStimDuration = (1 - rnd) * p.trial.(sn).minFixPreStim + rnd * p.trial.(sn).maxFixPreStim;

% --- Fix Hold after stimulus onset (truncated exponential)
mu = p.trial.(sn).fixHoldTau; % exponential decay (in seconds)
r  = inf; %initialize Hold Duration

% stop the while loop from running for ever
infLoopStopper = 100; itr = 1; 
 
% re-generate exponential random numbers that are less than the truncation
while r > p.trial.(sn).maxFixPostStim

    r = exprnd(setupRNG, mu, [1 1]); % call to the pep exprnd function
    % rnd = rand(setupRNG);
    % r   = -mu .* log(rnd) + p.trial.(sn).minFixPostStim; % new exponential random number
    if itr > infLoopStopper
        r = p.trial.(sn).maxFixPostStim;
        break
    end
        
    itr = itr + 1;
end

% update fixation module
p.trial.(sn).fixDurPostStim = p.trial.(sn).minFixPostStim + r; % depending on the order of the modules, might need to set fixDuration directly

% -------------------------------------------------------------------------
% DOTS: PROPERTIES

% --- setup trial difficulty
if p.trial.(sn).numBandwidths > 1
    % randomly sample from the bandwidths
    rnd=randi(p.trial.(sn).numBandwidths, 1) / p.trial.(sn).numBandwidths;
    p.trial.(sn).bandwdth = (1-rnd) * p.trial.(sn).minBandwidth + rnd * p.trial.(sn).maxBandwidth; 
end

% --- setup targets
numApertures = numel(p.trial.(sn).hTargs);

assert(numApertures==2, 'This code is not designed for more than 2 apertures')


for kTarg = 1:numApertures
    
    % ---------------------------------------------------------------------
    % IS DOTS?
    % this if statement checks if the class of the hTarg object is a dotsbase. If it is, it will use dot parameters
    if isa(p.trial.(sn).hTargs(kTarg), 'stimuli.objects.dotsbase')
        % dot Range / Bandwidth
        p.trial.(sn).hTargs(kTarg).range  = p.trial.(sn).dotRange;
        % dot lifetime
        p.trial.(sn).hTargs(kTarg).dotLifetime = p.trial.(sn).dotLifetime;
        % dot size (in pixels)
        p.trial.(sn).hTargs(kTarg).dotSize   = p.trial.(sn).dotSize * ppd; % pixels
        % dot speed (in pixels/frame)
        p.trial.(sn).hTargs(kTarg).dotSpeed  = p.trial.(sn).dotSpeed * ppd / fps; % pixels/frame
        % % dot color
        p.trial.(sn).hTargs(kTarg).dotColor  = p.trial.display.bgColor + p.trial.(sn).dotContrast;
        % aperture radius (pixels)
        p.trial.(sn).hTargs(kTarg).radius    = p.trial.(sn).dotApertureRadius * ppd;
        % number of dots (integer value, calculate from dot density)
        p.trial.(sn).hTargs(kTarg).numDots = ceil(p.trial.(sn).dotDensity * pi * p.trial.(sn).dotApertureRadius^2 / fps);
        
        % calculate position (currently this is based on polar coordinates with respect to an "RF CENTER")
        [th, rho] = cart2pol(p.trial.(sn).RfCenterXy(1),p.trial.(sn).RfCenterXy(2));
        th = th + p.trial.(sn).CenterAngle(kTarg)/180*pi;
        [xDeg, yDeg] = pol2cart(th, rho);
        p.trial.(sn).hTargs(kTarg).position    = [xDeg, -1*yDeg] * ppd + ctr;
    
        % direction
        n = p.trial.(sn).numDirs; % number of directions/choice targets
    
        if kTarg > 1 && p.trial.(sn).yokeDirections
            p.trial.(sn).direction(kTarg) = wrapTo360(p.trial.(sn).direction(kTarg-1) - 180);
        else
            p.trial.(sn).direction(kTarg) = ceil(rand(setupRNG)*n)/n*360;
        end
        p.trial.(sn).hTargs(kTarg).dotDirection(1) = p.trial.(sn).direction(kTarg);
    %----------------------------------------------------------------------
    % IS GABOR?
    elseif isa(p.trial.(sn).hTargs(kTarg), 'stimuli.objects.gaborTarget')
%         p.trial.(sn).hTargs(kTarg).setup(p)
        
        % calculate position
        [th, rho] = cart2pol(p.trial.(sn).RfCenterXy(1),p.trial.(sn).RfCenterXy(2));
        th = th + p.trial.(sn).CenterAngle(kTarg)/180*pi;
        [xDeg, yDeg] = pol2cart(th, rho);
        p.trial.(sn).hTargs(kTarg).position    = [xDeg, -1*yDeg] * ppd + ctr;
        p.trial.(sn).hTargs(kTarg).position 
        % direction
        n = p.trial.(sn).numDirs; % number of directions/choice targets
    
        if kTarg > 1 && p.trial.(sn).yokeDirections
            p.trial.(sn).direction(kTarg) = wrapTo360(p.trial.(sn).direction(kTarg-1) - 180);
        else
            p.trial.(sn).direction(kTarg) = ceil(rand(setupRNG)*n)/n*360;
        end
        p.trial.(sn).hTargs(kTarg).theta = p.trial.(sn).direction(kTarg);
        
        p.trial.(sn).hTargs(kTarg).sf = p.trial.(sn).sf;
        p.trial.(sn).hTargs(kTarg).sigma = p.trial.(sn).dotApertureRadius / 7.5; % divide by 7.5 because of standard deviations of a gaussian? why did this look right?
        p.trial.(sn).hTargs(kTarg).contrast = p.trial.(sn).contrast;
        p.trial.(sn).hTargs(kTarg).tf = p.trial.(sn).tf;
        p.trial.(sn).hTargs(kTarg).phase = rand(setupRNG)*360; % we're randomizing phase... do we want to
    end
        
    
end

% (re-)initialize dots
p.trial.(sn).dotRNG = rng();
for kTarg = 1:numApertures
    p.trial.(sn).hTargs(kTarg).trialSetup(p);
end

% --- setup reward for the trial

%********* This is where we could build in a contingency on past choices
% switched DotsNRewarded to a vector for easier implentation
p.trial.(sn).isRewarded(1) = rand(setupRNG) < p.trial.(sn).rewardDot1Rate;
p.trial.(sn).isRewarded(2) = rand(setupRNG) < p.trial.(sn).rewardDot2Rate;

% assign a color to the window for each target depending on which one is rewarded
for kTarg = 1:numel(p.trial.(sn).hTargs)
    p.trial.(sn).hTargs(kTarg).winRadius = p.trial.(sn).targWinRadius*p.trial.display.ppd;
    if p.trial.(sn).isRewarded(kTarg)
        p.trial.(sn).hTargs(kTarg).wincolor = p.trial.display.clut.greenbg;
    else
        p.trial.(sn).hTargs(kTarg).wincolor = p.trial.display.clut.redbg;
    end
end

%****************************
% initialize some measurements of interest
p.trial.(sn).holdXY = nan(1,2); % x,y position of fixation
p.trial.(sn).holdDuration = 0;

% --- Reward
p.trial.(sn).error = 1; % default to "never obtained fixation"

        
% --- Face for aditional reward
p.trial.(sn).hFace.texSize  = 2 * ppd;
p.trial.(sn).hFace.position = ctr;
p.trial.(sn).hFace.id       = p.trial.(sn).faceIndex;

% --- Setup State machine (This runs all the state transitions)
p.trial.(sn).states = stimuli.objects.stateControl();
p.trial.(sn).states.addState(stimuli.modules.targetselection.state0_FixWait)
p.trial.(sn).states.addState(stimuli.modules.targetselection.state1_FixGracePeriod)
p.trial.(sn).states.addState(stimuli.modules.targetselection.state2_preStim)
p.trial.(sn).states.addState(stimuli.modules.targetselection.state3_showStim)
p.trial.(sn).states.addState(stimuli.modules.targetselection.state4_Choice)
p.trial.(sn).states.addState(stimuli.modules.targetselection.state5_HoldChoice)
p.trial.(sn).states.addState(stimuli.modules.targetselection.state7_BreakFixTimeout)
p.trial.(sn).states.addState(stimuli.modules.targetselection.state8_InterTrialInterval)

p.trial.(sn).states.setState(0); % initialize state

  % 'rewardcount',    p.trial.(sn).rewardcount, ...       % added JM
  % 'rewardtravel',   p.trial.(sn).rewardtravel, ...      % added JM
  % 'rewardtransit',  p.trial.(sn).rewardtransit);

% allocate some variables
p.trial.(sn).frameFixationObtained = nan;
p.trial.(sn).preStimWaitFrames     = round(p.trial.(sn).fixPreStimDuration * p.trial.display.frate);
p.trial.(sn).dotsChosen            = nan;
p.trial.(sn).rewardAmount          = p.trial.(sn).maxRewardCnt; % will be overwritten by the choice

