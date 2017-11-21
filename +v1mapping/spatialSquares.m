function p=spatialSquares(p, state, sn)
% gaussian noise module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m

if nargin<3
    sn='gaussianNoiseBlobs';
end


switch state
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
    case p.trial.pldaps.trialStates.frameUpdate
        
    case p.trial.pldaps.trialStates.frameDraw
        
        if p.trial.(sn).on
            Screen('FillRect', p.trial.display.ptr, [1 1 1], p.trial.(sn).pos(:,:,p.trial.iFrame))
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % --- Set Blend Function
        p.trial.display.sourceFactorNew = GL_ONE;
        p.trial.display.destinationFactorNew = GL_ONE;
        
        Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);

        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        pxwin = pds.deg2px(reshape(p.trial.(sn).position, 2, 2), p.trial.display.viewdist, p.trial.display.w2px);
        pxwin = pxwin(:)'.*[1 -1 1 -1] + p.trial.display.ctr;
        pWidth  = pxwin(3)-pxwin(1);
        pHeight = pxwin(4)-pxwin(2);
        pUlX   = pxwin(1);
        pUlY   = pxwin(2);
        
        
        p.trial.(sn).pos = nan(4, p.trial.(sn).N, p.trial.pldaps.maxFrames);
        lifetime = randi(setupRNG, p.trial.(sn).lifetime, p.trial.(sn).N, 1);
        xpos = round(rand(setupRNG, p.trial.(sn).N, 1)*pWidth) + pUlX;
        ypos = round(rand(setupRNG, p.trial.(sn).N, 1)*pHeight) + pUlY;
        szpix = p.trial.(sn).size * p.trial.display.ppd;
        rect = [xpos(:) ypos(:) xpos(:)+szpix ypos(:)+szpix];
        p.trial.(sn).pos(:,:,1) = rect';
        for iFrame = 2:p.trial.pldaps.maxFrames
            idx = lifetime == 1;
            xpos = round(rand(setupRNG, sum(idx), 1)*pWidth) + pUlX;
            ypos = round(rand(setupRNG, sum(idx), 1)*pHeight) + pUlY;
            rect(idx,:) = [xpos(:) ypos(:) xpos(:)+szpix ypos(:)+szpix];
            p.trial.(sn).pos(:,:,iFrame) = rect';
                
%            p.trial.(sn).pos(iFrame,1:2

            lifetime = mod(lifetime, p.trial.(sn).lifetime)+1;
            
        end
        
        
        
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        if ~isfield(p.trial.(sn), 'size')
            p.trial.(sn).size=2;
        end
        
        if ~isfield(p.trial.(sn), 'N')
            p.trial.(sn).N=4;
        end
        
        if ~isfield(p.trial.(sn), 'contrast')
            p.trial.(sn).contrast=.25;
        end
        
        if ~isfield(p.trial.(sn), 'on')
            p.trial.(sn).on=true;
        end
        
        if ~isfield(p.trial.(sn), 'lifetime')
            p.trial.(sn).lifetime=3;
        end
        
        if ~isfield(p.trial.(sn), 'position')
            win = pds.px2deg([-p.trial.display.pWidth -p.trial.display.pHeight; p.trial.display.pWidth p.trial.display.pHeight]'/2, p.trial.display.viewdist, p.trial.display.px2w);
            win = win(:)'.*[1 -1 1 -1];
            p.trial.(sn).position = win;
        end
        
        p.trial.(sn).rngs.randomNumberGenerater='twister';
        p.trial.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        if p.trial.(sn).on
            ix=p.trial.iFrame:size(p.trial.(sn).pos,3);
            p.trial.(sn).pos(:,:,ix)=[];
        end
        
end