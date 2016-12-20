
%%
p=pldaps(@plain);
p=openScreen(p);
p.trial.display.switchOverlayCLUTs=0;
p.trial.display.useOverlay=1;
p=pds.datapixx.init(p);

%%
tic
screensize=ceil([p.trial.display.dWidth p.trial.display.dHeight]/2);
toc
res=[2 1 .5 .25];
level=4;
xpos=-screensize(1):res(level):screensize(1);
ypos=-screensize(2):res(level):screensize(2);
n=numel(xpos)*numel(ypos)
toc

%% quick easy grid sampling
n=20;
sx=100;
sy=50;

[i,j]=ind2sub([sy sx], randi(sx*sy, [n 1]));

xsamp=((j-1) ./ sx) * (screensize(1) * 2) - screensize(1);
ysamp=((i-1) ./ sy) * (screensize(2) * 2) - screensize(2);

xgrid=(((1:sx)-1) ./sx) * (screensize(1) * 2) - screensize(1);
ygrid=(((1:sy)-1) ./sy) * (screensize(2) * 2) - screensize(2);

[xx,yy]=meshgrid(xgrid, ygrid);
figure(1); clf
plot(xx(:), yy(:), '.'); hold on
plot(xsamp, ysamp, 'or')

%% specified by sigmas
levels=4;
step=1;
sigma0=2;
N=4;

figure(1); clf
sigma=sigma0./((step*2).^((1:levels)-1));

for level=1:levels

    n=N^level;
    sigma=sigma0/((step*2).^(level-1));
    sx=ceil((2*screensize(1))/sigma);
    sy=ceil((2*screensize(2))/sigma);

    [i,j]=ind2sub([sy sx], randi(sx*sy, [n 1]));

    xsamp=((j-1) ./ sx) * (screensize(1) * 2) - screensize(1);
    ysamp=((i-1) ./ sy) * (screensize(2) * 2) - screensize(2);

    xgrid=(((1:sx)-1) ./sx) * (screensize(1) * 2) - screensize(1);
    ygrid=(((1:sy)-1) ./sy) * (screensize(2) * 2) - screensize(2);

    [xx,yy]=meshgrid(xgrid, ygrid);
    subplot(1,levels,level)
    plot(xx(:), yy(:), '.'); hold on
    plot(xsamp, ysamp, 'or')

end