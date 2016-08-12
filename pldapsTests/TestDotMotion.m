function p = TestDotMotion(p)

p = pdsDefaultTrialStructure(p); 

p=stimuli.setupRandomSeed(p);

defaultColors(p);
p.trial.stimulus.eyeW=8;

p.defaultParameters.pldaps.trialFunction='dotmotion.dotTrial';

sn='stimulus';
%% Timing
 
% setup timing paramters
p.trial.(sn).preTrial     = 1;
p.trial.(sn).fixWait      = 5;
p.trial.(sn).minFixHold   = .1;
p.trial.(sn).maxFixHold   = 10;
p.trial.(sn).preStim      = .05;
p.trial.(sn).targOnset    = ceil(.1*p.trial.display.frate);
p.trial.(sn).targHold     = 1;
p.trial.(sn).targDuration = inf;

% fixation parameters
p.trial.(sn).fixDotW=20; % pixels
p.trial.(sn).fixDotXY=[0 0];

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
p.trial.(sn).motion1.position=[2 2];
p.trial.(sn).motion1.mode=1;
p.trial.(sn).motion1.dist=1;

dotmotion.updateConditions(p);
% p.defaultParameters.(stimulusname).states
p = defaultTrialVariables(p, sn);
% dotmotion.updateConditions
% 
% 
% 
% motion1=struct('type',@stimuli.dots, ...
%     'dotSize', .3, ...
%     'speed', 15, ...
%     'direction', 0:10:360, ...
%     'coherence', 1, ...
%     'mode', 1, ...
%     'dist', 1, ...
%     'bandwidth', 10, ...
%     'lifetime', 5, ...
%     'maxRadius', 100, ...
%     'position', [0 0]);
% 
% % p.trial.(sn).motion1.
% 
% 
% % p.trial.(sn).
% d=stimuli.dots(p.trial.display.ptr, ...
%     'size', 5, ...
%     'speed', 5, ... 
%     'direction', 90, ...
%     'numDots', 30, ...
%     'coherence', .5, ...
%     'mode', 1, ...
%     'dist', 1, ...
%     'bandwdth', 50, ...
%     'lifetime', 5, ...
%     'maxRadius', 100, ...
%     'position', [500 500]);
% 
% hFix=stimuli.fixation(p.trial.display.overlayptr, ...
%     'centreSize', p.trial.(sn).fixdotW/2, ...
%     'surroundSize', p.trial.(sn).fixdotW, ...
%     'position', p.trial.display.ctr(1:2));
% % 
% d.beforeTrial
% 
% 
% 
% %%
% 
% d.drawDots;
% f.drawFixation
% d.afterFrame;
% Screen('Flip', p.trial.display.ptr, 0);
% 
% d.moveDots;