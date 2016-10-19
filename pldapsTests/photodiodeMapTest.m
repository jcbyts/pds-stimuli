%% Test Stimulus Modules
% To map V1 RFs, we use a set of stimuli
% 1) pixelNoise
% 2) sparseNoise
% 3) gaussianNoise
% 4) natBackground
% 5) hartleyGratings

%% Flash black to white to test photodiode

p=pldaps(@plain);
p=openScreen(p);
p.trial.display.switchOverlayCLUTs=0;
p.trial.display.useOverlay=1;
p=pds.datapixx.init(p);
%%
iter=5;
t0=GetSecs;
t1=GetSecs-t0;

while t1<10
    
    t1=GetSecs-t0;
    if iter<5
        Datapixx('SetDoutValues', 2^1); Datapixx('RegWr');
        Screen('FillRect', p.trial.display.ptr, 1);
        Datapixx('SetDoutValues',0); Datapixx('RegWr');
        Screen('Flip', p.trial.display.ptr);
        if iter==0
            iter=100;
        end
    else
        Screen('FillRect', p.trial.display.ptr, 0);
        Screen('Flip', p.trial.display.ptr);
    end
    
    iter=iter-1;
end


%% Open a pldaps window
subject='test';


sca
clear settingsStruct
Screen('Preference','ScreenToHead', 1,0,0);
settingsStruct.newEraSyringePump.allowNewDiameter=1;
settingsStruct.sound.deviceid=[];
% add modular trial functions
settingsStruct.eyemarker.use=false;
settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';
settingsStruct.pldaps.save.mergedData=0;
settingsStruct.session.subject=subject;
settingsStruct.behavior.reward.defaultAmount=.01;

%--------------------------------------------------------------------------
% Turn off Eyelink if test mode
if strcmp(subject, 'test')
    settingsStruct.eyelink.use=false;
    settingsStruct.mouse.useAsEyepos=true;
end

% add openephys
settingsStruct.openephys.stateFunction.name='pds.openephys.openephys';
settingsStruct.openephys.use=false;
settingsStruct.openephys.stateFunction.acceptsLocationInput=true;
settingsStruct.openephys.stateFunction.order=0;
settingsStruct.openephys.stateFunction.requestedStates.experimentPostOpenScreen=true;
settingsStruct.openephys.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.openephys.stateFunction.requestedStates.trialSetup=true;
settingsStruct.openephys.stateFunction.requestedStates.trialCleanUpandSave=true;


%--------------------------------------------------------------------------
% Add natural background module
sn='natImgBackground';
settingsStruct.(sn).stateFunction.name='v1mapping.natImgBackground';
settingsStruct.(sn).use=false;
settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sn).stateFunction.requestedStates.framePrepareDrawing=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;

%--------------------------------------------------------------------------
% Add gaussian blob noise
sn='gaussianNoiseBlobs';
settingsStruct.(sn).stateFunction.name='v1mapping.gaussianNoiseBlobs';
settingsStruct.(sn).use=true;
settingsStruct.(sn).stateFunction.acceptsLocationInput=true;
settingsStruct.(sn).stateFunction.order=-5;
settingsStruct.(sn).stateFunction.requestedStates.experimentPostOpenScreen=true;
% settingsStruct.eyemarker.stateFunction.requestedStates.experimentCleanUp=true;
settingsStruct.(sn).stateFunction.requestedStates.trialSetup=true;
settingsStruct.(sn).stateFunction.requestedStates.trialPrepare=true;
settingsStruct.(sn).stateFunction.requestedStates.frameUpdate=true;
settingsStruct.(sn).stateFunction.requestedStates.frameDraw=true;
settingsStruct.(sn).stateFunction.requestedStates.trialCleanUpandSave=true;
% important parameters
settingsStruct.(sn).N=3; % number in the base level
settingsStruct.(sn).levels=5; % number of levels


settingsStruct.display.destinationFactorNew=GL_ONE;
settingsStruct.display.sourceFactorNew=GL_ONE;


settingsStruct.datapixx.use=true;
settingsStruct.datapixx.LogOnsetTimestampLevel=1;
settingsStruct.display.useOverlay=1;
settingsStruct.display.switchOverlayCLUTs=1;


p=pldaps(@plain, settingsStruct);
p.trial.pldaps.pause.preExperiment=false;
p.run

