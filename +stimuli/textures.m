classdef textures < handle
  % Matlab class for drawing textures using the psych. toolbox.
  %
  % The class constructor can be called with a range of arguments:
  %
  %   size     - texture size (wdth,hght; pixels)
  %   position - center of texture (x,y; pixels)
  
  % 26-06-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>
  
  properties (Access = public),
    id; % id of the texture to show on call to drawTextures();

    size@double; % width, or [wdth, hght] (pixels)
    position@double = [0.0, 0.0]; % position [x,y] (pixels)
    
    alpha@double = 1.0; % alpha (opacity) for the selected texture(s)
  end
        
  properties (Access = private)
    winPtr; % ptb window
    
    % each entry in the texture contains a structure with fields:
    %   id - the texture id
    %   size - the texture size (wdth, hght)
    %   alpha - alpha value (default: 1)
    %   ptr - a ptb texture pointer
    texture = {};
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
    % dependent property set methods
%     function o = set.alpha(o,value),
%       % get selected textures...
%       idx = o.getTexIdx(o.id);
% 
%       if isscalar(value),
%         value = repmat(value,size(idx));
%       end
%       
%       assert(length(value) == length(idx));
%       
%       for ii = 1:length(idx),
%         o.texture{idx(ii)}.alpha = value(ii);
%       end
%     end
    
    % dependent property get methods
%     function value = get.alpha(o),
%       % get selected textures...
%       idx = o.getTexIdx(o.id);
% 
%       value = cellfun(@(x) x.alpha, o.texture(idx), 'UniformOutput', 1);
%     end

    function value = get.texIds(o)
      value = cellfun(@(x) x.id, o.texture, 'UniformOutput', 0);
    end
    
    function value = get.numTex(o)
      value = length(o.texture);
    end
  end
  
  methods (Access = public)
    function o = textures(winPtr,varargin) % marmoview's initCmd?
      o.winPtr = winPtr;
      
      if nargin == 1
        return
      end

      % initialise input parser
      args = varargin;
      p = inputParser;
%       p.KeepUnmatched = true;
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
    
      o.size = args.size;
      o.position = args.position;
      o.alpha = args.alpha;
    end
        
    function beforeTrial(o)
    end
    
    function beforeFrame(o)
      o.drawTextures();
    end
        
    function afterFrame(o)
    end
  end % methods
    
  methods (Access = public)        
    function drawTextures(o)
      % get textures to draw...
      idx = o.getTexIdx(o.id);
      
      texPtr = cellfun(@(x) x.ptr, o.texture(idx),'UniformOutput',true);

%       alpha = cellfun(@(x) x.alpha, o.texture(idx),'UniformOutput',true);

%       sz = arrayfun(@(x) x.sz, o.tex(idx),'UniformOutput',true);      
%       rect = kron([1,1],o.position) + kron([-1,+1],sz);

      r = floor(o.size./2); % pixels
%       rect = kron([1,1],o.position) + kron(r(:),[-1, -1, +1, +1]);

      if size(r,2) == 1
        r = repmat(r,1,2); % square texture(s)
      end
      rect = bsxfun(@plus, kron([1,1],o.position),kron([-1,1],r));
    
      filterMode = 1; % bilinear interpolation
      Screen('DrawTextures',o.winPtr,texPtr,[],rect',[],filterMode,o.alpha);
    end
    
    function addTexture(o,id,img,varargin)
      % add IMG to the list of textures, with texture id ID.
      %
      % IMG can be a NxM matrix of pixel luminance values, an NxMx3 matrix
      % containing pixel RGB values or an NxMx4 matrix containing pixel RGBA
      % values. Alpha values range between 0 (transparent) and 255 (opaque)
       
      % FIXME: extend this to take an optional ALPHA value
      
      texPtr = Screen('MakeTexture',o.winPtr,img);
      
      % check if this Id already exists...
      idx = o.getTexIdx(id);
      if isempty(idx)
        % new texture
        idx = length(o.texture)+1;
      end
      
      assert(numel(idx) == 1,'Duplicate texture Id %s found!',id);

      sz = size(img);
      o.texture{idx} = struct('id',id,'size',sz(2:1),'alpha',1.0','ptr',texPtr);
    end
    
    function closeAll(o)
       
%         idx = o.getTexIdx(o.id);
%       
%       texPtr = cellfun(@(x) x.ptr, o.texture(idx),'UniformOutput',true);
        
	  Screen('Close', cell2mat(o.texIds))
      
%       o.id = [];
%       o.texIds = {};
%       o.numTex = 0;
        
    end
    
    function closeTexture(o,id)
        
    end
        
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
