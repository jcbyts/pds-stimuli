function p=screenSaverTrial2(p,state, sn)
%plain    a plain stimulus file for use with a pldaps class. This file
%         serves both as the expriment setup file and the trial state function
% example:
% load settingsStruct
% p=pldaps(@plain,'demo', settingsStruct);
% p.run

if nargin<3
    sn='screensaver';
end

    if nargin==1 %initial call to setup conditions
        
        p = pdsDefaultTrialStructure(p);

%         dv.defaultParameters.pldaps.trialMasterFunction='runTrial';
        p.defaultParameters.pldaps.trialFunction='screenSaverTrial2';
        %five seconds per trial.
        p.trial.pldaps.maxTrialLength = 5;
        p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;
        
        p.trial.(sn).imgDir='/media/marmorig/Data/tofu.psych.upenn.edu/fulldb/cd12B_closeup_ground_cover_woods_shade_sun/';
        p.trial.(sn).fileList=dir(fullfile(p.trial.(sn).imgDir,'*LUM.mat'));
        
        p.trial.(sn).numToShow=10;
        p.trial.(sn).imgIndex=randi(numel(p.trial.(sn).fileList), p.trial.(sn).numToShow, 1);
        %% Make Textures
        p.trial.(sn).A.tex = nan(p.trial.(sn).numToShow,1);
        
        for i=1:p.trial.(sn).numToShow
            tmp=load(fullfile(p.trial.(sn).imgDir, p.trial.(sn).fileList(p.trial.(sn).imgIndex(i)).name));
            m=tmp.LUM_Image/max(tmp.LUM_Image(:));
            p.trial.(sn).A.tex(i)=Screen('MakeTexture',p.trial.display.ptr,m*256);
            
        end

        c.Nr=1; %one condition;
        p.conditions=repmat({c},1,200);

        p.defaultParameters.pldaps.finish = length(p.conditions); 
    else
        %if you don't want all the pldapsDefaultTrialFucntions states to be used,
        %just call them in the states you want to use it.
        %otherwise just leave it here
        pldapsDefaultTrialFunction(p,state);
        switch state
            case p.trial.pldaps.trialStates.frameUpdate
                if mod(p.trial.iFrame, 10*120)==0
                p.trial.(sn).texToDraw=randi(numel(p.trial.(sn).A.tex));
                end
%             case dv.trial.pldaps.trialStates.framePrepareDrawing; 
            case p.trial.pldaps.trialStates.frameDraw;
                Screen('DrawTexture', p.trial.display.ptr, p.trial.(sn).A.tex(p.trial.(sn).texToDraw), [], [0 0 1900 1080] )
% %             case dv.trial.pldaps.trialStates.frameIdlePreLastDraw;
% %             case dv.trial.pldaps.trialStates.frameDrawTimecritical;
%             case dv.trial.pldaps.trialStates.frameDrawingFinished;
% %             case dv.trial.pldaps.trialStates.frameIdlePostDraw;
%
            case p.trial.pldaps.trialStates.trialSetup
                p.trial.(sn).texToDraw=randi(numel(p.trial.(sn).A.tex));
%             case dv.trial.pldaps.trialStates.trialPrepare
%             case dv.trial.pldaps.trialStates.trialCleanUpandSave

            case p.trial.pldaps.trialStates.frameFlip;   
                if p.trial.iFrame == p.trial.pldaps.maxFrames
                    p.trial.flagNextTrial=true;
                end
        end
    end