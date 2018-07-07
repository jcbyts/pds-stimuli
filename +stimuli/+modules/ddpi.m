function p = ddpi(p, state, sn)
% CSD FLASH: draw a full-field flash

if nargin<3
    sn='ddpi';
end


switch state
    
    case p.trial.pldaps.trialStates.trialSetup
        
        if ~isfield(p.trial.(sn), 'bitNumber')
            p.trial.(sn).bitNumber = 10;
        end
        
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
end