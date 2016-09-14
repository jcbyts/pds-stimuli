function p=sparseNoise(p, state, sn)
% sparse noise module for PLDAPS open reception
% Draws sparse noise

if nargin<3
    sn='sparseNoise';
end


switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
    case p.trial.pldaps.trialStates.frameUpdate
        if p.trial.(sn).on
            p.trial.(sn).n.update
            p.trial.(sn).xpos(p.trial.iFrame, :)=p.trial.(sn).n.x;
            p.trial.(sn).ypos(p.trial.iFrame, :)=p.trial.(sn).n.y;
            p.trial.(sn).scale(p.trial.iFrame, :)=p.trial.(sn).n.scale;
            p.trial.(sn).contrast(p.trial.iFrame, :)=p.trial.(sn).n.getContrast;
        end
        
    case p.trial.pldaps.trialStates.frameDraw
        
        if p.trial.(sn).on
            p.trial.(sn).n.draw
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        if p.trial.(sn).on
            p.trial.(sn).n=stimuli.gaussianNoise(p.trial.display.ptr, 'contrast', p.trial.(sn).contrast, ...
                'sc', p.trial.(sn).spatialScale, 'count', p.trial.(sn).count, 'rng', setupRNG);
            p.trial.(sn).n.setup;
            p.trial.(sn).n.update;
            p.trial.(sn).xpos=randi(10e3, p.trial.(sn).n.count);
            p.trial.(sn).ypos=nan(10e3, p.trial.(sn).n.count);
            p.trial.(sn).scale=nan(10e3, p.trial.(sn).n.count);
            p.trial.(sn).contrast=nan(10e3, p.trial.(sn).n.count);
        end
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        if ~isfield(p.trial.(sn), 'ctrXY')
            p.trial.(sn).ctrXY=[0 0];
        end
        
        if ~isfield(p.trial.(sn), 'dim')
            p.trial.(sn).dim=[10 10];
        end
        
        if ~isfield(p.trial.(sn), 'sparsity')
            p.trial.(sn).sparsity=.1;
        end
        
        if ~isfield(p.trial.(sn), 'gazeContingent')
            p.trial.(sn).gazeContingent=0;
        end
        
        p.trial.(sn).rngs.randomNumberGenerater='mt19937ar';
        p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        if p.trial.(sn).on
            ix=p.trial.iFrame+1:size(p.trial.(sn).xpos,1);
            p.trial.(sn).xpos(ix,:)=[];
            p.trial.(sn).ypos(ix,:)=[];
            p.trial.(sn).scale(ix,:)=[];
        end
        
end