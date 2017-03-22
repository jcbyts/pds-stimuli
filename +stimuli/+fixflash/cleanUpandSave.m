function p = cleanUpandSave(p, sn)

        % --- Staircase parameters
        if p.trial.(sn).staircaseOn
            
            
            lastError = p.trial.(sn).hTrial.error;
            if p.trial.pldaps.iTrial < numel(p.conditions)
                switch lastError
                    case 0 % held the whole way
                        p.conditions{p.trial.pldaps.iTrial + 1}.(sn).maxFixDuration =  p.trial.(sn).maxFixDuration + p.trial.(sn).staircaseStep;
                        p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration + p.trial.(sn).staircaseStep;
                    case 2 % broke fixation after obtaining
                        p.conditions{p.trial.pldaps.iTrial + 1}.(sn).maxFixDuration =  p.trial.(sn).maxFixDuration - p.trial.(sn).staircaseStep;
                        p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration - p.trial.(sn).staircaseStep;
                    otherwise % never obtained fixation -- Do nothing
                        
                end
                
            end % trial number
            
            
        end % staircase on


        Screen('FillRect', p.trial.display.overlayptr,p.trial.display.bgColor);
        Screen('Flip', p.trial.display.ptr);
        
        % --- Plotting
%         outcomes = cellfun(@(x) x.stimulus.hTrial.error, p.data);
%         errs = get(p.trial.(sn).hOutcomes, 'XData');
%         n = numel(errs);
%         num = zeros(n,1);
%         for i = 1:n
%            num(i) = sum(outcomes == errs(i)); 
%         end
%         
%         p.trial.(sn).hOutcomes.YData = num;
%         
%         
%         histogram(p.trial.(sn).hAxes(2), cellfun(@(x) x.(sn).hTrial.fixDuration, p.data), 'FaceColor', .5*[1 1 1]);
%         xlabel(p.trial.(sn).hAxes(2), 'Seconds');
%         p.trial.(sn).gui.update(p,sn);
          stimuli.fixflash.updateGUI(p, sn);
        
%         %breakFixationPenalty
%         if ~p.trial.pldaps.goodtrial && ~isnan( p.trial.stimulus.timeFpEntered) && p.trial.stimulus.breakFixPenalty>0 && ~p.trial.pldaps.quit>0
%             %flip to red screen
%             Screen('FillRect', p.trial.display.overlayptr,p.trial.display.clut.bRed);
%             Screen('Flip', p.trial.display.ptr);
%             %wait
%             WaitSecs(p.trial.stimulus.breakFixPenalty);
%             %flipBack
%             Screen('FillRect', p.trial.display.overlayptr,0);
%             Screen('Flip', p.trial.display.ptr);
%             
%         end

    end
