function updateConditions(p, sn)


c.Nr=1; %one condition;
if isinf(p.defaultParameters.pldaps.finish)
    p.conditions=repmat({c},1,200);
    p.defaultParameters.pldaps.finish = length(p.conditions);
else
    p.conditions=repmat({c},1,p.defaultParameters.pldaps.finish);
end