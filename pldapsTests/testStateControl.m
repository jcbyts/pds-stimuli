% Test state control

% set up a state control objects
sc = stimuli.objects.stateControl();

% initialize three states that don't do anything
sc.addState(stimuli.objects.state(0))
sc.addState(stimuli.objects.state(1))
sc.addState(stimuli.objects.state(2))

% step through each state and set the current state to that state
sc.setState(0);
sc.setState(0);
sc.setState(1);
sc.setState(2);

% start of the experiment
t0 = GetSecs;
ttime = t0;
stateId = 0;
frameId = 1;

nFrames = 10e3;
frameLog = nan(nFrames,1);

while frameId < nFrames
    
    ttime = GetSecs; % check the time
    
    if mod(frameId, 100)==0
        sc.setState(stateId)
        stateId = mod(stateId+1, 3);
    end
    
    frameLog(frameId) = ttime;
    
    frameId = frameId + 1;
    
end

sc.cleanup;
figure(1); clf
plot(frameLog-t0, [0; diff(frameLog)]*1e3, '.')
hold on
plot(sc.getLog(1)-t0, .1, 'r.')
plot(sc.getLog(0)-t0, .11, 'g.')
plot(sc.getLog(2)-t0, .12, 'b.')
ylabel('ms')
xlabel('seconds')