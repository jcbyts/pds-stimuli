function [p,S]=faceForageDemo(settingsStruct)
S=struct;
S.protocolTitle='faceForage';
S.subject='test';

% settingsStruct.display.screenSize=[100 100 800 600];
p=pldaps(@marmoview.faceForage, S.subject, settingsStruct);
p.trial.pldaps.pause.preExperiment=1;