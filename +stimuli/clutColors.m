function p = clutColors(p)

isOverlay=(p.defaultParameters.display.useOverlay == 2) | (p.defaultParameters.display.useOverlay & p.defaultParameters.datapixx.use);
% build up the CLUT for the overlay pointer
kColor=12;
p.defaultParameters.display.monkeyCLUT(kColor+1,:)=[1 0 0];
p.defaultParameters.display.humanCLUT(kColor+1,:)=[0 1 0];
if isOverlay
    p.defaultParameters.display.clut.red_green=kColor*[1 1 1];
else
    p.defaultParameters.display.clut.red_green=p.defaultParameters.display.humanCLUT(kColor+1,:);
end

kColor=kColor+1;
p.defaultParameters.display.monkeyCLUT(kColor+1,:)=[.8 .8 .8];
p.defaultParameters.display.humanCLUT(kColor+1,:)=[1 0 0];
if isOverlay
    p.defaultParameters.display.clut.ltgray_red=kColor*[1 1 1];
else
    p.defaultParameters.display.clut.ltgray_red=p.defaultParameters.display.humanCLUT(kColor+1,:);
end

kColor=kColor+1;
p.defaultParameters.display.monkeyCLUT(kColor+1,:)=[.8 .8 .8];
p.defaultParameters.display.humanCLUT(kColor+1,:)=[0 1 0];
if isOverlay
    p.defaultParameters.display.clut.ltgray_green=kColor*[1 1 1];
else
    p.defaultParameters.display.clut.ltgray_green=p.defaultParameters.display.humanCLUT(kColor+1,:);
end


kColor=kColor+1;
p.defaultParameters.display.monkeyCLUT(kColor+1,:)=p.defaultParameters.display.bgColor;
p.defaultParameters.display.humanCLUT(kColor+1,:)=[0 1 0];
if isOverlay
    p.defaultParameters.display.clut.bg_green=kColor*[1 1 1];
else
    p.defaultParameters.display.clut.bg_green=p.defaultParameters.display.humanCLUT(kColor+1,:);
end

kColor=kColor+1;
p.defaultParameters.display.monkeyCLUT(kColor+1,:)=p.defaultParameters.display.bgColor;
p.defaultParameters.display.humanCLUT(kColor+1,:)=[1 0 0];
if isOverlay
    p.defaultParameters.display.clut.bg_red=kColor*[1 1 1];
else
    p.defaultParameters.display.clut.bg_red=p.defaultParameters.display.humanCLUT(kColor+1,:);
end


kColor=kColor+1;
p.defaultParameters.display.monkeyCLUT(kColor+1,:)=p.defaultParameters.display.bgColor;
p.defaultParameters.display.humanCLUT(kColor+1,:)=[1 1 1];
if isOverlay
    p.defaultParameters.display.clut.bg_white=kColor*[1 1 1];
else
    p.defaultParameters.display.clut.bg_white=p.defaultParameters.display.humanCLUT(kColor+1,:);
end
