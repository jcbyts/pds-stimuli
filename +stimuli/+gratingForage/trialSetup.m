function trialSetup(p, sn)

	if nargin < 2
		sn = 'stimulus';
	end

p.trial.pldaps.goodtrial = 1; % trial is listed as good

ppd   = p.trial.display.ppd;        % pixels per degree (linear approximation)
ctr   = p.trial.display.ctr(1:2);   % center of the screen

% --- Random seed
p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
setupRNG=p.trial.(sn).rngs.conditionerRNG;


% --- Face for aditional reward
p.trial.(sn).hFace.size     = 2 * p.trial.(sn).faceRadius * ppd;
p.trial.(sn).hFace.position = p.trial.(sn).hFix(1).position;
p.trial.(sn).hFace.id       = p.trial.(sn).faceIndex;

% --- Reward
p.trial.(sn).hReward.defaultAmount = p.trial.behavior.reward.defaultAmount;
p.trial.(sn).hReward.iTrial        = p.trial.pldaps.iTrial;

% --- Setup dot motion trial
% the @trial object (initially in state 0)
% hFix,hDots,hChoice,hCue,hFace,hReward,
p.trial.(sn).hTrial = stimuli.fixflash.fixFlashTrial( ...
  p.trial.(sn).hGratings, p.trial.(sn).hFace, p.trial.(sn).hReward, ...
  'fixWinRadius',p.trial.(sn).fixWinRadius, ...
  'fixGracePeriod',p.trial.(sn).fixGracePeriod, ...
  'fixDuration', p.trial.(sn).minFixDuration, ...
  'trialTimeout',p.trial.(sn).trialTimeout, ...
  'iti',p.trial.(sn).iti);
end