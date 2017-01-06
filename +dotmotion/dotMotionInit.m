function A = dotMotionInit(S,A)
% DOTMOTIONINIT Initialise the psych. toolbox for MarmoView's dot motion task.
%
% Returns a structure A with fields:
%
%   A.window     - pointer to the ptb window pointer
%   A.screenRect - dimensions of the ptb window
%   A.bgColour   - clut index for ptb window background
%   A.frameRate  - ptb window refresh rate
%   A.faceTex    - indicies of OpenGL textures containing marmoset faces
%   A.faceTexSz  - sizes of the OpenGL textures containing faces

% 14-06-2016 - Shaun L. Cloherty <s.cloherty@ieee.org>

% FIXME: marmoview needs (at minimum) a class system for tasks and stimuli!

% disable ptb welcome screen
Screen('Preference','VisualDebuglevel',3);

% close any open windows
Screen('CloseAll');

% setup the image processing pipeline for ptb
PsychImaging('PrepareConfiguration');

PsychImaging('AddTask','General','FloatingPoint32BitIfPossible');

% create the ptb window...
% A.bgColour = 186; % should be 127 if gamma corrected, 186 if not

[A.window A.screenRect] = PsychImaging('OpenWindow',S.screenNumber,S.bgColour,S.screenRect);

A.frameRate = FrameRate(A.window);

% bump ptb to maximum priority
A.priorityLevel = MaxPriority(A.window);

% set alpha blending/antialiasing etc.
Screen(A.window,'BlendFunction',GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

% create a central fixation point
% [fixTex,fixRect,winRect] = MakeFixSpot_GazeAcu(S,P,A,0,255); % high contrast
% A.fixTex1 = fixTex;
% A.fixRect1 = fixRect;
% A.winRect1 = winRect;
% [fixTex,fixRect,winRect] = MakeFixSpot_GazeAcu(S,P,A,127-50,127+50); % low contrast
% A.fixTex2 = fixTex;
% A.fixRect2 = fixRect;
% A.winRect2 = winRect;

% A.hFix = stimuli.fixation(A.window);
A.hFix(1) = stimuli.fixation(A.window); % high contrast
A.hFix(2) = stimuli.fixation(A.window); % low(er) contrast

% create a circle to show gaze position
A.hGaze = stimuli.circles(A.window);

% create face textures... useful for visual feedback to our subject
tmp = load(fullfile('.','SupportData','MarmosetFaceLibrary.mat'));
tmp = struct2cell(tmp);
tmp = tmp([7,10,13,17:20,24,25,27]); % these faces seem most centered

A.hFace = stimuli.textures(A.window);

for id = 1:length(tmp),
  img = tmp{id};
  
  sz = size(img);
  % gaussian envelope...
  x = [1:sz(1)]-sz(1)/2; y = [1:sz(2)]-sz(2)/2;
  [x,y] = meshgrid(x,y);
  g = exp(-(x.^2+y.^2)/(2*(max(sz(1:2))/6)^2));
  g = g - min(g(:));
  g = g./max(g(:));
  img(:,:,4) = uint8(255.*g); % alpha channel: 0 = transparent, 255 = opaque

  A.hFace.addTexture(id,img);
end
A.hFace.id = 1; % the texture(s) to draw on call to drawTextures()

% FIXME: can't properly initialise @dots or the direction cue objects here
%        since we don't have access to the task parameters structure P...
A.hDots = stimuli.dots(A.window);

A.hChoice = stimuli.circles(A.window);

A.hCue(1) = stimuli.circles(A.window);
A.hCue(2) = stimuli.circles(A.window); % bold
