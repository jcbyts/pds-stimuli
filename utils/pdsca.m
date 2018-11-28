function pdsca()
% hardcore reset if pldaps is in bad shape
% add a clear all if you still have problems
Screen('CloseAll');
IOPort('CloseAll');
Eyelink('Shutdown')
fclose('all');
close all force
sca