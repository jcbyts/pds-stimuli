function trialSetup(p, sn)
% trial setup for simple dot trials

%p.trial will hold all variables for this trials. Once the Trial is
%done all changed variables will be copied to the PDS structure.
p.trial.pldaps.goodtrial = 1;


p.trial.(sn).abort=0;
p.trial.(sn).reward=0;
p.trial.(sn).rewardAmount=0;


end