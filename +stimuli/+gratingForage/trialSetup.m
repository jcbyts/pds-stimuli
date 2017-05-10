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

% --- Necessary parameters for fixation noise
p.trial.(sn).hNoise.position = [0 0];
p.trial.(sn).hNoise.alpha = .5;
p.trial.(sn).hNoise.id = randi(p.trial.(sn).nOrientations);
p.trial.(sn).hNoise.size = ceil(3*p.trial.(sn).noiseRadius*p.trial.display.ppd)*[1 1];

% --- Setup gratings
p.trial.(sn).hGratings.id = randi(p.trial.(sn).nOrientations, 1, p.trial.(sn).nGratings);
p.trial.(sn).hGratings.size = ceil(2.5*p.trial.(sn).gratingRadius*p.trial.display.ppd)*[1 1];

infiniteLoopStopper = 1e4;

pos = rand(setupRNG, 2,p.trial.(sn).nGratings)*20-10;
for kPos = 2:p.trial.(sn).nGratings
    
    pos(:,kPos) = rand(setupRNG, 2,1)*20 - 10;
    
    r = sqrt((pos(1,1:(kPos-1)) - pos(1,kPos)).^2 + (pos(2,1:(kPos-1)) - pos(2,kPos)).^2);
    loopCounter = 1;
    while any(r < p.trial.(sn).gratingBuffer)
        pos(:,kPos) = rand(setupRNG, 2,1)*10 - 5;
        r = sqrt((pos(1,1:(kPos-1)) - pos(1,kPos)).^2 + (pos(2,1:(kPos-1)) - pos(2,kPos)).^2);
    
        loopCounter = loopCounter + 1;
        if loopCounter > infiniteLoopStopper
            disp('Infinite Loop stopped')
            break
        end
    end
end

% --- Necessary parameters for foraged gratings
p.trial.(sn).hGratings.position = bsxfun(@plus, pds.deg2px(pos, p.trial.display.viewdist, p.trial.display.w2px)', p.trial.display.ctr(1:2));
p.trial.(sn).hGratings.alpha = p.trial.(sn).gratingContrast;
% --- Face for aditional reward
p.trial.(sn).hFace.size     = 2 * p.trial.(sn).faceRadius * ppd;
p.trial.(sn).hFace.position = [0 0];
p.trial.(sn).hFace.id       = 1;

% --- Reward
p.trial.(sn).hReward.defaultAmount = p.trial.behavior.reward.defaultAmount;
p.trial.(sn).hReward.iTrial        = p.trial.pldaps.iTrial;

% --- Setup dot motion trial
% the @trial object (initially in state 0)
% hFix,hDots,hChoice,hCue,hFace,hReward,
p.trial.(sn).hTrial = stimuli.gratingForage.gratingForageTrial(setupRNG, ...
  p.trial.(sn).hGratings, p.trial.(sn).hNoise, p.trial.(sn).hFace, p.trial.(sn).hReward, ...
  'fixWinRadius',p.trial.(sn).gratingRadius * p.trial.display.ppd, ...
  'fixGracePeriod',p.trial.(sn).fixGracePeriod, ...
  'fixDuration', p.trial.(sn).fixDuration, ...
  'trialTimeout',p.trial.(sn).trialTimeout, ...
  'iti',p.trial.(sn).iti);
end