function p=runImgScan(p,state, sn)
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
        
        % set random seed for Fixation object this trial
        p.trial.(sn).hFix.setRandomSeed();
        
        % setup the next trial
        stimuli.modules.fixflash.trialSetup(p, sn);
        p.trial.(sn).hFix.trialSetup(p);
        
        
        
        

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
        
        p.conditions{p.trial.pldaps.iTrial + 1} = [];
        
        % --- Staircase parameters
        if p.trial.(sn).staircaseOn && p.trial.(sn).minFixDuration < p.trial.(sn).maxFixDuration
            
            
            lastError = p.trial.(sn).error;
            
                switch lastError
                    case 0 % staircase up
                        p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration + p.trial.(sn).staircaseStep;
                    case 2 % staircase down
                        p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration - .75*p.trial.(sn).staircaseStep;
                    otherwise % do nothing
                        p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration;
                end
            
        end % staircase on
        
        stimuli.modules.fixflash.updateGUI(p, sn);
        
        p.trial.(sn).hFix.cleanup(p);
    
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
            'fixPointRadius',           1, ...
            'fixPointDim',              0.1, ...
            'fixWinRadius',             1.8, ...
            'fixFlashCnt',              round(1*p.trial.display.frate), ...
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
            'shrinkTimeConstant',       0.15, ...
            'maskType',                 'circle', ...
            'noisesigma',               20, ... % pixels (noise of random walk)
            };
        
        % step through argument pairs and add them to the module
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
        p.trial.(sn).hFix   = stimuli.fixationImg('position', p.trial.display.ctr(1:2));
        
        % apply specialized parameters
        p.trial.(sn).hFix.shrinkTimeConstant = p.trial.(sn).shrinkTimeConstant;
        
        % --- Reward Face
        p.trial.(sn).hFace  = stimuli.face(p);
        
        % --- Plotting
        p.functionHandles.fixFlashPlot = stimuli.modules.fixflash.fixFlashPlot;
        
        % --- Reward
%         p.trial.(sn).hReward    = stimuli.reward(p); % TODO: make this global

        
end % switch

end % function