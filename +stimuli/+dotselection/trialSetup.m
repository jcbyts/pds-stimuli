function trialSetup(p, sn)

	if nargin < 2
		sn = 'stimulus';
	end

p.trial.pldaps.goodtrial = 1;

% --- Useful constants
ppd   = p.trial.display.ppd;        % pixels per degree (linear approximation)
fps   = p.trial.display.frate;      % frames per second
ctr   = p.trial.display.ctr(1:2);   % center of the screen

% --- Random seed
p.trial.(sn).rngs.conditionerRNG = RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
setupRNG = p.trial.(sn).rngs.conditionerRNG;


% -------------------------------------------------------------------------
% FIXATION POINT TIMING / PROPERTIES

% --- Set Fixation Point Properties    
sz = p.trial.(sn).fixPointRadius * ppd;
p.trial.(sn).hFix(1).cSize      = sz;
p.trial.(sn).hFix(1).sSize      = 2*sz;
p.trial.(sn).hFix(1).cColour    = zeros(1,3);
p.trial.(sn).hFix(1).sColour    = ones(1,3);
p.trial.(sn).hFix(1).position   = p.trial.(sn).fixPointXy * ppd + p.trial.display.ctr(1:2);

p.trial.(sn).hFix(2).cSize      = sz;
p.trial.(sn).hFix(2).sSize      = 2*sz;
p.trial.(sn).hFix(2).cColour    = p.trial.display.bgColor + p.trial.(sn).fixPointDim;
p.trial.(sn).hFix(2).sColour    = p.trial.display.bgColor + p.trial.(sn).fixPointDim;
p.trial.(sn).hFix(2).position   = p.trial.(sn).fixPointXy * ppd + ctr;



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
    rnd = rand(setupRNG);
    r   = -mu .* log(rnd) + p.trial.(sn).minFixPostStim; % new exponential random number
    if itr > infLoopStopper
        r = p.trial.(sn).maxFixPostStim;
        break
    end
        
    itr = itr + 1;
end

p.trial.(sn).fixPostStimDuration = r;

% -------------------------------------------------------------------------
% DOTS: PROPERTIES

% --- setup trial difficulty
if p.trial.(sn).numBandwidths > 1
    rnd=randi(p.trial.(sn).numBandwidths, 1) / p.trial.(sn).numBandwidths;
    p.trial.(sn).bandwdth = (1-rnd) * p.trial.(sn).minBandwidth + rnd * p.trial.(sn).maxBandwidth; 
end

% --- setup dots
numDotApertures = numel(p.trial.(sn).hDots);
assert(numDotApertures==2, 'This code is not designed for more than 2 apertures')


for kDots = 1:numDotApertures
    
    % dot mode (coherence or sample from distribution)
    p.trial.(sn).hDots(kDots).mode      = p.trial.(sn).dotMode;
    
    % dot distribution
    p.trial.(sn).hDots(kDots).dist      = p.trial.(sn).dotDist;
    
    % dot Range / Bandwidth
    p.trial.(sn).hDots(kDots).bandwdth  = p.trial.(sn).dotBandwidth;
    
    % dot lifetime
    p.trial.(sn).hDots(kDots).lifetime  = p.trial.(sn).dotLifetime;
    
    % dot size (in pixels)
    p.trial.(sn).hDots(kDots).size      = p.trial.(sn).dotSize * ppd; % pixels
    
    % dot speed (in pixels/frame)
    p.trial.(sn).hDots(kDots).speed     = p.trial.(sn).dotSpeed * ppd / fps; % pixels/frame
    
    % % dot color
    p.trial.(sn).hDots(kDots).colour       = p.trial.display.bgColor + p.trial.(sn).dotContrast;
    
    % aperture radius (pixels)
    p.trial.(sn).hDots(kDots).maxRadius = p.trial.(sn).dotApertureRadius * ppd;
    
    % number of dots (integer value, calculate from dot density)
    p.trial.(sn).hDots(kDots).numDots = ceil(p.trial.(sn).dotDensity * pi * p.trial.(sn).dotApertureRadius^2 / fps);
    
    % calculate position
    [th, rho] = cart2pol(p.trial.(sn).RfCenterXy(1),p.trial.(sn).RfCenterXy(2));
    
    th = th + p.trial.(sn).DotCenterAngle(kDots)/180*pi;
    [xDeg, yDeg] = pol2cart(th, rho);
    p.trial.(sn).hDots(kDots).position     = [xDeg, -1*yDeg] * ppd + ctr;
    
    % direction
    n = p.trial.(sn).numDirs; % number of directions/choice targets
    
    if kDots > 1 && p.trial.(sn).yokeDirections
        p.trial.(sn).direction(kDots) = wrapTo360(p.trial.(sn).direction(kDots-1) - 180);
    else
        p.trial.(sn).direction(kDots) = ceil(rand(setupRNG)*n)/n*360;
    end
    p.trial.(sn).hDots(kDots).direction(1) = p.trial.(sn).direction(kDots);
    
end

% (re-)initialize dots
p.trial.(sn).dotRNG = rng();
for kDot = 1:numDotApertures
    p.trial.(sn).hDots(kDot).beforeTrial();
end

% --- setup reward for the trial
p.trial.(sn).Dots1Rewarded = rand(setupRNG) < p.trial.(sn).rewardDot1Rate;
p.trial.(sn).Dots2Rewarded = rand(setupRNG) < p.trial.(sn).rewardDot2Rate;

% --- Face for aditional reward
p.trial.(sn).hFace.texSize  = 2 * ppd;
p.trial.(sn).hFace.position = ctr;
p.trial.(sn).hFace.id       = p.trial.(sn).faceIndex;

% --- Reward
p.trial.(sn).hReward.defaultAmount = p.trial.behavior.reward.defaultAmount;
p.trial.(sn).hReward.iTrial        = p.trial.pldaps.iTrial;

% --- Setup Trial Object (This runs all the state transitions)
% the @trial object (initially in state 0)
p.trial.(sn).hTrial = stimuli.dotselection.dotMotionTrial( ...
  p.trial.(sn).hFix, ...
  p.trial.(sn).hDots,...
  p.trial.(sn).hFace, ...
  p.trial.(sn).hReward, ...
  p.trial.display.ppd, ...
  p.trial.display.ctr(1:2), ...
  'fixWinRadius',    p.trial.(sn).fixWinRadius, ...
  'fixGracePeriod',  p.trial.(sn).fixGracePeriod, ...
  'fixHoldPreStim',  p.trial.(sn).fixPreStimDuration, ...
  'fixFlashCnt',     p.trial.(sn).fixFlashCnt, ...
  'fixHoldPostStim', p.trial.(sn).fixPostStimDuration, ...
  'choiceHoldDuration',  p.trial.(sn).choiceHoldDuration, ...
  'rewardWindow',    p.trial.(sn).rewardWindow, ... % think about this parameter name
  'choiceTimeout',   p.trial.(sn).choiceTimeout, ...
  'trialTimeout',    p.trial.(sn).trialTimeout, ...
  'DotsRewarded',   [p.trial.(sn).Dots1Rewarded p.trial.(sn).Dots2Rewarded], ...
  'iti',0, ...
  'maxRewardCnt',   p.trial.(sn).maxRewardCnt, ...
  'viewpoint',      false);
