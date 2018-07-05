function p = ddpi(p, state, sn)
% Digital Dual Purkinje Imaging: trigger image capture

if nargin<3
    sn='ddpi';
end

% -------------------------------------------------------------------------
% This is just a courtesy: lists all the possible arguments and a
% description of what they are. The
if nargin < 1
    defaultArgs = {...
            'bitNumber',               'which bit signals the camera to captuer', ...
            };
    fprintf('No arguments passed in: call from within pldaps\n')
    fprintf('<strong>Optional Parameters:</strong>\n')
    fprintf('<strong>%s</strong>\t\t\t%s\n', defaultArgs{:})
    return
end

switch state
    
    % copy-paste this in every module that has the default trial states
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        requestedStates = {...
        'experimentPostOpenScreen',... % setup defaults
        'trialSetup',... % signal capture
        'trialCleanUpandSave',...
        };
    
        stimuli.setupDefaultFrameStates(p, sn, requestedStates);
        stimuli.setupRandomSeed(p, sn);
    
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % initialize the flash object to off
        p.trial.(sn).trialStart = GetSecs;
        
        Datapixx('SetDoutValues',2^p.trial.(sn).bitNumber);
        Datapixx('RegWr');
        
        Datapixx('SetDoutValues',0)
        Datapixx('RegWr');
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        
        % --- set up default parameters
        defaultArgs = {...
            'bitNumber',                10, ...
            };
        
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end
        end
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        % don't need to do anything because our stimulus logs itself
        
        % initialize the flash object to off
        p.trial.(sn).trialStart = GetSecs;
        
        Datapixx('SetDoutValues',2^p.trial.(sn).bitNumber);
        Datapixx('RegWr');
        
        Datapixx('SetDoutValues',0)
        Datapixx('RegWr');
        
end