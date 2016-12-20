%%
addpath Repos/PLDAPStools/
% uses:
% 
% runAnalysis (in huklabBasics) should be replaced with runModularTrial(p, true)
% 
% you also need to replace the trialStateFunction that calls pldapsDefaultTrialFunction 
% with something that copies over what you need, check out opticflow.analysisReplay, 
% specifically
%  trialPrepare, trialSetup and frameUpdate
%     and don't call pldapsDefaultTrialFunction for stuff you don't want 
% (see opticflow.analysisReplay where I don't actually draw, you might have 
% to draw for your purpose though.
% 
% functionLevels stuff could be replace by my newer
% [pa, trialLevelMatrix, nTrials] = recreateParams(PDS) fucntion in PLDAPStool
% in theory.
% 
% have fun, let me know what you don't get, but sparsely if possible

PDSfilename='~/Data/test20161102plain1552.PDS';
load(PDSfilename, '-mat')

[pa, trialLevelMatrix] = recreateParams(PDS);

iTrial=1;
pa.setLevels(trialLevelMatrix(:,iTrial));

p=pldaps;
% pa.setLevels(1);
p.defaultParameters=pa;
p.trial=pa;
%%
p.openScreen
%%
iTrial=1;
pa.setLevels(trialLevelMatrix(:,iTrial));
p.trial=pa;
p.data=PDS.data;
p.trial.sound.use=0;
p.trial.iFrame=1;
p.trial.pldaps.draw.grid.use=0;
p.trial.pldaps.draw.cursor.use=0;
I=replayModularTrial(p,true, [0 0 100 100], true);

%%
figure(1); clf
for k=1:size(I,4)
imagesc(I(:,:,:,k)); drawnow; pause(.15)
end


%%
