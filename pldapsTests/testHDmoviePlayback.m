
p=pldaps(@plain);
p=openScreen(p);
p=pds.datapixx.init(p);

%%
% moviefilename='/home/marmorig/MyTestMovie.mov';
moviefilename='/home/propixxrig/Videos/HeadPokeTraining001.MP4';
% moviefilename='/home/marmorig/test.avi';
% moviefilename='C:\Users\Jake\Downloads\scene.avi';
% if p.trial.display.useOverlay==2
h=stimuli.HDmovie(moviefilename, p.trial.display.ptr);
h.frameIndex=[9000 12000];
% h.frameIndex=[1 360];
h.open

%%
for i=1:(h.frameIndex(2)-h.frameIndex(1))
%     h.update
    h.update
    h.draw
%     h.draw
    %     h.drawNext
    Screen('Flip', p.trial.display.ptr);
end

%%
h.closeMovie
%%
sca
%%
h.loadFrames
%%

for i=1:(h.frameIndex(2)-h.frameIndex(1))
h.drawFrame(i)
Screen('Flip', p.trial.display.ptr);
end

%%
h.closeMovie
Screen('Flip', p.trial.display.ptr);
%%
moviefilename='/home/marmorig/HeadPokeTraining001.MP4';
SimpleMovieDemo(moviefilename);
% LoadMovieIntoTexturesDemo(moviefilename, 5, 7)

%%
moviefilename='/home/marmorig/HeadPokeTraining001.MP4';
PlayMoviesWithoutGapDemo2(moviefilename);