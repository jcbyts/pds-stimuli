classdef fixation < stimuli.target
  % FIXATION is a class for drawing fixation points in PLDAPS
  %
  % The fixation target consists of a central circular target and a
  % concentric circular surround (usually contrasting). The size and colour
  % of both the centre and surround can be configured independently.
  %
  % The class constructor can be called with a range of arguments:
  %
  %   <strong> position     </strong>     - center of the target (x,y; pixels)
  %   <strong> radius    </strong>     - radius of surround (pixels)
  %   <strong> winRadius </strong>     - radius of the fixation window 
  %   <strong> color     </strong>     - color of fixation point (clut index or [r,g,b])
  %   <strong> ctrColor  </strong>  (optional) color of fixation point center (clut index or [r,g,b])
  %   <strong> winColour </strong>  (optional) color of fixation window (clut index or [r,g,b])
  %
  % e.g., 
  %     targ = <strong>stimuli.fixation</strong>('position', [960 540], 'radius', 10)
  %
  %     targ = <strong>stimuli.fixation</strong>('position', p.trial.display.ctr(1:2), ...
  %             'radius', 0.5*p.trial.display.ppd, ...
  %             'winRadius', 1.5*p.trial.display.ppd, ...
  %             'color', [1 1 1], ...
  %             'ctrColor', [0 0 0], ...
  %             'winColor', p.trial.display.clut.bg_white);
  % 
  % The class has a number of useful properties and methods
  %   isFixated 
  %         is a flag for whether the fixation point is fixated currently
  %         fixlog(end) tells the time of the last fixation state change
  %
  %   e.g., 
  %     if targ.isFixated
  %         fixEntered = targ.fixlog(end);
  %         fixDuration = GetSecs - fixEntered;
  %     end
  % 
  %  frameUpdate()
  %         method that updates the status of isFixated. Should be called
  %         every trial during the frameUpdate state
  %         requires an active PDLAPS as input
  %     e.g., 
  %         targ.frameUpdate(p)
  %
  %  frameDraw()
  %         method for drawing the fixation point and windows
  %         requires an active PDLAPS as input
  %     e.g., 
  %         targ.frameDraw(p)
  
  properties (Access = public),
    radius@double = 5; % pixels
    color@double  = ones(1,3);
    ctrColor@double = -ones(1,3);
    wincolor
  end
  
  methods (Access = public)
      
      % --- Class constructor
      function o = fixation(varargin)
          
          o = o@stimuli.target(varargin{:}); % use parent constructor (inherits the properties and methods of TARGET)
          
          if nargin == 1
              return
          end
          
          % initialise input parser
          ip = inputParser;
          ip.StructExpand = true;
          ip.addParameter('radius', o.radius,   @isfloat); % pixels
          ip.addParameter('color',  o.color,    @isfloat); % color r,g,b triplet
          ip.addParameter('position',  o.position,    @isfloat); % [x,y] (pixels)
          
          try
              ip.parse(varargin{:});
          catch
              warning('Failed to parse name-value arguments.');
              return;
          end
          
          args = ip.Results;
          
          o.radius      = args.radius;
          o.color       = args.color;
          o.position    	= args.position;
      end
      
      
      function frameDraw(o,p)
          % draw the fixation point and fixation windows
          
          if nargin < 2
              warning('needs a pldaps to run')
              return
          end
          
          if ~o.stimValue % check if the stimulus should be shown
              return
          end
          
          
          r = o.radius; % radius in pixels
          
          rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
          Screen('FillOval',p.trial.display.overlayptr, o.color,rect');
          
          r = o.radius/2; % radius in pixels
          
          rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
          Screen('FillOval',p.trial.display.overlayptr, o.ctrColor,rect');
          
          % draw the fixation window
          if ~isempty(o.wincolor)
              r = o.winRadius;
              rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
              Screen('FrameOval', p.trial.display.overlayptr, o.wincolor, rect');
%               Screen('FillOval',p.trial.display.overlayptr, o.wincolor,rect');
          end
          
      end
      
      function frameUpdate(o,p)
          % every frame update call, check the fixation status
          
          if nargin < 2
              warning('needs a pldaps to run')
              return
          end
          
          o.isHeld([p.trial.eyeX p.trial.eyeY])
      end
      
      function trialSetup(o,p)
      end
      
      function cleanup(o,p)
      end
    
  end % methods
    
  
end % classdef
