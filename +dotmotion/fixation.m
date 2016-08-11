function fixation(p, state, sn)
% fixation state management

switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        checkFixation(p, sn)
        
    case p.trial.pldaps.trialStates.trialSetup
        
        p.trial.(sn).hFix=stimuli.fixation(p.trial.display.overlayptr, ...
            'centreSize', p.trial.(sn).fixDotW/2, ...
            'surroundSize', p.trial.(sn).fixDotW, ...
            'position', p.trial.display.ctr(1:2)+pds.deg2px(p.trial.(sn).fixDotXY(:), p.trial.display.viewdist, p.trial.display.w2px, true)', ...
            'fixType', 2, ...
            'winType', 2, ...
            'centreColour', p.trial.display.clut.bg, ...
            'surroundColour', p.trial.display.clut.bg, ...
            'winColour', p.trial.display.clut.bg);
        
        p.trial.(sn).state=p.trial.(sn).states.START;
        
    case p.trial.pldaps.trialStates.frameDraw
        p.trial.(sn).hFix.drawFixation
        
end


end

function checkFixation(p, sn)
    currentEye=[p.trial.eyeX p.trial.eyeY]; %p.trial.(sn).eyeXYs(1:2,p.trial.iFrame);
%     fprintf('checking: state ')
    % check if fixation should be shown
    switch p.trial.(sn).state
        case p.trial.(sn).states.START
%             fprintf('START\n')
            
            % time to turn on fixation
            if p.trial.ttime > p.trial.(sn).preTrial
                fixOn(p,sn) % fixation point on
            end
            
        case p.trial.(sn).states.FPON
%             fprintf('FPON\n')
            % is fixation held
            isheld=p.trial.(sn).hFix.isheld(currentEye);
            if isheld && p.trial.ttime < p.trial.(sn).fixWait + p.trial.(sn).timeFpOn
                fixHold(p,sn)
            elseif p.trial.ttime > p.trial.(sn).fixWait + p.trial.(sn).timeFpOn
                breakFix(p,sn)
            end
            
        case p.trial.(sn).states.FPHOLD
%             fprintf('FPHOLD\n')
            % is fixation held
            isheld=p.trial.(sn).hFix.isheld(currentEye);
            if isheld && p.trial.ttime < p.trial.(sn).maxFixHold + p.trial.(sn).timeFpEntered
                % do nothing
            elseif ~isheld && p.trial.ttime > p.trial.(sn).minFixHold + p.trial.(sn).timeFpEntered
               fixOff(p,sn)
            else % break fixation
                breakFix(p,sn)
            end
            
            
    end

end

function breakFix(p,sn)
p.trial.(sn).hFix.cColour = p.trial.display.clut.bg;
p.trial.(sn).hFix.sColour = p.trial.display.clut.bg;
p.trial.(sn).hFix.winColour=p.trial.display.clut.bg;
% PsychPortAudio('Start', p.trial.sound.breakfix)

p.trial.(sn).timeFpOff = p.trial.ttime;
p.trial.(sn).frameFpOff = p.trial.iFrame;
p.trial.(sn).state=p.trial.(sn).states.BREAKFIX;
end

function fixOn(p,sn)
p.trial.(sn).hFix.cColour = p.trial.display.clut.white;
p.trial.(sn).hFix.sColour = p.trial.display.clut.black;
p.trial.(sn).hFix.winColour=p.trial.display.clut.window;

p.trial.(sn).timeFpOn = p.trial.ttime;
p.trial.(sn).frameFpOn = p.trial.iFrame;
p.trial.(sn).state=p.trial.(sn).states.FPON;
end

function fixHold(p,sn)
p.trial.(sn).hFix.cColour = p.trial.display.clut.white;
p.trial.(sn).hFix.sColour = p.trial.display.clut.black;
p.trial.(sn).hFix.winColour=p.trial.display.clut.greenbg;

p.trial.(sn).timeFpEntered = p.trial.ttime;
p.trial.(sn).frameFpEntered = p.trial.iFrame;
p.trial.(sn).state=p.trial.(sn).states.FPHOLD;
end

function fixOff(p,sn)
p.trial.(sn).hFix.cColour = p.trial.display.clut.bg;
p.trial.(sn).hFix.sColour = p.trial.display.clut.bg;
p.trial.(sn).hFix.winColour=p.trial.display.clut.bg;

p.trial.(sn).timeFpOff = p.trial.ttime;
p.trial.(sn).frameFpOff = p.trial.iFrame;
p.trial.(sn).state=p.trial.(sn).states.CHOOSETARG;
end