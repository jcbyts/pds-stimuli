classdef fixationRsvp < stimuli.face
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
    cSize@double = 10; % pixels
    sSize@double = 20; % pixels
    cColour@double = zeros([1,3]); % clut index or [r,g,b]
    sColour@double = ones([1,3]);
    switchRate@double = .1;
  end
          
  properties(Access = private)
     winPtr 
  end
  methods (Access = public)
    function o = fixationRsvp(p,varargin) % marmoview's initCmd?
        
        % --- Face Textures
        o = o@stimuli.face(p); % call the parent constructor
      
        o.winPtr = p.trial.display.ptr;
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
      o.radius      = o.cSize;
    end
        
    function beforeTrial(o)
    end
    
    function beforeFrame(o)
      o.drawFixation();
    end
        
    function afterFrame(o)
        
        if rand < o.switchRate
            o.id = randi(numel(o.texIds)+1)-1;
            if o.id>0
                o.id = o.texIds{o.id};
            else
                o.cColour = rand(1,3);
                o.sColour = 1-o.cColour;
            end
        end
        
        o.cSize = o.cSize + randn;
        o.sSize = o.sSize + randn;
                
    end
  end % methods
    
  methods (Access = public)        
    function drawFixation(o)
        
        if o.id == 0
            
            r = floor(o.sSize./2); % radius in pixels
            
            rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
            Screen('FillOval',o.winPtr,o.sColour,rect');
            
            r = floor(o.cSize./2);
            
            rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
            Screen('FillOval',o.winPtr,o.cColour,rect');
        else
            o.texSize = [o.cSize*2 o.cSize*2];
            o.drawTextures
        end
      
      
      
    end
  end % methods
  
end % classdef
