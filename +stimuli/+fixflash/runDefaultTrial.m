function p=runDefaultTrial(p,state, sn)
% RUNDEFAULTTRIAL run a trial of the dotmotion task
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
        
        p.trial.(sn).hFix.frameUpdate(p); % update fixation object
        
        % call the state machine to update
        p.trial.(sn).states.frameUpdate(p,sn)
    

	% --- All Screen() calls go here
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.(sn).states.frameDraw(p,sn);
    
	% --- Cleanup and save all parameters
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        % --- Staircase parameters
        if p.trial.(sn).staircaseOn && p.trial.(sn).minFixDuration < p.trial.(sn).maxFixDuration
            
            
            lastError = p.trial.(sn).error;
            
%             if p.trial.pldaps.iTrial < numel(p.conditions)
                
                switch lastError
                    case 0 % staircase up
                        p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration + p.trial.(sn).staircaseStep;
                    case 1 % do nothing
                        p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration;
                    case 2 % staircase down
                        p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration - .75*p.trial.(sn).staircaseStep;
                end
                
%             end % trial number
            
        end % staircase on
        
        stimuli.fixflash.updateGUI(p, sn);
    
    % ---------------------------------------------------------------------
    % --- What to do before opening the pldaps screen
	case p.trial.pldaps.trialStates.experimentPreOpenScreen
        % This code should be copied from protocol to protocol
        
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
        p.trial.(sn).hFix   = stimuli.fixation('position', p.trial.display.ctr(1:2));
        
        % --- Reward Face
        p.trial.(sn).hFace  = stimuli.face(p);
        
        % --- Plotting
        p.functionHandles.fixFlashPlot = stimuli.fixflash.fixFlashPlot;

        
end % switch

end % function