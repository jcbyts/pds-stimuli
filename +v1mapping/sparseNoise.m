function p=sparseNoise(p, state, sn)
% sparse noise module for PLDAPS open reception
% Draws sparse noise

if nargin<3
    sn='sparseNoise';
end


switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        p.trial.(sn).n.update
%     case p.trial.pldaps.trialStates.frameUpdate
        
        
    case p.trial.pldaps.trialStates.frameDraw
        
        if p.trial.(sn).on
            if p.trial.(sn).gazeContingent
                p.trial.(sn).n.xy = [p.trial.eyeX p.trial.eyeY]+p.trial.(sn).xy;
            end
            p.trial.(sn).n.draw
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        
        p.trial.(sn).n=stimuli.pixelNoise(p.trial.display.ptr, 'rng', setupRNG);
        
        for fields = {'xy', 'size', 'pxsize', 'sigma', 'dc', 'contrast'}
            field = fields{1};
            p.trial.(sn).n.(field) = p.trial.(sn).(field);
        end
        
        p.trial.(sn).n.type = p.trial.(sn).type;
        
        p.trial.(sn).n.setup;
        p.trial.(sn).n.update;
        
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        if ~isfield(p.trial.(sn), 'size')
            p.trial.(sn).size=[10 10];
        end
        
        if ~isfield(p.trial.(sn), 'pxsize')
            p.trial.(sn).pxsize=20;
        end
        
        if ~isfield(p.trial.(sn), 'gazeContingent')
            p.trial.(sn).gazeContingent=1;
        end
        
        if ~isfield(p.trial.(sn), 'contrast')
            p.trial.(sn).contrast = .5;
        end
        
        if ~isfield(p.trial.(sn), 'dc')
            p.trial.(sn).dc = .5;
        end
        
        if ~isfield(p.trial.(sn), 'sigma')
            p.trial.(sn).sigma = .1;
        end
        
        if ~isfield(p.trial.(sn), 'xy')
            p.trial.(sn).xy = [0 0];
        end
        
        if ~isfield(p.trial.(sn), 'type')
            p.trial.(sn).type = 'sparse';
        end
        
        p.trial.(sn).on = true;
        
        p.trial.(sn).rngs.randomNumberGenerater='mt19937ar';
        p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
end