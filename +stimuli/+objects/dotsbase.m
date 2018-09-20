classdef dotsbase < stimuli.objects.target % (Abstract) % should this be abstract
    % Abstract class for drawing a circular patch of moving dots.
    %
    % The class constructor can be called with a number of arguments:
    %
    %   dotSize    - dot size (pixels)
    %   speed      - dot speed (pixels/frame),
    %   direction  - degrees
    %   numDots    - number of dots
    %   dotLifetime   - limit of dot dotLifetime (frames)
    %   minRadius  - minimum radius of aperture (pixels; not implemented yet)
    %   radius  - maximum radius of aperture (pixels)
    %   position   - aperture position (x,y; pixels)
    %   colour     - dot colour (RGB)
    %   visible    - flag to toggle dot visibility (default: true)
    %
    % Methods
    % trialSetup(p)
    % frameUpdate(p)
    % frameDraw(p)
    
    % 2017-06-04 - Shaun L. Cloherty <s.cloherty@ieee.org>
    
    properties (Access = public),
        radius@double       = 150;  % pixels TODO: should this be deg
        speed@double     = 2;    % pixels/s
        direction@double = 0;    % deg.
        dotSize@double      = 2;    % pixels (radius?)
        
        color@double     = zeros(1,3); % [r,g,b] or clut index
        lifetime@double  = inf; % dot dotLifetime (frames)
        numDots@double      = 50;
        
        dotType@double      = 1;    % anti-aliased dots
        useOverlay          = true;
        % dotType:
        %
        %   0 - square dots (default)
        %   1 - round, anit-aliased dots (favour performance)
        %   2 - round, anti-aliased dots (favour quality)
        %   3 - round, anti-aliased dots (built-in shader)
        %   4 - square dots (built-in shader)
        
        % cartessian coordinates (relative to center of aperture?)
        x % x coords (pixels)
        y % y coords (pixels)
        
        % cartesian displacements
        dx % pixels per frame?
        dy % pixels per frame?
    end
    
    properties (GetAccess = public, SetAccess = protected)
        
        
        % frames remaining
        frameCnt
    end
    
    properties (Access=private)
       drawCnt
    end
    
    
    methods (Access = public)
        function o = dotsbase(varargin)
            
            o = o@stimuli.objects.target(varargin{:});
            
            o.drawCnt = 0;
            
            if nargin < 2
                return
            end
            
            % initialise input parser
            args = varargin;
            ip = inputParser;
            ip.StructExpand = true;
            ip.addParameter('dotSize',     o.dotSize,      @double);
            ip.addParameter('speed',    o.speed,     @double);
            ip.addParameter('direction',o.direction, @(x) isscalar(x) && isreal(x)); % deg.
            ip.addParameter('lifetime', o.lifetime,  @double);
            ip.addParameter('color',    o.color,     @double);
            ip.addParameter('numDots',     o.numDots,      @(x) ceil(x));
            ip.addParameter('radius',      o.radius,       @double); % deg.
            ip.addParameter('position',    o.position,     @(x) isvector(x) && isreal(x)); % [x,y] (pixels)
            
            try
                ip.parse(args{:});
            catch
                warning('Failed to parse name-value arguments.');
                return
            end
            
            args = ip.Results;
            fields = fieldnames(args);
            for iParam = 1:numel(fields)
                o.(fields{iParam}) = args.(fields{iParam});
            end
            
        end
        
        function trialSetup(o, ~, ~)
            
            o.initDots(1:o.numDots); % <-- provided by the derived class
            
            % initialise frame counts for limited dotLifetime dots
            if o.lifetime ~= Inf
                o.frameCnt = randi(o.rng, o.lifetime,o.numDots,1); % 1:numDots
            else
                o.frameCnt = inf(o.numDots,1);
            end
            o.drawCnt = 1;
        end
        
        function frameDraw(o,p,~)
            
            if ~o.stimValue
                return
            end
            
            if o.useOverlay
                % Draw Dots
                Screen('DrawDots',p.trial.display.overlayptr,[o.x(:), -1*o.y(:)]', o.dotSize, o.color, o.position, o.dotType);
            else
                Screen('BlendFunction', p.trial.display.ptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawDots',p.trial.display.ptr,[o.x(:), -1*o.y(:)]', o.dotSize, o.color, o.position, o.dotType);
                Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
            end
%             disp(o.drawCnt)
            o.drawCnt = o.drawCnt + 1;
        end
        
        function frameUpdate(o, ~,~)
            
            % decrement frame counters
            o.frameCnt = o.frameCnt - 1;
            
            o.moveDots(); % provided by the derived class? maybe not...
        end
        
        function moveDots(o,~)
            % calculate future position
            o.x = o.x + o.dx;
            o.y = o.y + o.dy;
            
            r = sqrt(o.x.^2 + o.y.^2);
            idx = find(r > o.radius); % dots that have exited the aperture
            
            if ~isempty(idx)
                % (re-)place the dots on the other side of the aperture
                [th, ~]   = cart2pol(o.dx(idx),o.dy(idx));
                [xx, yy] = o.rotate(o.x(idx),o.y(idx),-1*th);
                chordLength = 2*sqrt(o.radius^2 - yy.^2);
                xx = xx - chordLength;
                [o.x(idx), o.y(idx)] = o.rotate(xx,yy,th);
            end
            
            idx = find(o.frameCnt == 0); % dots that have exceeded their dotLifetime
            
            if ~isempty(idx)
                % (re-)place dots randomly within the aperture
                o.initDots(idx);
            end
        end
        
        function [x,y] = regenerateDots(o)
            warning('dotsbase/regenerateDots: assumes that trialSetup was followed by frameUpdate before the first draw')
            nFrames = o.drawCnt;
            
            % reset random number generator
            o.rng.reset();
            o.trialSetup();
            x = {};
            y = {};
            for i = 1:nFrames
                o.frameUpdate();
                x{i} = o.x;
                y{i} = o.y;
            end
            
        end
        
        % initialize position (x,y) and frame displacement (dx,dy) for each dot
        initDots(o,idx); % abstract method
    end % methods
    
    methods (Static)
        function [xx, yy] = rotate(x,y,th)
            % rotate (x,y) by angle th
            
            n = length(th);
            
            xx = zeros([n,1]);
            yy = zeros([n,1]);
            
            for ii = 1:n
                % calculate rotation matrix
                R = [cos(th(ii)) -sin(th(ii)); ...
                    sin(th(ii))  cos(th(ii))];
                
                tmp = R * [x(ii), y(ii)]';
                xx(ii) = tmp(1,:);
                yy(ii) = tmp(2,:);
            end
        end
    end % methods
end % classdef
