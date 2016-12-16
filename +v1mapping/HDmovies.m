function p=HDmovies(p, state, sn)
% gaussian noise module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m

if nargin<3
    sn='HDmovies';
end


switch state
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
       
        p.trial.(sn).h.update
        
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.(sn).h.draw
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
%         setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        if ~isfield(p.trial.(sn), 'moviefilename')
            p.trial.(sn).moviefilename='/home/marmorig/HeadPokeTraining001.MP4';
        end
        
        if ~isfield(p.trial.(sn), 'frameIndex')
            p.trial.(sn).frameIndex=[1 inf];
        end
       
        
         p.trial.(sn).h=stimuli.HDmovie(p.trial.(sn).moviefilename, p.trial.display.ptr);
         p.trial.(sn).h.frameIndex=p.trial.(sn).frameIndex;
         p.trial.(sn).h.open
         
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        
        p.trial.(sn).rngs.randomNumberGenerater='mt19937ar';
        p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
end