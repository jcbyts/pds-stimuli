function fixation(p, state, sn)

switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        checkFixation(p, sn)
        
    case p.trial.pldaps.trialStates.trialSetup
        
        p.trial.(sn).hFix=stimuli.fixation(p.trial.display.overlayptr, ...
            'centreSize', p.trial.(sn).fixdotW/2, ...
            'surroundSize', p.trial.(sn).fixdotW, ...
            'position', p.trial.display.ctr(1:2));
        
        p.trial.(sn).hFix.cColour=p.trial.display.clut.bg;
        p.trial.(sn).hFix.sColour=p.trial.display.clut.bg;
        
    case p.trial.pldaps.trialStates.frameUpdate
        
end


end

function checkFixation(p, sn)
    currentEye=p.trial.(sn).eyeXYs(1:2,p.trial.iFrame);
    
    % check if fixation should be shown
    switch p.trial.(sn).state
        case p.trial.(sn).states.START
            
            
            % time to turn on fixation
            if p.trial.iFrame > p.trial.(sn).preTrial
                p.trial.(sn).state=p.trial.(sn).states.FPON;
                p.trial.(sn).hFix.cColour = p.trial.display.clut.targetnull;
                p.trial.(sn).hFix.sColour = p.trial.display.clut.black;
                
                p.trial.(sn).colorFixWindow = p.trial.display.clut.window;
                p.trial.(sn).timeFpEntered = p.trial.ttime;
                p.trial.(sn).frameFpEntered = p.trial.iFrame;
            end
            
        case p.trial.(sn).states.FPON
            fixRadius=p.trial.(sn).fpOnRadius;
            % is fixation held
            isheld=fixationHeld(p.trial.(sn).fixXY, currentEye, fixRadius, p.trial.(sn).fixationWindowType);
            if isheld && p.trial.iFrame < p.trial.(sn).fixWait
                p.trial.(sn).frameFpEntered=p.trial.iFrame;
                p.trial.(sn).state=p.trial.(sn).states.FPHOLD;
            else
                p.trial.(sn).state=p.trial.(sn).states.BREAKFIX;
            end
            
        case p.trial.(sn).states.FPHOLD
            fixRadius=p.trial.(sn).fpHoldRadius;
            % is fixation held
            isheld=fixationHeld(p.trial.(sn).fixXY, currentEye, fixRadius, p.trial.(sn).fixationWindowType);
            if isheld && p.trial.iFrame < p.trial.(sn).states.maxFixHold
                % do nothing
            elseif p.trial.iFrame > p.trial.(sn).states.minFixHold 
                p.trial.(sn).state=p.trial.(sn).states.CHOOSETARG;
                p.trial.(sn).hFix.cColour = p.trial.display.clut.bg;
                p.trial.(sn).hFix.sColour = p.trial.display.clut.bg;
                p.trial.(sn).timeFpOff = p.trial.ttime;
                p.trial.(sn).frameFpOff = p.trial.iFrame;
                
            else % break fixation
                p.trial.(sn).state=p.trial.(sn).BREAKFIX;
            end
            
            
    end

end

function held = fixationHeld(target, eye, window, type)
if type ==0 %pass
    held=true;
elseif type ==1 %squarewindows window is half width
    held=all(abs(target-eye)<window);
elseif type==2 %circular window is a radius
    held=sqrt(sum((target-eye).^2))<window;
end
end