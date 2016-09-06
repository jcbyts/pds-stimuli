classdef gaussianNoise < handle
    %GAUSSIANNOISE draw multiscale gaussian noise blobs
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
            ip.parse(varargin{:})
            
            n.ptr=ptr;
            n.contrast=ip.Results.contrast;
            n.count=ip.Results.count;
            n.dim=ip.Results.dim;
            n.sc=ip.Results.sc;
            n.aspectratio=ip.Results.aspectratio;
            n.dc=ip.Results.dc;
            
        end
        
        
        function setup(n)
            
            % Initialize matrix with spec for all 'ngabors' patches to start off
            % identically:
            n.mypars = repmat([n.contrast, n.sc, n.aspectratio, 0]', 1, n.count);
            
            n.tex = CreateProceduralGaussBlob(n.ptr, 150, 150, [0 0 0 0], 1, -.5);
            
            Screen('DrawTexture', n.ptr, n.tex, [], [], [], [], [], [], [], kPsychDontDoRotation, [n.contrast, n.sc, n.aspectratio, 0]);
            n.texrect = Screen('Rect', n.tex);
            n.inrect = repmat(n.texrect', 1, n.count);

            n.dstRects = zeros(4, n.count);
            for i=1:n.count
                n.scale(i) = 1*(0.1 + 0.9 * randn);
                n.dstRects(:, i) = CenterRectOnPoint(n.texrect * n.scale(i), rand * n.dim(1), rand * n.dim(2))';
            end
            
            n.x=rand(n.count,1) * n.dim(1);
            n.y=rand(n.count,1) * n.dim(2);
            n.mypars(1,:) = sign(randn(1,n.count))*n.contrast;
            n.scale=.1*randn(1,n.count).^4;
        end
        
        function update(n)
            % "Pulse" the aspect-ratio of each gabor with a sine-wave timecourse:
%             n.mypars(3,:) = 1.0 + 0.25 * sin(n.count*0.1);
            
%             t0=GetSecs;
            ix=rand(n.count,1)<.5;
            ns=sum(ix);
            n.x(ix)=rand(ns,1) * n.dim(1);
            n.y(ix)=rand(ns,1) * n.dim(2);
%             t1=GetSecs-t0;
%             fprintf('update (randomize) took %0.5f ms\n', t1*1e3)
    % Recompute dstRects destination rectangles for each patch, given the
    % 'per gabor' scale and new center location (x,y):
%     tic        
%             tmp=n.inrect .* repmat(n.scale,4,1);
            n.scale=.1*randn(1,n.count).^4;
            sx=n.scale.*n.texrect(3)/2;
            sy=n.scale.*n.texrect(4)/2;
            n.dstRects=[n.x'-sx;n.y'-sy;n.x'+sx;n.y'+sy];
%             tmp(1,:)=tmp(1,:)+n.x';
%             tmp(2,:)=tmp(2,:)+n.y';
%             tmp(3,:)=tmp(3,:)+n.x';
%             tmp(4,:)=tmp(4,:)+n.y';
%             n.dstRects=tmp;
%             toc
            
%             n.dstRects = CenterRectOnPointd(n.inrect .* repmat(n.scale,4,1), n.x(:)', n.y(:)');
%             t1=GetSecs-t0;
%             fprintf('update (total) took %0.5f ms\n', t1*1e3)
        end
        
        
        function draw(n)
%             t0=GetSecs;
            Screen('DrawTextures', n.ptr, n.tex, [], n.dstRects, 0, [], [], [], [], kPsychDontDoRotation, n.mypars);
%             t1=GetSecs-t0;
%             fprintf('draw (internal) took %0.5f ms\n', t1*1e3)
        end
    end
    
end



