classdef grating < stimuli.objects.stimulus
    % GRATING draws a sinewave grating
    
    properties
        dim                     % dimensions of the texture (pixels)
        position                % x, y position pixels
        contrast@double         % Michelson contrast
        ori@double              % Orientation
        sf@double               % spatial frequency
        tf@double               % temporal frequency
        phi@double              % phase
        rad@double              % radius
    end
    
    properties (Access = private)
        bgColorOffset@double    % [1 x 4] vector that offsets color (See the CreateProceduralGrating.m for use)
        tex                     % texture pointer
        mask                    % mask pointer
    end
    
    methods
        % constructor
        function obj = grating(p, varargin)
            % hartleybase
            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.addParameter('contrast',  .2)
            ip.addParameter('position', [])
            ip.addParameter('rad',        [])
            ip.parse(varargin{:})
            
            nextargs = [fieldnames(ip.Unmatched) struct2cell(ip.Unmatched)]';
            
            obj = obj@stimuli.objects.stimulus(nextargs{:}); % call parent constructer (hartley is a target)
            
            obj.contrast = ip.Results.contrast;
            
            obj.rad = ip.Results.rad;
            
            ppd = p.trial.display.ppd;
            
            if isempty(ip.Results.position)
                obj.position = p.trial.display.ctr(1:2);
            else
                obj.position = ip.Results.position;
            end
               
            
            if isempty(obj.rad) % fullfield
                obj.dim = p.trial.display.winRect(3:4);
            else 
                obj.dim = obj.rad * ppd * [1 1];
            end

            
            % initialize some values
            obj.tf  = 0; % temporal frequency
            obj.ori = 0; % orientation
            obj.sf  = 2; % spatial frequency
            obj.phi = 0; % phase

            obj.bgColorOffset = [0 0 0 0]; % gray
            
            % create procedural texture. Procedural textures evalute
            % functions on the graphics card when the texture is drawn.
            % They take in parameters, such sas the contrst, phase,
            % spatial freq, etc.
            obj.tex  = CreateBetterProceduralSineGrating(p.trial.display.ptr, obj.dim(1), obj.dim(2), obj.bgColorOffset, obj.rad*ppd, .5);
%             obj.tex  = CreateProceduralSineGrating(p.trial.display.ptr, obj.dim(1), obj.dim(2), obj.bgColorOffset, obj.rad*ppd, .5);

        end
        
        
        function trialSetup(~, ~)
            
        end
        
        function frameUpdate(~, ~)

        end
        
        function trialCleanup(obj, ~)
            if ~isempty(obj.tex)
                Screen('Close', obj.tex);
                obj.tex = [];
            end
        end
        
        
        function frameDraw(obj, p)
            
            if ~obj.stimValue
                return
            end
            dstRect = CenterRectOnPoint([0 0 obj.dim], obj.position(1), obj.position(2));
               
            Screen('BlendFunction', p.trial.display.ptr, GL_ONE, GL_ONE);
%             disp(obj.ori)
            Screen('DrawTexture', p.trial.display.ptr, obj.tex, [], dstRect, 0, [], [], [], [], [], [obj.phi+180, obj.sf/p.trial.display.ppd, obj.contrast, obj.ori, obj.ori, 0, 0, 0]);
%             Screen('DrawTexture', p.trial.display.ptr, obj.tex, [], [0 0 obj.dim], obj.ori, [], [], [], [], kPsychDontDoRotation, [obj.phi+180, obj.sf/p.trial.display.ppd, p.trial.display.ppd, obj.contrast, 0]);
            Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);

        end
        
    end
    
    
end



