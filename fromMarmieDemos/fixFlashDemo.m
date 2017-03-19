function [p,S]=fixFlashDemo(settingsStruct)
S=struct;
S.protocolTitle='FixFlash';
S.subject='test';

% -------------------------------------------------------------------------
% MARMOVIEW access to PLDAPS parameters
% setup parameters that marmoview has access to -- THis is shitty and
% hacky, but I think it's the easiest way
S.paramValues=struct;

pname = 'MaxTrialLength';
S.paramValues.(pname)=5;
S.paramDesc.(pname)='Maximum Trial Length (Seconds)';
S.paramPldaps.(pname)='trial.pldaps.maxTrialLength';

pname = 'minFixDuration';
S.paramValues.(pname)=.1;
S.paramDesc.(pname)='Minimum fixation hold (Seconds)';
S.paramPldaps.(pname)='trial.stimulus.minFixDuration';

pname = 'maxFixDuration';
S.paramValues.(pname)=1;
S.paramDesc.(pname)='Maximum fixation hold (Seconds)';
S.paramPldaps.(pname)='trial.stimulus.maxFixDuration';

pname = 'fixWinRadius';
S.paramValues.(pname)=1.5;
S.paramDesc.(pname)='Fixation window radius (degrees)';
S.paramPldaps.(pname)='trial.stimulus.fixWinRadius';

pname = 'maxRewardCnt';
S.paramValues.(pname)=4;
S.paramDesc.(pname)='max reward count';
S.paramPldaps.(pname)='trial.stimulus.maxRewardCnt';

pname = 'fixWinRadius';
S.paramValues.(pname)=1.5;
S.paramDesc.(pname)='Fixation window radius (degrees)';
S.paramPldaps.(pname)='trial.stimulus.fixWinRadius';

pname = 'faceIndex';
S.paramValues.(pname)=1;
S.paramDesc.(pname)='which face (1 = Ellie, -1 = random)';
S.paramPldaps.(pname)='trial.stimulus.faceIndex';

pname = 'trialTimeout';
S.paramValues.(pname)=4;
S.paramDesc.(pname)='Penalty for break fixation (seconds)';
S.paramPldaps.(pname)='trial.stimulus.trialTimeout';


p=pldaps(@stimuli.fixflash.defaultParameters, S.subject, settingsStruct);
p.trial.pldaps.pause.preExperiment=1;