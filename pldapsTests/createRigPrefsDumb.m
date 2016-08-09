% run createRigPrefs.m from the pldaps directory and add the default rig
% preferences

outStruct=getpref('pldaps');

% datapixx settings
outStruct.datapixx.use=0;
outStruct.datapixx.useAsEyepos=0;

% display settings
outStruct.display.scrnNum=1;
outStruct.display.viewdist=57;
outStruct.display.heightcm=29.8;
outStruct.display.widthcm=53.1;
outStruct.display.useOverlay=1;
outStruct.display.colorclamp=1;
outStruct.display.normalizeColor=1;

outStruct.display.switchOverlayCLUTs=true;

% eyelink settings
outStruct.eyelink.use=0;

% mouse settings
outStruct.mouse.useAsEyepos=1;

% pldaps main settings
outStruct.pldaps.dirs.data='~/Data';
outStruct.pldaps.dirs.wavfiles='~/Repos/PLDAPS/beepsounds';
outStruct.pldaps.draw.cursor=true;
outStruct.pldaps.draw.eyepos=true;
outStruct.pldaps.draw.framerate=true;
outStruct.pldaps.draw.grid=true;
outStruct.pldaps.draw.photodiode=false;
outStruct.pldaps.eyeposMovAv=1;
outStruct.pldaps.useModularStateFunctions=false;

outStruct.sound.deviceid=0;
%% update matlab preferences
fn=fieldnames(outStruct);
outStructc=struct2cell(outStruct);
    
rmpref('pldaps'); %remove current

setpref('pldaps',fn(:),outStructc); %set new