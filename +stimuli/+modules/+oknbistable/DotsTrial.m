function p=DotsTrial(p,state, sn)
% TESTSPACETRIAL run a blank trial
%
% stimuli.testSpaceTrial is a PLDAPS trial function. PLDAPS trial functions switch
% between different states that have to do with timing relative to the
% frame refresh
% 
% Add stimulus setup to the

if nargin<3
    sn='oknbistable';
end

% --- switch PLDAPS trial states
switch state

    % --- Called before each trial. Sets up all parameters
    case p.trial.pldaps.trialStates.trialSetup
        
        nDot = numel(p.trial.(sn).hDots);
        
        for iDot = 1:nDot
%             p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial)
            p.trial.(sn).hDots(iDot).setRandomSeed();
            p.trial.(sn).hDots(iDot).trialSetup(p);
            p.trial.(sn).hDots(iDot).stimValue = true;
            p.trial.(sn).hDots(iDot).speed = p.trial.(sn).dotspeed * p.trial.display.ppd / p.trial.display.frate;
            p.trial.(sn).hDots(iDot).lifetime = p.trial.(sn).dotlifetime;
            p.trial.(sn).hDots(iDot).radius =  p.trial.(sn).dotradius * p.trial.display.ppd;
            p.trial.(sn).hDots(iDot).winRadius = p.trial.(sn).hDots(iDot).radius;
            p.trial.(sn).hDots(iDot).dotSize = p.trial.(sn).dotsize;
            p.trial.(sn).hDots(iDot).range = p.trial.(sn).dotrange;
        end

        nFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        p.trial.(sn).direction = nan(nDot, nFrames);
        p.trial.(sn).stimValue = nan(nDot, nFrames);
        
        
        p.trial.(sn).lastUpdate = 0;
        p.trial.(sn).hDots(1).direction = p.trial.(sn).directionprior(1).drawfromprior;
        p.trial.(sn).hDots(2).direction = p.trial.(sn).directionprior(2).drawfromprior;
        
        
    % --- Draw task semantics using info from hTrial
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        p.trial.(sn).hDots(1).isHeld([p.trial.eyeX p.trial.eyeY]);
        if p.trial.(sn).hDots(1).isFixated
            disp('fixated')
            if rand() < p.trial.(sn).rewardrate
                p.trial.reward.deliver();
            end
        end
        
        if (p.trial.ttime - p.trial.(sn).lastUpdate) > (p.trial.(sn).onduration)
            p.trial.(sn).hDots(1).direction = p.trial.(sn).directionprior(1).drawfromprior;
            p.trial.(sn).hDots(2).direction = p.trial.(sn).directionprior(2).drawfromprior;
            p.trial.(sn).lastUpdate = p.trial.ttime;
        end
        
        for iDot = 1:2
            p.trial.(sn).hDots(iDot).frameUpdate(p);
            p.trial.(sn).direction(iDot,p.trial.iFrame) = p.trial.(sn).hDots(iDot).direction;
            p.trial.(sn).stimValue(iDot,p.trial.iFrame) = p.trial.(sn).hDots(iDot).stimValue;
        end
        
        

	% --- All Screen() calls go here
    case p.trial.pldaps.trialStates.frameDraw
        
        for iDot = 1:2
            p.trial.(sn).hDots(iDot).frameDraw(p);
        end
    
	% --- Cleanup and save all parameters
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
    
    % ---------------------------------------------------------------------
    % --- What to do before opening the pldaps screen
	case p.trial.pldaps.trialStates.experimentPreOpenScreen
        % This code should be copied from protocol to protocol
        
        p.defaultParameters.(sn).stateFunction.acceptsLocationInput = true; % is this necessary
        % setup states that will be called by this module
        requestedStates = {...
            'experimentPostOpenScreen',... % setup objects after opening screen
            'trialSetup',...               % setup the next trial
            'framePrepareDrawing',...      % actions before frame draw
            'frameDraw',...                % actual drawing calls
            'trialCleanUpandSave',...      % after trial what to do
            };
        
        for iState = 1:numel(requestedStates)
            stateName = requestedStates{iState};
            p.defaultParameters.(sn).stateFunction.requestedStates.(stateName) = true;
        end
        
        % initialize random seed for this protocol
        p = stimuli.setupRandomSeed(p, sn);
            
    % --- handles that depend on pldaps being totally set up
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        % --- set up default parameters
        defaultArgs = {'dotposition', [0 0], ...
            'dotradius', 5, ...
            'dotrange', 0, ...
            'dotsize', 4, ...
            'dotlifetime', 15, ...
            'numDots', 50, ...
            'dotspeed', 5, ...
            'onduration', 2, ...
            'rewardrate', .01 ...
            'nDirections', 22, ...
            'priorType', 'uniform', ...
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
        
        
        p.trial.(sn).hDots(1)   = stimuli.objects.dotsUniform('position', p.trial.display.ctr(1:2), ...
            'dotSize', 2, 'range', 50, 'numDots', p.trial.(sn).numDots);
        p.trial.(sn).hDots(2)   = stimuli.objects.dotsUniform('position', p.trial.display.ctr(1:2), ...
            'dotSize', 2, 'range', 50, 'numDots', p.trial.(sn).numDots);
        
        p.trial.(sn).directionprior(1) = stimuli.modules.dotmotion.directionprior(p.trial.(sn).nDirections, p.trial.(sn).priorType);
        p.trial.(sn).directionprior(2) = stimuli.modules.dotmotion.directionprior(p.trial.(sn).nDirections, p.trial.(sn).priorType);
end % switch

end % function