function p=dotTrial(p,state, stimulusname)
% simple dot motion trial
%
% 09.08.2016 Jacob L. Yates <jacoby8s@gmail.com>

if nargin<3
    stimulusname='stimulus';
end

pldapsDefaultTrialFunction(p,state)

dotmotion.fixation(p, state, stimulusname)
% dotmotion.motion(p, state, stimulusname)
% dotmotion.choice(p, state, stimulusname)


% switch state
%     case p.trial.pldaps.trialStates.framePrepareDrawing;
%         dotmotion.fixation(p, stimulusname)
%         
%         dotmotion.motion(p, stimulusname)
%         
%         dotmotion.choice(p, stimulusname)
%     case p.trial.pldaps.trialStates.trialSetup;
%         dotmotion.trialSetup(p, stimulusname);
        
%         
%     case p.trial.pldaps.trialStates.frameDraw;
% %         frameDraw(p, stimulusname);
%         

%         
%     case p.trial.pldaps.trialStates.trialCleanUpandSave;
%         cleanUpAndSave(p, stimulusname);
% end


end