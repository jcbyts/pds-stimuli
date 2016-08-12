function motionStates(p, state, sn)
% fixation state management

switch state
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        checkMotionStates(p, sn)
        
    case p.trial.pldaps.trialStates.trialSetup
        

        
        
        p.trial.(sn).state=p.trial.(sn).states.START;
        
    case p.trial.pldaps.trialStates.frameDraw
        for kMotion=1:numel(p.trial.motions)
            p.trial.(sn).(p.trial.motions{kMotion}).draw
        end
        
end
end

function checkMotionStates(p, sn)
if p.trial.(sn).showMotion
    
    for kMotion=1:numel(p.trial.motions)
        p.trial.(sn).(p.trial.motions{kMotion}).visible=true;
        p.trial.(sn).(p.trial.motions{kMotion}).update;
    end
    
    if p.trial.iFrame > (p.trial.(sn).stimDur-p.trial.(sn).frameStimOn)
    end
end
end