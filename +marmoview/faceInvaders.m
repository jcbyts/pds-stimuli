function p=faceInvaders(p, state, sn)
% FACEFORAGE module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m



if nargin<3
    sn='faceForage';
end

if nargin==1
    Screen('Preference', 'TextRenderer', 1)
    
    p = pdsDefaultTrialStructure(p);
    
    p.defaultParameters.pldaps.trialMasterFunction='runModularTrial';
    p.defaultParameters.pldaps.trialFunction='marmoview.faceInvaders';
    
    c.Nr=1; %one condition;
    p.conditions=repmat({c},1,200);
    
    p.defaultParameters.pldaps.finish = length(p.conditions);
    
    p.trial.(sn).rngs.randomNumberGenerater='mt19937ar';
    p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
    p.trial.exploded=0;
    
    %----------------------------------------------------------------------
    % Default Conditions
    if ~isfield(p.trial.(sn), 'maxTrialLength')
        p.trial.pldaps.maxTrialLength = 20;
    end
    p.trial.pldaps.maxFrames        = p.trial.pldaps.maxTrialLength*p.trial.display.frate;
    
    
    if ~isfield(p.trial.(sn), 'MotN')
        p.trial.(sn).MotN       = 30;  % number of face objects
    end
    
    if ~isfield(p.trial.(sn), 'minSpeed')
        p.trial.(sn).minSpeed   = 5;
    end
    
    if ~isfield(p.trial.(sn), 'maxSpeed')
        p.trial.(sn).maxSpeed   = 15;
    end
    
    if ~isfield(p.trial.(sn), 'motionType')
        p.trial.(sn).motionType = 'linear';
    end
    
    if ~isfield(p.trial.(sn), 'forcefield')
        p.trial.(sn).forcefield = false;
    end
    
    if ~isfield(p.trial.(sn), 'type')
        p.trial.(sn).type       = 'face';
    end
    
    return
end



pldapsDefaultTrialFunction(p,state);
switch state
    
    %----------------------------------------------------------------------
    % Update all behavior of the objects
    case p.trial.pldaps.trialStates.frameUpdate
        
        p.trial.(sn).m.move()
        p.trial.(sn).m.isheld([p.trial.eyeX p.trial.eyeY]);
        
        
        
        p.trial.(sn).x(p.trial.iFrame, :) = p.trial.(sn).m.x;
        p.trial.(sn).y(p.trial.iFrame, :) = p.trial.(sn).m.y;
        p.trial.(sn).ctrExplode(p.trial.iFrame, :) = p.trial.(sn).m.ctrExplode;
        p.trial.(sn).ctrHold(p.trial.iFrame, :) = p.trial.(sn).m.ctrHold;
        
        % flag end of trial (if time is greater than max trial length)
        if p.trial.iFrame >= p.trial.(sn).maxFrames
            p.trial.flagNextTrial=true;
        end
        
    case p.trial.pldaps.trialStates.frameDraw

        p.trial.(sn).m.draw()
%         Screen('DrawText', p.trial.display.ptr, num2str(p.trial.exploded), 50, 50, [1 1 1]);
        
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
        
        figure(1); clf
        plot(p.trial.(sn).x, p.trial.(sn).y, 'k.'); hold on
        
        for i=1:p.trial.(sn).MotN
            ix=diff(p.trial.(sn).ctrHold(:,i))>0;
            plot(p.trial.(sn).x(ix,i), p.trial.(sn).y(ix,i), 'r.');
        end
        
        
        drawnow
    
        % --- handles that depend on pldaps being totally set up
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        % --- Reward
%         p.trial.(sn).hReward    = stimuli.reward(p);
        
    otherwise    
        
end
