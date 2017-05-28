classdef textureFlashNoise < handle
    %TEXTUREFLASHNOISE uses a texture object to create a noise stimulus
    
    properties
        texObj@stimuli.textures
        num@double          = 10; % number of objects to draw
        imageDims@double
        bgColor@double
        rndStream@RandStream = RandStream('twister')
    end
    
    properties(Access = private)
        sourceBlending
        destinationBlending
    end
    
    methods
        % --- Class constructor 
        function o = textureFlashNoise(p,texObj,varargin)
            
            assert(isa(p, 'pldaps'), 'first argument must be a pldaps')
            
            o.imageDims = p.trial.display.winRect;
            o.bgColor   = p.trial.display.bgColor;
            
            % keep track of blending
            o.sourceBlending = p.trial.display.sourceFactorNew;
            o.destinationBlending = p.trial.display.destinationFactorNew;
            
            if nargin < 2
                o.texObj = stimuli.textures(p.trial.display.ptr);
                return
            else
                o.texObj = texObj;
            end
            
            ip = inputParser();
            ip.addParameter('num', o.num)
            ip.parse(varargin{:})
            
            o.num = ip.Results.num;

            
        end % constructor
        
        % --- Draing action before Screen Flip is called
        function beforeFrame(o)
            o.texObj.beforeFrame()           
        end
        
        % --- main action
        function afterFrame(o)
            
            uniqueTex = o.texObj.numTex;
            o.texObj.id       = randi(uniqueTex, 1, o.num);
            o.texObj.texSize  = cell2mat(cellfun(@(x) x.size, o.texObj.texture(o.texObj.id), 'UniformOutput', false)');
            o.texObj.position = bsxfun(@times, rand(o.rndStream, o.num, 2), [o.imageDims(3)-o.imageDims(1) o.imageDims(4)-o.imageDims(2)]);
        end
        
        function img = getImage(o)
            n = numel(o.bgColor);
            img = zeros(o.imageDims(3), o.imageDims(4), n+1, 'uint8');
            for iCol = 1:n
                img(:,:,iCol) = o.bgColor(iCol)*255;
            end
            
            ids = o.texObj.id;
            n   = numel(ids);
            for iTex = 1:n
                tex = o.texObj.texture{ids(iTex)};
                
                sz  = o.texObj.texSize(iTex,:);
                pos = o.texObj.position(iTex,:);
                
                indsx = ceil(pos(1)) - ceil(sz(1)/2) + (1:sz(1));
                indsy = ceil(pos(2)) - ceil(sz(2)/2) + (1:sz(2));
                
                tmp = zeros(size(img), 'uint8');
                
                tmp(indsx, indsy, :) = tex.ptr;
                
                % apply alpha blending
%                 img = AlphaSum(tmp, img);
                img = img + tmp;
                img = AlphaBlend(o.sourceBlending, o.destinationBlending, tmp, img);
  
                
            end
            
            img = AlphaBlend(o.sourceBlending, o.destinationBlending, img, img);
            
            
        end
        
    end
    
end

