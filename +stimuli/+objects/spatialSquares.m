classdef spatialSquares < stimuli.objects.stimulus %#ok<*MCSUP>
% SPATIAL SQUARES is a stimulus that draws random binarized noise for spatial mapping
%
% The constructor requires a pldaps object be passed in
%   hSquares = stimuli.objects.spatialSquares(p)
    
    properties
        position@double     % location of spatial grid (in degrees, relative to screen center)
        N@double            % number of squares on each frame
        size@double         % size of each square (degrees)
        contrast            % contrast of each square (positive=white, negative=black)
        lifetime            % max lifetime (in frames)
        gridded             % are the squares fixed to a grid (spaced by size)
    end
    
    properties (SetAccess = ?stimuli.objects.stimulus, GetAccess = public)
        % read only properties
        pxwin
        rect
    end

    properties (Access = private) % only this object can set and get these properties
        ctr             % center of the screen in pixels (p.trial.display.ctr)
        w2px            % scalar for converting from the world to pixel values (p.trial.display.w2px)
        viewdist        % view distance (p.trial.display.viewdist)
        life            % current life of each square
        uniformLifetime % do all the squares update at the same time
    end
    
    methods % set methods
        function set.position(obj, arg)
            % convert position to pixels and center in screen
            obj.position = arg;
            if isempty(obj.viewdist)
                return
            end
            obj.pxwin   = pds.deg2px(reshape(obj.position, 2, 2), obj.viewdist, obj.w2px);
            obj.pxwin   = obj.pxwin(:)'.*[1 -1 1 -1] + obj.ctr;
        end

    end 

    methods
        
        % constructor
        function obj = spatialSquares(p, varargin)
            
            % setup default argument for position (full screen)
            win = pds.px2deg([-p.trial.display.pWidth -p.trial.display.pHeight; p.trial.display.pWidth p.trial.display.pHeight]'/2, p.trial.display.viewdist, p.trial.display.px2w);
            win = win(:)'.*[1 -1 1 -1];

            % check for arguments
            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.addParameter('position',  win) % rectangle for stimulus location (degrees [x, y, x, y])
            ip.addParameter('N',         10)  % number of squares on each frame
            ip.addParameter('size',      2)   % size of each square (degrees)
            ip.addParameter('contrast',  [])  % contrast of the squares
            ip.addParameter('lifetime',  [])  % in frames
            ip.addParameter('gridded', false) % are the squares in a grid?
            ip.addParameter('uniformLifetime', true)
            ip.parse(varargin{:});
            
            nextargs = [fieldnames(ip.Unmatched) struct2cell(ip.Unmatched)]';
            
            obj = obj@stimuli.objects.stimulus(nextargs{:}); % call parent constructer (hartley is a target)

            % save arguments
            obj.N           = ip.Results.N;
            obj.size        = ip.Results.size;
            obj.contrast    = ip.Results.contrast;
            obj.lifetime    = ip.Results.lifetime;
            obj.uniformLifetime = ip.Results.uniformLifetime;

            % setup pldaps variables that are required for the degree 2 pixel computation    
            obj.ctr      = p.trial.display.ctr;
            obj.viewdist = p.trial.display.viewdist;
            obj.w2px     = p.trial.display.w2px;
            
            % set position -- this will updat pxwin
            obj.position = ip.Results.position;
        end

        function trialSetup(obj, p)

            pWidth  = obj.pxwin(3) - obj.pxwin(1); % width
            pHeight = obj.pxwin(4) - obj.pxwin(2); % height
            pUlx    = obj.pxwin(1); % upper left corner
            pUly    = obj.pxwin(2); % upper right corner

            % initialize squares
            if obj.uniformLifetime
                obj.life = repmat(obj.lifetime, 1, obj.N);
            else
                obj.life = randi(obj.rng, obj.lifetime, 1, obj.N); % lifetime
            end
            
            if obj.gridded
                szpx  = obj.size * p.trial.display.ppd;
                nGridX = ceil(pWidth/szpx);
                nGridY = ceil(pHeight/szpx);
                xpos = randi(obj.rng, nGridX, obj.N, 1)*szpx  + pUlx;  % x position of the upper left corner of each square
                ypos = randi(obj.rng, nGridY, obj.N, 1)*szpx + pUly;  % y position of the upper left corner of each square
            else
                xpos = round(rand(obj.rng, obj.N, 1)*pWidth)  + pUlx;  % x position of the upper left corner of each square
                ypos = round(rand(obj.rng, obj.N, 1)*pHeight) + pUly;  % y position of the upper left corner of each square
                szpx = obj.size * p.trial.display.ppd;
            end
            obj.rect = [xpos(:) ypos(:) xpos(:) + szpx ypos(:) + szpx]';

        end


        function frameUpdate(obj, p)
            if obj.stimValue

                idx = obj.life == 1; % find the squares that are ready to refresh
                if any(idx)
                    
                    pWidth  = obj.pxwin(3) - obj.pxwin(1); % width
                    pHeight = obj.pxwin(4) - obj.pxwin(2); % height
                    pUlx    = obj.pxwin(1); % upper left corner
                    pUly    = obj.pxwin(2); % upper right corner
                    if obj.gridded
                        szpx  = obj.size * p.trial.display.ppd;
                        nGridX = ceil(pWidth/szpx);
                        nGridY = ceil(pHeight/szpx);
                        xpos = randi(obj.rng, nGridX,sum(idx), 1)*szpx  + pUlx;  % x position of the upper left corner of each square
                        ypos = randi(obj.rng, nGridY, sum(idx), 1)*szpx + pUly;  % y position of the upper left corner of each square
                    else
                        xpos = round(rand(obj.rng, sum(idx), 1)*pWidth)  + pUlx;  % x position of the upper left corner of each square
                        ypos = round(rand(obj.rng, sum(idx), 1)*pHeight) + pUly;  % y position of the upper left corner of each square
                        szpx = obj.size * p.trial.display.ppd;
                    end
                    obj.rect(:,idx) = [xpos(:) ypos(:) xpos(:) + szpx ypos(:) + szpx]';
                end

                % update lifetime of each square
                obj.life = mod(obj.life, obj.lifetime)+1;
            end

        end

        function frameDraw(obj, p)
            if obj.stimValue
                Screen('FillRect', p.trial.display.ptr, obj.contrast*[1 1 1], obj.rect);
            end

        end
    end
end