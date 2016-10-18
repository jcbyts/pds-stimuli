
%%
clear
Screen('Preference','ScreenToHead', 1,0,0);
settingsStruct=struct;
settingsStruct.display.useOverlay=2;
settingsStruct.display.scrnNum=1;
settingsStruct.display.switchOverlayCLUTs=1;
settingsStruct.display.destinationFactorNew=GL_ONE;
settingsStruct.display.sourceFactorNew=GL_ONE;

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

settingsStruct.eyelink.use=false;
settingsStruct.mouse.useAsEyepos=true;


p=pldaps(@v1mappingTest, 'test', settingsStruct); p.run

figure(1); clf
plot(p.data{1}.timing.frameStateChangeTimes'*1000, '-')

%%
p=pldaps(@TestDotMotion, 'test', settingsStruct); p.run

figure(1); clf
plot(p.data{1}.timing.frameStateChangeTimes'*1000, '-')
%%
for k=1:numel(p.data)
    plot(p.data{k}.timing.frameStateChangeTimes'*1000, '-')
    title(sprintf('Trial: %d', k))
    pause
end

