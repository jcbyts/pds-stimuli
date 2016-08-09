function fixation(p, sn)
% check fixation state

    currentEye=p.trial.(sn).eyeXYs(1:2,p.trial.iFrame);
    
    % check if fixation should be shown
    if (p.trial.(sn).state == p.trial.(sn).states.START) && p.trial.iFrame > p.trial.(sn).preTrial
        p.trial.(sn).draw.showFixation=true;
    end
    
    % set fixation windowsize by state
    if (p.trial.(sn).state == p.trial.(sn).states.FPON)
        fixRadius=p.trial.(sn).fpOnRadius;
    elseif (p.trial.(sn).state == p.trial.(sn).states.FPHOLD)
        fixRadius=p.trial.(sn).fpHoldRadius;
    else
        fixRadius=nan;
    end
    
    % is fixation held
    isheld=fixationHeld(p.trial.(sn).fixXY, currentEye, fixRadius, p.trial.(sn).fixationWindowType);
    
    % if FPON
    if (p.trial.(sn).state == p.trial.(sn).states.FPON)
        if isheld && p.trial.iFrame < p.trial.(sn).fixWait
            p.trial.(sn).frameFpEntered=p.trial.iFrame;
            p.trial.(sn).state=p.trial.(sn).states.FPHOLD;
        else
            p.trial.(sn).state=p.trial.(sn).states.BREAKFIX;
        end
    end
    
    % if FPHOLD
    if (p.trial.(sn).state == p.trial.(sn).states.FPON)
        if isheld
            % do nothing
        elseif p.trial.iFrame > p.trial.(sn).states.minFixHold && p.trial.iFrame < p.trial.(sn).states.maxFixHold
            p.trial.(sn).state=p.trial.(sn).states.CHOOSETARG;
            p.trial.(sn).draw.showFixation=false;
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