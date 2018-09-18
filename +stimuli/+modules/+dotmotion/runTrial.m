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
        'framePrepareDrawing',... %         'frameUpdate',...
        'frameDraw', ...
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
%         disp(['state ' num2str(p.trial.(sn).states.stateId)])
%         p.trial.(sn).states.frameUpdate(p, sn);

    % --- Draw task semantics using info from hTrial
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        p.trial.(sn).states.frameUpdate(p, sn);
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
        
        ar = p.trial.(sn).reward.function(p.trial.(sn).error, p.trial.(sn).reward.windowWidth,  p.trial.(sn).reward.maxNumber);
        fprintf('Trial: %d, Direction: %02.2f, Choice: %02.2f, Error: %02.2f, Reward: %d\n', ...
            p.trial.trialnumber, p.trial.(sn).motion.direction, p.trial.(sn).choice, p.trial.(sn).error, ar);
        
        
%         stimuli.modules.dotmotion.plotTrialOutcome(p)
        % --- plot trial outcome
        figure(1); clf
        subplot(3,3,[1 2 4 5])
        plot(p.trial.(sn).fixation.hFix.position(1), p.trial.(sn).fixation.hFix.position(2), 'ko');
        hold on
        stateLog = p.trial.dotmotion.states.getStateTransitions;
        ft = p.trial.timing.flipTimes(3,:);
        cmap = lines;
        nTransitions = size(stateLog,1);
        eyeXY = p.trial.behavior.eyeAtFrame';
        for i = 1:nTransitions
            if i < nTransitions
                iix = ft > stateLog(i,1) & ft < stateLog(i+1,1);
                plot(eyeXY(iix,1), eyeXY(iix,2), '.', 'Color', cmap(stateLog(i,2)+1,:))
            else
                iix = ft > stateLog(i,1); % last transition
                plot(eyeXY(iix,1), eyeXY(iix,2), '. ', 'Color', cmap(stateLog(i,2)+1,:))
            end
        end
        [dx,dy] = pol2cart(p.trial.(sn).motion.direction/180*pi, 1);
        quiver(p.trial.(sn).motion.hMot.position(1), p.trial.(sn).motion.hMot.position(2), dx, -dy, p.trial.(sn).motion.hMot.radius, 'AutoScale', 'off', 'Color', 'r', 'MaxHeadSize', 5);
        quiver(p.trial.(sn).motion.hMot.position(1), p.trial.(sn).motion.hMot.position(2), p.trial.(sn).choiceX, -p.trial.(sn).choiceY, 1, 'AutoScale', 'off', 'Color', 'b', 'MaxHeadSize', 5);
        th = linspace(0, 2*pi, 100);
        plot(p.trial.(sn).motion.hMot.position(1) + p.trial.(sn).motion.hMot.radius*cos(th), p.trial.(sn).motion.hMot.position(2) + p.trial.(sn).motion.hMot.radius*sin(th), 'k--')
        
        xlim(p.trial.display.winRect([1 3]))
        ylim(p.trial.display.winRect([2 4]))
        axis ij
        
        hasData = cellfun(@(x) isfield(x, sn), p.data);
        errs = cellfun(@(x) x.(sn).error, p.data(hasData));
        chos = cellfun(@(x) x.(sn).error, p.data(hasData));
        subplot(3,3,3)
        
        
        subplot(3,3,6)
        
        subplot(3,3,7:9)
        
        
        
        
end % switch

end % function