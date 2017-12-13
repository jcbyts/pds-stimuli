function p=default(p,state, sn)
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

if nargin<3
    sn='fixflash';
end

% --- switch PLDAPS trial states
switch state

    % --- Called before each trial. Sets up all parameters
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup the next trial
        stimuli.fixflash.trialSetup(p, sn);
        

    % --- Draw task semantics using info from hTrial
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        % call the state machine to update
        p.trial.(sn).states.frameUpdate(p,sn)
    

	% --- All Screen() calls go here
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.(sn).states.frameDraw(p,sn);
    
	% --- Cleanup and save all parameters
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        stimuli.fixflash.cleanUpandSave(p, sn);
    
	case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        p.defaultParameters.(sn).stateFunction.acceptsLocationInput = true; % is this necessary
        % setup states that will be called by this module
        requestedStates = {...
            'experimentPostOpenScreen',...
            'trialSetup',...
            'framePrepareDrawing',...
            'frameDraw',...
            'trialCleanUpandSave',...
            };
        
        for iState = 1:numel(requestedStates)
            stateName = requestedStates{iState};
            p.defaultParameters.(sn).stateFunction.requestedStates.(stateName) = true;
        end
        
        p = stimuli.setupRandomSeed(p, sn);
            
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
            'rewardLevels',             [.2 .4 .8 1 1.2 1.4], ...
            'trialTimeout',             3, ... % seconds to obtain fixation
            };
        
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end 
        end
        
        % color scheme for this task
        stimuli.clutColors(p);
        
        %------------------------------------------------------------------
        % --- Instantiate classes
        
        % --- Fixation
        p.trial.(sn).hFix   = stimuli.fixation('xyPix', p.trial.display.ctr(1:2));
        
        % --- Reward Face
        p.trial.(sn).hFace  = stimuli.face(p);
        
        % --- Plotting
        p.functionHandles.fixFlashPlot = stimuli.fixflash.fixFlashPlot;
        
        % --- Reward
%         p.trial.(sn).hReward    = stimuli.reward(p); % TODO: make this global

        
end % switch

end % function