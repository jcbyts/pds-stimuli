classdef hartley < stimuli.objects.stimulus
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
        function h = hartley(p, varargin)
            ip=inputParser();
            ip.addParameter('contrast', .2)
            ip.addParameter('M', 1)
            ip.addParameter('dim', [1920 1080])
            ip.parse(varargin{:})
            
            h.ptr = p.trial.display.ptr;
            h.ppd = p.trial.display.ppd;
            
            h.contrast=ip.Results.contrast;
            
            h.M   = ip.Results.M;
            h.dim = ip.Results.dim;
            
            % initialize some values
            h.tf  = 0; % temporal frequency
            h.kx  = 1; % x spatial frequency
            h.ky  = 1; % y spatial frequency
            h.phi = 0; % phase

            h.bgColorOffset = [0 0 0 0]; % gray
            h.tex = CreateProceduralHartleyBasis(h.ptr, h.dim(1), h.dim(2), h.bgColorOffset, [], .5);
            
        end
        
        
        function setup(h)
            % Initialize matrix with spec for all 'ngabors' patches to start off
            h.kx  = rand(h.rng) * 2*pi - pi;
            h.ky  = rand(h.rng) * 2*pi - pi;
            h.phi = 0;
            
        end
        
%         function update(h, time)
% %             h.phi=sin(2*pi*h.tf*time);
%         end
        
        
        function draw(h)
              
%             Screen('DrawTexture', h.ptr, h.tex, [], [0 0 h.dim], 0, [], [], [], [], kPsychDontDoRotation, [h.kx, h.ky, h.M, h.contrast, h.ppd, h.phi, 0, 0]);
            Screen('DrawTexture', h.ptr, h.tex, [], [0 0 h.dim], 0, [], [], [], [], kPsychDontDoRotation, [h.kx, h.ky, h.ppd, h.contrast, h.M, h.phi, 0, 0]);
    
    
%             Screen('DrawTextures', h.ptr, h.tex, [], h.dstRects, 0, 0, [], [], [], kPsychDontDoRotation, h.mypars);
        end
        
%         function img=image(h)
%             
%         end
    end
    
end



