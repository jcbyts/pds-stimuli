%%

cas=@(x) sin(x) + cos(x);
[xx, yy]=meshgrid(-35:35, -35:35);
kx=xx(:); ky=yy(:); l=0; m=1;

ppd=35;
% sy=sy;

nOctaves = 3;
freq0 = .25;

steps = sort([0 2.^(0:nOctaves)*freq0]);
% steps=-pi:pi/4:pi;
% steps=[-8 -4 -2 -1 -.5 -.25 0 .25 .5 1 2 4 8];
% steps=-1:.2:1;
% steps=-1:(2/12):1;
% steps=sort([-logspace(-1,0,5) 0 logspace(-1,0,5)]);
% steps=sort([-2.^(0:5)*.25 0 2.^(0:5)*.25]);

% steps=[0 2 4 8];
sx=numel(steps);
M=ppd;
MaxSF=1;
msteps=fliplr(2.^(1:4));
figure(1); clf
ax=pdsa.tight_subplot(sx,sx,.001, .001);
for i = 1:sx
    for j = 1:sx
        
        set(gcf, 'currentaxes', ax((i-1)*numel(steps) + j))
        l=steps(j);
        m=steps(i);
        I=cas((MaxSF*2*pi * (kx * l + ky * m))/M);
        imagesc(reshape(I,size(xx)))
        axis off
        drawnow
    end
end

colormap gray