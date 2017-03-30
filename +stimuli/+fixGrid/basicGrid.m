function p=basicGrid(p, state, sn)
% FACEFORAGE module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m



if nargin<3
    sn='fixGrid';
end


switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        
    case p.trial.pldaps.trialStates.frameDraw
        
        Screen('DrawDots', p.trial.display.overlayptr, p.trial.(sn).xyPx, p.trial.(sn).szPx, p.trial.display.clut.black, [], 2);
        Screen('DrawDots', p.trial.display.overlayptr, p.trial.(sn).xyPx, p.trial.(sn).szPx/2, p.trial.display.clut.white, [], 2);
        
    case p.trial.pldaps.trialStates.trialSetup
        
        x0=(1:p.trial.(sn).gridSize) - p.trial.(sn).gridSize/2;
        
        [xx,yy] = meshgrid(x0*p.trial.(sn).gridSpacing);
        
        p.trial.(sn).xyDeg = [xx(:) yy(:)];
        p.trial.(sn).xyPx  = p.trial.(sn).xyDeg';
        for i=1:size(p.trial.(sn).xyPx,2)
            p.trial.(sn).xyPx(:,i) = pds.deg2px(p.trial.(sn).xyDeg(i,:)',p.trial.display.viewdist, p.trial.display.w2px)+p.trial.display.ctr(1:2)';
        end
        
        p.trial.(sn).szPx = p.trial.display.ppd*p.trial.(sn).dotSize;
        
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        if ~isfield(p.trial.(sn), 'dotSize')
            p.trial.(sn).dotSize=.7;
        end
        
        if ~isfield(p.trial.(sn), 'gridSize')
            p.trial.(sn).gridSize=11;
        end
        
        if ~isfield(p.trial.(sn), 'gridSpacing')
            p.trial.(sn).gridSpacing = 2;
        end
       
        p.trial.(sn).on = true;
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        
end
