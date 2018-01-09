function p = runNSaccadeTargets(p, state, sn)

if nargin < 3
	sn = 'saccade';
end

% --- switch PLDAPS trial states
switch state

    % ---------------------------------------------------------------------
    % --- What to do before opening the pldaps screen
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        % This code should be copied from protocol to protocol
        
        stimuli.setupDefaultFrameStates(p, sn)
        
        p = stimuli.setupRandomSeed(p, sn);


    % ---------------------------------------------------------------------
    % --- handles that depend on pldaps being totally set up
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        % --- set up default parameters
        defaultArgs = {...
        	'showTargets', 				true, ...
            'fixationBehavior',         'fixation', ...
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
            'staircaseOn',              false, ...
            'staircaseMax',             nan, ...
            'staircaseStep',            nan, ...
            'trialTimeout',             1, ... % seconds to obtain fixation
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

        % --- Targs to plot point to other objects (e.g., face or )
        p.trial.(sn).hTarg  = p.trial.(sn).hFix;

    case p.trial.pldaps.trialStates.trialSetup

    	% set up state controller
    	p.trial.(sn).states = stimuli.objects.stateConrol();
    	p.trial.(sn).states.addState(stimuli.behaviors.saccadeTargets.state0_turnOnTargets(0))
    	p.trial.(sn).states.addState(stimuli.behaviors.saccadeTargets.state1_waitForGo(1))
    	p.trial.(sn).states.addState(stimuli.behaviors.saccadeTargets.state2_chooseTargets(2))
    	p.trial.(sn).states.addState(stimuli.behaviors.saccadeTargets.state3_rewardOutcome(3))

    % --- Prepare drawing (All behavior action happens here)
    case p.trial.pldaps.trialStates.frameUpdate

    	% call the state machine to update
        p.trial.(sn).states.frameUpdate(p,sn)

        
    	showTargets = 2 - p.trial.(sn).showTargets;

    	if p.trial.(sn).fixationContingent % if targets only play when a fixation point is obtained
			if  p.trial.(sn).hFix(1).isFixated % if the fixation point is fixated
				timeSinceFixation = p.trial.ttime + p.trial.trstart - p.trial.(sn).hFix.log(end);

				n = numel(p.trial.(sn).targsOnset);

				% all targets on simultaneously	
				if n == 1 && timeSinceFixation > p.trial.(sn).targsOnset 

					for iTarg = 1:numel(p.trial.(sn).hTarg)
						p.trial.(sn).hTarg(iTarg).stimValue = showTargets;
					end

				else % check each target separately
					
					% is it time to turn on the targets
					for iTarg = 1:numel(p.trial.(sn).hTarg)
						if timeSinceFixation > p.trial.(sn).targsOnset(iTarg)
							p.trial.(sn).hTarg(iTarg).stimValue = showTargets;
						end
					end
				end
			end
		end

    	for iTarg = 1:numel(p.trial.(sn).hTarg)
    		p.trial.(sn).hTarg(iTarg).frameUpdate(p);

    		if p.trial.(sn).hTarg(iTarg).isFixated
    			p.trial.(sn).choice = iTarg;
    			p.trial.(sn).RT     = p.trial.ttime;
    		end

    	end

    case p.trial.pldaps.trialStates.frameDraw

    	for iTarg = 1:numel(p.trial.(sn).hTarg)
    		p.trial.(sn).hTarg(iTarg).frameDraw(p);
    	end

	case p.trial.pldaps.trialStates.trialCleanUpandSave    	

end