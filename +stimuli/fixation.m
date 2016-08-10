classdef fixation < handle
    % Matlab class for drawing fixation target(s) using the psych. toolbox.
    %
    % The fixation target consists of a central circular target and a
    % concentric circular surround (usually contrasting). The size and colour
    % of both the centre and surround can be configured independently.
    %
    % The class constructor can be called with a range of arguments:
    %
    %   centreSize     - diameter of centre (pixels)
    %   surroundRadius - diameter of surround (pixels)
    %   centreColour   - colour of centre (clut index or [r,g,b])
    %   surroundColour - colour of surround (clut index or [r,g,b])
    %   position  - center of target (x,y; pixels)
    %   fixType   - (1=dot, 2=bullseye, 3=bullseye + crosshairs)
    %   winRadius - size of fixation window
    %   winType   - type of window (1 = square, 2 = circle)
    %   winColour - colour of the window (clut index or [r,g,b])
    
    % 16-06-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
    % 09-08-2016 - Jacob L. Yates <jacoby8s@gmail.com>  added cross hairs
    
    properties (Access = public),
        cSize@double = 2; % pixels
        sSize@double = 4; % pixels
        cColour@double = zeros([1,3]); % clut index or [r,g,b]
        sColour@double = ones([1,3]);
        position@double = [0.0, 0.0]; % [x,y] (pixels)
        fixType@double = 2; % bullseye
        winRadius@double=50;
        winType@double=2;
        winColour@double=ones(1,3);
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
            p.addParameter('fixType', o.fixType, @isfloat)
            p.addOptional('winRadius', o.winRadius, @isfloat)
            p.addOptional('winType', o.winType, @isfloat)
            p.addOptional('winColour', o.winColour, @isfloat)
            
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
            o.fixType = args.fixType;
            o.winRadius = args.winRadius;
            o.winType = args.winType;
            o.winColour = args.winColour;
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
            switch o.fixType
                case 1 % single dot
                    Screen('DrawDots', o.winPtr, o.position, o.sSize, o.sColour, [], 2);
                case 2 % bullseye
                    Screen('DrawDots', o.winPtr, o.position, o.sSize, o.sColour, [], 2);
                    Screen('DrawDots', o.winPtr, o.position, o.cSize, o.cColour, [], 2);
                case 3 % bullseye + crosshairs
                    Screen('DrawDots', o.winPtr, o.position, o.sSize, o.sColour, [], 2);
                    Screen('DrawDots', o.winPtr, o.position, o.cSize, o.cColour, [], 2);
                    
                    len=o.sSize*.5;
                    line1=[o.position(1)+[-len len]; o.position(2)*[1 1]];
                    line2=[o.position(1)*[1 1]; o.position(2)+[-len len]];
                    Screen('DrawLines', o.winPtr, [line1 line2], 3, o.cColour, [], 2);
                    Screen('DrawLines', o.winPtr, [line1 line2], 1, o.sColour, [], 2);
            end
            
            if o.winType == 2 % circular window is a radius
                fpCirc = diag(o.position)*ones(2,91)+o.winRadius*[sind(0:4:360); cosd(0:4:360)];
                Screen('FramePoly',o.winPtr, o.winColour, fpCirc',3);
            elseif o.winType == 1 % squarewindows window is half width
                fpRect=[o.position-o.winRadius o.position+o.winRadius];
                Screen('FrameRect', o.winPtr, o.winColour, fpRect);
            end
            
            
            
        end
        
        function held=isheld(o, currentEye)
            
            if o.winType == 0 % pass
                held=true;
            elseif o.winType == 1 % squarewindows window is half width
                held=all(abs(o.position-currentEye)<o.winRadius);
            elseif o.winType == 2 % circular window is a radius
                held=sqrt(sum((o.position-currentEye).^2))<o.winRadius;
            end
            
        end
    end % methods
    
end % classdef
