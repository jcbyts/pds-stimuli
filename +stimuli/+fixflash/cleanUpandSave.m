function p = cleanUpandSave(p, sn)

% --- Staircase parameters
if p.trial.(sn).staircaseOn && p.trial.(sn).minFixDuration < p.trial.(sn).maxFixDuration
    
    
    lastError = p.trial.(sn).hTrial.error;
    
    if p.trial.pldaps.iTrial < numel(p.conditions)
        
        switch lastError
            case 0 % staircase up
                p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration + p.trial.(sn).staircaseStep;
            case 1 % do nothing
                p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration;
            case 2 % staircase down
                p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration - .75*p.trial.(sn).staircaseStep;
        end
        
        
        
        %                 end
        %                 if lastError~=1 && p.trial.(sn).hTrial.holdDuration > p.trial.(sn).hTrial.fixDur;
        %                         p.conditions{p.trial.pldaps.iTrial + 1}.(sn).maxFixDuration =  p.trial.(sn).maxFixDuration + p.trial.(sn).staircaseStep;
        %                         p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration + p.trial.(sn).staircaseStep;
        %                 elseif lastError~=1 && p.trial.(sn).hTrial.holdDuration < p.trial.(sn).minFixDuration;
        %                         p.conditions{p.trial.pldaps.iTrial + 1}.(sn).maxFixDuration =  p.trial.(sn).maxFixDuration - p.trial.(sn).staircaseStep;
        %                         p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration - p.trial.(sn).staircaseStep;
        %                 else
        %                         p.conditions{p.trial.pldaps.iTrial + 1}.(sn).maxFixDuration =  p.trial.(sn).maxFixDuration;
        %                         p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration;
        %                 end
        
    end % trial number
    
    
%     p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration = min(.5, p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration);
    
end % staircase on


Screen('FillRect', p.trial.display.overlayptr,p.trial.display.bgColor);
Screen('Flip', p.trial.display.ptr);

% --- Plotting
%         figNum = 999;
%         figure(999)
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
