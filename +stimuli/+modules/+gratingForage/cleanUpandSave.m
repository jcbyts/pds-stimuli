function p = cleanUpandSave(p, sn)


% Make a gabor texture using current parameters
nOr = p.trial.(sn).nOrientations;
nPh = p.trial.(sn).nPhases;

% initialize parameters
condOr  = ((1:nOr)-1)/nOr * 180;
condPh  = ((1:nPh)-1)/nPh * 180;

[orientations, phase] = meshgrid(condOr, condPh);
orientations = orientations(:);
phase        = phase(:);

p.trial.(sn).gratingsXpos = p.trial.(sn).hGratings.position(:,1);
p.trial.(sn).gratingsYpos = p.trial.(sn).hGratings.position(:,2);
p.trial.(sn).gratingsTheta = orientations(p.trial.(sn).hGratings.id);
p.trial.(sn).gratingsPhase = phase(p.trial.(sn).hGratings.id);

p.trial.(sn).revcoXyId(p.trial.iFrame:end,:) =[];
id = p.trial.(sn).revcoXyId(:,3);
p.trial.(sn).revcoXY_Th_Phi = [p.trial.(sn).revcoXyId(:,1:2) orientations(id) phase(id)];

p.trial.(sn) = rmfield(p.trial.(sn), 'revcoXyId');

% Screen('FillRect', p.trial.display.overlayptr,p.trial.display.bgColor);
% Screen('Flip', p.trial.display.ptr);

end
