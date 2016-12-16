function p=csdFlash(p, state, sn)
% gaussian noise module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m

if nargin<3
    sn='csdFlash';
end


switch state
    
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        
        
    case p.trial.pldaps.trialStates.frameDraw
        
        if p.trial.(sn).on(p.trial.iFrame)
            Screen('FillRect', p.trial.display.ptr, 1);
        else
            Screen('FillRect', p.trial.display.ptr, 0);
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        %         setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        if ~isfield(p.trial.(sn), 'OnDuration')
            p.trial.(sn).OnDuration=50;
        end
        
        if ~isfield(p.trial.(sn), 'OffDuration')
            p.trial.(sn).OffDuration=200;
        end
        
        p.trial.(sn).maxFrames=10e3;
        p.trial.(sn).on=zeros(p.trial.(sn).maxFrames,1);
        
        step=p.trial.(sn).OnDuration+p.trial.(sn).OffDuration;
        nUpdates=ceil(p.trial.(sn).maxFrames/step);
        
        for iStim=1:nUpdates
            iFrames=(iStim-1)*step + (1:p.trial.(sn).OnDuration);
            p.trial.(sn).on(iFrames)=1;
        end
        
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        
        p.trial.(sn).rngs.randomNumberGenerater='mt19937ar';
        p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        ix=p.trial.iFrame:size(p.trial.(sn).on,1);
        p.trial.(sn).on(ix,:)=[];
        
end