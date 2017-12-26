function p=spatialSquares(p, state, sn)
% gaussian noise module for PLDAPS open reception
% Draws randomly scaled gaussians across the screen for reverse
% correlation. Based loosely on ProceduralGarborium.m

if nargin<3
    sn='gaussianNoiseBlobs';
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
        
        p = stimuli.setupRandomSeed(p, sn);
        
    %--------------------------------------------------------------------------
    % --- Trial Setup: pre-allocate important variables for storage and
    %     generate stimulus sequence
    case p.trial.pldaps.trialStates.trialSetup
        
        % --- Set Blend Function
        p.trial.display.sourceFactorNew = GL_ONE;
        p.trial.display.destinationFactorNew = GL_ONE;
        
        Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);

        % trial random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        % --- build stimulus sequence
        pxwin   = pds.deg2px(reshape(p.trial.(sn).position, 2, 2), p.trial.display.viewdist, p.trial.display.w2px);
        pxwin   = pxwin(:)'.*[1 -1 1 -1] + p.trial.display.ctr;
        pWidth  = pxwin(3)-pxwin(1);
        pHeight = pxwin(4)-pxwin(2);
        pUlX    = pxwin(1);
        pUlY    = pxwin(2);
        
        
        p.trial.(sn).on  = true(p.trial.pldaps.maxFrames,1); % stimulus is on every frame
        
        p.trial.(sn).pos = nan(4, p.trial.(sn).N, p.trial.pldaps.maxFrames);
        lifetime         = randi(setupRNG, p.trial.(sn).lifetime, p.trial.(sn).N, 1);
        xpos             = round(rand(setupRNG, p.trial.(sn).N, 1)*pWidth) + pUlX;
        ypos             = round(rand(setupRNG, p.trial.(sn).N, 1)*pHeight) + pUlY;
        szpix            = p.trial.(sn).size * p.trial.display.ppd;
        rect             = [xpos(:) ypos(:) xpos(:)+szpix ypos(:)+szpix];
        
        p.trial.(sn).pos(:,:,1) = rect';
        for iFrame = 2:p.trial.pldaps.maxFrames
            idx = lifetime == 1;
            xpos = round(rand(setupRNG, sum(idx), 1)*pWidth) + pUlX;
            ypos = round(rand(setupRNG, sum(idx), 1)*pHeight) + pUlY;
            rect(idx,:) = [xpos(:) ypos(:) xpos(:)+szpix ypos(:)+szpix];
            p.trial.(sn).pos(:,:,iFrame) = rect';
                
            lifetime = mod(lifetime, p.trial.(sn).lifetime)+1;
            
        end
        
    %--------------------------------------------------------------------------
    % --- Manage stimulus before frame draw
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        % check if the stimulus should be on or off
        if p.trial.(sn).minFixation > 0 % fixation is required
            if p.trial.fixflash.hFix.isFixated
                if (p.trial.ttime + p.trial.trstart) < (p.trial.fixflash.hFix.fixlog(end) + p.trial.(sn).minFixation)
                    p.trial.(sn).on(p.trial.iFrame) = false;
                else
                    p.trial.(sn).on(p.trial.iFrame) = true;
                end
            else
                p.trial.(sn).on(p.trial.iFrame) = false;
            end
        end
        
    case p.trial.pldaps.trialStates.frameDraw
        
        if p.trial.(sn).on(p.trial.iFrame)
            Screen('FillRect', p.trial.display.ptr, [1 1 1], p.trial.(sn).pos(:,:,p.trial.iFrame))
        end
        
        
        
        
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        if p.trial.(sn).on
            ix=p.trial.iFrame:size(p.trial.(sn).pos,3);
            p.trial.(sn).pos(:,:,ix)=[];
        end
        
end