function p=forage(p, state, sn)
% FACEFORAGE module for PLDAPS open reception

if nargin<3
    sn='faceforage';
end

% -------------------------------------------------------------------------
% --- Switch statement for frame states

switch state
    
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        p.trial.(sn).stateFunction.acceptsLocationInput = true; % is this necessary
        % setup states that will be called by this module
        p.trial.(sn).stateFunction.requestedStates.experimentPostOpenScreen = true;
        p.trial.(sn).stateFunction.requestedStates.trialSetup = true;
        p.trial.(sn).stateFunction.requestedStates.framePrepareDrawing = true;
        p.trial.(sn).stateFunction.requestedStates.frameDraw = true;
        p.trial.(sn).stateFunction.requestedStates.trialCleanUpandSave = true;
        
        % --- setup random seeds
        p.trial.(sn).rngs.randomNumberGenerater='mrg32k3a';
        p.trial.(sn).rngs.trialSeeds = repmat(randi(2^32, [10 1]), 1e3,1);

    
    %--------------------------------------------------------------------------
    % --- Before Trial
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup random seed
        [p.trial.(sn).rngs.conditionerRNG, motionRNG]=RandStream.create(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial), 'NumStreams', 2);
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
        
        p.trial.(sn).maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        
        % --- this might not be ideal
        if ~isfield(p.trial.(sn), 'm') || ~isa(p.trial.(sn).m, 'butterfly')
            p.trial.(sn).m = stimuli.butterfly(p, p.trial.(sn).MotN, 'type', p.trial.(sn).type, ...
                'motionType', p.trial.(sn).motionType, 'randStream', motionRNG, ...
                'appearDist', 'gaussian', ...
                'appearGazeCont', p.trial.(sn).appearGazeContingent, ...
                'appearRangePar', p.trial.(sn).appearRangePar, ...
                'appearCenter', p.trial.(sn).appearCenter, ...
                'appearTau', p.trial.(sn).appearTau, ...
                'maxContrast', p.trial.(sn).maxContrast, ...
                'radius', p.trial.(sn).radius, ...
                'onLifetime', p.trial.(sn).onLifetime, ...
                'offLifetime', p.trial.(sn).offLifetime, ...
                'holdDuration', p.trial.(sn).holdDuration);
        end
        
        % randomize speed
        p.trial.(sn).m.speed = (p.trial.(sn).maxSpeed - p.trial.(sn).minSpeed) .* rand(setupRNG, size(p.trial.(sn).m.speed)) + p.trial.(sn).minSpeed;
        
        % --- preallocate variables to track
        p.trial.(sn).eyes = nan(p.trial.(sn).maxFrames, 2);
        p.trial.(sn).x = nan(p.trial.(sn).maxFrames, p.trial.(sn).MotN);
        p.trial.(sn).y = nan(p.trial.(sn).maxFrames, p.trial.(sn).MotN);
        
        p.trial.(sn).ctrHold    = nan(p.trial.(sn).maxFrames, p.trial.(sn).MotN);
    
    % ---------------------------------------------------------------------
    % --- Update all behavior of the objects
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        p.trial.(sn).m.isheld([p.trial.eyeX p.trial.eyeY]);
        p.trial.(sn).m.move()
        
        % --- logging parameters
        p.trial.(sn).eyes(p.trial.iFrame,:) = [p.trial.eyeX;p.trial.eyeY];
        p.trial.(sn).x(p.trial.iFrame, :)   = p.trial.(sn).m.x;
        p.trial.(sn).y(p.trial.iFrame, :)   = p.trial.(sn).m.y;
        p.trial.(sn).ctrHold(p.trial.iFrame, :) = p.trial.(sn).m.ctrHold;
        
        % flag end of trial (if time is greater than max trial length)
        if p.trial.iFrame >= p.trial.(sn).maxFrames
            p.trial.flagNextTrial=true;
        end
        
    % ---------------------------------------------------------------------
    % --- Draw objects
    case p.trial.pldaps.trialStates.frameDraw

        p.trial.(sn).m.draw()
      
	% ---------------------------------------------------------------------
    % --- After Trial
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        figure(1); clf
        subplot(4,3,1:6)
        plot(p.trial.(sn).x, p.trial.(sn).y, '.', 'MarkerSize', 2); hold on
        
        p.trial.(sn).eyes = bsxfun(@minus, p.trial.(sn).eyes, p.trial.display.ctr(1:2));
        p.trial.(sn).eyes = pds.px2deg(p.trial.(sn).eyes', p.trial.display.viewdist, p.trial.display.px2w)';
        p.trial.(sn).eyes = bsxfun(@times, p.trial.(sn).eyes, [1 -1]);
        
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
        
        p.trial.(sn).m.objects.closeAll;
        drawnow
    
	% ---------------------------------------------------------------------
    % --- Set up default parameters
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        % --- Set up default parameters 
        if ~isfield(p.trial.(sn), 'MotN')
            p.trial.(sn).MotN       = 3;  % number of face objects
        end
        
        if ~isfield(p.trial.(sn), 'minSpeed')
            p.trial.(sn).minSpeed   = 5;
        end
        
        if ~isfield(p.trial.(sn), 'maxSpeed')
            p.trial.(sn).maxSpeed   = 10;
        end
        
        if ~isfield(p.trial.(sn), 'motionType')
            p.trial.(sn).motionType = 'randomwalk';
        end
        
        if ~isfield(p.trial.(sn), 'forcefield')
            p.trial.(sn).forcefield = false;
        end
        
        if ~isfield(p.trial.(sn), 'type')
            p.trial.(sn).type       = 'face';
        end
        
        if ~isfield(p.trial.(sn), 'appearGazeContingent')
            p.trial.(sn).appearGazeContingent = false;
        end
        
        if ~isfield(p.trial.(sn), 'appearRangePar')
            p.trial.(sn).appearRangePar = 2;
        end
        
        if ~isfield(p.trial.(sn), 'appearCenter')
            p.trial.(sn).appearCenter = [0 0];
        end
        
        if ~isfield(p.trial.(sn), 'appearTau')
            p.trial.(sn).appearTau = 5;
        end
        
        if ~isfield(p.trial.(sn), 'offLifetime')
            p.trial.(sn).offLifetime = 240;
        end
        
        if ~isfield(p.trial.(sn), 'onLifetime')
            p.trial.(sn).onLifetime = 100;
        end
        
        if ~isfield(p.trial.(sn), 'maxContrast')
            p.trial.(sn).maxContrast = 0.2;
        end
        
        if ~isfield(p.trial.(sn), 'holdDuration')
            p.trial.(sn).holdDuration = 15; % frames
        end
        
        if ~isfield(p.trial.(sn), 'radius')
            p.trial.(sn).radius = 1; % degrees of visual angle
        end
        

        
    otherwise    
        
end
