classdef dots < handle
  % Matlab class for drawing a patch of random dots.
  %
  % The class constructor can be called with a range of arguments:
  %
  %   size       - dot size (pixels)
  %   speed      - dot speed (pixels/frame),
  %   direction  - radians
  %   numDots    - number of dots
  %   mode       - 0: proportion
  %                1: distribution
  %   coherence  - dot coherence (0-1) (mode = 0)
  %   dist       - 0: gaussian (mode = 1)
  %                1: uniform (mode = 1)
  %   bandwdth   - width of gaussian/uniform noise (mode = 1)
  %   lifetime   - limit of dot lifetime (frames)
  %   minRadius  - minimum radius of aperture (pixels)
  %   maxRadius  - maximum radius of aperture (pixels)
  %   position   - aperture position (x,y; pixels)
  
  % 14-06-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties (Access = public),
    size@double; % pixels
    speed@double; % pixels/s
    direction@double; % radians (?)
    numDots@double;
    coherence@double; % pcnt coherence (0-1)
    mode@double; % 0 = proportion, 1 = distribution
    dist@double; % 0 = gaussian, 1 = uniform
    bandwdth@double; % width of gaussian/uniform noise.
    lifetime@double; % dot lifetime (frames)
%     minRadius@double; % minimum radius (pixels)
    truncateGauss = -1;
    maxRadius@double; % maximum radius (pixels)
    position@double; % aperture position (x,y; pixels)
    colour@double;
  end
    
  properties (Access = public) %private)
    % polar ocordinates (relative to center of aperture)
    radius; % deg.
    theta;  % deg.

    % cartessian coordinates (relative to center of aperture?)
    x; % x coords (pixels)
    y; % y coords (pixels)
    
    % cartesian displacements
    dx; % pixels per frame?
    dy; % pixels per frame?
    
    % frames remaining
    frameCnt;
  end
    
  properties (Access = private)
    winPtr; % ptb window
  end
  
  methods (Access = public)
    function o = dots(winPtr,varargin)
      o.winPtr = winPtr;
      
      if nargin == 1,
        return
      end

      % initialise input parser
      args = varargin;
      p = inputParser;
%       p.KeepUnmatched = true;
      p.StructExpand = true;
      p.addParameter('size',10.0,@double); % pixels?
      p.addParameter('speed',0.2,@double); % deg./s
      p.addParameter('direction',0.0,@(x) isscalar(x) && isreal(x)); % deg.
      p.addParameter('numDots',50,@(x) ceil(x));

      p.addParameter('mode',0,@(x) any(ismember(x,[0, 1]))); % 0 = proportion, 1 = distribution      

      % mode = 0
      p.addParameter('coherence',1.0,@(x) isscalar(x) && isreal(x)); % 0..1
      
      % mode = 1
      p.addParameter('dist',0,@(x) any(ismember(x,[0, 1]))); % 0 = gaussian, 1 = uniform
      p.addParameter('bandwdth',20.0,@(x) isscalar(x) && isreal(x)); % bandwidth (deg.)

      
      p.addParameter('lifetime',Inf,@double);

%       p.addParamValue('minRadius',0.0,@double); % deg.?
      p.addParameter('maxRadius',10.0,@double);

      p.addParameter('position',[0.0,0.0],@(x) isvector(x) && isreal(x)); % [x,y] (pixels)
                  
      p.addParameter('colour',zeros(1,3),@double);
      try
        p.parse(args{:});
      catch
        warning('Failed to parse name-value arguments.');
        return;
      end
      
      args = p.Results;
    
      o.size = args.size;
      o.speed = args.speed;
      
      o.direction = args.direction;
      
      o.numDots = args.numDots;

      o.mode = args.mode;
      o.coherence = args.coherence;
      o.dist = args.dist;
      o.bandwdth = args.bandwdth;

      o.truncateGauss = -1; % multiples of std. dev. (i.e., o.bw)
      
      o.lifetime = args.lifetime;
      
      o.maxRadius = args.maxRadius;
      
      o.position = args.position;
      o.colour=args.colour;
    end
        
    function beforeTrial(o)
      o.initialize([1:o.numDots]); % all dots!
      
      % initialise dots' lifetime
      if o.lifetime ~= Inf,
        o.frameCnt = randi(o.lifetime,o.numDots,1); % 1:numDots
      else
        o.frameCnt = inf(o.numDots,1);
      end
    end
    
        
    function update(o)
      % decrement frame counters
      o.frameCnt = o.frameCnt - 1;
      o.move();
    end
    
  end % methods
    
  methods (Access = public)        
    function initialize(o,idx)
      % initialises dot positions
      n = length(idx); % the number of dots to (re-)place
      
      o.frameCnt(idx) = o.lifetime; % default: Inf
      
      % dot positions (polar coordinates, r and theta) - store this?
      r = sqrt(rand(n,1).*o.maxRadius.*o.maxRadius); % pixels
      th = rand(n,1).*360.0; % deg.
      
      % convert r and theta to x and y
       [o.x(idx),o.y(idx)] = pol2cart(th.*(pi/180.0),r);
                    
      % set displacements (dx and dy) for each dot
      [o.dx(idx),o.dy(idx)] = pol2cart(o.direction.*(pi/180),o.speed);
      
      switch o.mode,
        case 0, % proportion of dots
          if o.coherence == 1.0,
            return;
          end
          
          nc = ceil(o.coherence*o.numDots); % the number of dots moving coherently
          
          % set displacements for the dots moving incoherently
          idx_ = idx(idx > nc);
          if o.coherence == 0.0 || ~isempty(idx_),
            tmpdirection = rand(sum(idx_)).*360.0; % deg.

            [o.dx(idx_),o.dy(idx_)] = pol2cart(tmpdirection*(pi/180),o.speed);
          end
                            
        case 1, % directions sampled from some distribution
          switch o.dist,
            case 0,  % gaussian
              phi = o.bandwdth.*randn(n,1);
              if o.truncateGauss ~= -1
                a = abs(o.direction/o.bandwdth) > o.truncateGauss;
                while max(a),
                  phi(a) = o.bandwdth.*randn(sum(a),1);
                  a = abs(phi(idx)/o.bandwdth) > o.truncateGauss;
                end
              end
            case 1, % uniform
              phi = o.bandwdth.*rand(n,1) - o.bandwdth/2;
            otherwise
              error('Unknown noiseDist');
          end
          
          tmpdirection = o.direction + phi;
          [dx, dy] = pol2cart(tmpdirection.*(pi/180),o.speed);
          o.dx(idx) = dx;
          o.dy(idx) = dy;
          
        otherwise
          error('Unknown noiseMode');    
      end
      
      
    end
                
    function move(o)
      % calculate future position
      x = o.x + o.dx;
      y = o.y + o.dy;
      
      r = sqrt(x.^2 + y.^2);
      idx = find(r > o.maxRadius); % dots that have exited the aperture
         
      o.x = x;
      o.y = y;
      
      if ~isempty(idx),
        % (re-)place the dots on the other side of the aperture
        [th,~] = cart2pol(o.dx(idx),o.dy(idx));
        [xx, yy] = o.rotate(o.x(idx),o.y(idx),-1*th);
        chordLength = 2*sqrt(o.maxRadius^2 - yy.^2);
        xx = xx - chordLength;
        [o.x(idx), o.y(idx)] = o.rotate(xx,yy,th);
      end
      
      idx = find(o.frameCnt == 0); % dots that have exceeded their lifetime
      
      if ~isempty(idx),
%         fprintf(1,'%i dots expired\n',length(idx));
        % (re-)place dots randomly within the aperture
        o.initialize(idx);
      end
    end
    
    function draw(o)
      % dotType:
      %
      %   0 - square dots (default)
      %   1 - round, anit0aliased dots (fvour performance)
      %   2 - round, anti-aliased dots (favour quality)
      %   3 - round, anti-aliased dots (built-in shader)
      %   4 - square dots (built-in shader)
      dotType = 1;
      Screen('DrawDots',o.winPtr,[o.x(:), -1*o.y(:)]', o.size, o.colour, o.position, dotType);

%       if 0,
%         plot(o.x+o.position(1),o.y+o.position(2),'o');
%         axis equal;
%         axis([-1, 1, -1, 1]*20);
%       end
    end
  end % methods
  
  methods (Static)
    function [xx, yy] = rotate(x,y,th)
      % rotate (x,y) by angle th

      for ii = 1:length(th),
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
