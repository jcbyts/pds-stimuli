function [A,P] = dotMotionNext(S,P,A),
% DOTMOTIONNEXT initialise the next trial of MarmoView's dot motion task.
%
% Returns structures A and P with fields:
%
%   A.rngSettings - the state of the random number generator on this trial
%   A.direction   - the direction of motion on this trial

% 14-06-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>

% FIXME: marmoview needs (at minimum) a class system for tasks and stimuli!

% FIXME: most of this should be done in the xxxInit() function... but xxxInit()
%        doesn't get passed the S and P structures.. wtf?

% set gaze indicator color
A.hGaze.size = (2*P.gazeRadius)*S.pixPerDeg;
% A.hGaze.colour = uint8(repmat(A.bgColour,1,3) + P.gazeIntensity*S.gazeColorStep);
A.hGaze.colour = repmat(S.bgColour,1,3) + P.gazeIntensity*S.gazeColorStep;

% set fixation point properties
sz = P.fixPointRadius*S.pixPerDeg;
A.hFix(1).cSize = sz;
A.hFix(1).sSize = 2*sz;
A.hFix(1).cColour = repmat(1,1,3); % black
A.hFix(1).sColour = repmat(255,1,3); % white
A.hFix(1).position = [0,0]*S.pixPerDeg + S.centerPix;

A.hFix(2).cSize = sz;
A.hFix(2).sSize = 2*sz;
A.hFix(2).cColour = repmat(S.bgColour-50,1,3); % "black"
A.hFix(2).sColour = repmat(S.bgColour+50,1,3); % "white"
A.hFix(2).position = [0,0]*S.pixPerDeg + S.centerPix;

% A.fixDuration = 0.2 + 0.3*rand(); % random duration 0.2-0.5s
rnd = rand();
A.fixDuration = (1-rnd)*P.minFixDuration + rnd*P.maxFixDuration; % random duration

% A.choiceTargetDelay = 0.1+0.3*rand(); % random delay 0.1-0.4s
rnd = rand();
A.cueDelay = (1-rnd)*P.minCueDelay + rnd*P.maxCueDelay; % random delay (was choiceTargetDelay)

% set properties of the @dots object...
fnames = {'numDots','bandwdth'};
for f = fnames,
  A.hDots.(f{1}) = P.(f{1});
end

A.hDots.size = P.size*S.pixPerDeg; % pixels
A.hDots.speed = P.speed*S.pixPerDeg/A.frameRate; % pixels/frame

A.hDots.maxRadius = P.stimWinRadius*S.pixPerDeg; % pixels

A.hDots.mode = S.mode; % 0 = proportion of dots, 1 = sample from random dist.
A.hDots.dist = S.dist; % 0 = uniform, 1 = gaussian

A.hDots.lifetime = P.lifetime; % dot lifetime (in frames)

A.hDots.position = [P.xDeg,-1*P.yDeg]*S.pixPerDeg + S.centerPix;

%
% 1. uniformly distributed direction...
%
% A.direction = rand()*360.0;

%
% 2. n AFC
%
n = P.numDirs; % number of directions/choice targets
A.direction = mod(round((rand()*360)/(360/n))*(360/n),360);

A.hDots.direction = A.direction; 

% (re-)initialise dots
A.rngSettings = rng(); % save the state of the rng so we can exactly reconstruct our dot pattern
A.hDots.beforeTrial();

%
% choice targets
%
r = (P.stimWinRadius+P.cueApertureRadius)*S.pixPerDeg;
th = [0:n-1]*(2*pi/n);

[x,y] = pol2cart(th,r);

sz = P.choiceTargetRadius*S.pixPerDeg;
A.hChoice.size = repmat(2*sz,1,n);
A.hChoice.position = [x; -1*y]' + repmat(S.centerPix,n,1);
A.hChoice.colour = repmat(S.bgColour+50,1,3);
A.hChoice.weight = -1; % weight < 0, filled circle(s)

%
% choice cue
%
r = (P.stimWinRadius+P.cueApertureRadius)*S.pixPerDeg;
th = A.direction*(pi/180);

[x,y] = pol2cart(th,r);

A.hCue(1).size = 2*P.cueApertureRadius*S.pixPerDeg;
A.hCue(1).position = [x; -1*y]' + S.centerPix;
A.hCue(1).colour = repmat(S.bgColour-32,1,3);
A.hCue(1).weight = 2; % weight < 0, filled circle(s)

% choice cue to show for incorrect choices...
A.hCue(2).size = 2*P.cueApertureRadius*S.pixPerDeg;
A.hCue(2).position = [x; -1*y]' + S.centerPix;
A.hCue(2).colour = repmat(S.bgColour-64,1,3);
A.hCue(2).weight = 4;

% face, for additional reward (?)
A.hFace.size = 2.5*P.cueApertureRadius*S.pixPerDeg;
A.hFace.position = [x; -1*y]' + S.centerPix;
A.hFace.id = randi(A.hFace.numTex);
