function [p,S]=faceForageDemo(settingsStruct)
S=struct;
S.protocolTitle='faceInvaders';
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

pname = 'NumFaces';
S.paramValues.(pname)=25;
S.paramDesc.(pname)='Number of Faces';
S.paramPldaps.(pname)='trial.faceForage.MotN';

pname = 'minSpeed';
S.paramValues.(pname)=5;
S.paramDesc.(pname)='Minimum Speed (degrees/sec)';
S.paramPldaps.(pname)='trial.faceForage.minSpeed';

pname = 'minSpeed';
S.paramValues.(pname)=5;
S.paramDesc.(pname)='Minimum Speed (degrees/sec)';
S.paramPldaps.(pname)='trial.faceForage.minSpeed';

pname = 'maxSpeed';
S.paramValues.(pname)=15;
S.paramDesc.(pname)='Maxiumum Speed (degrees/sec)';
S.paramPldaps.(pname)='trial.faceForage.maxSpeed';

    
%     if ~isfield(p.trial.(sn), 'motionType')
%         p.trial.(sn).motionType = 'linear';
%     end
%     
%     if ~isfield(p.trial.(sn), 'forcefield')
%         p.trial.(sn).forcefield = false;
%     end
%     
%     if ~isfield(p.trial.(sn), 'type')
%         p.trial.(sn).type       = 'face';
%     end

% settingsStruct.display.screenSize=[100 100 800 600];
p=pldaps(@marmoview.faceInvaders, S.subject, settingsStruct);
p.trial.pldaps.pause.preExperiment=1;