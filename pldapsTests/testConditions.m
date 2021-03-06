

% subject name
settingsStruct.session.subject = 'test';
% save PDS file as this experimental protocol
settingsStruct.session.experimentName = 'testConditions';

settingsStruct = mergeStruct(settingsStruct, forage_face_randomwalk);

c = {};
N = nan;

behavior = @forage_face_randomwalk;
% condition 1: colony pictures with face forage
c{1} = combineConditions({@naturalimg_colonypics, behavior});
c{1}.Nr = 1;
c{1}.ConditionName = 'colonypics_faceforage';
c{1}.pldaps.maxTrialLength = 10;
N(1) = 1;

% condition 2: hartleyFF autocorr with face forage
c{2} = combineConditions({@hartleyFF_autocorr_2_contrast_010, behavior});
c{2}.Nr = 2;
c{2}.ConditionName = 'hartleyFF_autocorr_faceforage';
c{2}.pldaps.maxTrialLength = 20;
N(2) = 10;

% condition 3: hartleyFF pBlank with face forage
c{3} = combineConditions({@hartleyFF_pblank_050_contrast_010, behavior});
c{3}.Nr = 3;
c{3}.ConditionName = 'hartleyFF_pblank_faceforage';
c{3}.pldaps.maxTrialLength = 20;
N(3) = 10;

% condition 4: hartleyFF frozen with face forage
c{4} = combineConditions({@hartleyFF_frozen_contrast_010, behavior});
c{4}.Nr = 4;
c{4}.ConditionName = 'hartleyFF_frozen_faceforage';
c{4}.pldaps.maxTrialLength = 20;
N(4) = 5;

conditions = buildConditions(c, N);

settingsStruct.pldaps.pause.preExperiment = false;


settingsStruct = loadCalibration(settingsStruct);

% --- Open PLDAPS
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct, conditions);

p.run