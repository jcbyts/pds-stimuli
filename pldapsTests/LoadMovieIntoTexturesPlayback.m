p=pldaps(@plain);
p=openScreen(p);
p.trial.display.switchOverlayCLUTs=0;
p.trial.display.useOverlay=1;
p=pds.datapixx.init(p);

%%
moviefilename='/home/marmorig/MyTestMovie.mov';
h=stimuli.HDmovie(moviefilename, p.trial.display