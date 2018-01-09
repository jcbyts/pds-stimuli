classdef state0_TurnOnTargets < stimuli.objects.state
    % state 0 - wait for fixation
    
    % --- Parameters that make this state operate
    properties (Access = public)
        
        % properties for flashing the fixation target
        showFix=false;
        frameCnt  = 0; % frame counter (for this state?)
        faceFlash = 0; % face intermixed in flashing point
    end
    
    methods (Access = public)
        
        function s = state0_TurnOnTargets(varargin) % constructor
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(0); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(~,p,sn)
            
            nTargs = numel(p.trial.(sn).currTarg);

            for iTarg = 1:nTargs
                p.trial.(sn).currTarg.frameDraw(p);
            end
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;
            
            nTargs = numel(p.trial.(sn).currTarg);
            
            % string that points to the fixation module where hFix is
            fixationsn = p.trial.(sn).fixationBehavior; 

            % if fixation is obtained, Turn on the targets at the appropriate time
            lastFixation = find(p.trial.(fixationsn).hFix(1).fixlog(1,:)>0, 1, 'last');
            fixationObtained = p.trial.(fixationsn).hFix(1).fixlog(2,lastFixation) - p.trial.trstart;

            timeTillGo = p.trial.ttime - p.trial.(fixationsn).minFixationDuration + fixationObtained;

            if timeTillGo > 0
            
                % Check if targets are fixated
                for iTarg = 1:numel(p.trial.(sn).hTarg)
                    p.trial.(sn).hTarg(iTarg).frameUpdate(p);
    
                    if p.trial.(sn).hTarg(iTarg).isFixated
                        p.trial.(sn).choice = iTarg;
                        p.trial.(sn).RT     = p.trial.ttime;
                        sc.setState(2); % move to hold target
                        return
                    end
    
                end
            end               
            
        end % after frame
        
    end % methods
    
end % classdef