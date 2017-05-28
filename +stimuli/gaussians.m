classdef gaussians < stimuli.textures
    % GAUSSIANS is a textures object that draws gaussians
    % gratings(p, varargin)
    %   'sigma'         (degrees)
    
    properties
        sigma
        signs
    end
    
    properties(Access = private)
        
    end
    
    
    methods
        function o = gaussians(p, varargin)
            % GRATINGS makes gratings
            % Takes a pldaps as input.
            
            ip = inputParser();
            ip.addParameter('sigma', 1); % degrees
            ip.parse(varargin{:})
                         
            o = o@stimuli.textures(p.trial.display.ptr); % call the parent constructor
            
            o.signs = [-1 1];
            
            [sg,si]=meshgrid(ip.Results.sigma, o.signs);
            
            o.sigma = sg(:);
            o.signs = si(:);
            
            n = numel(o.sigma);
            
            ppd = p.trial.display.ppd; % pixels per degree multiplier
            
            for k = 1:n
                dpix = ceil(7*o.sigma(k)*ppd);
                if rem(dpix,2) % force even
                    dpix = dpix-1;
                end
                
                xax = (-dpix/2:dpix/2) ./ ppd ; % convert back to degrees
                [xx,yy] = meshgrid( xax );

                mask = .5*exp(-.5 * (xx.^2 + yy.^2)/o.sigma(k)^2);
                
%                 img  = o.signs(k) * mask;
                img  = o.signs(k) * mask;
                
%                 img  = img;
%                 img(:,:,2) = abs(img(:,:,1));
%                 img  = uint8(255 * img);
%                 img(:,:,2) = uint8(255*mask);
% %                 img(:,:,2) = abs(xx + yy) < o.sigma(k)^2; %255; %img(:,:,1);
%                 img(:,:,2) = img(:,:,1);
%                 img(:,:,3) = img(:,:,1);
%                 img(:,:,4) = img(:,:,1);
                
                o.addTexture(k, img);
            end

            % --- initialize so the texture is ready to use
            o.id  = o.numTex;
            
%             repmat(ceil(7*o.sigma*ppd), numel(o.sigma), 2);
            o.texSize  = o.texture{o.id}.size;
            o.position = p.trial.display.ctr(1:2);
            
        end
    end % methods
    
end % classdef