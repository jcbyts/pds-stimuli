function trialSetup(p, sn)
% TRIALSETUP sets up the parameters for the upcoming FIXFLASH trial

if nargin < 2
    sn = 'fixflash';
end

p.trial.pldaps.goodtrial = 1; % trial is listed as good (until otherwise specified)

ppd   = p.trial.display.ppd;        % pixels per degree (linear approximation)
ctr   = p.trial.display.ctr(1:2);   % center of the screen

% --- Random seed
if isfield(p.trial.(sn),'rngs') && isfield(p.trial.(sn).rngs, 'conditionerRNG')
    p.trial.(sn).rngs.conditionerRNG.reset; % reset saved stream
else
    p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
end
setupRNG=p.trial.(sn).rngs.conditionerRNG;

% --- Fixation position
if p.trial.(sn).fixationJitter
    xpos = p.trial.(sn).fixationJitterSize * randn(setupRNG) + p.trial.(sn).fixationX;
    ypos = p.trial.(sn).fixationJitterSize * randn(setupRNG) + p.trial.(sn).fixationY;
else
    xpos = p.trial.(sn).fixationX;
    ypos = p.trial.(sn).fixationY;
end

% --- Set Fixation Point Properties
sz = p.trial.(sn).fixPointRadius * ppd;
p.trial.(sn).hFix.radius     = sz;
p.trial.(sn).hFix.color      = ones(1,3);
% p.trial.(sn).hFix.ctrColor   = -ones(1,3);
p.trial.(sn).hFix.xyPix      = [xpos ypos] * ppd + ctr;
p.trial.(sn).hFix.winRadius  = p.trial.(sn).fixWinRadius * ppd;
p.trial.(sn).hFix.wincolor   = p.trial.display.clut.bg_white;

% fixation duration
p.trial.(sn).fixDuration = p.trial.(sn).minFixDuration;

% initialize some measurements of interest
p.trial.(sn).holdXY = nan(1,2); % x,y position of fixation
p.trial.(sn).holdDuration = 0;

% --- Face for reward feedback
p.trial.(sn).hFace.texSize  = 2 * p.trial.(sn).faceRadius * ppd;
p.trial.(sn).hFace.position = p.trial.(sn).hFix.xyPix;
p.trial.(sn).hFace.id       = p.trial.(sn).faceIndex;

% --- Reward
p.trial.(sn).error = 1; % default to "never obtained fixation"

% -------------------------------------------------------------------------
% --- Setup trial state machine

% behavior on this module progresses through a set of states, starting with
% state 1
p.trial.(sn).states = stimuli.stateControl();
p.trial.(sn).states.addState(stimuli.fixflash.state0_FixWait(0))
p.trial.(sn).states.addState(stimuli.fixflash.state1_FixGracePeriod(1))
p.trial.(sn).states.addState(stimuli.fixflash.state2_FixHold(2))
p.trial.(sn).states.addState(stimuli.fixflash.state7_BreakFixTimeout(7))
p.trial.(sn).states.addState(stimuli.fixflash.state8_InterTrialInterval(8))

p.trial.(sn).states.setState(0); % initialize state machine
end