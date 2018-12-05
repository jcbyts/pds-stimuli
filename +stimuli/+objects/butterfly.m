classdef butterfly < stimuli.objects.stimulus
    % MOTION OBJECT Summary of this class goes here
    %   Call by passing in a pldaps and the number of objects
    %   m=MotionOject(pldapsObject, Num, varargin)
    %   
    %   All arguments can be vectorized and if they are, must be size Num
    properties (Access = public)

        N@double                % number of motion objects
        radius@double           % array of object sizes
        
        visible@logical         % visible or not
        type                    % stimulus type (1: face, 2: grating)
        
        speed@double            % array of speeds
        direction@double        % array of directions
        x@double                % x location (degrees)
        y@double                % y location (degrees)
        xpx@double              % x location (pixels)
        ypx@double              % y location (pixels)

        % --- parameters governing the location that an object can appear in
        appearDist@char         % distribution from which to generate locations
        appearGazeCont@logical  % is Ctr in gaze contingent coordinates
        appearRangePar@double   % range parameter for appearance of objects
        appearCenter@double     % center of pdf for object appearance
        appearTau@double        % frequency of transition (linear? cosine?)
        
        onLifetime@double       % number frames on
        offLifetime@double      % number of frames off before reappearing
        
        alpha@double            % transparency of texture (~ contrast)
        maxContrast             % max Alpha

        % --- parameters governing behavior of the objects
        ctrHold                 % frame counter for fixation
        ctrOn                   % how long object has been on
        ctrOff                  % how long object has been off
        holdDuration@double=200  % how many frames to hold before reward
        motionType              % governs movement 
        
        rewardWindow@double = .1;

        % --- parameters governing the appearance of objects
        objects
        texid
        
        boundaries              % [x,y] boundaries for object movement
        
        rotAngles
        rotate@logical
        
        colorThresh
        color

        maxradius
        removed
        
        isFixated           % mimics the isFixated property of stimuli.target
        position            % mimics position property of stimuli.target, in case you want to plot things in a gaze-contingent manner
    end
    
    properties (Access = private)
        
        % --- object parameters
        dx@double               % x velocity
        dy@double               % y velocity
        
        % --- texture info
        dstRects
        srcRect
    end
    
    methods
        % --- Contstructor make motion objects
        function obj = butterfly(p, N, varargin)
            % m=MotionOject(pldapsObject, Number, varargin)
            % Since we're setting most of the parameters here, we don't
            % need to parse a lot of arguments. Let's just set it up
            
            % --- Parse all arguments
            ip=inputParser();
            ip.KeepUnmatched = true; % save arguments that don't match
            ip.addParameter('type', 'face')
            
            % --- parameters for the appearance behavior
            ip.addParameter('appearDist',       'gaussian')
            ip.addParameter('appearGazeCont',   false)
            ip.addParameter('appearRangePar',   5)
            ip.addParameter('appearCenter',     [0 0])
            ip.addParameter('appearTau',        10)
            ip.addParameter('maxContrast',      .3)
            
            % --- parameters for movement behavior
            ip.addParameter('motionType',       'linear')
            ip.addParameter('speed',            0)
            ip.addParameter('radius',           1)
            ip.addParameter('boundaries',       [15 10])
            ip.addParameter('onLifetime',       60)
            ip.addParameter('offLifetime',      120)
            ip.addParameter('holdDuration',     100)
            
            ip.parse(varargin{:}); % parse optional inputs
            
            % convert the unmatched arguments to a cell array of arg. pairs
            nextargs = [fieldnames(ip.Unmatched) struct2cell(ip.Unmatched)]';
            % call the parent constructor to create the object
            obj = obj@stimuli.objects.stimulus(nextargs{:}); 
            
            % size of the display
            obj.boundaries  = ip.Results.boundaries; % boundaries for bouncing objects off the "walls"
            
            obj.N = N; % number of moving objects
            
            obj.type         = ip.Results.type;
            obj.motionType   = ip.Results.motionType;
            obj.onLifetime   = ip.Results.onLifetime;
            obj.offLifetime  = ip.Results.offLifetime;
            obj.maxContrast  = ip.Results.maxContrast;
            obj.holdDuration = ip.Results.holdDuration;
            
            switch obj.type
                case {1, 'face', 'Face'}
                    obj.objects = stimuli.objects.face(p, 'maxContrast', obj.maxContrast);
                case {2, 'grating', 'Grating'}
                    obj.objects = stimuli.objects.grating(p, 'maxContrast', obj.maxContrast);
                otherwise
                    obj.objects = stimuli.objects.singledot(p, 'maxContrast', obj.maxContrast);

            end

            obj.direction         = rand(obj.rng, 1,obj.N)*360;
            
            obj.appearDist        = ip.Results.appearDist;
            obj.appearGazeCont    = ip.Results.appearGazeCont;
            obj.appearRangePar    = ip.Results.appearRangePar;
            obj.appearCenter      = ip.Results.appearCenter;
            obj.appearTau         = ip.Results.appearTau;

            obj.visible=false(1,obj.N);
            
            obj.radius(1:obj.N) = ip.Results.radius;
            obj.speed(1:obj.N)  = ip.Results.speed;

            obj.color         = ones(3,obj.N);
            obj.colorThresh   = 40;
                        
            obj.rotAngles     = zeros(1,obj.N);
            obj.ctrHold       = zeros(1,obj.N);
            obj.ctrOn         = nan(1,obj.N);
            obj.ctrOff        = nan(1,obj.N);
            
            counter = (obj.onLifetime + obj.offLifetime)*(1:obj.N)/obj.N - obj.offLifetime;
            
            ix=counter >= 0;
            obj.ctrOn(ix) = ceil(abs(counter(ix)));
            ix=counter < 0;
            obj.ctrOff(ix) = ceil(abs(counter(ix)));
            
            % initialize objects
            obj.initObjects(p, 1:obj.N);
            
            
        end % constructor

        function initObjects(m, p, idx)

            if nargin < 2
                idx = 1:m.N;
            end

            if islogical(idx)
                idx = find(idx);
            end
            
            n = numel(idx);
            
            % --- update generating distribution
            switch m.appearDist
                case 'uniform'
                    genX = @(n) (rand(m.rng,1,n) - 0.5) * m.appearRangePar + m.appearCenter(1);
                    genY = @(n) (rand(m.rng,1,n) - 0.5) * m.appearRangePar + m.appearCenter(2);
                case 'gaussian'
                    genX = @(n) randn(m.rng,1,n) * m.appearRangePar + m.appearCenter(1);
                    genY = @(n) randn(m.rng,1,n) * m.appearRangePar + m.appearCenter(2);
                otherwise
                    m.appearDist = 'uniform';
                    genX = @(n) (rand(m.rng,1,n) - 0.5) * m.appearRangePar + m.appearCenter(1);
                    genY = @(n) (rand(m.rng,1,n) - 0.5) * m.appearRangePar + m.appearCenter(2);
            end
            
            % --- generate x,y with buffer 
            others = setdiff(1:m.N, idx);
            
            infiniteLoopStopper = 1e3;
            
            for i = idx(:)'
                
                m.x(i) = genX(1);
                m.y(i) = genY(1);
                
                r = sqrt( (m.x(others) - m.x(i)).^2 + (m.y(others) - m.y(i)).^2);
                loopCounter = 1;
                while any(r < 4 * m.radius(others))
                    
                    m.x(i) = genX(1);
                    m.y(i) = genY(1);
                    
                    r = sqrt( (m.x(others) - m.x(i)).^2 + (m.y(others) - m.y(i)).^2);
                    
                    loopCounter = loopCounter + 1;
                    if loopCounter > infiniteLoopStopper
                        disp('Infinite Loop stopped')
                        break
                    end
                    
                end
                
                others = [others(:); i];
            end
            

            m.direction(idx)  = rand(m.rng,1,n)*360;
           
            % initialize variables
            m.texid(idx)         = randi(m.rng,m.objects.numTex, 1, n);
            
            m.color(:,idx)       = ones(3,n);
            m.colorThresh(idx)   = 40;
            
            m.alpha(idx)         = rand(m.rng,1,n)*m.maxContrast; % faces appear gradually
            m.rotAngles(idx)     = zeros(1,n);
            m.ctrHold(idx)       = zeros(1,n);
            
            m.dx(idx) = cosd(m.direction(idx)) .* m.speed(idx) .* p.trial.display.ifi;
            m.dy(idx) = sind(m.direction(idx)) .* m.speed(idx) .* p.trial.display.ifi;
            
            
        end % initialize locations


        % -----------------------------------------------------------------
        % General move function
        function move(obj, p)
            
            % compute the x,y velocity vector
            obj.dx = cosd(obj.direction) .* obj.speed .* p.trial.display.ifi;
            obj.dy = sind(obj.direction) .* obj.speed .* p.trial.display.ifi;
            
            % enforce that the objects don't leave the screen
            obj.bounceOffWalls(p)
           
            % --- Translate position
            switch obj.motionType

                case 'linear'
                    % done. vectors are already set
                case 'randomdrift'
                    % random walk along a drift rate
                    obj.dx = obj.dx + randn(obj.rng, 1, obj.N) .* obj.speed * p.trial.display.ifi;
                    obj.dy = obj.dy + randn(obj.rng, 1, obj.N) .* obj.speed * p.trial.display.ifi;
                case 'randomwalk'
                    % gaussian random walk (stationary, zero mean)
                    obj.dx = randn(obj.rng, 1, obj.N) .* obj.speed * p.trial.display.ifi;
                    obj.dy = randn(obj.rng, 1, obj.N) .* obj.speed * p.trial.display.ifi;
            end
            
            % translate the objects
            obj.x = obj.x + obj.dx;
            obj.y = obj.y + obj.dy;
            
            % conver to pixels
            obj.xpx = p.trial.display.ppd * obj.x + p.trial.display.ctr(1);
            obj.ypx = -p.trial.display.ppd * obj.y + p.trial.display.ctr(2);
            
            % update speed and direction
            th = cart2pol(obj.dx, obj.dy); % convert back to direction
            obj.direction = th/pi*180;
           
        end
        
        function frameUpdate(obj, p)
            
            % --- move objects
            obj.move(p);
            obj.isheld(p);
            
            
            % --- update objects
            obj.objects.position = [obj.xpx(:) obj.ypx(:)];
            obj.objects.texSize  = repmat(2 * obj.radius(:) * p.trial.display.ppd,1,2);
            
            % --- Find the objects that need to be turned off or on
            turnOff = obj.ctrOn > obj.onLifetime;
            turnOn  = obj.ctrOff > obj.offLifetime;
            
            % --- check hold status
            heldIx = obj.ctrHold >= obj.holdDuration;
            if any(heldIx)
                pds.behavior.reward.give(p);
                obj.initObjects(p, heldIx); % re-initialize objects that have been held
                obj.ctrHold(:) = 0;      % reset all objects hold counters
                % m.ctrHold(heldIx) = 0;
            end

            
            % --- flip states
            turnOff = turnOff | heldIx;
            turnOn  = turnOn & ~heldIx;
            
            obj.ctrOn(turnOff) = nan;
            obj.ctrOff(turnOff) = 1;
            obj.alpha(turnOff)  = 0;
            
            obj.ctrOff(turnOn) = nan;
            obj.ctrOn(turnOn)  = 1;
            obj.alpha(turnOn)  = 1;
            
            obj.alpha(obj.alpha > 0) = min(obj.maxContrast, (obj.maxContrast/obj.appearTau) * obj.ctrOn(obj.alpha > 0));

            obj.objects.alpha    = obj.alpha;
            
            obj.objects.id       = obj.texid; 
            
        end
        
        % -----------------------------------------------------------------
        % Handles edges of active area
        function bounceOffWalls(obj, p)
            
            % --- Bounce of walls
            ii = obj.x >= p.trial.display.dWidth/2; % if x position (deg) > width of screen/2 (deg)
            obj.dx(ii) = -obj.dx(ii);
            obj.x(ii)  = p.trial.display.dWidth/2 - abs(obj.dx(ii)); % repulse
            
            ii = obj.x <= -p.trial.display.dWidth/2;
            obj.dx(ii) = -obj.dx(ii);
            obj.x(ii)  = -p.trial.display.dWidth/2 + abs(obj.dx(ii)); % repulse
            
            ii = obj.y > p.trial.display.dHeight/2;
            obj.dy(ii) = -obj.dy(ii);
            obj.y(ii)  = p.trial.display.dHeight/2 - abs(obj.dy(ii)); % repulse
            
            ii = obj.y < -p.trial.display.dHeight/2;
            obj.dy(ii) = -obj.dy(ii);
            obj.y(ii)  = -p.trial.display.dHeight/2 + abs(obj.dy(ii)); % repulse
            
        end
        
        % -----------------------------------------------------------------
        % Checks if is held
        function isheld(obj, p)
            % check if the object is
            
            % get the eye position in degrees (relative to the center of
            % screen)
            xDeg =  (p.trial.eyeX - p.trial.display.ctr(1)) / p.trial.display.ppd;
            yDeg = -(p.trial.eyeY - p.trial.display.ctr(2)) / p.trial.display.ppd;
            
            % calculate the cartesian distance from each object
            dist = sqrt( (xDeg - obj.x).^2 + (yDeg - obj.y).^2 );
            
            % eliminate invisible faces
            dist(obj.alpha == 0) = inf;
            
            % find the objects that are being fixated. 
            iiHeld = dist < (obj.radius + obj.rewardWindow);
            
            % fixation boolean
            obj.isFixated = any(iiHeld);
            % position of fixated object
            obj.position  = [obj.xpx(iiHeld) obj.ypx(iiHeld)];
            
            % convert to +1 or -1
            iiHeld = (iiHeld - .5) * 2;
            
            % increment the counter by whether each object is held
            obj.ctrHold = obj.ctrHold + iiHeld;
            obj.ctrHold(obj.ctrHold < 0) = 0;

        end
        
        % -----------------------------------------------------------------
        % Calls screen calls
        function frameDraw(obj, p)

              obj.objects.frameDraw(p);
              
              obj.ctrOn  = obj.ctrOn + 1;
              obj.ctrOff = obj.ctrOff + 1;
                      
        end
        
            
    end % methods
    
end % classdef

