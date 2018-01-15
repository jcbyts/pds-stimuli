function p=runDefaultTrial(p,state, sn)
% run 

if nargin<3
    sn='dotselection';
end

% --- switch PLDAPS trial states
switch state
    
    % ---------------------------------------------------------------------
    % --- What to do before opening the pldaps screen
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        % This code should be copied from protocol to protocol (I know.
        % There should be a way to make this automatic, but can't think of
        % an easy way)
        
        stimuli.setupDefaultFrameStates(p, sn)
        
        p = stimuli.setupRandomSeed(p, sn);
    
    % --- handles that depend on pldaps being totally set up
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        % --- setup default parameters that don't depend on other variables
        defaultArgs = {...
            'RfCenterXy',               [5, -5], ...    % degrees
            'dotSize',                  0.1, ...        % degrees (diameter)
            'dotSpeed',                 8.0, ...        % dot speed (deg/sec)
            'dotContrast',              -0.5, ...       % - 0.5 yo 0.5
            'dotRange',                 0.0, ...        % degrees (range of uniform distribution over direction)
            'dotDensity',               400, ...        % dots / deg^2 / sec 
            'dotContrast',              5, ...
            'dotLifetime',              12, ...         % frames
            'maxBandwidth',             0.0, ...
            'minBandwidth',             0.0, ...
            'numBandwidths',            1, ...
            'numDirs',                  8, ...
            'DotCenterAngle',           [0 180], ...
            'rewardUpdateFun',          @stimuli.modules.dotselection.rewardUpdateSwitchRule, ...
            'rewardUpdateArgs',         {.1}, ...
            'rewardForFixation',        false, ...
            'yokeDirections',           false, ...      % yoke the direction of dots for dots1 and dots2
            'rewardDot1Rate',           0.1, ...
            'rewardDot2Rate',           0.85, ...
            'maxRewardCnt',             2, ...          % max drops of juice
            'faceIndex',                1, ...
            'minFixPreStim',            0.1, ...
            'maxFixPreStim',            0.2, ...
            'minFixPostStim',           0.1, ...
            'maxFixPostStim',           0.2, ...        % seconds (wrt dot motion onset)
            'fixHoldTau',               0.2, ...        % seconds(time constant of exponential)
            'choiceGracePeriod',        1.4, ...        % grace period for decision time (seconds)
            'choiceHoldDuration',       0.025, ...      % minimum choice hold duration (seconds)
            'iti',                      1.0, ...
            'rewardcount',              zeros(1,2), ... % two targets, only two states
        	'rewardtravel',             4, ...          % must choose this many times before move
            'rewardtransit',            1.0, ...        % prob to transition reward state
            'stimVisible',              [true true], ... % will the dots be shown
            };
        
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end 
        end
        
        % --- Default variables that depend on others being set
        if ~isfield(p.trial.(sn), 'dotApertureRadius')
            p.trial.(sn).dotApertureRadius = norm(p.trial.(sn).RfCenterXy)/3;     % degrees
        end
        
        % -------------------------------------------------------------------------
        % --- setup stimuli and prepare to run
        
        % --- Face Textures
        p.trial.(sn).hFace      = stimuli.objects.face(p);
        p.trial.(sn).hFace.id   = p.trial.(sn).faceIndex;
        
        % --- Dots
        p.trial.(sn).hDots(1)   = stimuli.objects.dotsUniform();
        p.trial.(sn).hDots(2)   = stimuli.objects.dotsUniform();

	% --- Called before the main trial loop. Sets up all parameters
    case p.trial.pldaps.trialStates.trialSetup
         
        stimuli.modules.dotselection.trialSetup(p, sn);
        

    % --- Draw task semantics using info from hTrial
    case p.trial.pldaps.trialStates.framePrepareDrawing
       
        p.trial.(sn).states.frameUpdate(p, sn);

        
        
        
%         ctr=p.trial.display.ctr(1:2);
%         switch p.trial.(sn).hTrial.stateId
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
% %         targColor=p.trial.display.clut.bg_green;
% 
% %         if p.trial.(sn).hTrial.showChoice
% %             % choice window
% %             th=p.trial.(sn).direction:360+p.trial.(sn).direction;
% %             x=cosd(th);
% %             y=-sind(th);
% %             winpolyx=[p.trial.(sn).choiceWinMinRadius*x p.trial.(sn).choiceWinMaxRadius*fliplr(x)]*p.trial.display.ppd;
% %             winpolyy=[p.trial.(sn).choiceWinMinRadius*y p.trial.(sn).choiceWinMaxRadius*fliplr(y)]*p.trial.display.ppd;
% %             
% %             Screen('FramePoly', p.trial.display.overlayptr, fixClr, [winpolyx(:)+ctr(1), winpolyy(:)+ctr(2)]);
% %             
% %             % reward window
% %             th=p.trial.(sn).direction-p.trial.(sn).rewardWindow:p.trial.(sn).direction+p.trial.(sn).rewardWindow;
% %             x=cosd(th);
% %             y=-sind(th);
% %             winpolyx=[p.trial.(sn).choiceWinMinRadius*x p.trial.(sn).choiceWinMaxRadius*fliplr(x) p.trial.(sn).choiceWinMinRadius*x(1)]*p.trial.display.ppd;
% %             winpolyy=[p.trial.(sn).choiceWinMinRadius*y p.trial.(sn).choiceWinMaxRadius*fliplr(y) p.trial.(sn).choiceWinMinRadius*y(1)]*p.trial.display.ppd;
% %             ctr=p.trial.display.ctr(1:2);
% %             Screen('FramePoly', p.trial.display.overlayptr, targColor, [winpolyx(:)+ctr(1), winpolyy(:)+ctr(2)]);
% %         end
% 
%         if p.trial.(sn).hTrial.showDots
%             for kDots = 1:2
%                 fixRect = [p.trial.(sn).hTrial.hDots(kDots).position p.trial.(sn).hTrial.hDots(kDots).position] + kron(p.trial.(sn).hTrial.hDots(kDots).maxRadius + p.trial.(sn).hTrial.rewardWindow * p.trial.display.ppd,[-1, -1, +1, +1]);
%                 Screen('FrameOval', p.trial.display.overlayptr, fixClr, fixRect);
%             end
%         end
%         
%         if p.trial.(sn).hTrial.showFix
%             fixRect = p.trial.display.ctr + kron(p.trial.(sn).fixWinRadius * p.trial.display.ppd,[-1, -1, +1, +1]);
%             Screen('FrameOval', p.trial.display.overlayptr, fixClr, fixRect);
%         end
    

	% --- All Screen() calls go here
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.(sn).states.frameDraw(p,sn);
    
	% --- Cleanup and save all parameters
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        % this is where we update the reward rates
%         hasData = ~cellfun(@isempty, p.data(:));
        hasData = cellfun(@(x) isfield(x, sn), p.data(:));
        choices = cellfun(@(x) x.(sn).dotsChosen, p.data(hasData));
        choices = [choices p.trial.stimulus.dotsChosen];
        
        [p.trial.(sn).rewardDot1Rate, p.trial.(sn).rewardDot2Rate, p.trial.(sn).stimVisible] = ...
            p.trial.stimulus.rewardUpdateFun(choices, p.trial.(sn).rewardDot1Rate, p.trial.(sn).rewardDot2Rate, ...
                                           p.trial.stimulus.stimVisible,p.trial.stimulus.rewardUpdateArgs{:});
        
       
        %upload to conditions for next trial to live on
        currTrial = size(p.data,2);
        for iTrial = (currTrial+1):numel(p.conditions)
             p.conditions{iTrial}.(sn).rewardDot1Rate = p.trial.(sn).rewardDot1Rate;
             p.conditions{iTrial}.(sn).rewardDot2Rate = p.trial.(sn).rewardDot2Rate;
             p.conditions{iTrial}.(sn).stimVisible = p.trial.(sn).stimVisible;
        end
        
    
        
end % switch

end % function