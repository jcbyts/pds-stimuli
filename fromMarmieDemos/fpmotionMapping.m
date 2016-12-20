function p = fpmotionMapping(p)
p = pdsDefaultTrialStructure(p); 

%some meaningfull understandable colors for this annoying color scheme
%system
p = defaultBitNames(p);
p = twoDdots.jonasDefaultColors(p);

%% Random numb
p.trial.stimulus.rngs.sessionSeed=fix(1e6*sum(clock));
p.trial.stimulus.rngs.sessionRNG=RandStream(p.trial.stimulus.randomNumberGenerater, 'seed', p.trial.stimulus.rngs.sessionSeed);
if datenum(version('-date')) >= datenum('February 9, 2012') %strcmp(version, '7.14.0.739 (R2012a)')
    RandStream.setGlobalStream(p.trial.stimulus.rngs.sessionRNG);
else
    RandStream.setDefaultStream(p.trial.stimulus.rngs.sessionRNG); %#ok<SETRS>
end
p.defaultParameters.stimulus.rngs.trialSeeds = randi(2^32, [1e3 1]); %1e5

% dv.defaultParameters.pldaps.trialMasterFunction='runTrial';
p.defaultParameters.pldaps.trialFunction='twoDdots.twoDdots';

pWidth=p.defaultParameters.display.winRect(3)-p.defaultParameters.display.winRect(1);
pHeight=p.defaultParameters.display.winRect(4)-p.defaultParameters.display.winRect(2);

p.defaultParameters.stimulus.fpWin     = p.trial.display.ppd*[4 4];
p.defaultParameters.stimulus.fixationXY = [-30 0];

%% input parameters
% p.trial.stimulus.nframes = 2400; %absolute maximum number of frames a trial can have
p.trial.stimulus.nMotions = 1;
 
p.trial.stimulus.motion1.type='mtrfmap';
  
p.trial.stimulus.motion1.motionStateStartTime = [100,200,3000,200,100]; %4.5 full cycles
p.trial.stimulus.motion1.velocityRelativetoEye = false;
p.trial.stimulus.motion1.motionDirectionNoiseSD=0;

p.trial.stimulus.motion1.thetas     =  0:45:359; %[90 270]; [0 180];
p.trial.stimulus.motion1.nThetas     =  4;%8 %no specifying defaults to all
% p.trial.stimulus.motion1.thetas     =  0:10:359; %[90 270]; [0 180];
% p.trial.stimulus.motion1.nThetas     =  36;%8 %no specifying defaults to all
p.trial.stimulus.motion1.dotSpeed     = 15;
p.trial.stimulus.motion1.dotLifetime   = 100*20/120; % in seconds
p.trial.stimulus.motion1.aperture  = 15; 
p.trial.stimulus.apertureType=2;
p.trial.stimulus.aperture=15;
p.trial.stimulus.motion1.coherence = 1;
p.trial.stimulus.motion1.dotDensity    = 2; %about 100/pi/60 :)
p.trial.stimulus.motion1.dotColor1 = [0.15 0.15 0.15]';
p.trial.stimulus.motion1.dotColor2 = [1 1 1]';                    
%%
p.trial.pldaps.maxTrialLength = 20;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
p.trial.stimulus.showFixationPoint=true;
p.trial.stimulus.followMouse = true;
p.trial.stimulus.followMouseAtTrialOnset = false;
p.trial.stimulus.fixationFollowsMouse = false;
p.trial.stimulus.fixationFollowsMouseAtTrialOnset = false;
p.trial.pldaps.draw.cursor.use = true;
p.trial.mouse.use=true;
%alernative:
p.trial.stimulus.motion1.offset = [0 0];

% dot sizes
p.defaultParameters.stimulus.eyeW = 10; 
p.defaultParameters.stimulus.cursorW = 6; 
p.defaultParameters.stimulus.fixdotW = 10;
p.defaultParameters.stimulus.dotsW  = 4; 


%% timing
p.defaultParameters.stimulus.preTrial = .0; 
p.defaultParameters.stimulus.fixWait      = 8; 

%movie to play in the background
p.trial.stimulus.movie.play = false;

%%reward
% p.trial.behavior.reward.defaultAmount = 0.1;
p.trial.stimulus.breakFixPenalty = 0;

p.trial.stimulus.degreeOffset = true;

%%conditions
%create some conditions. not pretty yet

 cc.clockwise = [false, true];%0 1 
    %have boolean switch whether to keep the motion vector length constant
 cc.randomizeStart=[1];%0 1 
%  cc.dotSpeed=[10]; %deg/second
    
 fn=fieldnames(cc);
 numConds=1;
 for parameter=1:length(fn)
     numConds=numConds*length(cc.(fn{parameter}));
 end
 
 c=cell(1,numConds);
 numCondsTillNow=1;
 for parameter=1:length(fn)
     numParmValues=length(cc.(fn{parameter}));
     
     for condition=1:numConds
         thisParmValue=floor(mod((condition-1)/numCondsTillNow,numParmValues)+1);
         if(isnumeric(cc.(fn{parameter})) || islogical(cc.(fn{parameter})))
             c{condition}.(fn{parameter})=cc.(fn{parameter})(thisParmValue);
         else
             fn2=fieldnames(cc.(fn{parameter}){thisParmValue});
             for ParmValueField=1:length(fn2)
                c{condition}.(fn2{ParmValueField})=cc.(fn{parameter}){thisParmValue}.(fn2{ParmValueField});
             end            
         end
         
     end
     
     numCondsTillNow=numCondsTillNow*numParmValues;
 end
 

  
 for(condition=1:numConds)
     ctmp.stimulus.motion1=c{condition};
     ctmp.nr = condition;
     c{condition}=ctmp;
 end
 
 c=repmat(c,1,200);
  
p.conditions=Shuffle(c); %rand , can't specifiy the rng here, but we set the default so it's ok.


% dv.defaultParameters.stimulus.dotSeeds = randi(1e5, [1e3 1]); 
p.defaultParameters.pldaps.finish = 1e3; 

% setup default trial values in the dv.trial struct
 p = defaultTrialVariables(p);

