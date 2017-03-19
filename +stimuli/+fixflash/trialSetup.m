function trialSetup(p, sn)

	if nargin < 2
		sn = 'stimulus';
	end

p.trial.pldaps.goodtrial = 1;

ppd   = p.trial.display.ppd;        % pixels per degree (linear approximation)
% fps   = p.trial.display.frate;      % frames per second
ctr   = p.trial.display.ctr(1:2);   % center of the screen

% --- Set Fixation Point Properties    
sz = p.trial.(sn).fixPointRadius * ppd;
p.trial.(sn).hFix(1).cSize      = sz;
p.trial.(sn).hFix(1).sSize      = 2*sz;
p.trial.(sn).hFix(1).cColour    = zeros(1,3);
p.trial.(sn).hFix(1).sColour    = ones(1,3);
p.trial.(sn).hFix(1).position   = [0,0] * ppd + ctr;

p.trial.(sn).hFix(2).cSize      = sz;
p.trial.(sn).hFix(2).sSize      = 2*sz;
p.trial.(sn).hFix(2).cColour    = p.trial.display.bgColor + p.trial.(sn).fixPointDim;
p.trial.(sn).hFix(2).sColour    = p.trial.display.bgColor + p.trial.(sn).fixPointDim;
p.trial.(sn).hFix(2).position   = p.trial.(sn).hFix(1).position;

% --- Random seed
p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
setupRNG=p.trial.(sn).rngs.conditionerRNG;

% fixation duration
rnd=rand(setupRNG);
p.trial.(sn).fixDuration = (1 - rnd) * p.trial.(sn).minFixDuration + rnd * p.trial.(sn).maxFixDuration;

assert(p.trial.display.colorclamp | p.trial.display.normalizeColor, 'color range not [0-1]')

% --- Feedback for incorrect choices...
p.trial.(sn).hFbk.size      = 2 * p.trial.(sn).feedbackApertureRadius * ppd;
p.trial.(sn).hFbk.position  = p.trial.(sn).hFix(1).position;
p.trial.(sn).hFbk.colour    = p.trial.display.bgColor + p.trial.(sn).feedbackApertureContrast;
p.trial.(sn).hFbk.weight    = 4;

% --- Face for aditional reward
p.trial.(sn).hFace.size     = 2 * p.trial.(sn).faceRadius * ppd;
p.trial.(sn).hFace.position = p.trial.(sn).hFix(1).position;
p.trial.(sn).hFace.id       = p.trial.(sn).faceIndex;

% --- Setup dot motion trial
% the @trial object (initially in state 0)
% hFix,hDots,hChoice,hCue,hFace,hReward,
p.trial.(sn).hTrial = stimuli.fixflash.fixFlashTrial( ...
  p.trial.(sn).hFix,p.trial.(sn).hFbk,p.trial.(sn).hFace, p, ...
  'fixWinRadius',p.trial.(sn).fixWinRadius, ...
  'fixGracePeriod',p.trial.(sn).fixGracePeriod, ...
  'fixDuration',p.trial.(sn).fixDuration, ...
  'fixFlashCnt',p.trial.(sn).fixFlashCnt, ...
  'holdDuration',p.trial.(sn).holdDuration, ...
  'trialTimeout',p.trial.(sn).trialTimeout, ...
  'iti',0, ...
  'maxRewardCnt',p.trial.(sn).maxRewardCnt, ...
  'viewpoint',false);
