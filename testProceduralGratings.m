
p = pldaps(@stimuli.forage.gratingWalk, 'test');

p.openScreen;
%%
win = p.trial.display.ptr;

internalRotation = 0; % Does the grating rotate within the envelope?
rotateMode = []; % rotation of mask grating (1= horizontal, 2= vertical, etc?)
res = [1920 1080]; % screen resoloution
sfreq = [8/1000, 8/1000];% Frequency of the grating in cycles per pixel: Here 0.01 cycles per pixel,,This should be specified in cycles per degree...
cyclespersecond = [0.5,0.5]; % temporal frequency
angle = [0 0]  ; % angle of gratings on screen
contrast=[.1,.1]
    
% Phase is the phase shift in degrees (0-360 etc.)applied to the sine grating:
phase=[0 0];

% Compute increment of phase shift per redraw:
phaseincrement = [cyclespersecond] * 360 * p.trial.display.ifi;


% Build a procedural sine grating texture for a grating with a support of
% res(1) x res(2) pixels and a RGB color offset of 0.5 -- a 50% gray.


Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Compute the alpha and amplitudes that we will use
% [amps,alpha]=flytv_computeAlphaAmps(contrast);

gratingtex1 = CreateProceduralSineGrating(win, res(1), res(2),[.5,.5,.5, 1]); % Bottom grating
gratingtex2 = CreateProceduralSineGrating(win, res(2), res(1),[.5 .5 .5 .5]); % Top grating blend 50%

amps = [.5 .5]
ifi = p.trial.display.ifi
%%

% Wait for release of all keys on keyboard, then sync us to retrace:

vbl = Screen('Flip', win);

Duration = 5;

% We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
 vblendtime = vbl + Duration;
    i=0;

% while (vbl < vblendtime)
    
    % Update some grating animation parameters:
    
    % Increment phase by the appropriate amount for this time period:
%     phase = phase + phaseincrement;
%     pMod = 180*(round(phase/180 ));
    phase = [0 180]; %phase + phaseincrement;
	pMod = phase + [0 1]; %[0 phase(2)+1];

    
    % Draw the grating, centered on the screen, with given rotation 'angle',
    % sine grating 'phase' shift and amplitude, rotating via set
    % 'rotateMode'. Note that we pad the last argument with a 4th
    % component, which is 0. This is required, as this argument must be a
    % vector with a number of components that is an integral multiple of 4,
    % i.e. in our case it must have 4 components:

     Screen('DrawTextures', win, [gratingtex1 gratingtex1], [], [], [angle(1)], [], [0], [], [], [rotateMode], [pMod(1),sfreq(1),amps(1),0]');
     Screen('DrawTexture', win, [gratingtex1], [], [], [angle(2)], [], [0], [], [], [rotateMode], [pMod(2),sfreq(1),amps(1),0]');


    % Show it at next retrace:
    vbl = Screen('Flip', win, vbl + 0.5 * ifi);
% end

%%
img = Screen('GetImage', win);
imagesc(img)

plot(squeeze(double(img(:,:,1)))' - 129)