function [p,S]=faceForageDemo(settingsStruct)
S=struct;
S.protocolTitle='faceForage';

settingsStruct.display.screenSize=[100 100 800 600];
p=pldaps(@marmoview.faceForage, 'test', settingsStruct);
p.trial.pldaps.pause.preExperiment=1;