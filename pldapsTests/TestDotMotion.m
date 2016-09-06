function p = TestDotMotion(p)

p = pdsDefaultTrialStructure(p); 

p=stimuli.setupRandomSeed(p);


defaultColors(p);
p=stimuli.clutColors(p);
p.trial.stimulus.eyeW=8;

p.defaultParameters.pldaps.trialFunction='dotmotion.dotTrial';

sn='stimulus';
%% Timing
 
% setup timing paramters
p.trial.(sn).preTrial     = 1;
p.trial.(sn).fixWait      = 5;
p.trial.(sn).minFixHold   = .1;
p.trial.(sn).maxFixHold   = 10;
p.trial.(sn).preStim      = ceil(.05*p.trial.display.frate);
p.trial.(sn).stimDur      = 1; %ceil(1*p.trial.display.frate);
p.trial.(sn).targOnset    = ceil(.1*p.trial.display.frate);
p.trial.(sn).targHold     = 1;
p.trial.(sn).targDuration = inf;
p.trial.(sn).cueTiming=ceil([.25 .55]*p.trial.display.frate);

% fixation parameters
p.trial.(sn).fixDotW=20; % pixels
p.trial.(sn).fixDotXY=[0 0];

% Targets
p.trial.(sn).targetType='annulus';
p.trial.(sn).targetRadius=7; % degrees
p.trial.(sn).targetSize=2;
p.trial.(sn).targetWinSize=4;

n=8;
p.trial.(sn).conds.directions=0:(360/n):(360-360/n);
p.trial.(sn).conds.speeds=15;
% setup motion parameters

p.trial.(sn).motion1.type='dots';
p.trial.(sn).motion1.size=.3;
p.trial.(sn).motion1.density=100;
p.trial.(sn).motion1.coherence=1;
p.trial.(sn).motion1.bandwidth=0;
p.trial.(sn).motion1.lifetime=55; % frames
p.trial.(sn).motion1.radius=5;
p.trial.(sn).motion1.position=[0 0];
p.trial.(sn).motion1.mode=1;
p.trial.(sn).motion1.dist=1;

%% load marmoset face textures
% create face textures... useful for visual feedback to our subject
MFL=load(fullfile(marmoview.supportDataDir,'MarmosetFaceLibrary.mat'));
MFL = struct2cell(MFL);
MFL = MFL([7,10,13,17:20,24,25,27]); % these faces seem most centered

for id = 1:length(MFL),
  img = MFL{id};
  
  sz = size(img);
  % gaussian envelope...
  x = [1:sz(1)]-sz(1)/2; y = [1:sz(2)]-sz(2)/2;
  [x,y] = meshgrid(x,y);
  g = exp(-(x.^2+y.^2)/(2*(max(sz(1:2))/6)^2));
  g = g - min(g(:));
  g = g./max(g(:));
  img(:,:,4) = uint8(255.*g); % alpha channel: 0 = transparent, 255 = opaque
    
  p.trial.(sn).MarmoFaces.tex(id)=Screen('MakeTexture',p.trial.display.ptr,img);
  p.trial.(sn).MarmoFaces.texSize(1,id)=sz(1);
  p.trial.(sn).MarmoFaces.texSize(2,id)=sz(2);
end



%%
dotmotion.updateConditions(p);
% p.defaultParameters.(stimulusname).states
p = defaultTrialVariables(p, sn);
% dotmotion.updateConditions
