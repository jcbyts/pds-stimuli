function [p,S]=ChelseaFaceInvaders(settingsStruct)
S=struct;
S.protocolTitle='faceInvaders';
S.subject='Chelsea';

% setup parameters that marmoview has access to -- THis is shitty and
% hacky, but I think it's the easiest way
S.paramValues=struct;
S.paramValues.MaxTrialLength=5;
S.paramDesc.MaxTrialLength='Maximum Trial Length (Seconds)';
S.paramPldaps.MaxTrialLength='trial.pldaps.maxTrialLength';

% settingsStruct.display.screenSize=[100 100 800 600];
p=pldaps(@marmoview.faceInvaders, S.subject, settingsStruct);
p.trial.pldaps.pause.preExperiment=1;