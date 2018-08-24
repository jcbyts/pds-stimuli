function p=runDefaultTrial(p,state, sn)
% run 

if nargin<3
    sn='targetselection';
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
        
        stimuli.modules.fixflash.defaultParameters(p, sn);      % default fixation parameters
        stimuli.modules.targetselection.defaultParameters(p);   % default target parameters
        
        % --- Default variables that depend on others being set
        
        % size of the target (if not already specified)
        if ~isfield(p.trial.(sn), 'dotApertureRadius')
            p.trial.(sn).dotApertureRadius = norm(p.trial.(sn).RfCenterXy)/3;     % degrees
        end
        
        % radius of the acceptance window
        if ~isfield(p.trial.(sn), 'targWinRadius')
            p.trial.(sn).targWinRadius = p.trial.(sn).dotApertureRadius*1.1;
        end
        
        % -------------------------------------------------------------------------
        % --- setup stimuli and prepare to run
        
        % --- Fixation
        if ~(isfield(p.trial.(sn), 'hFix') && isa(p.trial.(sn).hFix, 'stimuli.objects.target'))
            fixXYdeg = [p.trial.(sn).fixationX; p.trial.(sn).fixationY];
            fixXY = pds.deg2px(fixXYdeg, p.trial.display.viewdist, p.trial.display.w2px)';
            p.trial.(sn).hFix   = stimuli.objects.fixation('position', fixXY);
        end
        
        % --- Face Textures
        p.trial.(sn).hFace      = stimuli.objects.face(p);
        p.trial.(sn).hFace.id   = p.trial.(sn).faceIndex;
                
        % --- Targs (default targets are gabors)
        if ~isfield(p.trial.(sn), 'hTargs')
            p.trial.(sn).hTargs(1)   = stimuli.objects.gaborTarget();
            p.trial.(sn).hTargs(2)   = stimuli.objects.gaborTarget();
        end

	% --- Called before the main trial loop. Sets up all parameters
    case p.trial.pldaps.trialStates.trialSetup
         
        stimuli.modules.targetselection.trialSetup(p, sn);
        

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
        choices  = cellfun(@(x) x.(sn).dotsChosen, p.data(hasData));
        rewarded = cellfun(@(x) x.(sn).rewardAmount, p.data(hasData));
        choices = [choices p.trial.(sn).dotsChosen];
        rewarded = [rewarded p.trial.(sn).rewardAmount];
        
%         figure(1); clf
%         for i = 1:2
%             ix = find(choices==i);
%             
%             wasRewarded = rewarded(ix)>0;
%             
%             plot(ix(wasRewarded), i*ones(1,sum(wasRewarded)), 'og'); hold on
%             plot(ix(~wasRewarded), i*ones(1,sum(~wasRewarded)), 'or');
%         end
            

        [p.trial.(sn).rewardDot1Rate, p.trial.(sn).rewardDot2Rate, p.trial.(sn).stimVisible] = ...
            p.trial.(sn).rewardUpdateFun(choices, p.trial.(sn).rewardDot1Rate, p.trial.(sn).rewardDot2Rate, ...
                                           p.trial.(sn).stimVisible,p.trial.(sn).rewardUpdateArgs{:},...
                                           p.trial.(sn).trialsToSwap);
                
        %upload to conditions for next trial to live on
        stimuli.updateConditions(p, sn, 'rewardDot1Rate', p.trial.(sn).rewardDot1Rate);
        stimuli.updateConditions(p, sn, 'rewardDot2Rate', p.trial.(sn).rewardDot2Rate);
        stimuli.updateConditions(p, sn, 'stimVisible', p.trial.(sn).stimVisible);
        
end % switch

end % function