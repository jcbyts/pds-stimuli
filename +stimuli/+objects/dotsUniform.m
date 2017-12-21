classdef dotsUniform < stimuli.objects.dotsbase
    % Moving random dot stimulus with uniformly distributed dot directions.
    %
    % This class generates random dot stimuli with dot directions drawn
    % form a uniform distribution of the specified range/width.
    %
    % Rendering the dots is handled by the parent class @dotsbase
    % which provides properties and methods applicable to all moving dot
    % stimuli. Type 'help stimuli.dotsbase' for supported arguments.
    %
    % This class constructor can be instantiated with one additional
    % arguments:
    %
    %   range   - range/width of the uniform noise distribution
    
    
    properties (Access = public),
        range@double; % range/width of uniform distribution
    end
    
    methods (Access = public)
        function o = dotsUniform(varargin)
            
            % initialise input parser
            args = varargin;
            ip = inputParser;
            ip.KeepUnmatched = true;
            ip.StructExpand  = true;
            ip.addParameter('range',0.0,@(x) isscalar(x) && isreal(x)); % bandwidth (deg.)
            
            ip.parse(args{:});
            
            % pass unmatched name-value arguments to the parent constructor
            nextargs = [fieldnames(ip.Unmatched) struct2cell(ip.Unmatched)]';
            
            o = o@stimuli.objects.dotsbase(nextargs{:});
            
            args = ip.Results;
            o.range = args.range;
        end
        
        function initDots(o,idx)
            % overloads the initDots method
            % initialises position (x,y) and per frame displacement (dx,dy)
            % for the dots specified by idx
            
            n = length(idx); % the number of dots to (re-)place
            
            o.frameCnt(idx) = o.dotLifetime; % default: Inf, see @dotsbase
            
            % dot positions (polar coordinates, r and th)
            r  = sqrt(rand(o.rng,n,1) * o.radius * o.radius); % pixels
            th = rand(o.rng,n,1) * 360; % deg.
            
            % convert r and theta to x and y
            [x,y] = pol2cart(th * (pi/180),r);
            o.x(idx) = x;
            o.y(idx) = y;
            
            % set displacements (dx and dy) for each dot (note: rand(n,1))
            phi = o.range.*rand(o.rng, n, 1) - o.range/2;
            
            direction = o.dotDirection + phi;
            [dx, dy]  = pol2cart(direction * (pi/180), o.dotSpeed);
            o.dx(idx) = dx;
            o.dy(idx) = dy;
        end
    end % methods
end % classdef
