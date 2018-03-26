function p=v1mappingForage(p,state, sn)
% Trial function for doing a generic V1 mapping paradigm with noise
% stimuli, natural backgrounds, and a foraging task

if nargin<3
    sn='stimulus';
end


pldapsDefaultTrialFunction(p,state);

switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        % check keyboard presses
        if any(p.trial.keyboard.firstPressQ)
            
            if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.nKey)
                p.trial.(sn).pixelNoise.on=~p.trial.(sn).pixelNoise.on;
            end
            
            if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.bKey)
                p.trial.(sn).background.on=~p.trial.(sn).background.on;
            end
            
        end
        
    case p.trial.pldaps.trialStates.frameUpdate
        if mod(p.trial.iFrame, 10*120)==0
            p.trial.(sn).background.texToDraw=randi(numel(p.trial.(sn).background.tex));
        end
        %------------------------------------------------------------------
        % Noise
        if p.trial.(sn).pixelNoise.on
            p.trial.(sn).pixelNoise.n.update
            p.trial.(sn).pixelNoise.img(p.trial.iFrame,:)=p.trial.(sn).pixelNoise.n.img(:);
        end
        
        if p.trial.(sn).gaussianNoise.on
            p.trial.(sn).gaussianNoise.n.update
            p.trial.(sn).gaussianNoise.xpos(p.trial.iFrame, :)=p.trial.(sn).gaussianNoise.n.x;
            p.trial.(sn).gaussianNoise.ypos(p.trial.iFrame, :)=p.trial.(sn).gaussianNoise.n.y;
            p.trial.(sn).gaussianNoise.scale(p.trial.iFrame, :)=p.trial.(sn).gaussianNoise.n.scale;
%             p.trial.(sn).gaussianNoise.xpos(p.trial.iFrame, :)=p.trial.(sn).gaussianNoise.n.x;
        end

    case p.trial.pldaps.trialStates.frameDraw
        %------------------------------------------------------------------
        % Background
        if p.trial.(sn).background.on
            Screen('DrawTexture', p.trial.display.ptr, p.trial.(sn).background.tex(p.trial.(sn).background.texToDraw), [], [0 0 1900 1080], [], [], [], [], [], kPsychDontDoRotation)
        end
        %------------------------------------------------------------------
        % Noise
        if p.trial.(sn).pixelNoise.on
            p.trial.(sn).pixelNoise.n.draw
        end
        
        if p.trial.(sn).gaussianNoise.on
            p.trial.(sn).gaussianNoise.n.draw
        end
        
        %% Eyeposition
        if p.trial.eyelink.use
            estart=(p.trial.eyelink.sampleNum-p.trial.(sn).eyeTrailLength);
            eye=p.trial.eyelink.samples(p.trial.eyelink.eyeIdx+[13 15],max( estart+mod(-estart,p.trial.(sn).eyeTrailStep),1):p.trial.(sn).eyeTrailStep:p.trial.eyelink.sampleNum);
            
             Screen('Drawdots',  p.trial.display.overlayptr, eye, ...
            2, p.trial.display.clut.greenbg, [0 0],0);
        end
       
        % %             case dv.trial.pldaps.trialStates.frameIdlePreLastDraw;
        % %             case dv.trial.pldaps.trialStates.frameDrawTimecritical;
        %             case dv.trial.pldaps.trialStates.frameDrawingFinished;
        % %             case dv.trial.pldaps.trialStates.frameIdlePostDraw;
        %
    case p.trial.pldaps.trialStates.trialSetup % before trial
        
        % setup default trial values in the dv.trial struct
        p.trial.stimulus.rngs.trialSeed=p.trial.stimulus.rngs.trialSeeds(p.trial.pldaps.iTrial);
        p.trial.stimulus.rngs.trialRNG=RandStream(p.trial.stimulus.randomNumberGenerater, 'seed', p.trial.stimulus.rngs.trialSeed);
        p.trial.stimulus.rngs.conditionerRNG=RandStream(p.trial.stimulus.randomNumberGenerater, 'seed',  randi(p.trial.stimulus.rngs.trialRNG,2^32, 1));
        setupRNG=p.trial.stimulus.rngs.conditionerRNG;
        
        %% Background Image
        % Randomly select images to draw and make textures
        p.trial.(sn).background.imgIndex=randi(setupRNG, numel(p.trial.(sn).background.fileList), p.trial.(sn).background.numToShow, 1);
        
        p.trial.(sn).background.tex = nan(p.trial.(sn).background.numToShow,1);
        
        if ~isfield(p.trial.(sn).background, 'on')
            p.trial.(sn).background.on=true;
        end
        
        for i=1:p.trial.(sn).background.numToShow
            m=imread(fullfile(p.trial.(sn).background.imgDir, p.trial.(sn).background.fileList(p.trial.(sn).background.imgIndex(i)).name));
%             m=m-127;
%             m=m/max(m(:))*255;
%             m(:,:,4)=1;
%             m(1:2:end,1:2:end,:)
            p.trial.(sn).background.tex(i)=Screen('MakeTexture',p.trial.display.ptr,m,[],[]);
%             Screen('BlendFunction', p.trial.(sn).background.tex(i), GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        end
        
        if p.trial.(sn).background.on
            Screen('BlendFunction', p.trial.display.ptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        else
            Screen('BlendFunction', p.trial.display.ptr, GL_ONE, GL_ONE);
        end
        
        p.trial.(sn).background.texToDraw=randi(setupRNG, numel(p.trial.(sn).background.tex));
        
        %% Noise
        if p.trial.(sn).pixelNoise.on
            p.trial.(sn).pixelNoise.n=stimuli.pixelNoise(p.trial.display.ptr, 'type', p.trial.(sn).pixelNoise.type, ...
                'dim', p.trial.(sn).pixelNoise.dim, 'xy', p.trial.(sn).pixelNoise.xy+p.trial.display.ctr([1 2]), ...
                'pxsize', p.trial.(sn).pixelNoise.checkSize, 'sigma', p.trial.(sn).pixelNoise.sigma);
            p.trial.(sn).pixelNoise.img=nan(20e3, prod(p.trial.(sn).pixelNoise.dim));
        end
        
        if p.trial.(sn).gaussianNoise.on
            p.trial.(sn).gaussianNoise.n=stimuli.gaussianNoise(p.trial.display.ptr, 'contrast', p.trial.(sn).gaussianNoise.contrast, ...
                'sc', p.trial.(sn).gaussianNoise.sc, 'count', p.trial.(sn).gaussianNoise.count, 'rng', setupRNG);
            p.trial.(sn).gaussianNoise.n.setup;
            p.trial.(sn).gaussianNoise.n.update;
            p.trial.(sn).gaussianNoise.xpos=nan(10e3, p.trial.(sn).gaussianNoise.n.count);
            p.trial.(sn).gaussianNoise.ypos=nan(10e3, p.trial.(sn).gaussianNoise.n.count);
            p.trial.(sn).gaussianNoise.scale=nan(10e3, p.trial.(sn).gaussianNoise.n.count);
            p.trial.(sn).gaussianNoise.contrast=nan(10e3, p.trial.(sn).gaussianNoise.n.count);
        end
        %% Forage
        %             case dv.trial.pldaps.trialStates.trialPrepare
    case p.trial.pldaps.trialStates.trialCleanUpandSave
         
        for i=1:p.trial.(sn).background.numToShow
           Screen('Close', p.trial.(sn).background.tex(i));
        end
        
        if p.trial.(sn).gaussianNoise.on
            ix=p.trial.iFrame+1:size(p.trial.(sn).gaussianNoise.xpos,1);
            p.trial.(sn).gaussianNoise.xpos(ix,:)=[];
            p.trial.(sn).gaussianNoise.ypos(ix,:)=[];
            p.trial.(sn).gaussianNoise.scale(ix,:)=[];
        end
%         p.trial.(sn).gaussianNoise.xpos(ix,:)=[];
        
    case p.trial.pldaps.trialStates.frameFlip;
        if p.trial.iFrame == p.trial.pldaps.maxFrames
            p.trial.flagNextTrial=true;
        end
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        p=stimuli.setupRandomSeed(p);
end