classdef face < stimuli.textures
    % FACE is a texture of a marmoset faces
    %   Detailed explanation goes here
    
    properties
        radius
        maxContrast
    end
    
    methods
        function o = face(p, varargin)
            
            ip = inputParser();
            ip.addParameter('radius', 1); % degrees
            ip.addParameter('maxContrast', 1);
            ip.parse(varargin{:})
            
            % --- Face Textures
            o = o@stimuli.textures(p.trial.display.ptr); % call the parent constructor
            
            o.maxContrast = ip.Results.maxContrast;
            
            % load marmoset face textures
            MFL=load(fullfile(marmoview.supportDataDir,'MarmosetFaceLibrary.mat'));
            MFL = struct2cell(MFL);
            MFL = MFL([7,10,13,17:20,24,25,27]); % these faces seem most centered
            
            for id = 1:length(MFL)
                img = MFL{id};
                
                sz = size(img);
                % gaussian envelope...
                x = (1:sz(1))-sz(1)/2; y = (1:sz(2))-sz(2)/2;
                [x,y] = meshgrid(x,y);
                g = exp(-(x.^2+y.^2)/(2*(max(sz(1:2))/6)^2));
                g = g - min(g(:));
                g = g./max(g(:));
                
                
                
                if strcmp(p.trial.display.sourceFactorNew, GL_SRC_ALPHA) && strcmp(p.trial.display.destinationFactorNew, GL_ONE_MINUS_SRC_ALPHA)
                    img(:,:,4) = uint8(255.*g); % alpha channel: 0 = transparent, 255 = opaque
                else
                    img = double(img);
%                     img(:,:,4) = 255*g;
                    img = (img - 127)/127;
                    for i = 1:3
                        img(:,:,i) = img(:,:,i).*g;
                    end
                    
                    if strcmp(p.trial.display.sourceFactorNew, GL_ONE)
                        img = img .* o.maxContrast;
                    end
                end
                
                o.addTexture(id, img);
            end
            
            % --- initialize so the texture is ready to use
            o.id  = randi(o.numTex);
            o.texSize  = sz(1:2);
            o.position = p.trial.display.ctr(1:2);
        end
        
    end % methods
    
end % classdef

