classdef hartley < handle
    % HARTLEY draws full-field hartley basis stimuli
    
    properties
        ptr
        tex
        dim
        contrast
        lifetime
        kx@double
        ky@double
        M@double
        tf@double
        phi@double
    end
    
    properties (Access = private)
        bgColorOffset@double
        ppd@double
    end
    
    methods
        % constructor
        function h=hartley(ptr, varargin)
            ip=inputParser();
            ip.addParameter('contrast', .2)
            ip.addParameter('M', 10)
            ip.addParameter('dim', [1920 1080])
            ip.addParameter('ppd', .02)
            ip.parse(varargin{:})
            
            h.ptr=ptr;
            
            h.ppd=ip.Results.ppd;
            h.contrast=ip.Results.contrast;
            h.M=ip.Results.M;
            h.dim=ip.Results.dim;
            % initialize some values
            h.tf=0;
            h.kx=1;
            h.ky=1;
            h.phi=0;
%             h.bgColorOffset=[0.5 0.5 0.5 0.0];
%             h.bgColorOffset=[0.5 0.5 0.5 0.0];
            h.bgColorOffset=[0 0 0 0];
            h.tex = CreateProceduralHartleyBasis(h.ptr, h.dim(1), h.dim(2), h.bgColorOffset, [], .5);
            
        end
        
        
        function setup(h)
            % Initialize matrix with spec for all 'ngabors' patches to start off
            h.kx=rand*2*pi-pi;
            h.ky=rand*2*pi-pi;
            h.phi=0;
            
        end
        
%         function update(h, time)
% %             h.phi=sin(2*pi*h.tf*time);
%         end
        
        
        function draw(h)
              
            Screen('DrawTexture', h.ptr, h.tex, [], [0 0 h.dim], 0, [], [], [], [], kPsychDontDoRotation, [h.kx, h.ky, h.M, h.contrast, h.ppd, h.phi, 0, 0]);
    
    
%             Screen('DrawTextures', h.ptr, h.tex, [], h.dstRects, 0, 0, [], [], [], kPsychDontDoRotation, h.mypars);
        end
        
%         function img=image(h)
%             
%         end
    end
    
end



