function p=testTriPlaidTrial(p,state, sn)
% testGaborTargetTrial run a testGaborTargetTrial trial
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
        
        sf = 3;
        tf = 3;
        kTarg = 1;
        p.trial.(sn).hTarg(kTarg).setup(p); % setup with pldaps
        p.trial.(sn).hTarg(kTarg).position = p.trial.display.ctr(1:2);
        p.trial.(sn).hTarg(kTarg).theta = [0 120 240];
        p.trial.(sn).hTarg(kTarg).sf = sf;
        p.trial.(sn).hTarg(kTarg).sigma = 2;
        p.trial.(sn).hTarg(kTarg).contrast = .3;
        p.trial.(sn).hTarg(kTarg).tf = tf;
        phi = randi(360,1,3);
        p.trial.(sn).hTarg(kTarg).phase = phi;
        
        kTarg = 2;
        p.trial.(sn).hTarg(kTarg).setup(p); % setup with pldaps
        p.trial.(sn).hTarg(kTarg).position = p.trial.(sn).hTarg(1).position + [100 100];
        p.trial.(sn).hTarg(kTarg).theta = [0 120 240];
        p.trial.(sn).hTarg(kTarg).sf = sf;
        p.trial.(sn).hTarg(kTarg).sigma = .3;
        p.trial.(sn).hTarg(kTarg).contrast = 0;
        p.trial.(sn).hTarg(kTarg).tf = tf;
%         p.trial.(sn).hTarg(kTarg).phase = randi(360, 1, 3);
        p.trial.(sn).hTarg(kTarg).phase = phi;
        
%         kTarg = 3;
%         p.trial.(sn).hTarg(kTarg).setup(p); % setup with pldaps
%         p.trial.(sn).hTarg(kTarg).position = p.trial.(sn).hTarg(1).position + [150 0];
%         p.trial.(sn).hTarg(kTarg).theta = [0 120 240];
%         p.trial.(sn).hTarg(kTarg).sf = sf;
%         p.trial.(sn).hTarg(kTarg).sigma = .3;
%         p.trial.(sn).hTarg(kTarg).contrast = .2;
%         p.trial.(sn).hTarg(kTarg).tf = tf;
%         p.trial.(sn).hTarg(kTarg).phase = phi;

        
    % --- Draw task semantics using info from hTrial
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        angleOffset = 10;
        kTarg = 1;
        phaseinc = 360 * (p.trial.(sn).hTarg(kTarg).tf / p.trial.display.frate);
%         if (p.trial.(sn).hTarg(kTarg).phase > 360)
%             
%             || (p.trial.(sn).hTarg(kTarg).phase < 0)
%         end
            
        for kTarg = 1:numel(p.trial.(sn).hTarg)
            
%             p.trial.(sn).hTarg(kTarg).frameUpdate(p);
            p.trial.(sn).hTarg(kTarg).phase = p.trial.(sn).hTarg(kTarg).phase + phaseinc;
        end
        
        if any(p.trial.keyboard.firstPressQ)


            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.kKey)
                  for kTarg = 1
                  p.trial.(sn).hTarg(kTarg).theta = p.trial.(sn).hTarg(kTarg).theta + angleOffset;
                  end
                  
            end
        end
        
        

	% --- All Screen() calls go here
    case p.trial.pldaps.trialStates.frameDraw
        
        for kTarg = 1:numel(p.trial.(sn).hTarg)
            p.trial.(sn).hTarg(kTarg).frameDraw(p);
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
        
        
        
        for kTarg = 1:2
            p.trial.(sn).hTarg(kTarg) = stimuli.objects.plaidGaborTarget();
        end
        

        
end % switch

end % function