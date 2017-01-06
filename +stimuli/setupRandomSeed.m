function p=setupRandomSeed(p, sn)
% set random seed for a PLDAPS session
% p=setupRandomSeed(p)

if nargin < 2
    sn = 'stimulus';
end

% 09.08.2016 Jacob L. Yates <jacoby8s@gmail.com> copied from Jonas Knoll
if ~isField(p.trial, [sn '.rngs.randomNumberGenerater'])
    p.trial.(sn).rngs.randomNumberGenerater='mt19937ar';
end
p.trial.(sn).rngs.sessionSeed=fix(1e6*sum(clock));
p.trial.(sn).rngs.sessionRNG=RandStream(p.trial.(sn).rngs.randomNumberGenerater, 'seed', p.trial.(sn).rngs.sessionSeed);
if datenum(version('-date')) >= datenum('February 9, 2012') %strcmp(version, '7.14.0.739 (R2012a)')
    RandStream.setGlobalStream(p.trial.(sn).rngs.sessionRNG);
else
    RandStream.setDefaultStream(p.trial.(sn).rngs.sessionRNG); 
end
p.defaultParameters.(sn).rngs.trialSeeds = randi(2^32, [3e3 1]);
