classdef fixationImg < stimuli.objects.target
  % FIXATIONIMG is a class for drawing fixation points in PLDAPS
  %
  % fixationImg is a <strong> stimuli.target </strong>
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
	radius@double             = 5; % pixels
	color@double              = ones(1,3);
	ctrColor@double           = -ones(1,3);
	wincolor                  % pointer to clut. see: pldaps.display.clut.(color)
    imgDir                    % directory where the images live
	fileList                  % list of files to draw from
	contrast@double           = .5;         % contrast in range [-.5, .5]
    maskType@char             = 'circle';   % 'circle', 'guassian', 'tukey'
    noisesigma@double         = 20;         % pixels (noise of random walk)
    shrinkTimeConstant@double = .3;
  end
  
  properties (Access = private)
    
    % --- properties for image-scanning fixation point  
    tex         % pointer to PTB texture of the image
	mask        % pointer to PTB texture of the mask
    sz          % size of the mask (based on radius)
    srcrect     % rectangle indicating the size of the image
    cliprect    % rectangle for the clipped region of the image
    dstrect     % rectangle for the destination (of the image) on the screen
    maskrect    % rectangle for the destination (of the mask) on the screen
    xyclip      % random walk path of the mask/clipped region
    frameIter=1 % counter for tracking frames
  end
  
  methods (Access = public)
      
      % --- Class constructor
      function o = fixationImg(varargin)
          
          o = o@stimuli.objects.target(varargin{:}); % use parent constructor (inherits the properties and methods of TARGET)
          
          if nargin == 1
              return
          end
          
          % initialise input parser
          ip = inputParser;
          ip.StructExpand = true;
          ip.addParameter('radius',   o.radius,   @isfloat); % pixels
          ip.addParameter('color',    o.color,    @isfloat); % color r,g,b triplet
          ip.addParameter('position', o.position, @isfloat); % [x,y] (pixels)
          ip.addParameter('imgDir',   o.imgDir,   @isdir);
          ip.addParameter('fileList', o.fileList);
          ip.addParameter('rng',      o.rng);
          ip.addParameter('seed',     []);
          ip.addParameter('maskType', o.maskType, @ischar)
          
          try
              ip.parse(varargin{:});
          catch
              warning('Failed to parse name-value arguments.');
              return;
          end
          
          args = ip.Results;
          
          o.radius      = args.radius;
          o.color       = args.color;
          o.position    = args.position;
          o.maskType    = args.maskType;
          
        %------------------------------------------------------------------
        % Setup IMG directory
        if isempty(o.imgDir)
            cguipath = which('calibrationGUI');
            pathto = fileparts(cguipath);
            
            o.imgDir   = fullfile(pathto, 'Colony');
            if isempty(o.fileList)
                o.fileList = dir(fullfile(o.imgDir, '*.JPG'));
            end
        end
        
      end
      
      
      function trialSetup(o,p)
            
            blendFlag = strcmp(p.trial.display.destinationFactorNew, GL_ONE);
            
            % build mask
            r = o.radius*2; % mask radius parameter (pixels)
            o.mask = o.makeMask(r,o.maskType);
            o.sz = size(o.mask,1)*[1 1];
            
            % load up a random image
            I = imread(fullfile(o.imgDir, o.fileList(randi(o.rng, numel(o.fileList))).name));
            % rescale image so the x-dimension fits on the screen
            I = imresize(I, p.trial.display.pWidth/size(I,2));
            
            % keep track of the image size as a rectangle
            o.srcrect = [0 0 size(I,1) size(I,2)];
            
            % rescale color if in GLONE blend mode
            texMode = []; % optional argument to texture call
            if blendFlag
                I = double(I);
                I = (I - 127) / 127;
                I = I .* o.contrast;
                texMode = 2;
            end
                
            % clipping point random walk center
            xyclip0 = o.position; % center of clipping point on source image
              
            maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;

            o.xyclip = repmat(xyclip0, maxFrames, 1);
            
            
            % generate random walk centered on target point
            rndwlk = cumsum(randn(o.rng, maxFrames,2)*o.noisesigma);
            
            o.xyclip = o.xyclip + rndwlk;
            
            % bound random walk
            by = o.srcrect(4) - o.radius; % y upper bound
            iiy = o.xyclip(:,2) > by;
            o.xyclip(iiy,2) = by;
            iiy = o.xyclip(:,2) < o.radius; % lower bound
            o.xyclip(iiy,2) = o.radius;
            
            bx = o.srcrect(3) - o.radius; % x upper bound
            iix = o.xyclip(:,1) > bx;
            o.xyclip(iix,1) = bx;
            
            iix = o.xyclip(:,1) < o.radius;
            o.xyclip(iix,1) = o.radius;
            
            % smooth random walk
            o.xyclip = filter(ones(50,1)/50, 1, o.xyclip);
              
            o.frameIter = 1;
            
            myrect = [o.xyclip(1,:) - o.sz*2 o.xyclip(1,:) + o.sz*2 + 1];
            o.cliprect = ClipRect(myrect,p.trial.display.winRect);
            o.dstrect  = CenterRectOnPoint([0 0 o.sz], o.position(1), o.position(2));
            
            
            % make and store texture pointers
            o.tex  = Screen('MakeTexture',p.trial.display.ptr,I,[],[],texMode);
            o.mask = Screen('MakeTexture',p.trial.display.ptr,o.mask,[], [], texMode);
          
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
          
          switch o.stimValue
              case 1
                  Screen('DrawTexture', p.trial.display.ptr, o.tex, o.cliprect, o.dstrect);
                  Screen('DrawTexture', p.trial.display.ptr, o.mask, [], o.maskrect);
                  
                  
                  
              case 2
                  
                  r = o.radius; % radius in pixels
                  
                  rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
                  Screen('FillOval',p.trial.display.overlayptr, o.color,rect');
                  
                  r = o.radius/2; % radius in pixels
                  
                  rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
                  Screen('FillOval',p.trial.display.overlayptr, o.ctrColor,rect');
                  
          end
          
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
          
          if ~o.stimValue % do nothing if it's not on
              return
          end
          
          if nargin < 2
              warning('needs a pldaps to run')
              return
          end
%           myrect = [o.xyclip(o.frameIter,:) - o.sz*10 o.xyclip(o.frameIter,:) + o.sz + 1];
%           myrect = [o.xyclip(o.frameIter,:) - o.sz o.xyclip(o.frameIter,:) + o.sz + 1];
          
          % shrinking window
          % exponential decay since last time on
          tt = p.trial.trstart + p.trial.ttime - o.log(2,end);
          
          ss = max(exp(-tt/o.shrinkTimeConstant)*p.trial.display.pWidth, o.sz);
          
          myrect = [o.xyclip(o.frameIter,:) - ss o.xyclip(o.frameIter,:) + ss + 1];
          o.cliprect = ClipRect(myrect,o.srcrect);
          
          o.dstrect  = CenterRectOnPoint([0 0 ss], o.position(1), o.position(2));
          o.maskrect = o.dstrect;
            
          o.frameIter = o.frameIter + 1; %p.trial.iFrame;
          
          % check if point is fixated
          o.isHeld([p.trial.eyeX p.trial.eyeY])
      end
      
      function cleanup(o,p)
          Screen('Close', o.tex)
          Screen('Close', o.mask)
          o.xyclip(p.trial.iFrame+1:end,:) = [];
      end
    
  end % methods
  
  
  methods (Static)
      function mask = makeMask(r, type)
          % make a 2D image mask of specified type and size
          % mask = makeMask(r, type)
          
          switch type
              case 'circle'
                  [xx,yy] = meshgrid(linspace(-r,r, ceil(r)));
                  m = sqrt(xx.^2 + yy.^2) < r;
                  m = 255 - (255*m);
              case 'gaussian' % NEEDS WORK'
                  [xx,yy] = meshgrid(linspace(-r,r, ceil(r)));
                  m = 255 - (255*exp(-(xx.^2 + yy.^2)/(r^2/3.5)));
              case 'tukey' % IMPLEMENT ME
                  
              otherwise
                  
          end
          
          sz = size(m);
          mask = ones(sz(1), sz(2), 2)*127; %mode(p.trial.display.bgColor);
          mask(:,:,end) = m;
      end
  end
    
  
end % classdef
