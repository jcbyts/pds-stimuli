function p=runTrial(p,state, sn)
% simple dot motion trial
%
% 09.08.2016 Jacob L. Yates <jacoby8s@gmail.com>

if nargin<3
    sn='stimulus';
end

pldapsDefaultTrialFunction(p,state)

switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        p.trial.stimulus.hTrial.afterFrame(p.trial.ttime);

    case p.trial.pldaps.trialStates.trialSetup
        
        trialSetup(p, sn);
        
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.stimulus.hTrial.beforeFrame;
        
end % switch

end % function


function trialSetup(p, sn)

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
p.trial.(sn).hFix(2).cColour    = repmat(p.trial.display.bgColor + p.trial.(sn).fixPointDim, 1, 3);
p.trial.(sn).hFix(2).sColour    = repmat(p.trial.display.bgColor + p.trial.(sn).fixPointDim, 1, 3);
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
    p.trial.(sn).hDots.(f{1}) = p.trial.(sn).(f{1});
end

p.trial.(sn).hDots.size         = p.trial.(sn).size * ppd; % pixels
p.trial.(sn).hDots.speed        = p.trial.(sn).speed * ppd / fps; % pixels/frame
p.trial.(sn).hDots.maxRadius    = p.trial.(sn).stimWinRadius * ppd;

p.trial.(sn).hDots.position     = [p.trial.(sn).xDeg, -1*p.trial.(sn).yDeg] * ppd + ctr;
p.trial.(sn).hDots.colour       = p.trial.display.bgColor + p.trial.(sn).contrast;

% --- setup conditions
n = p.trial.(sn).numDirs; % number of directions/choice targets
p.trial.(sn).direction = ceil(rand(setupRNG)*n)/n*360;
p.trial.(sn).hDots.direction = p.trial.(sn).direction;

% (re-)initialize dots
p.trial.(sn).dotRNG = rng();
p.trial.(sn).hDots.beforeTrial();

% --- Choice targets
r  = (p.trial.(sn).stimWinRadius + p.trial.(sn).cueApertureRadius) * ppd;
th = (0:n-1) * (2*pi/n);

[x,y] = pol2cart(th, r);

sz = p.trial.(sn).choiceTargetRadius * ppd;
p.trial.(sn).hChoice.size       = repmat(2*sz,1,n);
p.trial.(sn).hChoice.position   = [x; -1*y]' + repmat(ctr,n,1);
p.trial.(sn).hChoice.colour     = p.trial.display.bgColor + p.trial.(sn).choiceTargetContrast;
p.trial.(sn).hChoice.weight     = -1;

assert(p.trial.display.colorclamp | p.trial.display.normalizeColor, 'color range not [0-1]')

% --- Choice cue (Gabor) -- per acuity task... why!?
rPix    = round(p.trial.(sn).cueApertureRadius * ppd);
cycles  = 2 * 4 * p.trial.(sn).cueApertureRadius;
phase   = 0;

img = MakeGabor(rPix,127, cycles, phase, p.trial.(sn).cueApertureContrast*127);

p.trial.(sn).hCue.addTexture(1,img); % we better clear this at the end of trial
p.trial.(sn).hCue.size      = p.trial.(sn).cueApertureRadius * ppd;
p.trial.(sn).hCue.position  = [x; -1*y]' + ctr;
p.trial.(sn).hCue.id        = 1;

% --- Feedback for incorrect choices...
p.trial.(sn).hFbk.size      = 2 * p.trial.(sn).feedbackApertureRadius * ppd;
p.trial.(sn).hFbk.position  = [x; -1*y]' + ctr;
p.trial.(sn).hFbk.colour    = p.trial.display.bgColor + p.trial.(sn).feedbackApertureContrast;
p.trial.(sn).hFbk.weight    = 4;

% --- Face for aditional reward
p.trial.(sn).hFace.size     = 2.5 * p.trial.(sn).cueApertureRadius * ppd;
p.trial.(sn).hFace.position = [x; -1*y]' + ctr;
p.trial.(sn).hFace.id       = p.trial.(sn).faceIndex;

% --- Setup dot motion trial
% the @trial object (initially in state 0)
p.trial.(sn).hTrial = dotmotion.dotMotionTrial( ...
  p.trial.(sn).hFix,p.trial.(sn).hDots,p.trial.(sn).hChoice,p.trial.(sn).hCue,p.trial.(sn).hFbk,p.trial.(sn).hFace,[], ...
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