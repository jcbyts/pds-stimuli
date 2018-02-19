function p=forage(p, state, sn)
% FACEFORAGE module for PLDAPS open reception

if nargin<3
    sn='faceforage';
end

% -------------------------------------------------------------------------
% This is just a courtesy: lists all the possible arguments and a
% description of what they are. The
if nargin < 1
    defaultArgs = {...
            'MotN',                     'number of moving objects', ...
            'minSpeed',                 'minimum speed of the objects (deg/sec)', ...
            'maxSpeed',                 'maximum speed of the objects (deg/sec)', ...
            'forcefield',               'objects repel each other', ...
            'type',                     'type of motion object: "face","grating"', ...
            'appearGazeContingent',     'do the objects regenerate in a gaze-contingent coordinate frame', ...
            'appearRangePar',           'range of the generating distribution for the appearance of objects (deg)', ...
            'appearCenter',             'center of the regenerating distribution (deg)', ...
            'appearTau',                'do the objects fade on? (frames)', ...
            'offLifetime',              'time objects remain off (frames)', ...
            'onLifetime',               'time objects remain on (frames)', ...
            'maxContrast',              'contrast of the objects', ...
            'holdDuration',             'frames to hold fixation before reward', ...
            'radius',                   'radius of the objects (deg)', ...
            'motionType',               'randomwalk, linear', ...
            };
    fprintf('No arguments passed in: call from within pldaps\n')
    fprintf('<strong>Optional Parameters:</strong>\n')
    fprintf('<strong>%s</strong>\t\t\t%s\n', defaultArgs{:})
    return
end

% -------------------------------------------------------------------------
% --- Switch statement for frame states

switch state
    
    %--------------------------------------------------------------------------
    % --- Before Opening the screen: Setup the random seed and turn on the
    %     default pldaps frame states
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        stimuli.setupDefaultFrameStates(p, sn);
        stimuli.setupRandomSeed(p, sn);
        
     % ---------------------------------------------------------------------
     % --- After screen is open: Set up default parameters
     case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
         % --- Set up default parameters
         %     These will be overwritten by any parameters in the
         %     settingsStruct
        defaultArgs = {...
            'MotN',                     3, ...      % number of moving objects
            'minSpeed',                 5, ...      % minimum speed of the objects (deg/sec)
            'maxSpeed',                 10, ...     % maximum speed of the objects (deg/sec)
            'forcefield',               false, ...  % objects repel each other
            'type',                     'face', ... % 'face', 'grating'
            'appearGazeContingent',     false, ...  % do the objects regenerate in a gaze-contingent coordinate frame
            'appearRangePar',           2, ...      % range of the generating distribution for the appearance of objects (deg)
            'appearCenter',             [0,0], ...  % center of the regenerating distribution (deg)
            'appearTau',                5, ...      % do the objects fade on? (frames)
            'offLifetime',              240, ...    % time objects remain off (frames)
            'onLifetime',               100, ...    % time objects remain on (frames)
            'maxContrast',              .5, ...     % contrast of the objects
            'holdDuration',             60, ...     % frames to hold fixation before reward
            'radius',                   1, ...      % radius of the objects (deg)
            'motionType',               'randomwalk', ... % randomwalk, linear
            };
        
        % step through argument pairs and add them to the module
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end 
        end
        
        p.trial.(sn).hTargs = stimuli.objects.butterfly(p, p.trial.(sn).MotN, ...
            'type',             p.trial.(sn).type, ...
            'motionType',       p.trial.(sn).motionType, ...
            'appearDist',       'gaussian', ...
            'appearGazeCont',   p.trial.(sn).appearGazeContingent, ...
            'appearRangePar',   p.trial.(sn).appearRangePar, ...
            'appearCenter',     p.trial.(sn).appearCenter, ...
            'appearTau',        p.trial.(sn).appearTau, ...
            'maxContrast',      1, ... % has to be 1 at this point so we can modulate alpha later
            'radius',           p.trial.(sn).radius, ...
            'onLifetime',       p.trial.(sn).onLifetime, ...
            'offLifetime',      p.trial.(sn).offLifetime, ...
            'holdDuration',     p.trial.(sn).holdDuration);

    
    %--------------------------------------------------------------------------
    % --- Before Trial: Setup the many parameters
    case p.trial.pldaps.trialStates.trialSetup
        
        % --- Random seed
        if isfield(p.trial.(sn),'rngs') && isfield(p.trial.(sn).rngs, 'conditionerRNG')
            p.trial.(sn).rngs.conditionerRNG.reset; % reset saved stream
            p.trial.(sn).hTargs.rng.reset;
        else
            [p.trial.(sn).rngs.conditionerRNG] = RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
            p.trial.(sn).hTargs.setRandomSeed();
        end
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        p.trial.(sn).maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        
        % randomize speed
        p.trial.(sn).hTargs.speed = (p.trial.(sn).maxSpeed - p.trial.(sn).minSpeed) .* rand(setupRNG, size(p.trial.(sn).hTargs.speed)) + p.trial.(sn).minSpeed;
        
        % --- preallocate variables to track
        p.trial.(sn).eyes    = nan(p.trial.(sn).maxFrames, 2);
        p.trial.(sn).x       = nan(p.trial.(sn).maxFrames, p.trial.(sn).MotN);
        p.trial.(sn).y       = nan(p.trial.(sn).maxFrames, p.trial.(sn).MotN);
        p.trial.(sn).ctrHold = nan(p.trial.(sn).maxFrames, p.trial.(sn).MotN);
    
    % ---------------------------------------------------------------------
    % --- Update all behavior of the objects
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        p.trial.(sn).hTargs.frameUpdate(p);
        
        % --- logging parameters
        p.trial.(sn).eyes(p.trial.iFrame,:)     = [p.trial.eyeX; p.trial.eyeY];
        p.trial.(sn).x(p.trial.iFrame, :)       = p.trial.(sn).hTargs.x;
        p.trial.(sn).y(p.trial.iFrame, :)       = p.trial.(sn).hTargs.y;
        p.trial.(sn).ctrHold(p.trial.iFrame, :) = p.trial.(sn).hTargs.ctrHold;
        
        % flag end of trial (if time is greater than max trial length)
        if p.trial.iFrame >= p.trial.(sn).maxFrames
            p.trial.flagNextTrial=true;
        end
        
    % ---------------------------------------------------------------------
    % --- Draw objects
    case p.trial.pldaps.trialStates.frameDraw

        p.trial.(sn).hTargs.frameDraw(p);
      
	% ---------------------------------------------------------------------
    % --- After Trial
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        
        
        % convert eye position to degrees
        p.trial.(sn).eyes = bsxfun(@minus, p.trial.(sn).eyes, p.trial.display.ctr(1:2));
        p.trial.(sn).eyes = pds.px2deg(p.trial.(sn).eyes', p.trial.display.viewdist, p.trial.display.px2w)';
        p.trial.(sn).eyes = bsxfun(@times, p.trial.(sn).eyes, [1 -1]);
        
        % plot the outcome of the trial
        figure(1); clf
        subplot(4,3,1:6)
        plot(p.trial.(sn).x, p.trial.(sn).y, '.', 'MarkerSize', 2); hold on
        plot(p.trial.(sn).eyes(:,1), p.trial.(sn).eyes(:,2), 'k.', 'MarkerSize', 2)
        xlabel('Degrees')
        ylabel('Degrees')
        ylim([-15 15])
        xlim([-15 15])
        
        subplot(4,3,7:9)
        plot(p.trial.(sn).x); hold on
        plot(p.trial.(sn).eyes(:,1), 'k')
        xlabel('Frame')
        ylabel('Degrees')
        axis tight
        ylim([-10 10])
        
        subplot(4,3,10:12)
        plot(p.trial.(sn).y); hold on
        plot(p.trial.(sn).eyes(:,2), 'k')
        xlabel('Frame')
        ylabel('Degrees')
        axis tight
        ylim([-10 10])
        
%         p.trial.(sn).hTargs.objects.closeAll;
        drawnow
    
	
        

        
    otherwise    
        
end
