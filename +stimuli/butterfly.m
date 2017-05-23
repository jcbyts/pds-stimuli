classdef butterfly < handle
    % MOTION OBJECT Summary of this class goes here
    %   Call by passing in a pldaps and the number of objects
    %   m=MotionOject(pldapsObject, Num, varargin)
    %   
    %   All arguments can be vectorized and if they are, must be size Num
    properties (Access = public)
        ptr                     % pointer to PTB display
        hReward                 % reward class
        N@double                % number of motion objects
        radius@double           % array of object sizes
        
        visible@logical         % visible or not
        type                    % stimulus type (1: face, 2: grating)
        
        speed@double            % array of speeds
        direction@double        % array of directions
        x@double                % x location (degrees)
        y@double                % y location (degrees)

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
        motionType              % governs movement 


        % --- parameters governing the appearance of objects
        objects
        texid
        
        
        rotAngles
        rotate@logical
        
        colorThresh
        color

        
        winRect

        maxradius
        removed
    end
    
    properties (Access = private)
        dWidth % display width
        dHeight
        pWidth
        pHeight
        
        ifi % inter frame interval (1/framerate)
        ppd
        ctr
        
        % --- object parameters
        dx@double               % x velocity
        dy@double               % y velocity
        xpx@double              % x location (pixels)
        ypx@double              % y location (pixels)
        
        % --- texture info
        dstRects
        srcRect
    end
    
    methods
        % --- Contstructor make motion objects
        function m=butterfly(p, N, varargin)
            % m=MotionOject(pldapsObject, Number, varargin)
            % Since we're setting most of the parameters here, we don't
            % need to parse a lot of arguments. Let's just set it up
            
            % --- Save all important pldaps variables
            m.ptr       = p.trial.display.ptr;
            
            m.hReward   = stimuli.reward(p); % object that handles the reward delivery
            
            % size of the display
            m.dWidth    = p.trial.display.dWidth;
            m.dHeight   = p.trial.display.dHeight;
            m.pWidth    = p.trial.display.pWidth;
            m.pHeight   = p.trial.display.pHeight;
            
            % variables for converting units
            m.ppd       = p.trial.display.ppd;
            m.ctr       = p.trial.display.ctr;
            m.ifi       = p.trial.display.ifi;
            
            m.N=N; % number
            
            ip=inputParser();
            ip.addParameter('type', 'face')
            
            % --- parameters for the appearance behavior
            ip.addParameter('appearDist', 'gaussian')
            ip.addParameter('appearGazeCont', false)
            ip.addParameter('appearRangePar', 5)
            ip.addParameter('appearCenter', [0 0])
            ip.addParameter('appearTau', 10)
            ip.addParameter('maxContrast', .3)
            
            % --- parameters for movement behavior
            ip.addParameter('motionType', 'linear')
            ip.addParameter('speed', 0)
            ip.addParameter('radius', 1)
            ip.addParameter('onLifetime', 60)
            ip.addParameter('offLifetime', 120)
          
            % --- parameters for general appearance
            
            
            ip.parse(varargin{:}); % parse optional inputs
            
            m.type        = ip.Results.type;
            m.motionType  = ip.Results.motionType;
            m.onLifetime  = ip.Results.onLifetime;
            m.offLifetime = ip.Results.offLifetime;
            m.maxContrast = ip.Results.maxContrast;
            
            switch m.type
                case {1, 'face', 'Face'}
                    m.objects = stimuli.face(p);
                case {2, 'grating', 'Grating'}
                    m.objects = stimuli.gratings(p);
                otherwise

            end

            m.direction         = rand(1,m.N)*360;
            
            m.appearDist        = ip.Results.appearDist;
            m.appearGazeCont    = ip.Results.appearGazeCont;
            m.appearRangePar    = ip.Results.appearRangePar;
            m.appearCenter      = ip.Results.appearCenter;
            m.appearTau         = ip.Results.appearTau;

            m.visible=false(1,m.N);
            
            m.radius(1:m.N) = ip.Results.radius;
            m.speed(1:m.N)  = ip.Results.speed;

            m.color         = ones(3,m.N);
            m.colorThresh   = 40;
            
            m.alpha         = rand(1,m.N)*2*pi; % faces appear gradually
            
            m.rotAngles     = zeros(1,m.N);
            m.ctrHold       = zeros(1,m.N);
            m.ctrOn         = randi(m.onLifetime,1,m.N);
            m.ctrOff        = randi(m.offLifetime,1,m.N);
            
            idx = m.ctrOn > m.ctrOff;
            m.ctrOff(idx) = nan;
            m.ctrOn(~idx) = nan;
            
            % initialize objects
            m.initObjects(1:m.N);
            
            
        end % constructor

        function initObjects(m, idx)

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
                    genX = @(n) (rand(1,n) - 0.5) * m.appearRangePar + m.appearCenter(1);
                    genY = @(n) (rand(1,n) - 0.5) * m.appearRangePar + m.appearCenter(2);
                case 'gaussian'
                    genX = @(n) randn(1,n) * m.appearRangePar + m.appearCenter(1);
                    genY = @(n) randn(1,n) * m.appearRangePar + m.appearCenter(2);
                otherwise
                    m.appearDist = 'uniform';
                    genX = @(n) (rand(1,n) - 0.5) * m.appearRangePar + m.appearCenter(1);
                    genY = @(n) (rand(1,n) - 0.5) * m.appearRangePar + m.appearCenter(2);
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
            

            m.direction(idx)  = rand(1,n)*360;
           
            % initialize variables
            m.texid(idx)    = randi(m.objects.numTex, 1, n);
            
            m.color(:,idx)       = ones(3,n);
            m.colorThresh(idx)   = 40;
            
            m.alpha(idx)         = rand(1,n)*2*pi; % faces appear gradually
            m.rotAngles(idx)     = zeros(1,n);
            m.ctrHold(idx)       = zeros(1,n);
            
            m.dx(idx) = cosd(m.direction(idx)) .* m.speed(idx) .* m.ifi;
            m.dy(idx) = sind(m.direction(idx)) .* m.speed(idx) .* m.ifi;
            
            
        end % initialize locations


        % -----------------------------------------------------------------
        % General move function
        function move(m)
            
            m.dx = cosd(m.direction) .* m.speed .* m.ifi;
            m.dy = sind(m.direction) .* m.speed .* m.ifi;
            
            m.bounceOffWalls()
           
            % --- Translate position
            switch m.motionType
                
                case 'linear'
                    
                    m.x = m.x + m.dx;
                    m.y = m.y + m.dy;
                case 'randomwalk'
                    m.dx = m.dx + randn(1,m.N) .* m.speed * m.ifi;
                    m.dy = m.dy + randn(1,m.N) .* m.speed * m.ifi;
                    m.x = m.x + m.dx;
                    m.y = m.y + m.dy;
            end
            
            % --- update speed and direction
            th = cart2pol(m.dx, m.dy);
            m.direction = th/pi*180; 
           
            % --- update objects
            m.update();
        end
        
        function update(m)
            
           % --- update objects
            m.objects.position = [m.ppd*m.x(:) + m.ctr(1) -m.ppd*m.y(:) + m.ctr(2)];
            m.objects.size     = repmat(2*m.radius(:)*m.ppd,1,2);
            
            % --- turn off
            turnOff = m.ctrOn > m.onLifetime;
            turnOn  = m.ctrOff > m.offLifetime;
            
            m.ctrOn(turnOff) = nan;
            m.ctrOff(turnOff) = 0;
            m.alpha(turnOff)  = 0;
            
            m.ctrOff(turnOn) = nan;
            m.ctrOn(turnOn)  = 0;
            m.alpha(turnOn)  = 1;
            
            m.alpha(m.alpha > 0) = max(m.maxContrast, (m.maxContrast/m.appearTau) * m.ctrOn(m.alpha > 0));

            m.objects.alpha    = m.alpha;
            
            m.objects.id       = m.texid; 
            
            heldIx = m.ctrHold >= 10;
            if any(heldIx)
                m.hReward.give();
                m.initObjects(heldIx);
            end
            m.ctrHold(heldIx) = 0;
        end
        
        % -----------------------------------------------------------------
        % Handles edges of active area
        function bounceOffWalls(m)
            
             % --- Bounce of walls
            ii = m.x >= m.dWidth/2;
            m.dx(ii) = -m.dx(ii);
            m.x(ii)  = m.dWidth/2 - abs(m.dx(ii)); % repulse
            
            ii = m.x <= -m.dWidth/2;
            m.dx(ii) = -m.dx(ii);
            m.x(ii)  = -m.dWidth/2 + abs(m.dx(ii)); % repulse
            
            ii = m.y > m.dHeight/2;
            m.dy(ii) = -m.dy(ii);
            m.y(ii)  = m.dHeight/2 - abs(m.dy(ii)); % repulse
            
            ii = m.y < -m.dHeight/2;
            m.dy(ii) = -m.dy(ii);
            m.y(ii)  = -m.dHeight/2 + abs(m.dy(ii)); % repulse
            
        end
        
        % -----------------------------------------------------------------
        % Checks if is held
        function isheld(m, xy)
            
            xDeg=(xy(1) - m.ctr(1)) / m.ppd;
            yDeg=-(xy(2) - m.ctr(2)) / m.ppd;
            
            dist=sqrt((xDeg - m.x).^2 + (yDeg - m.y).^2);
            
            iiHeld = ((dist < m.radius*2) - .5) * 2;
            
            m.ctrHold = m.ctrHold + iiHeld;
            m.ctrHold(m.ctrHold < 0) = 0;
            
        end
        
        % -----------------------------------------------------------------
        % Calls screen calls
        function draw(m)

              m.objects.drawTextures();
              
              m.ctrOn  = m.ctrOn + 1;
              m.ctrOff = m.ctrOff + 1;
                      
        end
        
            
    end % methods
    
end % classdef

