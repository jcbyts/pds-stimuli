function c = naturalimg_colonypics()

%--------------------------------------------------------------------------
% Add natural background module
sn='natImgBackground';
c.(sn).stateFunction.name = 'stimuli.modules.natImgBackground';
c.(sn).stateFunction.order = -1;
c.(sn).use = true;
c.(sn).imgDir = getpref('pep', 'colonyPics');