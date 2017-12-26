function p = basicFlash(p, state, sn)
% CSD FLASH: draw a full-field flash

if nargin<3
    sn='csdFlash';
end


switch state
    
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
    
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        frameCtr = p.trial.iFrame - p.trial.(sn).frameAtChange; % frame counter since last change
        
        
        % update the flash
        if p.trial.(sn).isOn % if it's on
            
            % is it time to turn off?
            if frameCtr > p.trial.(sn).onDuration    
                disp('turned off')
                % turn it off
                p.trial.(sn).isOn = false;
                p.trial.(sn).hFlash.stimValue = false;
                p.trial.(sn).frameAtChange = p.trial.iFrame;
            end
        else
            
            % is it time to turn on?
            if frameCtr > p.trial.(sn).offDuration    
                disp('flash on')
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
        p.trial.(sn).hFlash = stimuli.objects.ffflash('color', p.trial.(sn).onColor);
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        % don't need to do anything because our stimulus logs itself
        
        % turn off the flash
        p.trial.(sn).hFlash.stimValue = false;
        
end