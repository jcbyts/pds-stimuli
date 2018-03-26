function runSpatialMapping(varargin)

ip = inputParser();
ip.addParameter('subject', 'jnk')
ip.addParameter('pauseBefore', false)
ip.addParameter('lifetime', 3)
ip.addParameter('N', 3)
ip.addParameter('size', 2)
ip.addParameter('contrast', -.2)
ip.addParameter('task', 'fixflash')
ip.addParameter('mappingStimulus', 2)
ip.addParameter('onDuration', 60)
ip.addParameter('offDuration', 60)
ip.addParameter('holdDuration', 30)
ip.addParameter('position', []) % empty is full-field
ip.addParameter('targetSpeed', 10)


settingsStruct = struct(); % settingsStruct is a structure that modifies pldaps default parameters

if strcmp(ip.Results.subject, 'jnk')
    settingsStruct.pldaps.nosave = true; % don't save any files
end

% set blend function appropriately
settingsStruct.display.destinationFactorNew = GL_ONE_MINUS_SRC_ALPHA;
settingsStruct.display.sourceFactorNew = GL_SRC_ALPHA;

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';