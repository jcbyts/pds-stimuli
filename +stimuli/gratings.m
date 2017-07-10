classdef gratings < stimuli.textures
    % GRATINGS is a textures object that draws gratings
    % gratings(p, varargin)
    %   'radius'        (degrees)
    %   'sf'            (cycles / degree)
    %   'orientation'   (degrees)
    %   'phase'         (degrees)
    %   'isgabor'       (boolean)
    % All arguments can be passed in as vectors except 'isgabor'
    
    properties
        orientation
        phase
        sf
        isgabor
        radius
        maxContrast
    end
    
    
    methods
        function o = gratings(p, varargin)
            % GRATINGS makes gratings
            % Takes a pldaps as input.
            
            ip = inputParser();
            ip.addParameter('radius', 1); % degrees
            ip.addParameter('sf', 1);
            ip.addParameter('orientation', 0:(180/8):(180 - (180/8)));
            ip.addParameter('phase', 0:(360/4):(360 - (360/4)));
            ip.addParameter('isgabor', true);
            ip.addParameter('maxContrast', 1);
            ip.parse(varargin{:})
            
            [th, ph, sz, sfs] = ndgrid(ip.Results.orientation, ip.Results.phase, ip.Results.radius, ip.Results.sf);
             
            o = o@stimuli.textures(p.trial.display.ptr); % call the parent constructor
            
            o.orientation = th(:);
            o.phase       = ph(:);
            o.sf          = sfs(:);
            o.radius      = sz(:);
            o.isgabor     = ip.Results.isgabor;
            o.maxContrast = ip.Results.maxContrast;
            
            n = numel(o.orientation);
            
            % pixels per degree multiplier
            ppd = p.trial.display.ppd;
            
            for k = 1:n
                dpix = ceil(2.5*o.radius(k)*ppd);
                if rem(dpix,2) % force even
                    dpix = dpix-1;
                end
                
                xax = (-dpix/2:dpix/2) ./ ppd ; % convert back to degrees
                [xx,yy] = meshgrid( xax );
                
                % variables for this
                omega    = 2 * pi * o.sf(k);
                theta    = o.orientation(k) / 180 * pi;
                phi      = o.phase(k) / 180 * pi;
                
                % get rotation
                zz = sin(theta) .* xx + cos(theta) .* yy;
                
                sinecarrier = sin(omega * zz + phi);
                
                if o.isgabor % gaussian window
                    sigma = o.radius(k)/2;
                    mask = exp(-.5 * (xx.^2 + yy.^2)/sigma^2);
                else % circular (hard) aperture
                    sigma = o.radius(k);
                    mask = sqrt(xx.^2 + yy.^2) < sigma;
                end
                
                if strcmp(p.trial.display.sourceFactorNew, GL_SRC_ALPHA) && strcmp(p.trial.display.destinationFactorNew, GL_ONE_MINUS_SRC_ALPHA)
                    img = sinecarrier*255/2 + 255/2;
                    
                    mask = mask - min(mask(:));
                    mask = mask./max(mask(:));
                    img(:,:,2) = img(:,:,1);
                    img(:,:,3) = img(:,:,1);
                    img(:,:,4) = uint8(255.*mask);
                elseif strcmp(p.trial.display.sourceFactorNew, GL_ONE) && strcmp(p.trial.display.destinationFactorNew, GL_ONE)
                    img = o.maxContrast .* sinecarrier .* mask;
                else
                    img = sinecarrier .* mask;
                end
                
                o.addTexture(k, img);
            end

            % --- initialize so the texture is ready to use
            o.id       = o.numTex;
            o.texSize  = ceil(2.5 * o.radius(o.id)*ppd)*[1 1];
            o.position = p.trial.display.ctr(1:2);
            
        end
    end % methods
    
end % classdef