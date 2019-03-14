function c = oknBistable_dots_test()

% Add Hartley module
sn = 'oknbistable';
c.(sn).stateFunction.name  = 'stimuli.modules.oknbistable.DotsTrial';
c.(sn).use                 = true;

c.(sn).stateFunction.order = 2; % draw before behavior

c.(sn).dotposition  = [0 0];
c.(sn).dotradius    = 3;
c.(sn).dotrange     = 0;
c.(sn).dotsize      = 4;
c.(sn).dotlifetime  = inf;
c.(sn).numDots      = 50;
c.(sn).dotspeed     = 10;
c.(sn).onduration   = 2;
c.(sn).rewardrate   = .025;
c.(sn).nDirections  = 22;
c.(sn).priorType    = 'uniform';