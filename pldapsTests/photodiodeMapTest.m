%% Test Stimulus Modules
% To map V1 RFs, we use a set of stimuli
% 1) pixelNoise
% 2) sparseNoise
% 3) gaussianNoise
% 4) natBackground
% 5) hartleyGratings


%% Debuggin openScreen with software overlay
settingsStruct.datapixx.use=false;
settingsStruct.datapixx.LogOnsetTimestampLevel=0;
settingsStruct.display.useOverlay=2;
settingsStruct.display.switchOverlayCLUTs=0;
settingsStruct.display.colorclamp=1;
settingsStruct.display.normalizeColor=1;
% Turn off Eyelink if test mode
settingsStruct.eyelink.use=false;
settingsStruct.mouse.useAsEyepos=true;

p=pldaps(@plain, 'test', settingsStruct);
p=openScreen(p);
%
p=pds.datapixx.init(p);

% p.run
%% Flash black to white to test photodiode
settingsStruct.datapixx.use=true;
settingsStruct.datapixx.LogOnsetTimestampLevel=0;
settingsStruct.display.useOverlay=2;
settingsStruct.display.switchOverlayCLUTs=0;

% Turn off Eyelink if test mode
settingsStruct.eyelink.use=false;
settingsStruct.mouse.useAsEyepos=true;

p=pldaps(@plain, 'test', settingsStruct);
% p=openScreen(p);
%
% p=pds.datapixx.init(p);

p.run
%%
iter=5;
t0=GetSecs;
t1=GetSecs-t0;

while t1<10
    
    t1=GetSecs-t0;
    if iter<5
        %         Datapixx('SetDoutValues', 2^1); Datapixx('RegWr');
        Screen('FillRect', p.trial.display.ptr, 1);
        %         Datapixx('SetDoutValues',0); Datapixx('RegWr');
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
settingsStruct.(sn).contrast=.25;
settingsStruct.(sn).sigma0=1;


%--------------------------------------------------------------------------
% Add Hartley Stimulus
sn='hartley';
settingsStruct.(sn).stateFunction.name='v1mapping.hartleyStimuli';
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
settingsStruct.(sn).OnDuration=10;
settingsStruct.(sn).OffDuration=10;
settingsStruct.(sn).contrast=.5;
settingsStruct.(sn).tfs=0; %[0 2 4];
settingsStruct.(sn).sfscale=10;



if settingsStruct.gaussianNoiseBlobs.use || settingsStruct.hartley.use
    settingsStruct.display.destinationFactorNew=GL_ONE;
    settingsStruct.display.sourceFactorNew=GL_ONE;
end

settingsStruct.datapixx.use=true;
settingsStruct.datapixx.LogOnsetTimestampLevel=0;
settingsStruct.display.useOverlay=2;
settingsStruct.display.switchOverlayCLUTs=0;
settingsStruct.pldaps.pause.preExperiment=false;

%
% settingsStruct.display.movie.create=1;
% settingsStruct.display.movie.width=1920;
% settingsStruct.display.movie.heigh=1080;

p=pldaps(@plain, settingsStruct);
p.trial.pldaps.pause.preExperiment=false;
p.run

