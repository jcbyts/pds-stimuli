function hGratings = makeGratings(p, sn)
% MAKEGRATINGS makes gratings
% Takes a pldaps as input. Needs to have the parameters set by
% stimuli.gratingForage.defaultParameters

if nargin < 2
    sn = 'stimulus';
end


% Make a gabor texture using current parameters
n = p.trial.(sn).nOrientations;
A.tex           = nan(n,1);
A.texRect       = nan(n,4);

% initialize parameters
A.orientations  = ((1:n)-1)/n * 180;
A.phase         = repmat(pi,1,n); %rand(1,n)*pi;
A.contrast      = repmat(p.trial.(sn).gratingContrast,1,n);
A.sf            = repmat(p.trial.(sn).gratingSF,1,n);
ppd = p.trial.display.ppd;
dpix = ceil(2.5*p.trial.(sn).gratingRadius*ppd);
if rem(dpix,2) % force even
    dpix = dpix-1;
end

xax = (-dpix/2:dpix/2)./ppd ;
[xx,yy] = meshgrid( xax );

hGratings = stimuli.textures(p.trial.display.ptr);

for k = 1:n
    
  % variables for this 
  omega   = pi * A.sf(k);
  theta = A.orientations(k)/180*pi;
  phi   = A.phase(k);
  contrast = A.contrast(k);
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
%   img = img.*contrast;
  mask = mask - min(mask(:));
  mask = mask./max(mask(:));
  img(:,:,2) = img(:,:,1);
  img(:,:,3) = img(:,:,1);
  img(:,:,4) = uint8(255.*mask);
  
  
  %   G = round(G*128 + 128); % round to pixel values (is this necessary?)
  
  hGratings.addTexture(k, img);
end