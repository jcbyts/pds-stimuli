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

%--------------------------------------------------------------------------
% Sparse noise
sn='sparseNoise';
settingsStruct.(sn).stateFunction.name='v1mapping.sparseNoise';
settingsStruct.(sn).use=false;
settingsStruct.(sn).stateFunction.acceptsLocationInput=false;
settingsStruct.(sn).stateFunction.order=1;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.trialPrepare=true;
settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;

S.paramValues.(sn) = false;
S.paramDesc.(sn)   = 'Show sparse noise stimulus (1 or 0)';
S.paramPldaps.(sn) = ['trial.' sn '.use'];
% 
% pname = 'size';
% S.paramValues.(pname)=4;
% S.paramDesc.(pname)='Penalty for break fixation (seconds)';
% S.paramPldaps.(pname)='trial.stimulus.trialTimeout';
% 
%    if ~isfield(p.trial.(sn), 'size')
%             p.trial.(sn).size=[10 10];
%         end
%         
%         if ~isfield(p.trial.(sn), 'pxsize')
%             p.trial.(sn).pxsize=2;
%         end
%         
%         if ~isfield(p.trial.(sn), 'gazeContingent')
%             p.trial.(sn).gazeContingent=0;
%         end
%         
%         if ~isfield(p.trial.(sn), 'contrast')
%             p.trial.(sn).contrast = .5;
%         end
%         
%         if ~isfield(p.trial.(sn), 'dc')
%             p.trial.(sn).dc = .5;
%         end
%         
%         if ~isfield(p.trial.(sn), 'sigma')
%             p.trial.(sn).sigma = .1;
%         end
%         
%         if ~isfield(p.trial.(sn), 'xy')
%             p.trial.(sn).xy = [500 500];
%         end
%         
%         if ~isfield(p.trial.(sn), 'type')
%             p.trial.(sn).type = 'sparse';
%         end
%         
%         p.trial.(sn).on = true;

%--------------------------------------------------------------------------
% make a pldaps
p=pldaps(@stimuli.fixflash.defaultParameters, S.subject, settingsStruct);
p.trial.pldaps.pause.preExperiment=1;


%--------------------------------------------------------------------------
% Add stimulus modules
p = v1mapping.sparseNoise(p, p.trial.pldaps.trialStates.experimentPostOpenScreen);