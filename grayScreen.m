
settingsStruct= struct();
settingsStruct.eyelink.use=false;
settingsStruct.mouse.useAsEyepos=true;
settingsStruct.display.switchOverlayCLUTs=true;

p=pldaps(@plain, 'jnk', settingsStruct);

p.trial.pldaps.pause.preExperiment=true;
p.run