function p = cleanUpandSave(p)
%         dv=cleanUpandSave@pldaps(dv);
        setupRNG=p.trial.stimulus.rngs.conditionerRNG;
%         glDeleteLists(dv.trial.stimulus.screenAxisList,1);

    %% prune unnecessary data
%         p.trial.stimulus.timeReward(isnan(p.trial.stimulus.timeReward))=[];
        
%         for jj=1:p.trial.stimulus.nMotions
%             iMotion=['motion' int2str(jj)];
%             fn=fieldnames(p.trial.stimulus.(iMotion));
%             for j=1:length(fn)
%                if(size(p.trial.stimulus.(iMotion).(fn{j}),2) == p.trial.pldaps.maxFrames) %assume its a frame variables
%                    p.trial.stimulus.(iMotion).(fn{j})(:,p.trial.iFrame:end)=[];
%                end
%             end
%         end

        %remove info from unshown frames
        fn=fieldnames(p.trial.stimulus);
        for j=1:length(fn)
           if(size(p.trial.stimulus.(fn{j}),2) == p.trial.pldaps.maxFrames) %assume its a frame variables
               p.trial.stimulus.(fn{j})(:,p.trial.iFrame:end)=[];
           end
        end
        for jj=1:p.trial.stimulus.nMotions
            iMotion=['motion' int2str(jj)];
            fn=fieldnames(p.trial.stimulus.(iMotion));
            for j=1:length(fn)
               if(size(p.trial.stimulus.(iMotion).(fn{j}),2) == p.trial.pldaps.maxFrames) %assume its a frame variables
                   p.trial.stimulus.(iMotion).(fn{j})(:,p.trial.iFrame:end)=[];
               end
            end
        end
        
        %%handle conditions
        %missing: condition should have its seed stored as field and there
        %should be an option to copy this seed to ensure identical trials
        thisCondition=p.conditions{p.trial.pldaps.iTrial};
        if ~p.trial.pldaps.goodtrial %need to repeat that condition
           insertPosition=randi(setupRNG,[p.trial.pldaps.iTrial+1 max(p.trial.pldaps.iTrial+1,length(p.conditions)+1)]);
           p.conditions=[p.conditions(1:insertPosition-1) thisCondition p.conditions(insertPosition:end)];
        end
        if(p.trial.pldaps.iTrial==length(p.conditions))
            p.trial.pldaps.finish=p.trial.pldaps.iTrial;
        end
        
        if p.trial.newEraSyringePump.use && p.trial.behavior.reward.iReward >1
%             display(sprintf('Trial %i\tTotal reward: %.3f ml.', p.trial.pldaps.iTrial,(sum(p.trial.behavior.reward.timeReward(1:p.trial.behavior.reward.iReward-1,2)))));
%         else
%             display(sprintf('Trial %i\tTotal reward: %f ms.', p.trial.pldaps.iTrial,(sum(p.trial.behavior.reward.timeReward(2,1:p.trial.behavior.reward.iReward-1)))));
        end
        
        %breakFixationPenalty
        if ~p.trial.pldaps.goodtrial && ~isnan( p.trial.stimulus.timeFpEntered) && p.trial.stimulus.breakFixPenalty>0 && ~p.trial.pldaps.quit>0
            %flip to red screen
            Screen('FillRect', p.trial.display.overlayptr,p.trial.display.clut.bRed);
            Screen('Flip', p.trial.display.ptr);
            %wait
            WaitSecs(p.trial.stimulus.breakFixPenalty);
            %flipBack
            Screen('FillRect', p.trial.display.overlayptr,0);
            Screen('Flip', p.trial.display.ptr);
            
        end
%         glDeleteLists(p.trial.stimulus.dotsList,1);
        
%         % Stop playback:
%         Screen('PlayMovie', dv.trial.stimulus.movie, 0);
%         % Close movie:
%         Screen('CloseMovie', dv.trial.stimulus.movie);
    end
