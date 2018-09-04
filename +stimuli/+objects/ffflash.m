classdef ffflash < stimuli.objects.stimulus
    
   properties
        color
        bgColor
   end
   
   methods
       % object constructor
       function obj = ffflash(winPtr, varargin)
           
           ip = inputParser();
           ip.KeepUnmatched = true;
           ip.addParameter('color', [1, 1, 1]);
           ip.addParameter('bgColor', repmat(.5, 1, 3))
           ip.parse(varargin{:});
           
           % pass unmatched name-value arguments to the parent constructor
           nextargs = [fieldnames(ip.Unmatched) struct2cell(ip.Unmatched)]';
           
           obj = obj@stimuli.objects.stimulus(winPtr, nextargs{:});
           
           % update optional parameters
           obj.color = ip.Results.color;
           obj.bgColor = ip.Results.bgColor;
           
       end
       
       function frameUpdate(~, ~)
            % do nothing
       end
       
       function frameDraw(obj)
           if ~obj.stimValue
               Screen('FillRect', obj.ptr, obj.bgColor)
           else
               Screen('FillRect', obj.ptr, obj.color)
           end
       end
       
   end
end