function runKreisReizMT(subject, pauseBeforeExperiment)

if nargin<2
    pauseBeforeExperiment = true;
    if nargin<1
        subject = 'Ellie';
    end
end

settingsStruct.pldaps.useModularStateFunctions = false;
settingsStruct.pldaps.trialMasterFunction='runTrial';

settingsStruct.pldaps.trialStates.trialReplaySetup = 8;
settingsStruct.pldaps.trialStates.frameReplayUpdate = 9;


    settingsStruct.eyelink.use=true;
    settingsStruct.mouse.useAsEyepos=false;

% settingsStruct.pldaps.useModularStateFunctions = true;
% settingsStruct.pldaps.trialMasterFunction='runModularTrial';
% settingsStruct.pldaps.save.mergedData=0;
settingsStruct.session.subject=subject;


settingsStruct.pldaps.draw.framerate.show=false;
settingsStruct.pldaps.draw.framerate.use=false;
settingsStruct.pldaps.draw.framerate.location=[-15 -5];
settingsStruct.pldaps.draw.framerate.size=[10 5];

if pauseBeforeExperiment
    settingsStruct.pldaps.pause.preExperiment = true;
else
    settingsStruct.pldaps.pause.preExperiment = false;
end

p=pldaps(@kreisreizGTA,subject,settingsStruct);
% p.trial.pldaps.draw.grid.use=false;
p.trial.eyemarker.use=true;
p.trial.eyemarker.refineCalibratrionFromWindow = true;
p.trial.eyemarker.drawStims = false;
p.trial.eyemarker.targetstimulus='fixation';


p.run
