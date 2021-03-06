classdef plaidGaborTarget < stimuli.objects.target
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public),
        radius@double = 300; % pixels
        color@double  = ones(1,3);
        ctrColor@double = -ones(1,3);
        wincolor
        gabortex
        theta=[0 120]     % direction 0-360, in degrees (0: horizontal, 90: vertical)
        sf=[1 1]        % cyc/deg
        phase=[0 0]     % 0-360 degrees
        contrast=[.25 .25] % michelson
        ppd=1
        sigma=1     % deg
        tf=[5 5]
        track=true
    end
    
    methods (Access = public)
        
        % --- Class constructor
        function obj = plaidGaborTarget(varargin)
            
            obj = obj@stimuli.objects.target(varargin{:}); % use parent constructor (inherits the properties and methods of TARGET)
            
            if nargin == 1
                return
            end
            
            % initialise input parser
            ip = inputParser;
            ip.StructExpand = true;
            ip.addParameter('radius', obj.radius,   @isfloat); % pixels
            ip.addParameter('color',  obj.color,    @isfloat); % color r,g,b triplet
            ip.addParameter('position',  obj.position,    @isfloat); % [x,y] (pixels)
            ip.addParameter('track', obj.track)
            try
                ip.parse(varargin{:});
            catch
                warning('Failed to parse name-value arguments.');
                return;
            end
            
            args = ip.Results;
            
            obj.radius      = args.radius;
            obj.color       = args.color;
            obj.position    = args.position;
            obj.track       = args.track;
        end
        
        
        function obj = setup(obj, p)
            
            if ~isempty(obj.gabortex) % setup has already been run
                return
            end
            
            obj.ppd = p.trial.display.ppd;
            disableNormalization = 1;
            contrastPreMultiplicator = .5;
            
            modulateColor = [0 0 0 0];
            obj.gabortex = CreateProceduralGabor(p.trial.display.ptr, obj.radius, obj.radius, [], modulateColor, disableNormalization,contrastPreMultiplicator);
%             obj.gabortex = CreateProceduralGabor(p.trial.display.ptr, obj.radius, obj.radius, modulateColor, [],contrastPreMultiplicator);
            
            
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
            
            num = numel(o.theta);
            rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
            rect = repmat(rect(:), 1, num);
            gaborParams = [180, 1/o.ppd, o.sigma*o.ppd, 1, 1, 0, 0, 0];
            gaborParams = repmat(gaborParams(:), 1, num);
            gaborParams(1,:) = gaborParams(1,:)-o.phase;
            gaborParams(2,:) = o.sf/o.ppd;
            gaborParams(4,:) = o.contrast;
            
            Screen('BlendFunction', p.trial.display.ptr, GL_ONE, GL_ONE);
            Screen('DrawTextures', p.trial.display.ptr, o.gabortex, [], rect, o.theta, [], [], [], [], kPsychDontDoRotation, gaborParams);
            Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
            
            % draw the fixation window
            if ~isempty(o.wincolor)
                r = o.winRadius;
                rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
                Screen('FrameOval', p.trial.display.overlayptr, o.wincolor, rect');
            end
            
        end
        
        function trialSetup(o,p)
            o.setup(p)
        end
        
        function frameUpdate(o,p)
            % every frame update call, check the fixation status
            
            if nargin < 2
                warning('needs a pldaps to run')
                return
            end
            
            phaseinc = 360 * (o.tf / p.trial.display.frate);
            o.phase = o.phase + phaseinc;
            if o.track
                o.isHeld([p.trial.eyeX p.trial.eyeY])
            end
        end
    end
    
end

