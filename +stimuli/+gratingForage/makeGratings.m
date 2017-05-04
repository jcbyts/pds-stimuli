function hGratings = makeGratings(p, sn)
% MAKEGRATINGS makes gratings
% Takes a pldaps as input. Needs to have the parameters set by
% stimuli.gratingForage.defaultParameters

if nargin < 2
    sn = 'stimulus';
end


% Make a gabor texture using current parameters
nOr = p.trial.(sn).nOrientations;
nPh = p.trial.(sn).nPhases;

n = nOr * nPh;

% initialize parameters
condOr  = ((1:nOr)-1)/nOr * 180;
condPh  = ((1:nPh)-1)/nPh * 180;

[orientations, phase] = meshgrid(condOr, condPh);
orientations = orientations(:);
phase        = phase(:);

sf            = repmat(p.trial.(sn).gratingSF,1,n);

% pixels per degree multiplier
ppd = p.trial.display.ppd;

dpix = ceil(2.5*p.trial.(sn).gratingRadius*ppd);
if rem(dpix,2) % force even
    dpix = dpix-1;
end

xax = (-dpix/2:dpix/2)./ppd ; % convert back to degrees
[xx,yy] = meshgrid( xax );

hGratings = stimuli.textures(p.trial.display.ptr);

for k = 1:n
    
  % variables for this 
  omega    = 2 * pi * sf(k);
  theta    = orientations(k) / 180 * pi;
  phi      = phase(k) / 180 * pi;
  
  % get rotation
  zz = sin(theta) .* xx + cos(theta) .* yy;
  
  sinecarrier = sin(omega * zz + phi);

  if p.trial.(sn).isGabor
      sigma = p.trial.(sn).gratingRadius/2;
      mask = exp(-.5 * (xx.^2 + yy.^2)/sigma^2);
  else
      sigma = p.trial.(sn).gratingRadius;
      mask = sqrt(xx.^2 + yy.^2) < sigma;
  end
  
  img = sinecarrier*255/2 + 255/2;
  
  mask = mask - min(mask(:));
  mask = mask./max(mask(:));
  img(:,:,2) = img(:,:,1);
  img(:,:,3) = img(:,:,1);
  img(:,:,4) = uint8(255.*mask);
  
  hGratings.addTexture(k, img);
end