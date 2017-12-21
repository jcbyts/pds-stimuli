classdef vmdots < stimuli.dotsbase
  % Moving random dot stimulus with von Mises distributed dot directions.
  %
  % This class generates random dot stimuli with dot directions drawn
  % form a von Mises distribution with specified bandwidth.
  %
  % Rendering the dots is handled by the parent class @dotsbase
  % which provides properties and methods applicable to all moving dot
  % stimuli. Type 'help stimuli.dotsbase' for supported arguments.
  %
  % This class constructor can be called with one additional
  % arguments:
  %  
  %   k - concentration parameter (~1/variance) of the von Mises
  %       distribution (default: 0.0; produces a uniform distribution)

  % 2017-06-04 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties (Access = public),
    k@double; % concentration (~1/variance) of the von Mises distribution
  end
      
  methods (Access = public)
    function o = vmdots(winPtr,varargin)
      % initialise input parser
      args = varargin;
      p = inputParser;
      p.KeepUnmatched = true;
      p.StructExpand = true;
      p.addParameter('k',0.0,@(x) isscalar(x) && isreal(x)); % 0.0 produces a uniform distribution?
      
      p.parse(args{:});
      
      % pass unmatched name-value arguments to the parent constructor
      o = o@stimuli.dotsbase(winPtr,p.Unmatched);

      args = p.Results;
    
      o.k = args.k;
    end
    
    function initDots(o,idx)
      % initialises position (x,y) and per frame displacement (dx,dy)
      % for the dots specified by idx
      
      n = length(idx); % the number of dots to (re-)place
      
      o.frameCnt(idx) = o.lifetime; % default: Inf, see @dotsbase
      
      % dot positions (polar coordinates, r and th)
      r = sqrt(rand(n,1).*o.maxRadius.*o.maxRadius); % pixels
      th = rand(n,1).*360.0; % deg.
      
      % convert r and theta to x and y
      [x,y] = pol2cart(th.*(pi/180.0),r);
      o.x(idx) = x;
      o.y(idx) = y;
                    
      % set displacements (dx and dy) for each dot (note: rand(n,1))
      phi = vmrand(0.0,o.k,n,1); % radians
          
      direction = o.direction.*(pi/180) + phi; % radians
      [dx, dy] = pol2cart(direction,o.speed);
      o.dx(idx) = dx;
      o.dy(idx) = dy;      
    end
  end % methods
  
  methods (Static)
    function hw = k2hw(k)
      % convert k to half-width (deg.)
      hw = rad2deg(acos(log(0.5)./k + 1));
    end
    
    function k = hw2k(hw)
      % convert half-width (deg.) to k
      k = log(0.5)./(cos(deg2rad(hw)) - 1);
      
      if isinf(k)
        k = 0.0;
      end % divide by zero...
    end
  end % static methods
end % classdef
