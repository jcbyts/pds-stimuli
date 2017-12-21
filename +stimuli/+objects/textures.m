classdef textures < stimuli.objects.target
    % Matlab class for drawing textures using the psych. toolbox.
    %
    % The class constructor can be called with a range of arguments:
    %
    %   size     - texture size (wdth,hght; pixels)
    %   position - center of texture (x,y; pixels)
    %
    % Example Call:
    %  o = textures()
    
    properties (Access = public),
        id; % id of the texture to show on call to drawTextures();
        
        texSize@double; % width, or [wdth, hght] (pixels)
        
        alpha@double = 1.0; % alpha (opacity) for the selected texture(s)
        
         % each entry in the texture contains a structure with fields:
        %   id - the texture id
        %   size - the texture size (wdth, hght)
        %   alpha - alpha value (default: 1)
        %   ptr - a ptb texture pointer
        texture = {};
    end
    
    properties (Access = private)
        winPtr@double % ptb window (pass nan to operate without PTB)
        glsl
        texMode=2;
    end
    
    % dependent properties, calculated on the fly...
    properties (Dependent, SetAccess = private, GetAccess = public)
        texIds@cell; % texture ids
        numTex@double;   % the number of textures
       
    end
    
    %   properties (Dependent, SetAccess = public, GetAccess = public)
    %     alpha@double; % alpha (opacity) for the selected texture(s)
    %   end
    
    methods % set/get dependent properties
        
        function value = get.texIds(o)
            value = cellfun(@(x) x.id, o.texture, 'UniformOutput', 0);
        end
        
        function value = get.numTex(o)
            value = length(o.texture);
        end
        
    end
    
    methods (Access = public)
        function o = textures(winPtr,varargin) % marmoview's initCmd?
            
            o = o@stimuli.objects.target(varargin{:});
            
            o.winPtr = winPtr;
            
            if ~isnan(o.winPtr)
                try
                [sourceFactorOld, destinationFactorOld]=Screen('BlendFunction', o.winPtr);
                
                if strcmp(sourceFactorOld, GL_SRC_ALPHA) && strcmp(destinationFactorOld, GL_ONE_MINUS_SRC_ALPHA)
                    o.texMode = [];
                else
                    o.texMode=2;
                end
                end
            end
            
            if nargin == 1
                return
            end
            
            % initialise input parser
            args = varargin;
            p = inputParser;
            p.StructExpand = true;
            p.addParameter('size',NaN,@isfloat); % pixels
            p.addParameter('position',o.position,@isfloat); % [x,y] (pixels)
            p.addParameter('alpha',o.alpha,@isfloat); % opacity, 0..1
            
            try
                p.parse(args{:});
            catch
                warning('Failed to parse name-value arguments.');
                return;
            end
            
            args = p.Results;
            
            o.texSize = args.size;
            o.position = args.position;
            o.alpha = args.alpha;
            
            if ~isnan(o.winPtr)
                o.glsl = []; %MakeTextureDrawShader(o.winPtr, 'SeparateAlphaChannel');
            else
                o.glsl = [];
            end
        end

        
        function frameDraw(o,p)
            if ~o.stimValue
                return
            end
            
            % get textures to draw...
            idx = o.getTexIdx(o.id);
            
            texPtr = cellfun(@(x) x.ptr, o.texture(idx),'UniformOutput',true);
            
            r = floor(o.texSize./2); % pixels
            
            if size(r,2) == 1
                r = repmat(r,1,2); % square texture(s)
            end
            rect = bsxfun(@plus, kron([1,1],o.position),kron([-1,1],r));
            
            filterMode = 1; % bilinear interpolation
            if ~isnan(o.winPtr)
                Screen('DrawTextures',p.trial.display.ptr,texPtr,[],rect',[],filterMode,o.alpha);
            end
        end
        
%         function frameUpdate(o)
%         end
    end % methods
    
    methods (Access = public)
        
        
        function addTexture(o,id,img,varargin)
            % add IMG to the list of textures, with texture id ID.
            %
            % IMG can be a NxM matrix of pixel luminance values, an NxMx3 matrix
            % containing pixel RGB values or an NxMx4 matrix containing pixel RGBA
            % values. Alpha values range between 0 (transparent) and 255 (opaque)
            
            % FIXME: extend this to take an optional ALPHA value
            
            if ~isnan(o.winPtr)
                texPtr = Screen('MakeTexture',o.winPtr,img, [], [], o.texMode, [], o.glsl);
            else
                texPtr = img;
            end
            
            % check if this Id already exists...
            idx = o.getTexIdx(id);
            if isempty(idx)
                % new texture
                idx = length(o.texture)+1;
            end
            
            assert(numel(idx) == 1,'Duplicate texture Id %s found!',id);
            
            sz = size(img);
            o.texture{idx} = struct('id',id,'size',sz(1:2),'alpha',1.0','ptr',texPtr);
        end
        
        function closeAll(o)
            
            if ~isnan(o.winPtr)
                for i = 1:o.numTex
                    Screen('Close', o.texture{i}.ptr)
                end
            end
            
        end
        
%         function closeTexture(o,id)
%             
%         end
        
    end % methods
    
    methods (Access = private),
        function idx = getTexIdx(o,id)
            % get index in texPtr (or texIds) based on id
            if isempty(o.texture)
                idx = [];
                return;
            end
            
            if ~iscell(id)
                id = arrayfun(@(x) x, id, 'UniformOutput', 0);
            end
            
            % FIXME: extend this to take a cell array of id's
            %       idx = find(cellfun(@(x) isequal(x.id,id), o.texture));
            idx = cellfun(@(x) find(cellfun(@(y) isequal(x,y),o.texIds)),id,'UniformOutput',0);
            idx = cell2mat(idx);
        end
    end % methods
    
end % classdef
