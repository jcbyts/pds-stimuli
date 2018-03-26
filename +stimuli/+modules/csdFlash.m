function p = csdFlash(p, state, sn)
% CSD FLASH: draw a full-field flash

if nargin<3
    sn='csdFlash';
end


switch state
    
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        
        
    case p.trial.pldaps.trialStates.frameDraw
        
        if p.trial.(sn).on(p.trial.iFrame)
            Screen('FillRect', p.trial.display.ptr, p.trial.(sn).onColor);
        else
            Screen('FillRect', p.trial.display.ptr, p.trial.(sn).offColor);
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        %         setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        if ~isfield(p.trial.(sn), 'onDuration')
            p.trial.(sn).onDuration=50;
        end
        
        if ~isfield(p.trial.(sn), 'offDuration')
            p.trial.(sn).offDuration=200;
        end
        
        if ~isfield(p.trial.(sn), 'onColor')
            p.trial.(sn).onColor = 1;
        end
        
        if ~isfield(p.trial.(sn), 'offColor')
            p.trial.(sn).offColor = p.trial.display.bgColor;
        end
        
        p.trial.(sn).maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        p.trial.(sn).on=zeros(p.trial.(sn).maxFrames,1);
        
        step=p.trial.(sn).onDuration+p.trial.(sn).offDuration;
        nUpdates=ceil(p.trial.(sn).maxFrames/step);
        
        for iStim=1:nUpdates
            iFrames=(iStim-1)*step + (1:p.trial.(sn).onDuration);
            p.trial.(sn).on(iFrames)=1;
        end
        
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        
        p.trial.(sn).rngs.randomNumberGenerater='mt19937ar';
        p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        ix=p.trial.iFrame:size(p.trial.(sn).on,1);
        p.trial.(sn).on(ix,:)=[];
        
end