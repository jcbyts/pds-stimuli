classdef ffflash < stimuli.objects.stimulus
    
   properties
        color
   end
   
   methods
       % object constructor
       function obj = ffflash(varargin)
           
           ip = inputParser();
           ip.KeepUnmatched = true;
           ip.addParameter('color', [1, 1, 1]);
           ip.parse(varargin{:});
           
           % pass unmatched name-value arguments to the parent constructor
           nextargs = [fieldnames(ip.Unmatched) struct2cell(ip.Unmatched)]';
           
           obj = obj@stimuli.objects.stimulus(nextargs{:});
           
           % update optional parameters
           obj.color = ip.Results.color;
           
       end
       
       function frameUpdate(~, ~)
            % do nothing
       end
       
       function frameDraw(obj, p)
           if ~obj.stimValue
               Screen('FillRect', p.trial.display.ptr, p.trial.display.bgColor)
           else
               Screen('FillRect', p.trial.display.ptr, obj.color)
           end
       end
       
   end
end