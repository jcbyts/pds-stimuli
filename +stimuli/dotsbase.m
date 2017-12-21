classdef dotsbase < stimuli.target % (Abstract) % should this be abstract
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
    
    % 2017-06-04 - Shaun L. Cloherty <s.cloherty@ieee.org>
    
    properties (Access = public),
        radius@double       = 150;  % pixels TODO: should this be deg
        dotSpeed@double     = 2;   % pixels/s
        dotDirection@double = 0;    % deg.
        dotSize@double      = 2;    % pixels (radius?)
        
        dotColor@double     = zeros(1,3); % [r,g,b] or clut index
        dotLifetime@double  = inf; % dot dotLifetime (frames)
        numDots@double      = 50;
        
        dotType@double      = 1;    % anti-aliased dots
        % dotType:
        %
        %   0 - square dots (default)
        %   1 - round, anit-aliased dots (favour performance)
        %   2 - round, anti-aliased dots (favour quality)
        %   3 - round, anti-aliased dots (built-in shader)
        %   4 - square dots (built-in shader)
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % cartessian coordinates (relative to center of aperture?)
        x % x coords (pixels)
        y % y coords (pixels)
        
        % cartesian displacements
        dx % pixels per frame?
        dy % pixels per frame?
        
        % frames remaining
        frameCnt
    end
    
    
    methods (Access = public)
        function o = dotsbase(varargin)
            
            o = o@stimuli.target(varargin{:});
            
            if nargin < 2
                return
            end
            
            % initialise input parser
            args = varargin;
            ip = inputParser;
            ip.StructExpand = true;
            ip.addParameter('dotSize',     o.dotSize,      @double);
            ip.addParameter('dotSpeed',    o.dotSpeed,     @double);
            ip.addParameter('dotDirection',o.dotDirection, @(x) isscalar(x) && isreal(x)); % deg.
            ip.addParameter('dotLifetime', o.dotLifetime,  @double);
            ip.addParameter('dotColor',    o.dotColor,     @double);
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
        
        function trialSetup(o, p)
            o.initDots(1:o.numDots); % <-- provided by the derived class
            
            % initialise frame counts for limited dotLifetime dots
            if o.dotLifetime ~= Inf
                o.frameCnt = randi(o.rng, o.dotLifetime,o.numDots,1); % 1:numDots
            else
                o.frameCnt = inf(o.numDots,1);
            end
        end
        
        function frameDraw(o,p)
            
            if ~o.stimValue
                return
            end
            
            % Draw Dots
            Screen('DrawDots',p.trial.display.overlayptr,[o.x(:), -1*o.y(:)]', o.dotSize, o.dotColor, o.position, o.dotType);
        end
        
        function frameUpdate(o, ~)
            
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
