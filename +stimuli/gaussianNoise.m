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
        ranNumGen
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
            ip.addParameter('sc', 100)
            ip.addParameter('contrast', .5)
            ip.addParameter('aspectratio', 1.0)
            ip.addParameter('dc', .5)
            ip.addParameter('rng', RandStream('twister'))
            ip.parse(varargin{:})
            
            n.ptr=ptr;
            n.contrast=ip.Results.contrast;
            n.count=ip.Results.count;
            n.dim=ip.Results.dim;
            n.sc=ip.Results.sc;
            n.aspectratio=ip.Results.aspectratio;
            n.dc=ip.Results.dc;
            n.ranNumGen=ip.Results.rng;
            
        end
        
        
        function setup(n)
            
            % Initialize matrix with spec for all 'ngabors' patches to start off
            % identically:
            n.mypars = repmat([n.contrast, n.sc, n.aspectratio, 0]', 1, n.count);
            
            [n.tex, n.texrect] = CreateProceduralGaussBlob(n.ptr, 250, 250, [0 0 0 0], 1, .5);

            Screen('DrawTexture', n.ptr, n.tex, [], CenterRectOnPoint(n.texrect, n.dim(1)/2, n.dim(2)/2), [], [], [], [], [], kPsychDontDoRotation, [n.contrast, n.sc, n.aspectratio, 0]);
            n.inrect = repmat(n.texrect', 1, n.count);
            
            n.x=rand(n.ranNumGen,1,n.count) * n.dim(1);
            n.y=rand(n.ranNumGen,1,n.count) * n.dim(2);
            n.mypars(1,:) = sign(randn(n.ranNumGen,1,n.count))*n.contrast;
            n.scale=.1*randn(n.ranNumGen,1,n.count).^4;
            n.dstRects = CenterRectOnPointd(n.inrect .* repmat(n.scale,4,1), n.x, n.y);
        end
        
        function update(n)
            ix=rand(n.ranNumGen,n.count,1)<.5;
            ns=sum(ix);
            n.x(ix)=ceil(rand(n.ranNumGen,ns,1) * n.dim(1));
            n.y(ix)=ceil(rand(n.ranNumGen,ns,1) * n.dim(2));
            
            n.scale=.1+rand(n.ranNumGen,1,n.count)*2;

            sx=n.scale.*n.texrect(3)/2;
            sy=n.scale.*n.texrect(4)/2;
            n.dstRects=[n.x-sx;n.y-sy;n.x+sx;n.y+sy];
        end
        
        
        function draw(n)
            Screen('DrawTextures', n.ptr, n.tex, [], n.dstRects, 0, 0, [], [], [], kPsychDontDoRotation, n.mypars);
        end
        
        function img=image(n)
            [xx,yy]=meshgrid(0:(n.dim(1)-1), 0:(n.dim(2)-1));
            s=[n.texrect(3) n.texrect(4)];
            fun=@(x,y,s,c) c*exp(- ( (xx-x).^2 + (yy - y).^2)/(2*s^2));
            img=0;
            for i=1:n.count
                tmp=fun(n.x(i), n.y(i), n.scale(i).*n.sc, n.mypars(1,i)*n.contrast);
                tmp=tmp*512;
                % window out texture region
                ix=abs(xx-n.x(i))>s(1)*n.scale(i) & abs(yy-n.y(i))>s(2)*n.scale(i);
                tmp(ix)=0;
                img=img+tmp;
            end
            img(abs(img)<1)=0;
            img=img+127;
            img=ceil(img);
        end
    end
    
end



