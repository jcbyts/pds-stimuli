function p=faceForageRandomWalk(p, sn)


if nargin<2
    sn='stimulus';
end


p = pdsDefaultTrialStructure(p);

p.defaultParameters.pldaps.trialMasterFunction = 'runModularTrial';
p.defaultParameters.pldaps.trialFunction       = 'stimuli.forage.forage';


p.defaultParameters.pldaps.finish = 200;

p.trial.(sn).rngs.randomNumberGenerater='mrg32k3a';
p.trial.(sn).rngs.trialSeeds = repmat(randi(2^32, [10 1]), 1e3,1);

%----------------------------------------------------------------------
% Default Conditions


if ~isfield(p.trial.(sn), 'holdDuration')
    p.trial.(sn).holdDuration = 15;
end
    
if ~isfield(p.trial.(sn), 'maxTrialLength')
    p.trial.pldaps.maxTrialLength = 20;
end


p.trial.pldaps.maxFrames        = p.trial.pldaps.maxTrialLength*p.trial.display.frate;