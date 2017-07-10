function p=gaussianNoiseBlobs(p, state, sn)
% gaussian noise module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m

if nargin<3
    sn='gaussianNoiseBlobs';
end


switch state
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
    case p.trial.pldaps.trialStates.frameUpdate
        if p.trial.(sn).on
            p.trial.(sn).n.update
            p.trial.(sn).xpos(p.trial.iFrame, :)=p.trial.(sn).n.x;
            p.trial.(sn).ypos(p.trial.iFrame, :)=p.trial.(sn).n.y;
            p.trial.(sn).gridpos(p.trial.iFrame,:)=p.trial.(sn).n.gridpos;
%             p.trial.(sn).scale(p.trial.iFrame, :)=p.trial.(sn).n.scale;
%             p.trial.(sn).contrast(p.trial.iFrame, :)=p.trial.(sn).n.getContrast;
        end
        
    case p.trial.pldaps.trialStates.frameDraw
        
        if p.trial.(sn).on
            p.trial.(sn).n.draw
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        
        p.trial.display.sourceFactorNew = GL_ONE;
        p.trial.display.destinationFactorNew = GL_ONE;
        Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        if p.trial.(sn).on
            p.trial.(sn).n=stimuli.gaussianNoise(p.trial.display.ptr, 'contrast', p.trial.(sn).contrast, ...
                'sc', p.trial.display.ppd, 'N', p.trial.(sn).N, ...
                'step', p.trial.(sn).step, 'rng', setupRNG, ...
                'lifetime', p.trial.(sn).lifetime, 'sigma0', p.trial.(sn).sigma0,...
                'levels', p.trial.(sn).levels);
            p.trial.(sn).n.setup;
            p.trial.(sn).n.update;
            p.trial.(sn).xpos=nan(p.trial.pldaps.maxFrames, p.trial.(sn).n.count);
            p.trial.(sn).ypos=nan(p.trial.pldaps.maxFrames, p.trial.(sn).n.count);
            p.trial.(sn).gridpos=nan(p.trial.pldaps.maxFrames,p.trial.(sn).n.count);
%             p.trial.(sn).scale=nan(10e3, p.trial.(sn).n.count);
%             p.trial.(sn).contrast=nan(10e3, p.trial.(sn).n.count);
        end
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        if ~isfield(p.trial.(sn), 'sigma0')
            p.trial.(sn).sigma0=2;
        end
        
        if ~isfield(p.trial.(sn), 'N')
            p.trial.(sn).N=4;
        end
        
        if ~isfield(p.trial.(sn), 'contrast')
            p.trial.(sn).contrast=.25;
        end
        
        if ~isfield(p.trial.(sn), 'on')
            p.trial.(sn).on=true;
        end
        
        if ~isfield(p.trial.(sn), 'levels')
            p.trial.(sn).levels=4;
        end
        
        if ~isfield(p.trial.(sn), 'lifetime')
            p.trial.(sn).lifetime=3;
        end
        
        if ~isfield(p.trial.(sn), 'step')
            p.trial.(sn).step=1;
        end
        
        p.trial.(sn).rngs.randomNumberGenerater='twister';
        p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        if p.trial.(sn).on
            ix=p.trial.iFrame:size(p.trial.(sn).xpos,1);
            p.trial.(sn).xpos(ix,:)=[];
            p.trial.(sn).ypos(ix,:)=[];
            p.trial.(sn).gridpos(ix,:)=[];
            
            p.trial.(sn).n.closeTextures();
%             p.trial.(sn).scale(ix,:)=[];
        end
        
end