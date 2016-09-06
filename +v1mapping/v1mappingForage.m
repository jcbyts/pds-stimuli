function p=v1mappingForage(p,state, sn)
% Trial function for doing a generic V1 mapping paradigm with noise
% stimuli, natural backgrounds, and a foraging task

global GL

if nargin<3
    sn='stimulus';
end


pldapsDefaultTrialFunction(p,state);

switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        % check keyboard presses
        if any(p.trial.keyboard.firstPressQ)
            
            if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.nKey)
                p.trial.(sn).noise.on=~p.trial.(sn).noise.on;
            end
            
            if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.bKey)
                p.trial.(sn).background.on=~p.trial.(sn).background.on;
            end
            
        end
        
    case p.trial.pldaps.trialStates.frameUpdate
        if mod(p.trial.iFrame, 10*120)==0
            p.trial.(sn).background.texToDraw=randi(numel(p.trial.(sn).background.tex));
        end
        
        p.trial.(sn).noise.n.update
        %             case dv.trial.pldaps.trialStates.framePrepareDrawing;
    case p.trial.pldaps.trialStates.frameDraw
        %------------------------------------------------------------------
        % Background
        if p.trial.(sn).background.on
% %             glCallList(p.trial.(sn).my);
            Screen('DrawTexture', p.trial.display.ptr, p.trial.(sn).background.tex(p.trial.(sn).background.texToDraw), [], [0 0 1900 1080], [], [], [], [], [], kPsychDontDoRotation)
        end
        %------------------------------------------------------------------
        % Noise
        p.trial.(sn).noise.n.draw
        
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
        
        
        %% Background Image
        % Randomly select images to draw and make textures
        p.trial.(sn).background.imgIndex=randi(numel(p.trial.(sn).background.fileList), p.trial.(sn).background.numToShow, 1);
        
        p.trial.(sn).background.tex = nan(p.trial.(sn).background.numToShow,1);
        
        if ~isfield(p.trial.(sn).background, 'on')
            p.trial.(sn).background.on=true;
        end
        
        for i=1:p.trial.(sn).background.numToShow
            m=imread(fullfile(p.trial.(sn).background.imgDir, p.trial.(sn).background.fileList(p.trial.(sn).background.imgIndex(i)).name));
            
            p.trial.(sn).background.tex(i)=Screen('MakeTexture',p.trial.display.ptr,m(1:2:end,1:2:end,:));
            
        end
        p.trial.(sn).background.texToDraw=randi(numel(p.trial.(sn).background.tex));
        
% %         %% try GL list background textur
% %         p.trial.(sn).my = glGenLists(1);
% %         glNewList(p.trial.(sn).my,GL.COMPILE);
% % %         Screen('DrawTexture', p.trial.display.ptr, p.trial.(sn).background.tex(p.trial.(sn).background.texToDraw), [], [0 0 1900 1080] )
% %         Screen('DrawTexture', p.trial.display.ptr, p.trial.(sn).background.tex(p.trial.(sn).background.texToDraw), [], [0 0 1900 1080] )
% %         glEndList();
        
        %% Noise
%         p.trial.(sn).noise.n=stimuli.pixelNoise(p.trial.display.ptr, 'type', p.trial.(sn).noise.type, ...
%             'dim', p.trial.(sn).noise.dim, 'xy', p.trial.(sn).noise.xy+p.trial.display.ctr([1 2]), ...
%             'pxsize', p.trial.(sn).noise.checkSize, 'sigma', p.trial.(sn).noise.sigma);
        p.trial.(sn).noise.n=stimuli.gaussianNoise(p.trial.display.ptr);
        p.trial.(sn).noise.n.setup;
        p.trial.(sn).noise.n.update;
        
        
        %% Forage
        %             case dv.trial.pldaps.trialStates.trialPrepare
    case p.trial.pldaps.trialStates.trialCleanUpandSave
         
        for i=1:p.trial.(sn).background.numToShow
           Screen('Close', p.trial.(sn).background.tex(i));
        end
% %         glDeleteLists(p.trial.stimulus.my,1);
        
    case p.trial.pldaps.trialStates.frameFlip;
        if p.trial.iFrame == p.trial.pldaps.maxFrames
            p.trial.flagNextTrial=true;
        end
end