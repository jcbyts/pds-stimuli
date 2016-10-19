function p=screenSaverTrial(p,state, sn)
%plain    a plain stimulus file for use with a pldaps class. This file
%         serves both as the expriment setup file and the trial state function
% example:
% load settingsStruct
% p=pldaps(@plain,'demo', settingsStruct);
% p.run

if nargin<3
    sn='screensaver';
end


switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        if mod(p.trial.iFrame, 10*120)==0
            p.trial.(sn).texToDraw=randi(numel(p.trial.(sn).A.tex));
        end
        %             case dv.trial.pldaps.trialStates.framePrepareDrawing;
        if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.bKey)
            p.trial.(sn).drawbackground=~p.trial.(sn).drawbackground;
        end
        
    case p.trial.pldaps.trialStates.frameDraw;
        if p.trial.(sn).drawbackground
        Screen('DrawTexture', p.trial.display.ptr, p.trial.(sn).A.tex(p.trial.(sn).texToDraw), [], [0 0 1900 1080] )
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        p.trial.(sn).texToDraw=randi(numel(p.trial.(sn).A.tex));
        %             case dv.trial.pldaps.trialStates.trialPrepare
        %             case dv.trial.pldaps.trialStates.trialCleanUpandSave
        
        
        %% experiment
%     case p.trial.pldaps.trialStates.experimentPreOpenScreen
        %%
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
%         p.trial.(sn).imgDir='/media/marmorig/Data/tofu.psych.upenn.edu/fulldb/cd12B_closeup_ground_cover_woods_shade_sun/';
%         p.trial.(sn).fileList=dir(fullfile(p.trial.(sn).imgDir,'*LUM.mat'));
        p.trial.(sn).imgDir='/media/marmorig/Data/RangeDatabase1080p/';
        p.trial.(sn).fileList=dir(fullfile(p.trial.(sn).imgDir, 'lImage*V.png'));
        
        p.trial.(sn).numToShow=10;
        p.trial.(sn).imgIndex=randi(numel(p.trial.(sn).fileList), p.trial.(sn).numToShow, 1);
        %% Make Textures
        p.trial.(sn).A.tex = nan(p.trial.(sn).numToShow,1);
        
        if ~isfield(p.trial.(sn), 'drawbackground')
            p.trial.(sn).drawbackground=true;
        end
        
        for i=1:p.trial.(sn).numToShow
%             tmp=load(fullfile(p.trial.(sn).imgDir, p.trial.(sn).fileList(p.trial.(sn).imgIndex(i)).name));
% m=tmp.LUM_Image/max(tmp.LUM_Image(:));
            m=imread(fullfile(p.trial.(sn).imgDir, p.trial.(sn).fileList(p.trial.(sn).imgIndex(i)).name));
%             m=permute(m, [2 1 3]);
%             m=m./max(m(:));
%             m=m*255;
% % %             m(:,:,4)=255;
% %             m=uint8(m);
%             m=double(m);
            
            p.trial.(sn).A.tex(i)=Screen('MakeTexture',p.trial.display.ptr,m);
            
        end
end
