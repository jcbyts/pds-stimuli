function p=faceInvaders(p, state, sn)
% FACEFORAGE module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m



if nargin<3
    sn='faceForage';
end


switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        p.trial.(sn).n.update
        %     case p.trial.pldaps.trialStates.frameUpdate
        
        
    case p.trial.pldaps.trialStates.frameDraw
        
        if p.trial.(sn).on
            if p.trial.(sn).gazeContingent
                p.trial.(sn).n.xy = [p.trial.eyeX p.trial.eyeY]+p.trial.(sn).xy;
            end
            p.trial.(sn).n.draw
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        
        x0=(1:p.trial.(sn).gridSize) - p.trial.(sn).gridSize/2);
        
        [xx,yy] = meshgrid(x0);
        
        p.trial.(sn).xyDeg = [xx(:) yy(:)];
        p.trial.(sn).xyPx  = p.trial.(sn).xyDeg;
        for i=1:size(p.trial.(sn).xyPx,1)
            p.trial.(sn).xyPx(i,:) = pds.px2deg(p.trial.(sn).xyDeg(i,:), 
        
        
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        if ~isfield(p.trial.(sn), 'fixRadius')
            p.trial.(sn).fixRadius=1;
        end
        
        if ~isfield(p.trial.(sn), 'gridSize')
            p.trial.(sn).gridSize=10;
        end
        
        if ~isfield(p.trial.(sn), 'gridSpacing')
            p.trial.(sn).gridSpacing = 5;
        end
       
        p.trial.(sn).on = true;
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
end
