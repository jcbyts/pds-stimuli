
close all
% subject name
settingsStruct = struct();
settingsStruct.session.subject = 'Harold';
settingsStruct.newEraSyringePump.vol = .02;
settingsStruct.eyelink.collectQueue = false;

% save PDS file as this experimental protocol
settingsStruct.session.experimentName = 'rfmapSparseDotsTest';

settingsStruct = mergeStruct(settingsStruct, forage_face_randomwalk);

c = {};
N = nan;

% sn = 'oknbistable';
% c{1} = oknBistable_dots_test;
% c{1}.Nr = 2;
% c{1}.ConditionName = 'okn_bistable_dots_test';
% c{1}.pldaps.maxTrialLength = 20;
% N(1) = 3;

% sn = 'dotsparserevco';
c{1} = rfmapping_dots_sparse_test;
c{1}.Nr = 2;
c{1}.ConditionName = 'rfmapping_dots_sparse_test';
c{1}.pldaps.maxTrialLength = 20;
N(1) = 3;



behavior = @forage_face_randomwalk;
% condition 1: colony pictures with face forage
c{2} = combineConditions({@naturalimg_colonypics, behavior});
c{2}.Nr = 1;
c{2}.ConditionName = 'colonypics_faceforage';
c{2}.pldaps.maxTrialLength = 10;
N(2) = 1;

conditions = repmat(buildConditions(c, N), 15, 1);

settingsStruct.pldaps.pause.preExperiment = false;

settingsStruct = loadCalibration(settingsStruct);

% --- Open PLDAPS
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct, conditions);

p = p.run;

pds.plotTiming(p)