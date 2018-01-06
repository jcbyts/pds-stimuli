function p=spatialSquares(p, state, sn)
% gaussian noise module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m

if nargin<3
    sn='spatialSquares';
end


switch state
        
    %--------------------------------------------------------------------------
    % --- Before Opening the screen: Setup the random seed and turn on the
    %     default pldaps frame states
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        stimuli.setupDefaultFrameStates(p, sn);
        stimuli.setupRandomSeed(p, sn);
        
        
	%--------------------------------------------------------------------------
    % --- After screen is open: Setup default parameters
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        % BLEND FUNCTION MUST BE GL_ONE, GL_ONE FOR THIS MODULE TO WORK
        p.trial.display.sourceFactorNew      = GL_ONE;
        p.trial.display.destinationFactorNew = GL_ONE;
        
        Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
        
        
        win = pds.px2deg([-p.trial.display.pWidth -p.trial.display.pHeight; p.trial.display.pWidth p.trial.display.pHeight]'/2, p.trial.display.viewdist, p.trial.display.px2w);
        win = win(:)'.*[1 -1 1 -1];
            
        % --- set up default parameters
        defaultArgs = {...
            'size',                 2, ...   % size of each square (degrees)
            'N',                    20, ...  % number of squares on each frame
            'contrast',           	.25, ... % contrast of the squares
            'lifetime',             3, ...   % frames
            'position',             win, ... % rectangle for stimulus location (degrees)
            'minFixation',          nan, ... % time fixation has been held before showing stimulus (default: no fixation)
            };
        
        % step through argument pairs and add them to the module
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end
        end

        % setup default object
        p.trial.(sn).hSquares = stimuli.objects.spatialSquares(p);
        
    %--------------------------------------------------------------------------
    % --- Trial Setup: pre-allocate important variables for storage and
    %     generate stimulus sequence
    case p.trial.pldaps.trialStates.trialSetup
        
        % --- Set Blend Function
        % We want these squares to override whatever they're on top of
        p.trial.display.sourceFactorNew = GL_ONE;
        p.trial.display.destinationFactorNew = GL_ONE;
        
        Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
        
        p.trial.(sn).hSquares.setRandomSeed(p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial)); % setup random seed

        % update variable if they have changed
        p.trial.(sn).hSquares.position = p.trial.(sn).position;
        p.trial.(sn).hSquares.N        = p.trial.(sn).N;
        p.trial.(sn).hSquares.size     = p.trial.(sn).size;
        p.trial.(sn).hSquares.contrast = p.trial.(sn).contrast;
        p.trial.(sn).hSquares.lifetime = p.trial.(sn).lifetime;

        % prepare object for trial
        p.trial.(sn).hSquares.trialSetup(p);

        if p.trial.(sn).minFixation > 0 % fixation required
            p.trial.(sn).hSquares.stimValue = 0; % make sure squares are off
        else
            p.trial.(sn).hSquares.stimValue = 1; % stimulus on from the start
        end
        
        % --- still log the same way you did before for easy reconstruction
        p.trial.(sn).on  = nan(p.trial.pldaps.maxFrames,1);
        p.trial.(sn).pos = nan(4, p.trial.(sn).N, p.trial.pldaps.maxFrames);
        
        
    %--------------------------------------------------------------------------
    % --- Manage stimulus before frame draw
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        % check if the stimulus should be on or off
        if p.trial.(sn).minFixation > 0 % fixation is required

            if p.trial.fixflash.hFix.isFixated % is fixation obtained?

                % check if it's time to turn on the object
                if (p.trial.ttime + p.trial.trstart) > (p.trial.fixflash.hFix.fixlog(end) + p.trial.(sn).minFixation)
                    p.trial.(sn).hSquares.stimValue = 1; % turn it on
                end
            end
        end
        
        p.trial.(sn).hSquares.frameUpdate(p);
        
        p.trial.(sn).on(p.trial.iFrame) = p.trial.(sn).hSquares.stimValue;
        p.trial.(sn).pos(:,:, p.trial.iFrame) = p.trial.(sn).hSquares.rect;
        
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.(sn).hSquares.frameDraw(p);
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave

        p.trial.(sn).on     = p.trial.(sn).on(1:p.trial.iFrame);
        p.trial.(sn).pos    = p.trial.(sn).pos(:,:, 1:p.trial.iFrame);
        
end