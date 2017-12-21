function p=testBlankTrial(p,state, sn)
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
        
        

    % --- Draw task semantics using info from hTrial
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
    

	% --- All Screen() calls go here
    case p.trial.pldaps.trialStates.frameDraw
        
    
	% --- Cleanup and save all parameters
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
    
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
        

        
end % switch

end % function