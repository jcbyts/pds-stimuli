function p=DotMotionMapping(p, state, sn)
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
        'nDotApertures',        'number of dot apertures to show', ...
        'dotSpeeds',            'dot speeds (deg/sec)', ...
        'dotSize',              'dot size (radius, degrees)', ...
        'randomizeDirection',   'directions in random order (opposed to in sequence)', ...
        'gazeContingent',       'position is relative to current eye position if true', ...
        'dotx',                 'x position (relative to screen center or eye position depending on gazeContingent flag)', ...
        'doty',                 'y position (relative to screen center or eye position depending on gazeContingent flag)', ...
        'apertureSize',         'dot aperture size (radius, degrees)', ...
        'dotContrast',          'gray scale of dots (0 = mean gray; -.5 = black; .5 = white)', ...
        'minDuration',          'what is this', ...
        'maxDuration',          'what is this', ...
        'minFixation',          'time fixation has been held before showing stimulus (default: no fixation)', ...
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
            'onDuration',           2, ...          % duration stimulus is on (in frames)
            'offDuration',          2, ...          % duration between stimulus presentations (in frames)
            'numDirections',        12, ...         % number of directions (evenly spaced between 0 and 360)
            'nDotApertures',        8, ...          % number of dot apertures to show
            'dotSpeeds',            [10 15], ...    % speeds (deg/sec)
            'dotSize',              .2, ...         % dot size (radius, degrees)
            'direction',            0, ...          % what is this for?
            'randomizeDirection',   true, ...       % directions in random order (opposed to in sequence)
            'gazeContingent',       false, ...      % position is relative to current eye position if true
            'dotx',                 0, ...          % x position (relative to screen center or eye position depending on gazeContingent flag)
            'doty',                 0, ...          % y position (relative to screen center or eye position depending on gazeContingent flag)
            'apertureSize',         5, ...          % dot aperture size (radius, degrees)
            'dotContrast',          -.2, ...        % gray scale of dots (0 = mean gray; -.5 = black; .5 = white)
            'minDuration',          8, ...          % what is this
            'maxDuration',          20, ...         % what is this
            'minFixation',          nan, ...        % time fixation has been held before showing stimulus (default: no fixation)
            'handMap',              false, ...      % controlled with mouse?
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
        
        p.trial.(sn).hDots = stimuli.objects.dotsUniform(p.trial.display.ptr);
        nSpeeds = numel(p.trial.(sn).dotSpeeds);
        rnd = randi(setupRNG, nSpeeds);
        p.trial.(sn).speed = p.trial.(sn).dotSpeeds(rnd); % deg/sec
        p.trial.(sn).hDots.dotSpeed = p.trial.(sn).speed * p.trial.display.ppd / p.trial.display.frate;
        p.trial.(sn).hDots.dotSize  = p.trial.(sn).dotSize * p.trial.display.ppd;
        
        p.trial.(sn).directionPrior = directionprior(p.trial.(sn).numDirections, 'unimodal', p.trial.(sn).priorMu, p.trial.(sn).priorKappa);
        
        if (p.trial.(sn).numDirections > 1)
            %             p.trial.(sn).hDots.dotDirection = 0;
            p.trial.(sn).hDots.dotDirection = p.trial.(sn).directionPrior.drawfromprior(setupRNG);
        else
            p.trial.(sn).hDots.dotDirection = p.trial.(sn).direction;
            p.trial.(sn).direction
            disp('check new trial')
        end
        
        p.trial.(sn).hDots.radius = p.trial.(sn).apertureSize*p.trial.display.ppd;
        p.trial.(sn).hDots.dotLifetime = inf;
        p.trial.(sn).hDots.range = 0;
        p.trial.(sn).hDots.position = [0 0];
        p.trial.(sn).hDots.dotColor = repmat(p.trial.(sn).dotContrast, 1, 3);
        p.trial.(sn).hDots.numDots = ceil(.3*pi*p.trial.(sn).apertureSize^2);
        
        p.trial.(sn).hDots.trialSetup();
        
        nFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
        p.trial.(sn).x  = nan(nFrames,1);
        p.trial.(sn).y  = nan(nFrames,1);
        p.trial.(sn).on = false(nFrames,1);
        p.trial.(sn).direction = nan(nFrames,1);
        p.trial.(sn).speed = nan(nFrames,1);
        p.trial.(sn).size  = nan(nFrames,1);
        
        %         p.trial.(sn).handMap = false;
        p.trial.offCtr = 1;
        p.trial.onCtr  = 0;
        
        if p.trial.(sn).offDuration==0
            p.trial.offCtr = 0;
            p.trial.onCtr  = 1;
        end
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        
        p.trial.(sn).hDots.frameUpdate(p);
        
        if isfield(p.trial.stimulus, 'm')
            dstep = 360/p.trial.(sn).numDirections;
            p.trial.stimulus.m.direction = round((p.trial.stimulus.m.direction/dstep)) * dstep;
        end
        
        on = false;
        
        % Update direction
        
        if p.trial.(sn).handMap && p.trial.iFrame > 1
            
            mxy = p.trial.mouse.cursorSamples(:,p.trial.iFrame-1); % - p.trial.display.ctr(1:2)';
            
            dx = mxy(1) - p.trial.(sn).hDots.position(1);
            dy = mxy(2) - p.trial.(sn).hDots.position(2);
            dx = dx/p.trial.display.frate*3;
            dy = -dy/p.trial.display.frate*3; %
            [th, rho] = cart2pol(dx, dy);
            p.trial.(sn).hDots.dotDirection = th/pi*180;
            p.trial.(sn).hDots.dotSpeed = rho;
            p.trial.(sn).hDots.dx(1:end) = dx;
            p.trial.(sn).hDots.dy(1:end) = dy;
            
            
            
        else
            
            if mod(p.trial.onCtr, p.trial.(sn).onDuration)==0
                on = false;
                p.trial.offCtr = p.trial.offCtr + 1;
                p.trial.onCtr  = 0;
            end
            
            if mod(p.trial.offCtr, p.trial.(sn).offDuration)==0 || p.trial.(sn).offDuration==0
                on = true;
                p.trial.offCtr = 0;
                p.trial.onCtr  = p.trial.onCtr + 1;
            end
            
            if p.trial.onCtr==1
                if (p.trial.(sn).numDirections > 1)
                    
                    if p.trial.(sn).randomizeDirection
                        p.trial.(sn).hDots.dotDirection = p.trial.(sn).directionPrior.drawfromprior;
                        %                     p.trial.(sn).hDots.dotDirection = (randi(p.trial.(sn).numDirections)-1)*(360)/p.trial.(sn).numDirections;
                    else
                        p.trial.(sn).hDots.dotDirection = p.trial.(sn).hDots.dotDirection + (360)/p.trial.(sn).numDirections;
                    end
                    %             p.trial.(sn).hDots.initDots(1:p.trial.(sn).hDots.numDots); % all dots!
                    dx = p.trial.(sn).hDots.dotSpeed * cosd(p.trial.(sn).hDots.dotDirection);
                    dy = p.trial.(sn).hDots.dotSpeed * sind(p.trial.(sn).hDots.dotDirection);
                    p.trial.(sn).hDots.dx(1:end) = dx;
                    p.trial.(sn).hDots.dy(1:end) = dy;
                    %                 disp(p.trial.(sn).hDots.dotDirection)
                end
            end
        end
        
        p.trial.(sn).x(p.trial.iFrame) = p.trial.(sn).hDots.position(1);
        p.trial.(sn).y(p.trial.iFrame) = p.trial.(sn).hDots.position(2);
        p.trial.(sn).direction(p.trial.iFrame) =  p.trial.(sn).hDots.dotDirection;
        p.trial.(sn).on(p.trial.iFrame) = on;
        p.trial.(sn).speed(p.trial.iFrame) = p.trial.(sn).hDots.dotSpeed;
        p.trial.(sn).size(p.trial.iFrame)  = p.trial.(sn).hDots.radius;
        
        % Keyboard Checking
        if any(p.trial.keyboard.firstPressQ)
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Rarrow)
                p.trial.(sn).dotx=p.trial.(sn).dotx+100;
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Larrow)
                p.trial.(sn).dotx=p.trial.(sn).dotx-100;
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Uarrow)
                p.trial.(sn).doty=p.trial.(sn).doty-100;
            end
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Darrow)
                p.trial.(sn).doty=p.trial.(sn).doty+100;
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.plusKey)
                p.trial.(sn).hDots.radius=p.trial.(sn).hDots.radius+50;
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.minusKey)
                p.trial.(sn).hDots.radius= max(p.trial.(sn).hDots.radius-50, 10);
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.rKey)
                % p.trial.(sn).randomizeDirection = ~p.trial.(sn).randomizeDirection;
                p.trial.(sn).hDots.dotDirection = p.trial.(sn).hDots.direction + ...
                    (360/12);
                dx = p.trial.(sn).hDots.dotSpeed * cosd(p.trial.(sn).hDots.direction);
                dy = p.trial.(sn).hDots.dotSpeed * sind(p.trial.(sn).hDots.direction);
                p.trial.(sn).hDots.dx(1:end) = dx;
                p.trial.(sn).hDots.dy(1:end) = dy;
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.hKey)
                % p.trial.(sn).handMap = ~p.trial.(sn).handMap;
                p.trial.(sn).hDots.direction = p.trial.(sn).hDots.direction - ...
                    (360/12);
                dx = p.trial.(sn).hDots.dotSpeed * cosd(p.trial.(sn).hDots.dotDirection);
                dy = p.trial.(sn).hDots.dotSpeed * sind(p.trial.(sn).hDots.dotDirection);
                p.trial.(sn).hDots.dx(1:end) = dx;
                p.trial.(sn).hDots.dy(1:end) = dy;
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.gKey)
                p.trial.(sn).gazeContingent = ~p.trial.(sn).gazeContingent;
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.zerKey)
                
                
                p.trial.(sn).hDots.dx = p.trial.(sn).hDots.dx*(3/2);
                p.trial.(sn).hDots.dy = p.trial.(sn).hDots.dy*(3/2);
                [~, rho] = cart2pol(p.trial.(sn).hDots.dx, p.trial.(sn).hDots.dy);
                p.trial.(sn).hDots.dotSpeed = mean(rho);
                
            end
            
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.ninKey)
                p.trial.(sn).hDots.dx = p.trial.(sn).hDots.dx*(2/3);
                p.trial.(sn).hDots.dy = p.trial.(sn).hDots.dy*(2/3);
                [~, rho] = cart2pol(p.trial.(sn).hDots.dx, p.trial.(sn).hDots.dy);
                p.trial.(sn).hDots.dotSpeed = mean(rho);
            end
        end
        
        if p.trial.(sn).gazeContingent
            p.trial.(sn).hDots.position = [p.trial.eyeX+p.trial.(sn).dotx p.trial.eyeY+p.trial.(sn).doty];
        else
            p.trial.(sn).hDots.position = [p.trial.display.ctr(1)+p.trial.(sn).dotx p.trial.display.ctr(2)+p.trial.(sn).doty];
        end
        
        
    case p.trial.pldaps.trialStates.frameDraw
        
        if p.trial.(sn).on(p.trial.iFrame)
            p.trial.(sn).hDots.frameDraw(p);
        end
        
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %         if p.trial.(sn).on
        ix=p.trial.iFrame:size(p.trial.(sn).x,1);
        p.trial.(sn).x(ix,:)=[];
        p.trial.(sn).y(ix,:)=[];
        p.trial.(sn).direction(ix,:)=[];
        p.trial.(sn).speed(ix,:)=[];
        p.trial.(sn).size(ix,:)=[];
        %             p.trial.(sn).scale(ix,:)=[];
        %         end
        trialStart = numel(p.data)+1;
        if isempty(trialStart)
            trialStart = 1;
        end
        for i = trialStart:p.trial.pldaps.finish
            p.conditions{i}.(sn).dotx = p.trial.(sn).dotx;
            p.conditions{i}.(sn).doty = p.trial.(sn).doty;
            p.conditions{i}.(sn).apertureSize = p.trial.(sn).hDots.radius/p.trial.display.ppd;
            p.conditions{i}.(sn).gazeContingent =  p.trial.(sn).gazeContingent;
            p.conditions{i}.(sn).handMap        =  p.trial.(sn).handMap;
            p.conditions{i}.(sn).speed          =  p.trial.(sn).hDots.dotSpeed*p.trial.display.frate/p.trial.display.ppd;
            p.conditions{i}.(sn).direction      =  p.trial.(sn).hDots.dotDirection;
        end
        
end