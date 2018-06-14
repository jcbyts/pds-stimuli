function p=DotsFullFieldDirectionMapping(p, state, sn)
% Draw Hartley Stimuli, module for PLDAPS open reception

if nargin<3
    sn='MotionMapping';
end

% -------------------------------------------------------------------------
% This is just a courtesy: lists all the possible arguments and a
% description of what they are. The
if nargin < 1
    defaultArgs = {...
        'onDuration',           'duration stimulus is on (in frames)', ...
        'offDuration',          'duration between stimulus presentations (in frames)', ...
        'numDirections',        'number of directions (evenly spaced between 0 and 360)', ...
        'dotSpeeds',            'dot speeds (deg/sec)', ...
        'dotSize',              'dot size (radius, degrees)', ...
        'randomizeDirection',   'directions in random order (opposed to in sequence)', ...
        'dotContrast',          'gray scale of dots (0 = mean gray; -.5 = black; .5 = white)', ...
        };
    fprintf('No arguments passed in: call from within pldaps\n')
    fprintf('<strong>Optional Parameters:</strong>\n')
    fprintf('<strong>%s</strong>\t\t\t%s\n', defaultArgs{:})
    return
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
        
        % --- set up default parameters
        defaultArgs = {...
            'onDuration',           5, ...          % duration stimulus is on (in frames)
            'offDuration',          5, ...          % duration between stimulus presentations (in frames)
            'numDirections',        12, ...         % number of directions (evenly spaced between 0 and 360)
            'dotSpeeds',            [10 15], ...    % speeds (deg/sec)
            'dotSize',              .2, ...         % dot size (radius, degrees)
            'direction',            0, ...          % what is this for?
            'randomizeDirection',   true, ...       % directions in random order (opposed to in sequence)
            'dotContrast',          -.2, ...        % gray scale of dots (0 = mean gray; -.5 = black; .5 = white)
            'priorMu',              0, ...          % center of a vonMises prior over dot directions
            'priorKappa',           0, ...          % Kappa (concentration) of circular Gaussian aka von Mises (0 = uniform distribution; bigger numbers are narrower)
            };
        
        % step through argument pairs and add them to the module
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end
        end
        
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup random seed
        p.trial.(sn).rngs.conditionerRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.trialSeeds(p.trial.pldaps.iTrial));
        setupRNG=p.trial.(sn).rngs.conditionerRNG;
       
        % build sequence
        nFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        
        p.trial.(sn).numDots = 1e3;
        p.trial.(sn).dotsXY = bsxfun(@times, rand(p.trial.(sn).rngs.conditionerRNG, 2,p.trial.(sn).numDots), p.trial.display.winRect(3:4)');
        p.trial.(sn).prior = directionprior(p.trial.(sn).numDirections, 5, p.trial.(sn).priorMu, p.trial.(sn).priorKappa);
        
        p.trial.(sn).dotsColor = (p.trial.(sn).dotContrast + p.trial.display.bgColor);
        
        % --- build sequence
        p.trial.(sn).sequence.direction = nan(nFrames,1);
        p.trial.(sn).sequence.speed = nan(nFrames,1);
        p.trial.(sn).sequence.on = nan(nFrames,1);
        
        lastSwitch = 0;
        on = rand(setupRNG) > .5; % initialize onset
        direction = p.trial.(sn).prior.drawfromprior;
        speed = p.trial.(sn).dotSpeeds(randi(setupRNG, numel(p.trial.(sn).dotSpeeds), 1));
        
        for iFrame = 1:nFrames
%             disp([lastSwitch on direction speed])
            
            if on && (iFrame - lastSwitch) > p.trial.(sn).onDuration
                % switch to off
                on = false;
                direction = nan;
                speed = nan;
                lastSwitch = iFrame;
            elseif ~on && (iFrame - lastSwitch) > p.trial.(sn).offDuration
                % switch to on
                direction = p.trial.(sn).prior.drawfromprior(setupRNG);
                speed = p.trial.(sn).dotSpeeds(randi(setupRNG, numel(p.trial.(sn).dotSpeeds), 1));
                on = true;
                lastSwitch = iFrame;
            end
            
            p.trial.(sn).sequence.direction(iFrame) = direction;
            p.trial.(sn).sequence.speed(iFrame) = speed;
            p.trial.(sn).sequence.on(iFrame) = on;
            
        
        end
        
        p.trial.(sn).direction = nan(nFrames, 1);
        p.trial.(sn).speed = nan(nFrames, 1);
        p.trial.(sn).on = nan(nFrames, 1);
        p.trial.(sn).sequenceFrame = 0;
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        p.trial.(sn).sequenceFrame = p.trial.(sn).sequenceFrame + 1;
        
        if p.trial.(sn).sequenceFrame == 0
            return
        end
        
        direction = p.trial.(sn).sequence.direction(p.trial.(sn).sequenceFrame);
        speed     = p.trial.(sn).sequence.speed(p.trial.(sn).sequenceFrame);
        on        = p.trial.(sn).sequence.on(p.trial.(sn).sequenceFrame);
        
        dx = cosd(direction)*speed*p.trial.display.ppd/p.trial.display.frate;
        dy = sind(direction)*speed*p.trial.display.ppd/p.trial.display.frate;
        
        if on
            p.trial.(sn).dotsXY = [p.trial.(sn).dotsXY(1,:)+dx; p.trial.(sn).dotsXY(2,:)+dy];
            
            % wrapping
            ix = p.trial.(sn).dotsXY(1,:) > p.trial.display.pWidth;
            p.trial.(sn).dotsXY(1,ix) = 0;
            p.trial.(sn).dotsXY(2,ix) = p.trial.display.pHeight - p.trial.(sn).dotsXY(2,ix);
            
            ix = p.trial.(sn).dotsXY(1,:) < 0;
            p.trial.(sn).dotsXY(1,ix) = p.trial.display.pWidth;
            p.trial.(sn).dotsXY(2,ix) = p.trial.display.pHeight - p.trial.(sn).dotsXY(2,ix);
            
            ix = p.trial.(sn).dotsXY(2,:) > p.trial.display.winRect(4);
            p.trial.(sn).dotsXY(2,ix) = 0;
            p.trial.(sn).dotsXY(1,ix) = p.trial.display.winRect(3) - p.trial.(sn).dotsXY(1,ix);
            
            ix = p.trial.(sn).dotsXY(2,:) < 0;
            p.trial.(sn).dotsXY(2,ix) = p.trial.display.winRect(4);
            p.trial.(sn).dotsXY(1,ix) = p.trial.display.winRect(3) - p.trial.(sn).dotsXY(1,ix);
            
            p.trial.(sn).direction(p.trial.iFrame) = direction;
            p.trial.(sn).speed(p.trial.iFrame) = speed;
            p.trial.(sn).on(p.trial.iFrame) = on;
        else
            p.trial.(sn).dotsXY = bsxfun(@times, rand(p.trial.(sn).rngs.conditionerRNG, 2,p.trial.(sn).numDots), p.trial.display.winRect(3:4)');
            p.trial.(sn).on(p.trial.iFrame) = on;
        end
        
        
    case p.trial.pldaps.trialStates.frameDraw
        
        if p.trial.(sn).on(p.trial.iFrame)
            Screen('BlendFunction', p.trial.display.ptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawDots',p.trial.display.ptr,p.trial.(sn).dotsXY, p.trial.(sn).dotSize*p.trial.display.ppd, p.trial.(sn).dotsColor, [], 3);
            Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
        end
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave

        ix=1:p.trial.iFrame;

        p.trial.(sn).direction = p.trial.(sn).direction(ix);
        p.trial.(sn).speed = p.trial.(sn).speed(ix);
        p.trial.(sn).on = p.trial.(sn).on(ix);
        
        p.trial.(sn) = rmfield(p.trial.(sn), 'sequence');
%         p.trial.(sn) = rmfield(p.trial.(sn), 'sequence');
        
        
end