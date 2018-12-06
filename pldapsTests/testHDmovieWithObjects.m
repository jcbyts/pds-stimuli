
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


% choice targets
hChoice = stimuli.objects.circles('position', p.trial.display.ctr(1:2), 'radius', 100);
n = 10;
th = 0:(360/n):(360-(360/n));
x = cosd(th)*100;
y = sind(th)*100;
hChoice.weight = [];
hChoice.position = bsxfun(@plus, p.trial.display.ctr(1:2),[x(:) y(:)]);
hChoice.radius   = repmat(20, n , 1);
hChoice.stimValue = 1;


%% draw





%% draw frame loop
for i=1:(h.frameIndex(2)-h.frameIndex(1))
    h.update
    hChoice.frameUpdate(p);
    
    h.draw
    hChoice.frameDraw(p);
    
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