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
        function frameDraw(s)
            % draw targets
            s.sc.hTargs.frameDraw();
            % draw cue
            s.sc.hCue.frameDraw();
        end
        
        function frameUpdate(s)
            
            % get the state controller ready
            sc = s.sc;
            
            % track eye position wrt fixation
            s.eyeXY = sc.eyeXY - sc.hFix.position;
            s.eyeXY = s.eyeXY .* [1 -1]; % flip y axis (because pixels run down)
            
            
            % start counting
            if sc.iFrame > (sc.timeChoiceMade + sc.timeChoiceGracePeriod)
                s.choiceX = s.choiceX + s.eyeXY(1);
                s.choiceY = s.choiceY + s.eyeXY(2);
                s.frameCnt = s.frameCnt + 1;
                
                if sc.iFrame > (sc.timeChoiceMade + sc.timeChoiceHold)
                    sc.choiceX = s.choiceX / s.frameCnt;
                    sc.choiceY = s.choiceY / s.frameCnt;
                    sc.choice = cart2pol(sc.choiceX, sc.choiceY)/pi*180;
                    sc.error  = angle(exp(1i * (sc.choice - sc.hMot.direction)/180*pi))/pi*180;
                    sc.setState(6); % transition to feedback
                    return
                end
            end
            
            % check if choice was made
            r = sqrt(sum(s.eyeXY.^2)); % euclidean distance
            if r < sc.windowMinEcc || r > sc.windowMaxEcc
                % break fixation
                sc.setState(7);
            end
            
        end
        
    end % methods
end % classdef