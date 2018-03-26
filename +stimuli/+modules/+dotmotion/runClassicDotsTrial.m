function p=runClassicDotsTrial(p,state, sn)
% RUNTRIAL run a trial of the dotmotion task
%
% stimuli.dotmotion.runTrial is a PLDAPS module. PLDAPS trial functions switch
% between different states that have to do with timing relative to the
% frame refresh

if nargin<3
    sn='dotmotion';
end

% --- switch PLDAPS trial states
switch state

    % ---------------------------------------------------------------------
    % --- What to do before opening the pldaps screen
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        % This code should be copied from protocol to protocol
        
        stimuli.setupDefaultFrameStates(p, sn)
        
        p = stimuli.setupRandomSeed(p, sn);


    case

    % ---------------------------------------------------------------------
    % --- handles that depend on pldaps being totally set up
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        % --- set up default parameters
        defaultArgs = {...
            'bgColor',                  0.5, ...
            'fixPointRadius',           0.3, ...
            'fixPointDim',              0.1, ...
            'fixWinRadius',             1.8, ...
            'fixFlashCnt',              round(0.250*p.trial.display.frate), ...
            'feedbackApertureRadius',   1.8, ...  % TODO: is this used?
            'feedbackApertureContrast', -0.5, ... % TODO: is this used?
            'maxRewardCnt',             4, ...
            'faceRadius',               1, ...
            'faceIndex',                1, ...
            'iti',                      1, ...
            'fixationJitter',           false, ...
            'fixationJitterSize',       0, ...
            'fixationX',                0, ...
            'fixationY',                0, ...
            'fixGracePeriod',           0.050, ...
            'minFixDuration',           0.200, ...
            'maxFixDuration',           1.5, ...
            'holdDuration',             0.1, ... % TODO: is this used?
            'staircaseOn',              true, ...
            'staircaseMax',             1, ...
            'staircaseStep',            .05, ...
            'trialTimeout',             3, ... % seconds to obtain fixation
            'rewardLevels',             [.2 .4 .8 1 1.2 1.4], ...
            'rewardForObtainFixation',  false, ...
            'rewardFaceDuration',       0.2, ...
            };
        
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end 
        end
        
        %------------------------------------------------------------------
        % --- Instantiate classes
        
        % --- Fixation
        p.trial.(sn).hFix   = stimuli.objects.fixation('position', p.trial.display.ctr(1:2));
        
        % --- Reward Face
        p.trial.(sn).hFace  = stimuli.objects.face(p);
        
        % --- Plotting
        p.functionHandles.fixFlashPlot = stimuli.modules.fixflash.fixFlashPlot;

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
        ctr=p.trial.display.ctr(1:2);
        switch p.trial.(sn).hTrial.stateId
            case 0 % FixWait
                fixClr = p.trial.display.clut.bg_white;
            case {1,2,3,4} % FixHold
                fixClr = p.trial.display.clut.bg_green;
            case {5,6}
                fixClr = p.trial.display.clut.bg;
            case 7
                fixClr = p.trial.display.clut.bg_red;
            case 8
                fixClr = p.trial.display.clut.bg;
                choXY=[p.trial.(sn).hTrial.choiceX -p.trial.(sn).hTrial.choiceY]*p.trial.display.ppd + ctr;
                Screen('DrawDots', p.trial.display.overlayptr, choXY, 15, p.trial.display.clut.bg_red, [], 2);
        end
%         kron([1,1],[50 50]) 
        targColor=p.trial.display.clut.bg_green;

        if p.trial.(sn).hTrial.showChoice
            % choice window
            th=p.trial.(sn).direction:360+p.trial.(sn).direction;
            x=cosd(th);
            y=-sind(th);
            winpolyx=[p.trial.(sn).choiceWinMinRadius*x p.trial.(sn).choiceWinMaxRadius*fliplr(x)]*p.trial.display.ppd;
            winpolyy=[p.trial.(sn).choiceWinMinRadius*y p.trial.(sn).choiceWinMaxRadius*fliplr(y)]*p.trial.display.ppd;
            
            Screen('FramePoly', p.trial.display.overlayptr, fixClr, [winpolyx(:)+ctr(1), winpolyy(:)+ctr(2)]);
            
            % reward window
            th=p.trial.(sn).direction-p.trial.(sn).rewardWindow:p.trial.(sn).direction+p.trial.(sn).rewardWindow;
            x=cosd(th);
            y=-sind(th);
            winpolyx=[p.trial.(sn).choiceWinMinRadius*x p.trial.(sn).choiceWinMaxRadius*fliplr(x) p.trial.(sn).choiceWinMinRadius*x(1)]*p.trial.display.ppd;
            winpolyy=[p.trial.(sn).choiceWinMinRadius*y p.trial.(sn).choiceWinMaxRadius*fliplr(y) p.trial.(sn).choiceWinMinRadius*y(1)]*p.trial.display.ppd;
            ctr=p.trial.display.ctr(1:2);
            Screen('FramePoly', p.trial.display.overlayptr, targColor, [winpolyx(:)+ctr(1), winpolyy(:)+ctr(2)]);
        end
        
        if p.trial.(sn).hTrial.showFix
            fixRect = p.trial.display.ctr + kron(p.trial.(sn).fixWinRadius * p.trial.display.ppd,[-1, -1, +1, +1]);
            Screen('FrameOval', p.trial.display.overlayptr, fixClr, fixRect);
        end
    
	% --- Called before the main trial loop. Sets up all parameters
    case p.trial.pldaps.trialStates.trialSetup
        
        stimuli.dotmotion.trialSetup(p, sn);
        
	% --- All Screen() calls go here
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.stimulus.hTrial.beforeFrame;
    
	% --- Cleanup and save all parameters
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
end % switch

end % function