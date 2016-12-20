classdef background < handle
    %BACKGROUND draw image as background
    %   Detailed explanation goes here
    
    properties
        ptr
        tex
        rect
        x
        y
        contrast
        count
        sc
        aspectratio
        dc
        scale
        dim
        rng
    end
    
    properties (Access = private)
        mypars
        texrect
        inrect
        dstRects
    end
    
    methods
        % constructor
        function n=gaussianNoise(ptr, varargin)
            ip=inputParser();
            ip.addParameter('count', 100)
            ip.addParameter('dim', [1920 1080])
            ip.addParameter('sc', 10)
            ip.addParameter('contrast', .5)
            ip.addParameter('aspectratio', 1.0)
            ip.addParameter('dc', .5)
            ip.addParameter('rng', rng)
            ip.parse(varargin{:})
            
            n.ptr=ptr;
            n.contrast=ip.Results.contrast;
            n.count=ip.Results.count;
            n.dim=ip.Results.dim;
            n.sc=ip.Results.sc;
            n.aspectratio=ip.Results.aspectratio;
            n.dc=ip.Results.dc;
            n.rng=ip.Results.rng;
            
        end
        
        
        function setup(n)
            
            % Initialize matrix with spec for all 'ngabors' patches to start off
            % identically:
            n.mypars = repmat([n.contrast, n.sc, n.aspectratio, 0]', 1, n.count);
            
            n.tex = CreateProceduralGaussBlob(n.ptr, 150, 150, [0 0 0 0], 1, -.5);
            
            Screen('DrawTexture', n.ptr, n.tex, [], [], [], [], [], [], [], kPsychDontDoRotation, [n.contrast, n.sc, n.aspectratio, 0]);
            n.texrect = Screen('Rect', n.tex);
            n.inrect = repmat(n.texrect', 1, n.count);
            
            n.x=rand(n.rng,1,n.count) * n.dim(1);
            n.y=rand(n.rng,1,n.count) * n.dim(2);
            n.mypars(1,:) = sign(randn(n.rng,1,n.count))*n.contrast;
            n.scale=.1*randn(n.rng, 1,n.count).^4;
            n.dstRects = CenterRectOnPointd(n.inrect .* repmat(n.scale,4,1), n.x, n.y);
        end
        
        function update(n)
            ix=rand(n.count,1)<.5;
            ns=sum(ix);
            n.x(ix)=rand(ns,1) * n.dim(1);
            n.y(ix)=rand(ns,1) * n.dim(2);
            
            n.scale=.1*randn(1,n.count).^4;
            sx=n.scale.*n.texrect(3)/2;
            sy=n.scale.*n.texrect(4)/2;
            n.dstRects=[n.x'-sx;n.y'-sy;n.x'+sx;n.y'+sy];
            
%             n.dstRects = CenterRectOnPointd(n.inrect .* repmat(n.scale,4,1), n.x(:)', n.y(:)');
        end
        
        
        function draw(n)
            Screen('DrawTextures', n.ptr, n.tex, [], n.dstRects, 0, [], [], [], [], kPsychDontDoRotation, n.mypars);
        end
    end
    
end



