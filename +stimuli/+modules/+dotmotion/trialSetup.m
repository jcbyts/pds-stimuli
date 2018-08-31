function trialSetup(p, sn)

	if nargin < 2
		sn = 'stimulus';
	end

p.trial.pldaps.goodtrial = 1;

ppd   = p.trial.display.ppd;        % pixels per degree (linear approximation)
fps   = p.trial.display.frate;      % frames per second
ctr   = p.trial.display.ctr(1:2);   % center of the screen

% --- Set Fixation Point Properties

% set color
ctrColor = p.trial.(sn).fixation.ctrColor;
if isfield(p.trial.(sn).fixation, 'surColor')
    surColor = p.trial.(sn).fixation.surColor;
else
    surColor = 1 - ctrColor;
end

% dim color
ctrColorDim = p.trial.(sn).fixation.dim * (ctrColor - p.trial.display.bgColor) + p.trial.display.bgColor;
surColorDim = p.trial.(sn).fixation.dim * (surColor - p.trial.display.bgColor) + p.trial.display.bgColor;

% get four free entries in the color lookup table
clutIx = pds.pldaps.draw.getOpenClutEntries(p, 4);
offset = 1;
% center color
p.trial.display.humanCLUT(clutIx(1)+offset,:)  = ctrColor;
p.trial.display.monkeyCLUT(clutIx(1)+offset,:) = ctrColor;
p.trial.display.clut.fixCtrColor = clutIx(1)*ones(size(p.trial.display.clut.bg));
% surround color (fixation point is a bullseye)
p.trial.display.humanCLUT(clutIx(2)+offset,:)  = surColor;
p.trial.display.monkeyCLUT(clutIx(2)+offset,:) = surColor;
p.trial.display.clut.fixSurColor = clutIx(2)*ones(size(p.trial.display.clut.bg));
% center color (Dimmed)
p.trial.display.humanCLUT(clutIx(3)+offset,:)  = ctrColorDim;
p.trial.display.monkeyCLUT(clutIx(3)+offset,:) = ctrColorDim;
p.trial.display.clut.fixCtrColorDim = clutIx(3)*ones(size(p.trial.display.clut.bg));
% surround color (Dimmed)
p.trial.display.humanCLUT(clutIx(4)+offset,:)  = surColorDim;
p.trial.display.monkeyCLUT(clutIx(4)+offset,:) = surColorDim;
p.trial.display.clut.fixSurColorDim = clutIx(4)*ones(size(p.trial.display.clut.bg));

sz = p.trial.(sn).fixation.radius * ppd;
p.trial.(sn).fixation.hFix.radius      = sz;
p.trial.(sn).fixation.hFix.winRadius   = p.trial.(sn).fixation.winRadius * ppd;
p.trial.(sn).fixation.hFix.wincolor    = p.trial.display.clut.window;
p.trial.(sn).fixation.hFix.ctrColor    = p.trial.display.clut.fixCtrColor;
p.trial.(sn).fixation.hFix.color       = p.trial.display.clut.fixSurColor;
p.trial.(sn).fixation.hFix.position   = [0,0] * ppd + p.trial.display.ctr(1:2);

% --- Random seed
p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));

setupRNG=p.trial.(sn).rngs.conditionerRNG;

% --- Setup Timing

% post fix obtained wait for stimulus
tau  = p.trial.(sn).timing.fixPreStimTau;
tmax = p.trial.(sn).timing.maxFixPreStim;
p.trial.(sn).timing.t_fixPreStimDuration = generate_truncated_exponential(setupRNG, tau, 0, tmax);

% post stimulus onset fixation duration
tau  = p.trial.(sn).timing.fixPostStimTau;
tmax = p.trial.(sn).timing.maxFixPostStim;
p.trial.(sn).timing.t_fixPostStimDuration = generate_truncated_exponential(setupRNG, tau, 0, tmax);

% stimulus duration
tau  = p.trial.(sn).timing.stimDurationTau;
tmax = p.trial.(sn).timing.maxStimDuration;
p.trial.(sn).timing.t_stimDuration = generate_truncated_exponential(setupRNG, tau, 0, tmax);

% set the fix hold duration to the fix on post-stim duration
if ~isfield(p.trial.(sn).timing, 'fixHoldDuration')
    p.trial.(sn).timing.fixHoldDuration = p.trial.(sn).timing.t_fixPostStimDuration;
end

% cue onset (wrt motion)
% cue delay (uniform distribution)
rnd=rand(setupRNG);
p.trial.(sn).timing.t_cueOnset = (1-rnd) * p.trial.(sn).timing.minCueOnset + rnd * (p.trial.(sn).timing.maxCueOnset - p.trial.(sn).timing.minCueOnset);

% choice target onset (wrt fixation obtained)
tau  = p.trial.(sn).timing.choiceTargetOnsetTau;
tmax = p.trial.(sn).timing.maxChoiceTargetOnset;
p.trial.(sn).timing.t_targetOnset = generate_truncated_exponential(setupRNG, tau, 0, tmax);


% --- setup trial difficulty (FIX ME: move these to a proper condition struct)
if ~isfield(p.trial.(sn).motion, 'bandwidth') % need to set difficulty parameter
    switch class(p.trial.(sn).motion.hMot)
        case {'stimuli.objects.dotsbase', 'stimuli.objects.dotsUniform'}
            
            rnd=randi(setupRNG, p.trial.(sn).motion.numBandwidths, 1) / p.trial.(sn).motion.numBandwidths;
            p.trial.(sn).motion.bandwidth = (1-rnd) * p.trial.(sn).minBandwidth + rnd * p.trial.(sn).maxBandwidth;
            
        otherwise
            error('trialSetup: I don''t recognize this type of motion stimulus')
    end
    
end


% --- Draw Direction
if ~isfield(p.trial.(sn).motion, 'direction')
    if isfield(p.trial.(sn).motion, 'directionprior')
        p.trial.(sn).motion.direction = p.trial.(sn).motion.directionprior.drawfromprior();
    else
        % draw direction with uniform probability from discrete number of
        % directions
        n = p.trial.(sn).motion.numDirs; % number of directions/choice targets
        p.trial.(sn).motion.direction = ceil(rand(setupRNG)*n)/n*360;
        warning('trialSetup: trialDirection needs to be set with a condition or a directionprior object!!')
    end
end

% --- setup motion
switch class(p.trial.(sn).motion.hMot)
    case 'stimuli.objects.dotsUniform'
        
        
        % set number of dots based on density
        apertureArea = p.trial.(sn).motion.radius^2 * pi;
        numDots = ceil(p.trial.(sn).motion.dotDensity * apertureArea  / fps);
        p.trial.(sn).motion.hMot.numDots     = numDots; 
        
        % setup object with parameters in pixels and frames (instead of
        % degrees and seconds)
        p.trial.(sn).motion.hMot.radius      = p.trial.(sn).motion.radius * ppd;
        p.trial.(sn).motion.hMot.dotSize     = p.trial.(sn).motion.dotSize  * ppd; % pixels
        p.trial.(sn).motion.hMot.speed    = p.trial.(sn).motion.dotSpeed * ppd / fps;
        p.trial.(sn).motion.hMot.lifetime = p.trial.(sn).motion.dotLifetime;
        p.trial.(sn).motion.hMot.range       = p.trial.(sn).motion.bandwidth;
        
        
        % set the dot color using the color lookup table (for overlay)
        clutIx = pds.pldaps.draw.getOpenClutEntries(p, 1);
        p.trial.display.humanCLUT(clutIx+1,:)  = p.trial.(sn).motion.dotContrast * [1 1 1] + .5;
        p.trial.display.monkeyCLUT(clutIx+1,:) = p.trial.(sn).motion.dotContrast * [1 1 1] + .5;
        p.trial.display.clut.dotColor = clutIx*ones(size(p.trial.display.clut.bg));
        
        p.trial.(sn).motion.hMot.dotColor     = p.trial.display.clut.dotColor;
        
        p.trial.(sn).motion.hMot.direction = p.trial.(sn).motion.direction;
        
        % do not treat as a target (e.g., check for fixations)
        p.trial.(sn).motion.hMot.tracked = false;
        
        xy = [p.trial.(sn).motion.xPos; p.trial.(sn).motion.yPos];
        p.trial.(sn).motion.hMot.position = pds.deg2px(xy, p.trial.display.viewdist, p.trial.display.w2px)' + p.trial.display.ctr(1:2);
        
        
    otherwise
        error('trialSetup: I don''t recognize this type of motion stimulus')
end
   
% initialize object
p.trial.(sn).motion.hMot.setRandomSeed(p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
p.trial.(sn).motion.hMot.trialSetup(p);

% --- Choice targets
assert(isa(p.trial.(sn).targets.hTargs, 'stimuli.objects.circles'), 'trialSetup: target object is unrecognized type. Must be stimuli.objects.circles')
n  = p.trial.(sn).motion.numDirs;
r  = p.trial.(sn).targets.eccentricity * ppd;

clutIx = pds.pldaps.draw.getOpenClutEntries(p, 1);
p.trial.display.humanCLUT(clutIx+offset,:)  = p.trial.display.bgColor + p.trial.(sn).targets.contrast;
p.trial.display.monkeyCLUT(clutIx+offset,:) = p.trial.display.bgColor + p.trial.(sn).targets.contrast;
p.trial.display.clut.targetColor = clutIx(1)*ones(size(p.trial.display.clut.bg));

targetColor = p.trial.display.clut.targetColor;

if n > 22 % draw a ring
    
    % the ring is centered at fixation
    p.trial.(sn).targets.hTargs.position = p.trial.(sn).fixation.hFix.position;
    p.trial.(sn).targets.hTargs.color = targetColor;
    % radius of the ring is eccentricity of targets
    p.trial.(sn).targets.hTargs.radius = r;
    % thickness of the ring is the radius of targets
    p.trial.(sn).targets.hTargs.weight = p.trial.(sn).targets.radius * ppd;
    
else % draw discrete targets
    warning('trialSetup: should this use a direction prior object to get the conditions?')
    th = (0:n-1) * (2*pi/n); % discretization of the thetas

    [x,y] = pol2cart(th, r);

    sz = p.trial.(sn).targets.radius * ppd;
    p.trial.(sn).targets.hTargs.radius = repmat(sz,1,n);
    p.trial.(sn).targets.hTargs.position   = [x; -1*y]' + repmat(ctr,n,1);    
    p.trial.(sn).targets.hTargs.color      = targetColor;
    p.trial.(sn).targets.hTargs.weight     = []; % fill 

end

% --- Choice cue (Gabor) -- per acuity task... why!?
th = p.trial.(sn).motion.direction * pi / 180;

[x,y] = pol2cart(th, r); % same r as for the targets

switch class(p.trial.(sn).cue.hCue)
    case 'stimuli.objects.gaborTarget'
        p.trial.(sn).cue.hCue
        p.trial.(sn).cue.hCue.setup(p); % setup with pldaps
        p.trial.(sn).cue.hCue.position = p.trial.display.ctr(1:2) + [x y];
        p.trial.(sn).cue.hCue.theta = p.trial.(sn).motion.direction;
        p.trial.(sn).cue.hCue.sf = 1;
        p.trial.(sn).cue.hCue.sigma = .25;
        p.trial.(sn).cue.hCue.contrast = .5;
        p.trial.(sn).cue.hCue.tf = p.trial.(sn).motion.dotSpeed;
        p.trial.(sn).cue.hCue.phase = randi(360);
    otherwise
        error('trialSetup: unrecognized cue object format')
end
        
% --- Feedback for correct / incorrect choices...
p.trial.(sn).feedback.hErr.position  = p.trial.(sn).cue.hCue.position;
p.trial.(sn).feedback.hErr.radius    = p.trial.(sn).feedback.radius * ppd;
p.trial.(sn).feedback.hFace.position = p.trial.(sn).cue.hCue.position;
p.trial.(sn).feedback.hFace.radius   = p.trial.(sn).feedback.radius * ppd;
p.trial.(sn).feedback.hFace.setRandomSeed;
idx = randi(p.trial.(sn).feedback.hFace.rng, p.trial.(sn).feedback.hFace.numTex);
p.trial.(sn).feedback.hFace.id = p.trial.(sn).feedback.hFace.texIds{idx};

% make sure all stimuli are off
p.trial.(sn).feedback.hErr.stimValue = 0;
p.trial.(sn).feedback.hFace.stimValue = 0;
p.trial.(sn).cue.hCue.stimValue = 0;
p.trial.(sn).targets.hTargs.stimValue = 0;

ifi = p.trial.display.ifi;

% update the reward function here
p.trial.(sn).reward.function     = str2func(sprintf('@(err) ceil( %d * exp( -err.^2/2*%d^2))', p.trial.(sn).reward.maxNumber, p.trial.(sn).reward.windowWidth));

% --- Setup State machine (This runs all the state transitions)
p.trial.(sn).states = stimuli.modules.dotmotion.trialstates(...
    p.trial.(sn).fixation.hFix, ...
    p.trial.(sn).motion.hMot, ...
    p.trial.(sn).targets.hTargs,...
    p.trial.(sn).cue.hCue, ...
    p.trial.(sn).feedback.hErr, ...
    p.trial.(sn).feedback.hFace, ...
    'timeTrialTimeout', ceil(p.trial.(sn).timing.trialTimeout / ifi), ...
    'timeFixGracePeriod', ceil(p.trial.(sn).timing.fixGracePeriod / ifi), ...
    'timeTargOnset', ceil(p.trial.(sn).timing.t_targetOnset / ifi), ...
    'timeMotionOnset', ceil(p.trial.(sn).timing.t_fixPreStimDuration / ifi), ...
    'timeMotionOffset', ceil(p.trial.(sn).timing.t_stimDuration / ifi), ...
    'timeCueOnset', ceil(p.trial.(sn).timing.t_cueOnset / ifi), ...
    'timeFixationOffset', ceil(p.trial.(sn).timing.t_fixPostStimDuration / ifi), ...
    'timeStopFixationHold', ceil(p.trial.(sn).timing.fixHoldDuration / ifi), ...
    'timeChoiceGracePeriod', ceil(p.trial.(sn).timing.choiceGracePeriod / ifi), ...
    'timeWaitForChoice', ceil(p.trial.(sn).timing.choiceWaitTimeout / ifi), ...
    'timeChoiceHold', ceil(p.trial.(sn).timing.choiceHold / ifi), ...
    'timeFeedback', ceil(p.trial.(sn).timing.t_targetOnset / ifi), ...
    'timeITI', ceil(p.trial.(sn).timing.iti / ifi), ...
    'windowMinEcc', (p.trial.(sn).targets.windowMinEcc * p.trial.display.ppd), ...
    'windowMaxEcc', (p.trial.(sn).targets.windowMaxEcc * p.trial.display.ppd), ...
    'rewardCnt', 0, ...
    'rewardFun', p.trial.(sn).reward.function);

p.trial.(sn).states.addState(stimuli.modules.dotmotion.state0_FixWait)
p.trial.(sn).states.addState(stimuli.modules.dotmotion.state1_FixGracePeriod)
p.trial.(sn).states.addState(stimuli.modules.dotmotion.state2_FixPreStim)
p.trial.(sn).states.addState(stimuli.modules.dotmotion.state3_ShowMotion)
p.trial.(sn).states.addState(stimuli.modules.dotmotion.state4_Choice)
p.trial.(sn).states.addState(stimuli.modules.dotmotion.state5_HoldChoice)
p.trial.(sn).states.addState(stimuli.modules.dotmotion.state6_Feedback)
p.trial.(sn).states.addState(stimuli.modules.dotmotion.state7_BreakFixTimeout)
p.trial.(sn).states.addState(stimuli.modules.dotmotion.state8_InterTrialInterval)

p.trial.(sn).states.setState(0);

% --- Preallocate logging variables
p.trial.(sn).frameFixationObtained = nan;
p.trial.(sn).choice = nan;
p.trial.(sn).error = nan;

% pds.datapixx.init(p); % reinitialize color lookup tables


function texp = generate_truncated_exponential(setupRNG, tau, tmin, tmax)

if nargin < 4
    tmax = inf;
end

if nargin < 3
    tmin = 0;
end

tdur = tmax - tmin; % truncation point
% stop the while loop from running for ever
infLoopStopper = 100; itr = 1; 
r = inf;

% re-generate exponential random numbers that are less than the truncation
while r > tdur

    r = exprnd(setupRNG, tau, [1 1]); % call to the pep exprnd function
    
    if itr > infLoopStopper
        r = tdur;
        break
    end
        
    itr = itr + 1;
end

texp = tmin + r;
