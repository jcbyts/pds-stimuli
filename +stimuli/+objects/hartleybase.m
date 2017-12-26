classdef hartleybase < stimuli.objects.stimulus
    % HARTLEY draws full-field hartley basis stimuli
    
    properties
        dim                     % dimensions of the texture (pixels)
        contrast@double         % Michelson contrast
        kx@double               % x spatial frequency
        ky@double               % y spatial frequency
        M@double                % Scale factor for frequency (default: 1)
        tf@double               % temporal frequency
        phi@double              % phase
    end
    
    properties (Access = private)
        bgColorOffset@double    % [1 x 4] vector that offsets color (See the CreateProceduralGrating.m for use)
        tex                     % texture pointer
        mask                    % mask pointer
    end
    
    methods
        % constructor
        function obj = hartleybase(p, varargin)
            % hartleybase
            ip = inputParser();
            ip.KeepUnmatched = true;
            ip.addParameter('contrast',  .2)
            ip.addParameter('M',         1)
            ip.addParameter('dim',       [])
            ip.parse(varargin{:})
            
            nextargs = [fieldnames(ip.Unmatched) struct2cell(ip.Unmatched)]';
            
            obj = obj@stimuli.objects.stimulus(nextargs{:}); % call parent constructer (hartley is a target)
            
            obj.contrast = ip.Results.contrast;
            
            obj.M   = ip.Results.M;
            
            if isempty(ip.Results.dim)
                obj.dim = p.trial.display.winRect(3:4);
            else
                obj.dim = ip.Results.dim;
            end
            
            % initialize some values
            obj.tf  = 0; % temporal frequency
            obj.kx  = 1; % x spatial frequency
            obj.ky  = 1; % y spatial frequency
            obj.phi = 0; % phase

            obj.bgColorOffset = [0 0 0 0]; % gray
            
            % create procedural texture. Procedural textures evalute
            % functions on the graphics card when the texture is drawn.
            % They take in parameters, such sas the contrst, phase,
            % spatial freq, etc.
            obj.tex  = CreateProceduralHartleyBasis(p.trial.display.ptr, obj.dim(1), obj.dim(2), obj.bgColorOffset, [], .5);
            
        end
        
        
        function trialSetup(~, ~)
            
        end
        
        function frameUpdate(~, ~)
            
            % Do Nothing
% %             h.phi=sin(2*pi*h.tf*time);
        end
        
        
        function frameDraw(obj, p)
            
            if ~obj.stimValue
                return
            end
                
            Screen('DrawTexture', p.trial.display.ptr, obj.tex, [], [0 0 obj.dim], 0, [], [], [], [], kPsychDontDoRotation, [obj.kx, obj.ky, p.trial.display.ppd, obj.contrast, obj.M, obj.phi, 0, 0]);
                
        end
        
    end
    
    
end



