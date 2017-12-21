function p=testDotUniformTrial(p,state, sn)
% TESTSPACETRIAL run a blank trial
%
% stimuli.testSpaceTrial is a PLDAPS trial function. PLDAPS trial functions switch
% between different states that have to do with timing relative to the
% frame refresh
% 
% Add stimulus setup to the

if nargin<3
    sn='testing';
end

% --- switch PLDAPS trial states
switch state

    % --- Called before each trial. Sets up all parameters
    case p.trial.pldaps.trialStates.trialSetup
        
        p.trial.(sn).hDots.setRandomSeed(p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        p.trial.(sn).hDots.trialSetup(p);

    % --- Draw task semantics using info from hTrial
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        p.trial.(sn).hDots.frameUpdate(p);

	% --- All Screen() calls go here
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.(sn).hDots.frameDraw(p);
    
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
        defaultArgs = {...
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
        
        % --- Fixation Image Object
        p.trial.(sn).hDots   = stimuli.dotsUniform('position', p.trial.display.ctr(1:2), ...
            'dotSize', 2, 'range', 50);
        p.trial.(sn).hDots.radius = 100; % 20 pixel radius
        
end % switch

end % function