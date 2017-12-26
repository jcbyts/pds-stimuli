function p=natImgBackground(p, state, sn)
% natImgBackground is a module for PLDAPS open reception
% Displays images found in a specified directory in the background of a
% task

if nargin<3
    sn='natImgBackground';
end


switch state
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        p.defaultParameters.(sn).stateFunction.acceptsLocationInput = true; % is this necessary
        % setup states that will be called by this module
        p.defaultParameters.(sn).stateFunction.requestedStates.experimentPostOpenScreen = true;
        p.defaultParameters.(sn).stateFunction.requestedStates.trialSetup = true;
        p.defaultParameters.(sn).stateFunction.requestedStates.framePrepareDrawing = true;
        p.defaultParameters.(sn).stateFunction.requestedStates.frameDraw = true;
        p.defaultParameters.(sn).stateFunction.requestedStates.trialCleanUpandSave = true;

        p = stimuli.setupRandomSeed(p, sn);
        
%         p.defaultParameters.(sn).rngs.randomNumberGenerater='mrg32k3a';
%         p.defaultParameters.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        p.trial.(sn).texShown(p.trial.iFrame)=p.trial.(sn).texToDraw;
        
    case p.trial.pldaps.trialStates.frameDraw
        
        %------------------------------------------------------------------
        % Draw Background
        Screen('DrawTexture', p.trial.display.ptr, p.trial.(sn).tex(p.trial.(sn).texToDraw), [], [0 0 p.trial.display.pWidth p.trial.display.pHeight], [], [], [], [], [], kPsychDontDoRotation)
        
    case p.trial.pldaps.trialStates.trialSetup
        
        %------------------------------------------------------------------
        % Select images to draw this trial
        p.trial.display.sourceFactorNew = GL_SRC_ALPHA;
        Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG = RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        
        p.trial.(sn).imgIndex = randi(p.trial.(sn).rngs.conditionerRNG, numel(p.trial.(sn).fileList), p.trial.(sn).numToShow, 1);
        p.trial.(sn).tex = nan(p.trial.(sn).numToShow,1);
        
        p.trial.(sn).texToDraw=randi(p.trial.(sn).rngs.conditionerRNG, p.trial.(sn).numToShow);
        
        blendFlag = strcmp(p.trial.display.destinationFactorNew, GL_ONE);
        for i=1:p.trial.(sn).numToShow
            m=imread(fullfile(p.trial.(sn).imgDir, p.trial.(sn).fileList(p.trial.(sn).imgIndex(i)).name));
            texMode = [];
            if blendFlag
                m = double(m);
                m = (m - 127) / 127;
                m = m .* p.trial.(sn).imageContrast;
                texMode = 2;
            end
            
            p.trial.(sn).tex(i)=Screen('MakeTexture',p.trial.display.ptr,m,[],[],texMode);
            %             Screen('BlendFunction', p.trial.(sn).background.tex(i), GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        end
        
        p.trial.(sn).texShown=nan(1,10e3);
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        %------------------------------------------------------------------
        % Setup IMG directory and random seeds
        if ~isfield(p.trial.(sn), 'imgDir')
            cguipath = which('calibrationGUI');
            pathto = fileparts(cguipath);
            
            p.trial.(sn).imgDir   = fullfile(pathto, 'Backgrounds');
            p.trial.(sn).fileList = dir(fullfile(p.trial.(sn).imgDir, '*.JPG'));

        end
        
        if ~isfield(p.trial.(sn), 'numToShow')
            p.trial.(sn).numToShow=10;
        end
        
        if ~isfield(p.trial.(sn), 'imageContrast')
            p.trial.(sn).imageContrast = .5;
        end
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        p.trial.(sn).texShown(p.trial.iFrame+1:end)=[];
        Screen('Close', p.trial.(sn).tex)
end