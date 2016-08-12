classdef targetAnnulus<handle
% Matlab class for drawing an annulus that operates as a target
%
% The class constructor can be called with a range of arguments:
%
%   position        - the center of the annulus (x,y in pixels)
%   minRadius       - the inner radius of the annulus (pixels)
%   maxRadius       - the outer radius of the annulus (pixels)
%   thetaSpan       - range of angles to cover (degrees)
%   colour          - ptb colour: can be [r,g,b] triplet or clut index
%   visible         - logical, is the target drawn
    properties (Access = public)
        position@double; % center of annulus
        radius@double;    % radius, center of ring (in pixels)
        size@double; % width of ring (in pixels)
        winSize@double; % size of window relativ
        thetaSpan@double; % range spanned
        colour@double;
        winColour@double;
        visible@logical; % is the target visible
        held=@double;
    end
    
    
    properties (Access = private)
        winPtr; % PTB window
        polyx@double;
        polyy@double;
        winpolyx@double;
        winpolyy@double;
        winRadiusMin@double;
        winRadiusMax@double;
    end
    
    methods (Access = public)
        function o=targetAnnulus(winPtr, varargin)
            o.winPtr=winPtr;
            
            if nargin==1
                return
            end
            
            args=varargin;
            p=inputParser;
            p.StructExpand = true;
            p.addParameter('position',[0 0], @isfloat)
            p.addParameter('radius', 100, @isfloat)
            p.addParameter('size', 200, @isfloat)
            p.addParameter('winSize', 200, @isfloat)
            p.addParameter('thetaSpan', [0 360], @isfloat)
            p.addParameter('colour', zeros(1,3), @isfloat)
            p.addParameter('winColour', ones(1,3), @isfloat)
            p.addParameter('visible', true)
            try
               p.parse(args{:});
            catch
                warning('Failed to parse name-value arguments.')
                return;
            end
            
            args=p.Results;
            o.position=args.position;
            o.radius=args.radius;
            o.size=args.size;
            o.winSize=args.winSize;
            o.thetaSpan=args.thetaSpan;
            o.colour=args.colour;
            o.winColour=args.winColour;
            o.visible=args.visible;
            o.held=false;
        end
        
        function beforeTrial(o)
            th=o.thetaSpan(1):o.thetaSpan(2);
            x=cosd(th);
            y=sind(th);
            minRadius=o.radius-o.size;
            maxRadius=o.radius+o.size;
            o.winRadiusMin=o.radius-o.winSize;
            o.winRadiusMax=o.radius+o.winSize;
            o.polyx=[minRadius*x maxRadius*fliplr(x) minRadius*x(1)];
            o.polyy=[minRadius*y maxRadius*fliplr(y) minRadius*y(1)];
            o.winpolyx=[o.winRadiusMin*x o.winRadiusMax*fliplr(x) o.winRadiusMin*x(1)];
            o.winpolyy=[o.winRadiusMin*y o.winRadiusMax*fliplr(y) o.winRadiusMin*y(1)];
        end
        
        function update(o)
        end
        
        function h=isheld(o, currentEye)
            xy=currentEye-o.position;
            [th, rho]=cart2pol(xy(1), xy(2));
            th=th*180/pi;
            th=mod(th,360);
            h = rho > o.winRadiusMin & rho < o.winRadiusMax & th>o.thetaSpan(1) & th < o.thetaSpan(2);
            o.held=o.held+h;
        end
        
        function draw(o)
            if o.visible
                Screen('FillPoly', o.winPtr, o.colour, [o.polyx(:)+o.position(1), o.polyy(:)+o.position(2)])
                Screen('FramePoly', o.winPtr, o.winColour, [o.winpolyx(:)+o.position(1), o.winpolyy(:)+o.position(2)])
            end
        end    
    end
    
    methods (Static)
    end
end