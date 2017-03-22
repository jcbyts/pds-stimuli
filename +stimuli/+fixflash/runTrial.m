function p=runTrial(p,state, sn)
% RUNTRIAL run a trial of the dotmotion task
%
% stimuli.dotmotion.runTrial is a PLDAPS trial function. PLDAPS trial functions switch
% between different states that have to do with timing relative to the
% frame refresh
% 
% all task/stimulus states are managed with a stimuli.trial object that is
% constructed in stimuli.dotmotion.trialSetup(). That object, hTrial, controls the
% transitions through the following states:
% 
% state0_ShowFixation - turn on the fixation point and wait for fixation
% state1_FixWait      - grace period immediately after entering window
% state2_FixPreStim   - hold fixation before showing dots
% state6_HoldChoice   - hold choice to be evaluated
% state7_BreakFixTimeout    - penalty for breaking fixation
% state8_InterTrialInterval - time at the end of the trial
%
% 09.08.2016 Jacob L. Yates <jacoby8s@gmail.com> - wrote it
% 01.06.2016 Jacob L. Yates <jacoby8s@gmail.com> - uses Shaun's class to run states

if nargin<3
    sn='stimulus';
end

% --- Gets Eye position and draws default overlays (grid, etc.)
pldapsDefaultTrialFunction(p,state)

% --- switch PLDAPS trial states
switch state

    % --- Prepare drawing (All behavior action happens here)
    case p.trial.pldaps.trialStates.frameUpdate
        
        % --- Update info in @dotMotionTrial object
        if p.trial.(sn).hTrial.done
            p.trial.flagNextTrial=true;
        end
        
        ctr = p.trial.display.ctr(1:2);
        p.trial.(sn).hTrial.x = (p.trial.eyeX - ctr(1)) / p.trial.display.ppd;
        p.trial.(sn).hTrial.y = -(p.trial.eyeY - ctr(2)) / p.trial.display.ppd;

        % --- @dotMotionTrial/afterFrame handles all task state transitions
        p.trial.(sn).hTrial.afterFrame(p.trial.ttime);

    % --- Draw task semantics using info from hTrial
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        % overlay pointer drawing
%         ctr=p.trial.display.ctr(1:2);
        switch p.trial.(sn).hTrial.stateId
            case 0 % FixWait
                fixClr = p.trial.display.clut.bg_white;
            case {1,2,3,4,8} % FixHold
                fixClr = p.trial.display.clut.bg_green;
            case 7
                fixClr = p.trial.display.clut.bg_red;
        end

    % TODO: add fixation position
        if p.trial.(sn).hTrial.showFix
            fixRect = p.trial.display.ctr + kron(p.trial.(sn).fixWinRadius * p.trial.display.ppd,[-1, -1, +1, +1]);
            Screen('FrameOval', p.trial.display.overlayptr, fixClr, fixRect);
        end
    
	% --- Called before the main trial loop. Sets up all parameters
    case p.trial.pldaps.trialStates.trialSetup
        
        stimuli.fixflash.trialSetup(p, sn);
        
	% --- All Screen() calls go here
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.stimulus.hTrial.beforeFrame;
    
	% --- Cleanup and save all parameters
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        stimuli.fixflash.cleanUpandSave(p, sn);
        
end % switch

end % function