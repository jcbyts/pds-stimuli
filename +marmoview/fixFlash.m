function p=fixFlash(p, state, sn)
% FIXFLASH for PLDAPS
% Fixation training protocol



if nargin<3
    sn='fixFlash';
end

if nargin==1
   
    p = pdsDefaultTrialStructure(p);
    
    p.defaultParameters.pldaps.trialMasterFunction='runModularTrial';
    p.defaultParameters.pldaps.trialFunction='marmoview.faceInvaders';
    
    c.Nr=1; %one condition;
    if isinf(p.defaultParameters.pldaps.finish)
        p.conditions=repmat({c},1,200);
        p.defaultParameters.pldaps.finish = length(p.conditions);
    else
        p.conditions=repmat({c},1,p.defaultParameters.pldaps.finish);
    end
    
    p.trial.(sn).rngs.randomNumberGenerater='mt19937ar';
    p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
    p.trial.exploded=0;
    
    %----------------------------------------------------------------------
    % Default Conditions
    if ~isfield(p.trial.(sn), 'maxTrialLength')
        p.trial.pldaps.maxTrialLength = 5;
    end
    p.trial.pldaps.maxFrames        = p.trial.pldaps.maxTrialLength*p.trial.display.frate;
        
    return
end



pldapsDefaultTrialFunction(p,state);
switch state
    
    %----------------------------------------------------------------------
    % Update all behavior of the objects
    case p.trial.pldaps.trialStates.frameUpdate
        
        
        % flag end of trial (if time is greater than max trial length)
        if p.trial.iFrame >= p.trial.(sn).maxFrames
            p.trial.flagNextTrial=true;
        end
        
    case p.trial.pldaps.trialStates.frameDraw
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        %         setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        % TODO: motion object should take this RNG stream to save the seed
        p.trial.(sn).maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        
        p.trial.(sn).m = stimuli.MotionObjects(p, p.trial.(sn).MotN);
        p.trial.(sn).m.setup;
        
        p.trial.(sn).x = nan(p.trial.(sn).maxFrames, p.trial.(sn).MotN);
        p.trial.(sn).y = nan(p.trial.(sn).maxFrames, p.trial.(sn).MotN);
        p.trial.(sn).ctrExplode = nan(p.trial.(sn).maxFrames, p.trial.(sn).MotN);
        p.trial.(sn).ctrHold    = nan(p.trial.(sn).maxFrames, p.trial.(sn).MotN);
        
        p.trial.(sn).rngs.trialStateRNG = rng();
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave

        
    otherwise    
        
end