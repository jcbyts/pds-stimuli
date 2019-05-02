%% Shaun way (modified to use IOport)
pdsca
p = pldaps;
a = marmoview.newera(p.trial.newEraSyringePump)

% 'port', p.trial.newEraSyringePump.port, ...
%     'diameter',p.trial.newEraSyringePump.diameter,...
%     'volume',p.trial.newEraSyringePump.volume,'rate',...
%     p.trial.newEraSyringePump.rate)
% a = p.trial.reward
%%
% a.volume = 1;
a.deliver();



%% Jonas way

p = pldaps;
p.trial.newEraSyringePump.allowNewDiameter = true;
pds.newEraSyringePump.setup(p);

%%
pds.newEraSyringePump.give(p)