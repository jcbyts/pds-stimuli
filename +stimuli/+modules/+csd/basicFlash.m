function p = basicFlash(p, state, sn)
% CSD FLASH: draw a full-field flash

if nargin<3
    sn='csdFlash';
end

% -------------------------------------------------------------------------
% This is just a courtesy: lists all the possible arguments and a
% description of what they are. The
if nargin < 1
    defaultArgs = {...
            'onDuration',               'frames flash is on', ...
            'offDuration',              'frames flash is off', ...
            'onColor',                  'color [1 x 3] during flash', ...
            };
    fprintf('No arguments passed in: call from within pldaps\n')
    fprintf('<strong>Optional Parameters:</strong>\n')
    fprintf('<strong>%s</strong>\t\t\t%s\n', defaultArgs{:})
    return
end

switch state
    
    % copy-paste this in every module that has the default trial states
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        stimuli.setupDefaultFrameStates(p, sn);
        stimuli.setupRandomSeed(p, sn);
    
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        frameCtr = p.trial.iFrame - p.trial.(sn).frameAtChange; % frame counter since last change
        
        
        % update the flash
        if p.trial.(sn).isOn % if it's on
            
            % is it time to turn off?
            if frameCtr > p.trial.(sn).onDuration    
%                 disp('turned off')
                % turn it off
                p.trial.(sn).isOn = false;
                p.trial.(sn).hFlash.stimValue = false;
                p.trial.(sn).frameAtChange = p.trial.iFrame;
            end
        else
            
            % is it time to turn on?
            if frameCtr > p.trial.(sn).offDuration    
%                 disp('flash on')
                % turn it off
                p.trial.(sn).isOn = true;
                p.trial.(sn).hFlash.stimValue = true;
                p.trial.(sn).frameAtChange = p.trial.iFrame;
            end
        end
        
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.(sn).hFlash.frameDraw(p); % draw the flash
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % initialize the flash object to off
        p.trial.(sn).hFlash.stimValue = false;
        
        % two variables will govern the update rules
        p.trial.(sn).isOn = false; % is it currently on
        p.trial.(sn).frameAtChange = p.trial.iFrame; % what frame did it change at
        
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        
        % --- set up default parameters
        defaultArgs = {...
            'onDuration',               60, ...
            'offDuration',              100, ...
            'onColor',                  [1,1,1], ...
            };
        
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end
        end
        
        % --- create object
        if ~isfield(p.trial.(sn), 'hFlash')
            p.trial.(sn).hFlash = stimuli.objects.ffflash('color', p.trial.(sn).onColor);
        end
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        % don't need to do anything because our stimulus logs itself
        
        % turn off the flash
        p.trial.(sn).hFlash.stimValue = false;
        
end