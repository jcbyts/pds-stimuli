function trialSetup(p, sn)

	if nargin < 2
		sn = 'stimulus';
	end

p.trial.pldaps.goodtrial = 1;

ppd   = p.trial.display.ppd;        % pixels per degree (linear approximation)
fps   = p.trial.display.frate;      % frames per second
ctr   = p.trial.display.ctr(1:2);   % center of the screen

% --- Set Fixation Point Properties    
sz = p.trial.(sn).fixPointRadius * ppd;
p.trial.(sn).hFix(1).cSize      = sz;
p.trial.(sn).hFix(1).sSize      = 2*sz;
p.trial.(sn).hFix(1).cColour    = zeros(1,3);
p.trial.(sn).hFix(1).sColour    = ones(1,3);
p.trial.(sn).hFix(1).position   = [0,0] * ppd + p.trial.display.ctr(1:2);

p.trial.(sn).hFix(2).cSize      = sz;
p.trial.(sn).hFix(2).sSize      = 2*sz;
p.trial.(sn).hFix(2).cColour    = p.trial.display.bgColor + p.trial.(sn).fixPointDim;
p.trial.(sn).hFix(2).sColour    = p.trial.display.bgColor + p.trial.(sn).fixPointDim;
p.trial.(sn).hFix(2).position   = [0,0] * ppd + ctr;

% --- Random seed
p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
setupRNG=p.trial.(sn).rngs.conditionerRNG;

% fixation duration
rnd=rand(setupRNG);
p.trial.(sn).fixDuration = (1 - rnd) * p.trial.(sn).minFixDuration + rnd * p.trial.(sn).maxFixDuration;
% cue delay
rnd=rand(setupRNG);
p.trial.(sn).cueDelay = (1-rnd) * p.trial.(sn).minCueDelay + rnd * p.trial.(sn).maxCueDelay;

% --- setup trial difficulty (FIX ME: move these to a proper condition struct)
if p.trial.(sn).numBandwidths > 1
    rnd=randi(p.trial.(sn).numBandwidths, 1) / p.trial.(sn).numBandwidths;
    p.trial.(sn).bandwdth = (1-rnd) * p.trial.(sn).minBandwidth + rnd * p.trial.(sn).maxBandwidth; 
end

% --- setup dots
fnames = {'numDots', 'bandwdth', 'mode', 'dist', 'lifetime'};
for f = fnames
    for kDots = 1:numel(p.trial.(sn).hDots)
        p.trial.(sn).hDots(kDots).(f{1}) = p.trial.(sn).(f{1});
    end
end

numDotApertures = numel(p.trial.(sn).hDots);
for kDots = 1:numDotApertures
    p.trial.(sn).hDots(kDots).size  = p.trial.(sn).dotSize * ppd; % pixels
    p.trial.(sn).hDots(kDots).speed        = p.trial.(sn).dotSpeed * ppd / fps; % pixels/frame
    p.trial.(sn).hDots(kDots).maxRadius    = p.trial.(sn).stimWinRadius * ppd;

    [th, rho] = cart2pol(p.trial.(sn).RfCenterXy);
    
    th = th + p.trial.(sn).DotCenterAngle(kDots)/180*pi;
    [xDeg, yDeg] = pol2cart(th, rho);
    p.trial.(sn).hDots(kDots).position     = [xDeg, -1*yDeg] * ppd + ctr;
    p.trial.(sn).hDots(kDots).colour       = p.trial.display.bgColor + p.trial.(sn).dotContrast;
end

% --- setup conditions
n = p.trial.(sn).numDirs; % number of directions/choice targets


for kDot = 1:numDotApertures
    if kDot > 1 && p.trial.(sn).yokeDirections
        p.trial.(sn).direction(kDot) = wrapTo360(p.trial.(sn).direction(kDot-1) - 180);
    else
        p.trial.(sn).direction(kDot) = ceil(rand(setupRNG)*n)/n*360;
    end
    p.trial.(sn).hDots(kDot).direction(1) = p.trial.(sn).direction(kDot);
end

% (re-)initialize dots
p.trial.(sn).dotRNG = rng();
for kDot = 1:numDotApertures
    p.trial.(sn).hDots(kDot).beforeTrial();
end

% --- Face for aditional reward
p.trial.(sn).hFace.texSize  = 2.5 * p.trial.(sn).cueApertureRadius * ppd;
p.trial.(sn).hFace.position = [x; -1*y]' + ctr;
p.trial.(sn).hFace.id       = p.trial.(sn).faceIndex;

% --- Setup dot motion trial
% the @trial object (initially in state 0)
% hFix,hDots,hChoice,hCue,hFace,hReward,
p.trial.(sn).hTrial = stimuli.dotselection.dotMotionTrial( ...
  p.trial.(sn).hFix,p.trial.(sn).hDots,p.trial.(sn).hFace, p, ...
  'fixWinRadius',p.trial.(sn).fixWinRadius, ...
  'fixGracePeriod',p.trial.(sn).fixGracePeriod, ...
  'fixDuration',p.trial.(sn).fixDuration, ...
  'fixFlashCnt',p.trial.(sn).fixFlashCnt, ...
  'stimDuration',p.trial.(sn).stimDuration, ...
  'holdDuration',p.trial.(sn).holdDuration, ...
  'cueDelay',p.trial.(sn).cueDelay, ...
  'choiceTargetDelay',p.trial.(sn).choiceTargetDelay, ...
  'choiceWinMinRadius',p.trial.(sn).choiceWinMinRadius,...
  'choiceWinMaxRadius',p.trial.(sn).choiceWinMaxRadius,...
  'choiceDuration',p.trial.(sn).choiceDuration, ...
  'rewardWindow',p.trial.(sn).rewardWindow, ... % think about this parameter name
  'choiceTimeout',p.trial.(sn).choiceTimeout, ...
  'trialTimeout',p.trial.(sn).trialTimeout, ...
  'iti',0, ...
  'maxRewardCnt',p.trial.(sn).maxRewardCnt, ...
  'bonusDirection',p.trial.(sn).bonusDirection, ...
  'bonusWindow',p.trial.(sn).bonusWindow, ...
  'bonusRewardCnt',p.trial.(sn).bonusRewardCnt, ... 
  'viewpoint',false);
end


function img = MakeGabor(rPix,bkgd,cycles,phase,range)
  % as much as it pains me, this code is cut and pasted from
  % SupportFunctions/MakeGabor.m...
  %
  % we don't use MakeGabor.m directly because it wants to create the
  % ptb texture but we just want an image that we can pass to the
  % @textures class

  % Find diameter
  dPix = 2*rPix+1;
  % Create a meshgrid
  [X,Y] = meshgrid(-rPix:rPix);

  % Standard deviation of gaussian (e1)
  sigma = dPix/8;
  % Create the gaussian (e1)
  e1 = exp(-.5*(X.^2 + Y.^2)/sigma^2);

  % Convert cycles to max radians (s1)
  maxRadians = pi*cycles;
  % Convert phase from degrees to radians (s1)
  phase = pi*phase/180;
  % Create the sinusoid (s1)
  s1 = sin(maxRadians*X/rPix + phase);

  % Create the gabor (g1)
%   g1 = s1.*e1;
  g1 = s1;
  
  % Convert to uint8
  g1 = uint8(bkgd + g1*range);
  
  % stick the gaussian envelope on the alpha channel...
  img = repmat(g1,1,1,3);
  img(:,:,4) = uint8(255.*e1);
end