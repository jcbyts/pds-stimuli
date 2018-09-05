function p=HDmovies(p, state, sn)
% gaussian noise module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m

if nargin<3
    sn='HDmovies';
end


switch state
    
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        p.defaultParameters.(sn).stateFunction.acceptsLocationInput = true;
        % setup states that will be called by this module
        p.defaultParameters.(sn).stateFunction.requestedStates.experimentPostOpenScreen = true;
        p.defaultParameters.(sn).stateFunction.requestedStates.trialSetup = true;
        p.defaultParameters.(sn).stateFunction.requestedStates.frameUpdate = true;
        p.defaultParameters.(sn).stateFunction.requestedStates.frameDraw = true;
        p.defaultParameters.(sn).stateFunction.requestedStates.trialCleanUpandSave = true;
        p.defaultParameters.(sn).stateFunction.requestedStates.trialPrepare = true;

        p = stimuli.setupRandomSeed(p, sn);
        
    case p.trial.pldaps.trialStates.trialPrepare
        
        p.trial.(sn).h.start
        
    case p.trial.pldaps.trialStates.frameUpdate
       h = p.trial.(sn).h;
       
        [h.movietexture, h.pts] = Screen('GetMovieImage', h.ptr, h.movie);
         
%         p.trial.(sn).h.update
        
    case p.trial.pldaps.trialStates.frameDraw
        h = p.trial.(sn).h;
%         p.trial.(sn).h.draw
        if h.movietexture > 0
        % Yes. Draw the new texture immediately to screen:
            Screen('DrawTexture', h.ptr, h.movietexture, [], [0 0 h.dim(1) h.dim(2)]);
    
            % Release texture:
            Screen('Close', h.movietexture);
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
%         setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        if ~isfield(p.trial.(sn), 'moviefilename')
            p.trial.(sn).moviefilename='/home/marmorig/Videos/HeadPokeTraining001.MP4';
        end
        
        if ~isfield(p.trial.(sn), 'frameIndex')
            p.trial.(sn).frameIndex=[9000 12000];
        end
%        h.frameIndex=[9000 12000];
        
         p.trial.(sn).h=stimuli.HDmovie(p.trial.(sn).moviefilename, p.trial.display.ptr);
         p.trial.(sn).h.frameIndex=p.trial.(sn).frameIndex;
         p.trial.(sn).h.open
         p.trial.(sn).h.update
         p.trial.(sn).h.draw
         Screen('Flip', p.trial.display.ptr)
         
         h=stimuli.HDmovie(p.trial.(sn).moviefilename, p.trial.display.ptr);
         h.frameIndex=p.trial.(sn).frameIndex;
         h.open
         
         %%
         h.update
         h.draw
         Screen('Flip', p.trial.display.ptr)
         %%
%          Screen('FillRect', p.trial.display.ptr, p.trial.display.bgColor)
         
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        p.trial.(sn).h.closeMovie
end