function p = updateConditions(p, sn, varName, val)
% Update PLDAPS conditions
% p = updateConditions(p, sn, varName, val)


%upload to conditions for next trial to live on
currTrial = size(p.data,2);
for iTrial = (currTrial+1):numel(p.conditions)
    p.conditions{iTrial}.(sn).(varName) = val;
end