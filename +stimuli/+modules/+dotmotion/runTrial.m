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
% state3_ShowDots     - self explanatory
% state4_ChoiceGracePeriod  - grace period after leaving fixation window
% state5_Choice       - choice is counted
% state6_HoldChoice   - hold choice to be evaluated
% state7_BreakFixTimeout    - penalty for breaking fixation
% state8_InterTrialInterval - time at the end of the trial
%
% 09.08.2016 Jacob L. Yates <jacoby8s@gmail.com> - wrote it
% 01.06.2016 Jacob L. Yates <jacoby8s@gmail.com> - uses Shaun's class to run states

if nargin<3
    sn='dotmotion';
end

% --- switch PLDAPS trial states
switch state

    % ---------------------------------------------------------------------
    % --- What to do before opening the pldaps screen
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        % This code should be copied from protocol to protocol (I know.
        % There should be a way to make this automatic, but can't think of
        % an easy way)
        requestedStates = {...
        'experimentPostOpenScreen',...
        'trialSetup',...
        'framePrepareDrawing',...
        'frameUpdate',...
        'trialCleanUpandSave',...
        };
        stimuli.setupDefaultFrameStates(p, sn, requestedStates)
        
        p = stimuli.setupRandomSeed(p, sn);

        % --- handles that depend on pldaps being totally set up
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        stimuli.modules.dotmotion.defaultParameters(p);   % default target parameters
        
    
	% --- Called before the main trial loop. Sets up all parameters
    case p.trial.pldaps.trialStates.trialSetup
        
        stimuli.modules.dotmotion.trialSetup(p, sn);
        
        % --- Prepare drawing (All behavior action happens here)
    case p.trial.pldaps.trialStates.frameUpdate
        
        p.trial.(sn).states.frameUpdate(p, sn);

    % --- Draw task semantics using info from hTrial
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
%         p.trial.(sn).states.frameUpdate(p, sn);
%         disp(['state ' num2str(p.trial.(sn).states.stateId)])
%         ctr=p.trial.display.ctr(1:2);
%         switch p.trial.(sn).states.stateId
%             case 0 % FixWait
%                 fixClr = p.trial.display.clut.bg_white;
%             case {1,2,3,4} % FixHold
%                 fixClr = p.trial.display.clut.bg_green;
%             case {5,6}
%                 fixClr = p.trial.display.clut.bg;
%             case 7
%                 fixClr = p.trial.display.clut.bg_red;
%             case 8
%                 fixClr = p.trial.display.clut.bg;
%                 choXY=[p.trial.(sn).hTrial.choiceX -p.trial.(sn).hTrial.choiceY]*p.trial.display.ppd + ctr;
%                 Screen('DrawDots', p.trial.display.overlayptr, choXY, 15, p.trial.display.clut.bg_red, [], 2);
%         end
% %         kron([1,1],[50 50]) 
%         targColor=p.trial.display.clut.bg_green;
% 
%         if p.trial.(sn).hTrial.showChoice
%             % choice window
%             th=p.trial.(sn).direction:360+p.trial.(sn).direction;
%             x=cosd(th);
%             y=-sind(th);
%             winpolyx=[p.trial.(sn).choiceWinMinRadius*x p.trial.(sn).choiceWinMaxRadius*fliplr(x)]*p.trial.display.ppd;
%             winpolyy=[p.trial.(sn).choiceWinMinRadius*y p.trial.(sn).choiceWinMaxRadius*fliplr(y)]*p.trial.display.ppd;
%             
%             Screen('FramePoly', p.trial.display.overlayptr, fixClr, [winpolyx(:)+ctr(1), winpolyy(:)+ctr(2)]);
%             
%             % reward window
%             th=p.trial.(sn).direction-p.trial.(sn).rewardWindow:p.trial.(sn).direction+p.trial.(sn).rewardWindow;
%             x= cosd(th);
%             y=-sind(th);
%             winpolyx=[p.trial.(sn).choiceWinMinRadius*x p.trial.(sn).choiceWinMaxRadius*fliplr(x) p.trial.(sn).choiceWinMinRadius*x(1)]*p.trial.display.ppd;
%             winpolyy=[p.trial.(sn).choiceWinMinRadius*y p.trial.(sn).choiceWinMaxRadius*fliplr(y) p.trial.(sn).choiceWinMinRadius*y(1)]*p.trial.display.ppd;
%             ctr=p.trial.display.ctr(1:2);
%             Screen('FramePoly', p.trial.display.overlayptr, targColor, [winpolyx(:)+ctr(1), winpolyy(:)+ctr(2)]);
%         end
%         
%         if p.trial.(sn).showFix
%             fixRect = p.trial.display.ctr + kron(p.trial.(sn).fixWinRadius * p.trial.display.ppd,[-1, -1, +1, +1]);
%             Screen('FrameOval', p.trial.display.overlayptr, fixClr, fixRect);
%         end
    
	% --- All Screen() calls go here
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.(sn).states.frameDraw(p, sn);
    
	% --- Cleanup and save all parameters
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
end % switch

end % function