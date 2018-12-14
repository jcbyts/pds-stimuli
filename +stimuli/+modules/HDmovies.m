function p=HDmovies(p, state, sn)
% gaussian noise module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m

if nargin<3
    sn='HDmovies';
end


switch state
        
    case p.trial.pldaps.trialStates.framePrepareDrawing

        p.trial.(sn).h.drawNext
        
        if p.trial.(sn).h.pts == 0 % use frame indexing
            p.trial.(sn).frameShown(p.trial.iFrame) = p.trial.(sn).frameIndex(1) + p.trial.iFrame - 1;
        else % use time index
            p.trial.(sn).frameShown(p.trial.iFrame) = p.trial.(sn).h.pts;
        end
%         p.trial.(sn).h.update
        
    case p.trial.pldaps.trialStates.frameDraw
        
%         p.trial.(sn).h.draw
%         p.trial.(sn).h.drawNext
%         p.trial.(sn).frameShown(p.trial.iFrame) = p.trial.(sn).h.pts;
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % --- Random seed
        if isfield(p.trial.(sn),'rngs') && isfield(p.trial.(sn).rngs, 'conditionerRNG')
            p.trial.(sn).rngs.conditionerRNG.reset; % reset saved stream
        else
            [p.trial.(sn).rngs.conditionerRNG] = RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        end
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        if ~isfield(p.trial.(sn), 'moviedatabase')
            p.trial.(sn).moviedatabase = 'videos';
        end
        
        p.trial.(sn).localdirectory = getpref('pep', p.trial.(sn).moviedatabase);
        
        if ~isfield(p.trial.(sn), 'moviefilename')
            fl = dir(fullfile(p.trial.(sn).localdirectory, '*.mp4'));
            p.trial.(sn).moviefilename = fl(randi(setupRNG, numel(fl))).name;
        end
        
        if ~isfield(p.trial.(sn), 'frameIndex')
            p.trial.(sn).frameIndex = [1 inf];
        end
       
        fname = fullfile(p.trial.(sn).localdirectory, p.trial.(sn).moviefilename);
        p.trial.(sn).h=stimuli.HDmovie(fname, p.trial.display.ptr);
        p.trial.(sn).h.frameIndex=p.trial.(sn).frameIndex;
        p.trial.(sn).h.open
         
        p.trial.(sn).frameShown = nan(p.trial.pldaps.maxFrames, 1);
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        stimuli.setupDefaultFrameStates(p, sn);
        stimuli.setupRandomSeed(p, sn);
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        p.trial.(sn).h.closeMovie;
        
end