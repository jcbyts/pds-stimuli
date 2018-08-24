classdef state5_HoldChoice < stimuli.objects.state
    % state 5 - hold choice
    
    
    properties
        eyeXY
        choice = 0;
        choiceX = 0;
        choiceY = 0;
        frameCnt = 0;
    end
    
    methods (Access = public)
        function s = state5_HoldChoice(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(5); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(s,p,sn)
            % draw targets
            p.trial.(sn).targets.hTargs.frameDraw(p);
            % draw cue
            p.trial.(sn).cue.hCue.frameDraw(p);
        end
        
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;
            
            % track eye position wrt fixation
            s.eyeXY = [p.trial.eyeX p.trial.eyeY] - p.trial.(sn).fixation.hFix.position;
            s.eyeXY = s.eyeXY .* [1 -1]; % flip y axis (because pixels run down)
            
            
            % start counting
            if p.trial.iFrame > (p.trial.(sn).frameChoiceMade + ceil(p.trial.(sn).timing.choiceGracePeriod / p.trial.display.ifi))
                s.choiceX = s.choiceX + s.eyeXY(1);
                s.choiceY = s.choiceY + s.eyeXY(2);
                s.frameCnt = s.frameCnt + 1;
                
                if p.trial.iFrame > (p.trial.(sn).frameChoiceMade + ceil(p.trial.(sn).timing.choiceHold / p.trial.display.ifi))
                    p.trial.(sn).choiceX = s.choiceX / s.frameCnt;
                    p.trial.(sn).choiceY = s.choiceY / s.frameCnt;
                    p.trial.(sn).choice = cart2pol(p.trial.(sn).choiceX, p.trial.(sn).choiceY)/pi*180;
                    p.trial.(sn).error  = angle(exp(1i * (p.trial.(sn).choice - p.trial.(sn).motion.direction)/180*pi))/pi*180;
                    sc.setState(6); % transition to feedback
                    return
                end
            end
            
            % check if choice was made
            r = sqrt(sum(s.eyeXY.^2)); % euclidean distance
            if r < (p.trial.(sn).targets.windowMinEcc * p.trial.display.ppd) || ...
                    r > (p.trial.(sn).targets.windowMaxEcc * p.trial.display.ppd)
                % break fixation
                sc.setState(7);
            end
            
        end
        
    end % methods
end % classdef