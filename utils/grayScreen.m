
settingsStruct= struct();
settingsStruct.eyelink.use=false;
settingsStruct.mouse.useAsEyepos=true;
settingsStruct.display.switchOverlayCLUTs=true;

p=pldaps(@plain, 'jnk', settingsStruct);

p.trial.pldaps.pause.preExperiment=true;
p.run

% % %%
% % p = pldaps(@plain, 'jnk');
% % p.openScreen
% % 
% % hTex = stimuli.textures(p.trial.display.ptr);
% % 
% % %%
% % img = repmat([ones(1080, 1) zeros(1080,1)], 1, 1920/2);
% % img = img*255;
% % 
% % hTex.addTexture(1, img);
% % 
% % %%
% % hTex.position = round(p.trial.display.ctr(1:2));
% % hTex.size = [1920 1080];
% % hTex.id = 1;
% % hTex.beforeFrame()
% % Screen('Flip', p.trial.display.ptr, 0)