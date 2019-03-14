function c = rfmapping_dots_sparse_test()

% Add Hartley module
sn = 'dotsparserevco';
c.(sn).stateFunction.name  = 'stimuli.modules.mapping.DotsSparseRevco';
c.(sn).use                 = true;

c.(sn).stateFunction.order = 2; % draw before behavior

c.(sn).dotposition  = [0 0];
c.(sn).dotradius    = 10;
c.(sn).dotrange     = 360;
c.(sn).dotsize      = 4;
c.(sn).dotlifetime  = 1;
c.(sn).numDots      = 200;
c.(sn).dotspeed     = 10;
c.(sn).onduration   = 2;
c.(sn).rewardrate   = .02;