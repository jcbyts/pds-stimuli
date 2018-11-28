function c = hartleyFF_autocorr_2_contrast_010()

% Add Hartley module
sn = 'hartley';
c.(sn).stateFunction.name  = 'stimuli.modules.hartley.defaultHartleyTrial';
c.(sn).use                 = true;
c.(sn).generativeModel     = 'exponentialDecay';

c.(sn).stateFunction.order = -1; % draw before behavior
c.(sn).OnDuration          = 2;  % if generative model is exponentialDecay or fixed
c.(sn).OffDuration         = 2;
c.(sn).contrast            = .1; % Michelson contrast of the gratings