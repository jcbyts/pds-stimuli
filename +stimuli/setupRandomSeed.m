function p=setupRandomSeed(p)
% set random seed for a PLDAPS session
% p=setupRandomSeed(p)

% 09.08.2016 Jacob L. Yates <jacoby8s@gmail.com> copied from Jonas Knoll
p.trial.stimulus.rngs.sessionSeed=fix(1e6*sum(clock));
p.trial.stimulus.rngs.sessionRNG=RandStream(p.trial.stimulus.randomNumberGenerater, 'seed', p.trial.stimulus.rngs.sessionSeed);
if datenum(version('-date')) >= datenum('February 9, 2012') %strcmp(version, '7.14.0.739 (R2012a)')
    RandStream.setGlobalStream(p.trial.stimulus.rngs.sessionRNG);
else
    RandStream.setDefaultStream(p.trial.stimulus.rngs.sessionRNG); 
end
p.defaultParameters.stimulus.rngs.trialSeeds = randi(2^32, [3e3 1]);
