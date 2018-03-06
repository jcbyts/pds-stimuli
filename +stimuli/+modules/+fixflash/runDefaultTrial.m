function p = runDefaultTrial(p, state, sn)
% RUNDEFAULTTRIAL run a trial of the fixflash task

if nargin<3
    sn='fixflash';
end

% --- switch PLDAPS trial states
switch state

    % --- Called before each trial. Sets up all parameters
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup the next trial
        stimuli.modules.fixflash.trialSetup(p, sn);
        

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
                            
            switch lastError
                case 0 % staircase up
                    p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration + p.trial.(sn).staircaseStep;
                case 1 % do nothing
                    p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration;
                case 2 % staircase down
                    p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration - .75*p.trial.(sn).staircaseStep;
            end
            
        end % staircase on
        
        if p.trial.(sn).showGUI
            stimuli.modules.fixflash.updateGUI(p, sn);
        end
    
    % ---------------------------------------------------------------------
    % --- What to do before opening the pldaps screen
	case p.trial.pldaps.trialStates.experimentPreOpenScreen
        % This code should be copied from protocol to protocol
        
        stimuli.setupDefaultFrameStates(p, sn)
        
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
            'fixHoldTau',               0.100, ...
            'FixEngagePenalty',         false, ...
            'waitForSaccade',           false, ...
            'maxFixDuration',           1.5, ...
            'holdDuration',             0.1, ... % TODO: is this used?
            'staircaseOn',              true, ...
            'staircaseMax',             1, ...
            'staircaseStep',            .05, ...
            'trialTimeout',             3, ... % seconds to obtain fixation
            'rewardLevels',             [.2 .4 .8 1 1.2 1.4], ...
            'rewardForObtainFixation',  false, ...
            'rewardFaceDuration',       0.2, ...
            'showGUI',                  true, ...
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
        if ~(isfield(p.trial.(sn), 'hFix') && isa(p.trial.(sn).hFix, 'stimuli.objects.target'))
            p.trial.(sn).hFix   = stimuli.objects.fixation('position', p.trial.display.ctr(1:2));
        end
        
        % --- Reward Face
        if ~(isfield(p.trial.(sn), 'hFace') && isa(p.trial.(sn).hFix, 'stimuli.objects.textures'))
            p.trial.(sn).hFace  = stimuli.objects.face(p);
        end
        
        % --- Plotting
        if p.trial.(sn).showGUI
            p.functionHandles.fixFlashPlot = stimuli.modules.fixflash.fixFlashPlot;
        end

        
end % switch

end % function