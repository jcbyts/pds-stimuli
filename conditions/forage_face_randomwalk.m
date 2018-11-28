function c = forage_face_randomwalk()

%--------------------------------------------------------------------------
% Add foraging module
sn = 'forage';
c.(sn).stateFunction.name = 'stimuli.modules.forage.forage';
c.(sn).stateFunction.order = 2;
c.(sn).use = true;
% foraging parameters -- Most of these parameters are overwritten below in
% the conditions!
c.(sn).MotN                 = 3;            % number of moving targets
c.(sn).minSpeed             = 1;            % minimum speed targets can move (deg/sec)
c.(sn).maxSpeed             = 3;            % maximum speed (deg/sec)
c.(sn).motionType           = 'randomwalk'; % motion follows this pattern (linear or randomwalk)
c.(sn).type                 = 'face';       % face or grating
c.(sn).appearGazeContingent = false;        % do the objects regenerate in a gaze-contingent coordinate frame
c.(sn).appearRangePar       = 5;            % range of the generating distribution for the appearance of objects (deg)
c.(sn).appearCenter         = [0 0];        % center of the regenerating distribution (deg, relative to center of screen)
c.(sn).appearTau            = 10;            % do the objects fade on? (frames)
c.(sn).maxContrast          = 1;            % contrast of the objects
c.(sn).radius               = 1;            % radius of the objects (deg)
c.(sn).onLifetime           = 1 * 120;      % time objects remain on (frames)
c.(sn).offLifetime          = 2 * 120;      % time objects remain off (frames)   
c.(sn).holdDuration         = 1.5;