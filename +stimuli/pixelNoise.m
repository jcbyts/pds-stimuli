classdef pixelNoise < handle
    % PIXELNOISE makes noise
    %   Noise is a class that generates noise for the psychtoolbox
    
    properties
        ptr
        type
        size
        xy
        img
        tex
        rect
        pxsize
        sigma
        dc
    end
    
    properties(Access = private)
        updateFun
    end
    
    methods
        
        function n=pixelNoise(ptr, varargin)
            ip=inputParser();
            ip.addParameter('type', 'gaussian')
            ip.addParameter('dim', [100 100])
            ip.addParameter('xy', [100 100])
            ip.addParameter('pxsize', 10)
            ip.addParameter('sigma', .1)
            ip.addParameter('dc', .5)
            ip.parse(varargin{:})
            
            n.ptr=ptr;
            n.type=ip.Results.type;
            n.size=ip.Results.dim;
            n.xy=ip.Results.xy;
            n.pxsize=ip.Results.pxsize;
            n.dc=ip.Results.dc;
            n.sigma=ip.Results.sigma;
            
        end
        
        function update(n)
            n.updateFun(n)
            
            if ~isempty(n.ptr)
                n.tex=Screen('MakeTexture', n.ptr, n.img*255);
            end
        end
        
        function setup(n)
            n.img=zeros(n.size(1), n.size(2));
            n.rect = SetRect(0,0,n.size(2)*n.pxsize, n.size(1)*n.pxsize);
            switch n.type
                case 'gaussian'
                    n.updateFun=@(x) updateGaussianNoise(x);
                case 'sparse'
                    n.updateFun=@(x) updateTernarySparseNoise(x);
                otherwise
                    n.updateFun=@(x) updateGaussianNoise(x);
            end
            
            n.update
        end
        
        function draw(n)
            dstRect=CenterRectOnPoint(n.rect, n.xy(1), n.xy(2));
            Screen('DrawTexture', n.ptr, n.tex, [], dstRect, [], 0);
            
            %             % Overdraw the rectangular noise image with our special
            %             % aperture image. The noise image will shine through in areas
            %             % of the aperture image where its alpha value is zero (i.e.
            %             % transparent):
            %             Screen('DrawTexture', p.trial.display.ptr, aperture, [], dstRect(i,:), [], 0);
            
            % After drawing, we can discard the noise texture.
            Screen('Close', n.tex);
        end
        
        
    end
    
    methods(Access = private)
        function updateGaussianNoise(n)
            n.img=n.dc+randn(n.size(1), n.size(2))*n.sigma;
            n.img=min(n.img, 1);
            n.img=max(n.img, 0);
        end
        
        function updateTernarySparseNoise(n)
            tmp=randn(n.size(1), n.size(2))*n.sigma;
            tmp(abs(tmp)<.1)=0;
            tmp=sign(tmp);
            n.img=tmp+n.dc;
            n.img=min(n.img, 1);
            n.img=max(n.img, 0);
        end
    end
    
    
end

