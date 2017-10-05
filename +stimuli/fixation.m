classdef fixation < handle
  % Matlab class for drawing fixation target(s) using the psych. toolbox.
  %
  % The fixation target consists of a central circular target and a
  % concentric circular surround (usually contrasting). The size and colour
  % of both the centre and surround can be configured independently.
  %
  % The class constructor can be called with a range of arguments:
  %
  %   centreSize - diameter of centre (pixels)
  %   surroundRadius - diameter of surround (pixels)
  %   centreColour - colour of centre (clut index or [r,g,b])
  %   surroundColour - colour of surround (clut index or [r,g,b])
  %   position - center of target (x,y; pixels)
  
  % 16-06-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties (Access = public),
    cSize@double = 2; % pixels
    sSize@double = 4; % pixels
    cColour@double = zeros([1,3]); % clut index or [r,g,b]
    sColour@double = ones([1,3]);
    position@double = [0.0, 0.0]; % [x,y] (pixels)
  end
        
  properties (Access = private)
    winPtr; % ptb window
  end
  
  methods (Access = public)
    function o = fixation(winPtr,varargin) % marmoview's initCmd?
      o.winPtr = winPtr;
      
      if nargin == 1
        return
      end

      % initialise input parser
      args = varargin;
      p = inputParser;
%       p.KeepUnmatched = true;
      p.StructExpand = true;
      p.addParameter('centreSize',o.cSize,@isfloat); % pixels
      p.addParameter('surroundSize',o.sSize,@isfloat);
      p.addParameter('centreColour',o.cColour,@isfloat); % clut index or [r,g,b]
      p.addParameter('surroundColour',o.sColour,@isfloat);
      p.addParameter('position',o.position,@isfloat); % [x,y] (pixels)
                  
      try
        p.parse(args{:});
      catch
        warning('Failed to parse name-value arguments.');
        return;
      end
      
      args = p.Results;
    
      o.cSize       = args.centreSize;
      o.sSize       = args.surroundSize;
      o.cColour     = args.centreColour;
      o.sColour     = args.surroundColour;
      o.position    = args.position;
    end
        
    function beforeTrial(o)
    end
    
    function beforeFrame(o)
      o.drawFixation();
    end
        
    function afterFrame(o)
    end
  end % methods
    
  methods (Access = public)        
    function drawFixation(o)
        
      r = floor(o.cSize*5);
      
      rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
      col = -1*[1 1 1]; %
      Screen('FillOval',o.winPtr,col,rect');
      
      rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
      col = +1*[1 1 1]; %floor( (o.sColour + o.cColour)/2 ); %-1*[1 1 1]; %
      Screen('FillOval',o.winPtr,col,rect');
      
     
           
      r = floor(o.sSize./2); % radius in pixels
      
      rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
      Screen('FillOval',o.winPtr,o.sColour,rect');

      r = floor(o.cSize./2);
      
      rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
      Screen('FillOval',o.winPtr,o.cColour,rect');   
      
      
      
    end
  end % methods
  
end % classdef
