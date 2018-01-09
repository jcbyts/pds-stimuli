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
            if p.trial.(fixationsn).hFix(1).isFixated
                
                timeSinceFixation = p.trial.ttime + p.trial.trstart - p.trial.(p.trial.(sn).fixationBehavior).hFix(1).fixlog(end);
                
                % time each target should come on
                uniqueOnsets = numel(p.trial.(sn).targsOnset);


                if uniqueOnsets == 1 
                    if timeSinceFixation >= p.trial.(sn).targsOnset && (timeSinceFixation < p.trial.(sn).targsOnset(iTarg) + p.trial.(sn).targsDuration(iTarg))
                        for iTarg = 1:nTargs
                            p.trial.(sn).currTarg(iTarg).stimValue = showTargets;
                        end
                    else % turn off targets
                        for iTarg = 1:nTargs
                            p.trial.(sn).currTarg(iTarg).stimValue = false;
                        end
                    end
                else
                    for iTarg = 1:nTargs
                        if timeSinceFixation >= p.trial.(sn).targsOnset(iTarg) && timeSinceFixation < p.trial.(sn).targsOnset(iTarg) + p.trial.(sn).targsDuration(iTarg)
                            p.trial.(sn).currTarg(iTarg).stimValue = showTargets;
                        else
                            p.trial.(sn).currTarg(iTarg).stimValue = false;
                        end
                    end
                end

                % if all targets are on move to next state
                if all([p.trial.(sn).currTarg(:).stimValue]>0)
                    warning('This should be if All targets HAVE been turned on. NOT are they currently on. Fix it.')
                    sc.setState(1); % move to next state
                    return
                end



            end
            
        end % after frame
        
    end % methods
    
end % classdef