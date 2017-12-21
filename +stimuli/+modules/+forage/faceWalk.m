function p=gratingWalk(p, sn)
% FACEFORAGE module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m



if nargin<2
    sn='stimulus';
end


p = pdsDefaultTrialStructure(p);

p.defaultParameters.pldaps.trialMasterFunction='runModularTrial';
p.defaultParameters.pldaps.trialFunction='stimuli.forage.forage';

c.Nr=1; %one condition;
p.conditions=repmat({c},1,200);

p.defaultParameters.pldaps.finish = length(p.conditions);

p.trial.(sn).rngs.randomNumberGenerater='mrg32k3a';
p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);

%----------------------------------------------------------------------
% Default Conditions
if ~isfield(p.trial.(sn), 'maxTrialLength')
    p.trial.pldaps.maxTrialLength = 20;
end
p.trial.pldaps.maxFrames        = p.trial.pldaps.maxTrialLength*p.trial.display.frate;


p.trial.(sn).MotN       = 2;  % number of face objects
p.trial.(sn).minSpeed   = 1;
p.trial.(sn).maxSpeed   = 3;
p.trial.(sn).motionType = 'randomwalk';
p.trial.(sn).type       = 'face';

p.trial.(sn).appearGazeContingent = false;
p.trial.(sn).appearRangePar = 5;
p.trial.(sn).appearCenter = [0 0];
p.trial.(sn).appearTau = 100;
p.trial.(sn).maxContrast = 0.1;
            
p.trial.(sn).radius = .5;
p.trial.(sn).onLifetime  = 1 * p.trial.display.frate;
p.trial.(sn).offLifetime = 2 * p.trial.display.frate;




