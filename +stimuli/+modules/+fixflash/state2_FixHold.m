classdef state2_FixHold < stimuli.objects.state
    % state 2 - hold fixation for reward
    
    properties
        eyeXY=nan(1,2) % variable for tracking the eye position during detected fixation
    end
    
    methods (Access = public)
        function s = state2_FixHold(varargin)
            fprintf(1,'%s\n',mfilename);
            
            s = s@stimuli.objects.state(2); % call the parent constructor
        end
        
        % --- Drawing commands
        function frameDraw(~,p,sn)
            
            % call draw functions for objects that should be shown
            p.trial.(sn).hFix.frameDraw();
            
        end % frameDraw
        
        % -- Evaluate state logic (prepare before drawing)
        function frameUpdate(s,p,sn)
            
            % get the state controller ready
            sc = s.sc;
            
            % --- Time to transition to next state if fixation is held
            startTime = sc.getTxTime(s.id) - p.trial.trstart;
            
            % --- eliminate penalty for slow engagement of fixation
            if (p.trial.(sn).fixStartOffset > 0)
                if ~p.trial.(sn).FixEngagePenalty
                    p.trial.(sn).fixStartOffset = 0;
                end
            end
            
            % --- If held to maximum duration --> move to next state
            if p.trial.ttime > startTime + p.trial.(sn).fixDuration + p.trial.(sn).fixStartOffset
                             
                if (p.trial.(sn).holdDuration == 0)
                    
                  p.trial.(sn).holdXY       = nanmean(s.eyeXY, 1); % record eye position
                  p.trial.(sn).holdDuration = p.trial.ttime - startTime;
                
                  % move to state 8 - inter-trial interval
                  p.trial.(sn).hFix.stimValue = false;  % offset fixation
                
         
                  if isfield(p.trial.(sn),'rewardForFixation')
                     if (rand < p.trial.(sn).rewardForFixation)
                         pds.behavior.reward.give(p);            
                     end
                  end
                
                  if ~p.trial.(sn).waitForSaccade
                     sc.setState(8);
                     return
                  end
                  
                end
    
            end
            
            if (p.trial.(sn).holdDuration > 0)  % already held requisite time, but still there
                     if p.trial.(sn).waitForSaccade
                       
                       % if rewardForFixation is negative, then use that as a time (secs)
                       % and if she holds at fix that amount or
                       % more, then she gets a drop of juice
                       if ~p.trial.(sn).rewardedfixation  
                          if isfield(p.trial.(sn),'rewardForFixation')    
                              if (p.trial.(sn).rewardForFixation < 0)
                                 holder = p.trial.ttime - startTime; %same as holdDuration
                                 exwait = p.trial.(sn).fixDuration - holder;
                                 if (exwait < p.trial.(sn).rewardForFixation)
                                     pds.behavior.reward.give(p);
                                     p.trial.(sn).rewardedfixation = true;
                                 end
                              end
                          end
                       end
                         
                        if ~p.trial.(sn).hFix.isFixated
                            
                            p.trial.(sn).holdDuration = p.trial.ttime - startTime;
                            
                            sc.setState(8);
                            return
                        end
                     end
            else
            
              % --- Check status of fixation
              if ~p.trial.(sn).hFix.isFixated % left fixation window
            
                p.trial.(sn).holdDuration = p.trial.ttime - startTime;

                p.trial.(sn).holdXY       = nanmean(s.eyeXY,1);
                
                sc.setState(7) % break fixation state

                return
              end
              
            end
            
            % keep track of fixated position
            s.eyeXY = [s.eyeXY; [p.trial.eyeX p.trial.eyeY]];
        end
        
    end % methods
    
end % classdef