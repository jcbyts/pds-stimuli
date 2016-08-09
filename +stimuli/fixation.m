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
    % 09-08-2016 - Jacob L. Yates <jacoby8s@gmail.com>  added cross hairs
    
    properties (Access = public),
        cSize@double = 2; % pixels
        sSize@double = 4; % pixels
        cColour@double = zeros([1,3]); % clut index or [r,g,b]
        sColour@double = ones([1,3]);
        position@double = [0.0, 0.0]; % [x,y] (pixels)
        crosshairs@logical = false;
    end
    
    properties (Access = private)
        winPtr; % ptb window
    end
    
    methods (Access = public)
        function o = fixation(winPtr,varargin) % marmoview's initCmd?
            o.winPtr = winPtr;
            
            if nargin == 1,
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
            p.addParameter('crosshairs', o.crosshairs, @logical)
            try
                p.parse(args{:});
            catch
                warning('Failed to parse name-value arguments.');
                return;
            end
            
            args = p.Results;
            
            o.cSize = args.centreSize;
            o.sSize = args.surroundSize;
            o.cColour = args.centreColour;
            o.sColour = args.surroundColour;
            o.position = args.position;
            o.crosshairs = args.crosshairs;
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
            %             r = floor(o.sSize./2); % radius in pixels
            %
            %             rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
            %             Screen('FillOval',o.winPtr,o.sColour,rect');
            %
            %             r = floor(o.cSize./2);
            %
            %             rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);
            %             Screen('FillOval',o.winPtr,o.cColour,rect');
            
            %             Screen('Drawdots',  p.trial.display.overlayptr,  p.trial.stimulus.fixationXY(:), p.trial.stimulus.fixdotW, p.trial.display.clut.fixation, p.trial.display.ctr(1:2), 2);
            Screen('DrawDots', o.winPtr, o.position, o.sSize, o.sColour, [], 2);
            Screen('DrawDots', o.winPtr, o.position, o.cSize, o.cColour, [], 2);
            
            if o.crosshairs
                len=o.sSize*.5;
                line1=[o.position(1)+[-len len]; o.position(2)*[1 1]];
                line2=[o.position(1)*[1 1]; o.position(2)+[-len len]];
                Screen('DrawLines', o.winPtr, [line1 line2], 3, o.cColour, [], 2);
                Screen('DrawLines', o.winPtr, [line1 line2], 1, o.sColour, [], 2);
            end
            
            
            
        end
    end % methods
    
end % classdef
