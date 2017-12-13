

% addlistener(fig,'Color','PostSet',@(src,evnt)disp('Color changed'));
sc = stimuli.stateControl();

sc.addState(stimuli.state(0))
sc.addState(stimuli.state(1))
sc.addState(stimuli.state(2))


%%
sc = stimuli.fixflash.fixFlashStates;



%%
sc.setState(0);
sc.setState(0);
sc.setState(1);
sc.setState(2);

t0 = GetSecs;
ttime = GetSecs;
stateId = 0;
frameId = 1;

frameLog = nan(10e3,1);

while frameId < 10e3
    
    ttime = GetSecs;
    
    if mod(frameId, 10)==0
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