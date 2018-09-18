% run createRigPrefs.m from the pldaps directory and add the default rig
% preferences

outStruct=getpref('pldaps');

% datapixx settings
outStruct.datapixx.use = 1;
outStruct.datapixx.useAsEyepos = 0;
outStruct.datapixx.enablePropixxRearProjection = false;
outStruct.datapixx.LogOnsetTimestampLevel = 0;
% display settings
outStruct.display.displayName = 'PROPIXX';
outStruct.display.scrnNum = 1;
outStruct.display.viewdist = 87;
outStruct.display.heightcm = 40;
outStruct.display.widthcm = 70;
outStruct.display.useOverlay = 1;
outStruct.display.colorclamp = 1;
outStruct.display.normalizeColor = 1;

outStruct.	display.	bgColor = [ 0.5000    0.5000    0.5000 ];
outStruct.	display.	colorclamp = 0;
outStruct.	display.	destinationFactorNew = 'GL_ONE_MINUS_SRC_ALPHA';
outStruct.	display.	sourceFactorNew = 'GL_SRC_ALPHA';
outStruct.	display.	stereoFlip = [ ];
outStruct.	display.	stereoMode = 0;
outStruct.  display.    crosstalk = 0;
outStruct.	display.	switchOverlayCLUTs = false;
outStruct.  display.    ipd = 3;
outStruct.  display.    useGL = false; % flag for custom 3D rendering features
outStruct.  display.    switchOverlayCLUTs = false;

% eyelink settings
outStruct.	eyelink.	buffereventlength = 30;
outStruct.	eyelink.	buffersamplelength = 31;
outStruct.	eyelink.	calibration_matrix = [ ];
outStruct.	eyelink.	collectQueue = false;
outStruct.	eyelink.	custom_calibration = false;
outStruct.	eyelink.	custom_calibrationScale = 0.2500;
outStruct.	eyelink.	saveEDF = false;
outStruct.	eyelink.	use = true;
outStruct.	eyelink.	useAsEyepos = true;
outStruct.	eyelink.	useRawData = true;

outStruct.	git.	use = true;

% mouse settings
outStruct.mouse.useAsEyepos=0;

% pldaps main settings
outStruct.pldaps.dirs.data='~/Data';
outStruct.pldaps.dirs.wavfiles='~/Repos/PLDAPS/beepsounds';
outStruct.pldaps.draw.cursor = true;
outStruct.pldaps.draw.eyepos = true;
outStruct.pldaps.draw.grid=true;
outStruct.pldaps.draw.photodiode=false;
outStruct.pldaps.eyeposMovAv=1;
outStruct.pldaps.useModularStateFunctions=true;
outStruct.pldaps.save.v73 = true;

 outStruct.	pldaps.	draw.	framerate.	location = [ 10   -10 ];
 outStruct.	pldaps.	draw.	framerate.	nSeconds = 3;
 outStruct.	pldaps.	draw.	framerate.	show = true;
 outStruct.	pldaps.	draw.	framerate.	size = [ 20     5 ];
 outStruct.	pldaps.	draw.	framerate.	use = true;

% new era syringe
 outStruct.	newEraSyringePump.	alarmMode = 0;
 outStruct.	newEraSyringePump.	allowNewDiameter = false;
 outStruct.	newEraSyringePump.	diameter = 38;
 outStruct.	newEraSyringePump.	lowNoiseMode = 0;
 outStruct.	newEraSyringePump.	port = '/dev/ttyUSB0';
 outStruct.	newEraSyringePump.	rate = 2900;
 outStruct.	newEraSyringePump.	triggerMode = 'T2';
 outStruct.	newEraSyringePump.	use = true;
 outStruct.	newEraSyringePump.	volumeUnits = 'ML';
 
 outStruct.	sound.	deviceid = [ ];
 outStruct.	sound.	use = true;
 outStruct.	sound.	useForReward = true;
%% update matlab preferences
fn=fieldnames(outStruct);
outStructc=struct2cell(outStruct);

try
rmpref('pldaps'); %remove current
end
setpref('pldaps',fn(:),outStructc); %set new