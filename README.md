# PEP 
**P**ldaps **E**xperimental **P**rotocols

Collection of stimulus protocols for [PLDAPS](https://github.com/huklab/PLDAPS).


The basic philosophy is that building new experimental *protocols* should be easy because the hard work is done for you by existing *modules*, *state machines*, and *objects*

## protocols
At the top level is the *experimental Protocol*. The protocol is a matlab script or function that sets up the experiment using *modules*. Let's take direction discrimination as an example: The experimental protocol would run the entire direction discrimination task, but it would be made up of smaller interchangeable components: a fixation point, a motion stimulus, choice targets. In PEP, the experimental protocol would draw on modules to run the fixation point, the motion stimulus, and the choice targets, which themselves would use objects so the actual form of the motion, targets, etc. are interchangeable.

### simple example:
For example, we'll set up a simple fixation task where a spatial reverse-correlation stimulus is presented when the subject fixates.
```matlab
settingsStruct = struct(); % settingsStruct is a structure that modifies pldaps default parameters
settingsStruct.pldaps.useModularStateFunctions 	= true;
settingsStruct.pldaps.trialMasterFunction 	   	='runModularTrial';

% Fixation module
sn = 'fixflash';
settingsStruct.(sn).stateFunction.name = 'stimuli.modules.fixflash.runDefaultTrial';
settingsStruct.(sn).stateFunction.order = 1;
settingsStruct.(sn).use = true;

settingsStruct.(sn).staircaseOn = False;
settingsStruct.(sn).minFixDuration = 1;

% reverse correlation module
sn = 'spatialSquares';
settingsStruct.(sn).stateFunction.name  = 'stimuli.modules.mapping.spatialSquares';
settingsStruct.(sn).stateFunction.order = 2;
settingsStruct.(sn).use 		= true; 		% the module is being used
settingsStruct.(sn).N 			= 4;  			% number of squares on each frame
settingsStruct.(sn).contrast 	= 1; 			% contrast of the 
settingsStruct.(sn).size 		= .5; 			% size of each square
settingsStruct.(sn).position 	= [0 0 5 -5]; 	% boundry of the stimulus (in degrees of visual angle)
settingsStruct.(sn).minFixation = .01; 			% time required fixation before showing the stimulus


% run pldaps
p = pldaps(@stimuli.pldapsDefaultTrial, 'subject', settingsStruct);

p.run
```
What exactly happened here? At the very bottom, `pldaps` was called with `@stimuli.pldapsDefaultTrial` as its trial function, 'subject' as the subject name, and `settingsStruct` as an extra set of instructions. `stimuli.pldapsDefaultTrial` simply gathers all behavior inputs (eye trackers, joysticks, button presses). It doesn't do any fixation or reverse correlation. All of the meat is in how `settingsStruct` was constructed.

`settingsStruct` is exactly as it sounds: a struct of settings. It gives additional instructions to `pldaps` that override the rig and default settings. The first line creates an empty struct. The second two lines tell pldaps to run in a modular mode. That means it will look for "modules" and on each trial run the ones that are turned on in a specified order. The next two sections (under `%Fixation module` and `%reverse correlation module`) turn on two modules.

## modules
Modules work when pldaps is set such that `.pldaps.useModularStateFunctions` is `true` and the `trialMasterFunction` is `runModularTrial`. When both of these conditions are met, pldaps will look through all of the fields/properties of `trial` to see if they have the field `stateFunction`. If they do, it knows that field specifies a module. The `stateFunction.name` is the matlab function that runs all the `pldaps` states for that module. More details on that can be found on the [readme]() for modules. The next argument is `stateFunction.order`. This allows the modules to be called in an order. Negative numbers are called before the default function (`@stimuli.pldapsDefaultTrial` in this case) and positive ones are called in sequence after that.

In the example above, the first module is called "fixflash" as can seen in the line `sn = 'fixflash';`. `sn` is used as a [dynamic field name](https://www.mathworks.com/help/matlab/matlab_prog/generate-field-names-from-variables.html), and all of the properties added below `(sn).` will actually be stored under the name `fixflash`. After setting the `stateFunction` arguments on, which identify this field as a module, the rest of the arguments specify parameters that are specific to this module (besides `.use`, which is a generic parameter for all modules-- and dictates whether the module is run on any given trial). Again, besides `.use`, all of the other parameters (`staircaseOn`, `minFixDuration`) are all parameters of the stateFunction above (`stimuli.modules.fixflash.runDefaultTrial`). These parameters are all optional and have some defaults that are set in the stateFunction itself. So, this is tricky. How do you know which parameters go to which modules? The answer is that either you can edit the stateFunction itself and look, or call it without any input. Most of them should be set up to print all the optional arguments to the command window when called with no input. If you build a new module, you'll have to hard code that yourself.

The second module is set up in very much the same way. It has a name (`spatialSquares`). It has a stateFunction (`stimuli.modules.mapping.spatialSquares`). It has an order, and it has parameters. The parameters, of course, are different than for `fixflash` because they govern the spatial square reverse correlation stimulus. Again, the optional parameters for spatialSquares can be viewed by calling that state function without any arguments. But, to look at the next level, we're going to edit a state function so we can see the objects that make it work. In the command window, open the state function with

`edit stimuli.modules.fixflash.runDefaultTrial`

At the very top, we can see that the state function is a matlab function that takes in three arguments
```matlab
function p = runDefaultTrial(p, state, sn)
% RUNDEFAULTTRIAL run a trial of the fixflash task
```
The first argument is an active pldaps object. The second is a state value, and the third is a string that is the name of the module (as it was setup in the active pldaps object). Pldaps will call this function many times during a trial from within the `runModularTrial` function.

After a few lines that check which arguments were passed in with `nargin`, the state function gets to the main thing it does: check which state it is and run the appropriate code.

```matlab
% --- switch PLDAPS trial states
switch state
```

Inside this switch statement, it steps through all the possible pldaps states:
*  [experimentPreOpenScreen](#experimentPreOpenScreen)
*  [experimentPostOpenScreen](#experimentPostOpenScreen)
*  [trialSetup](#trialSetup)
*  [frameUpdate](#frameUpdate)
*  [framePrepareDrawing](#framePrepareDrawing)
*  [frameDraw](#frameDraw)
*  [trialCleanUpandSave](#trialCleanUpandSave)

### experimentPreOpenScreen

experimentPreOpenScreen is the only state called *before* pldaps opens the PTB window. In the example, two functions are called. One that adds the default frame states to the module. The other initializes random seeds within pldaps.

```matlab
% ---------------------------------------------------------------------
    % --- What to do before opening the pldaps screen
	case p.trial.pldaps.trialStates.experimentPreOpenScreen
        % This code should be copied from protocol to protocol
        
        stimuli.setupDefaultFrameStates(p, sn)
        
        p = stimuli.setupRandomSeed(p, sn);
```

`setupDefaultFrameSates` should be inserted in any module state function if you want all of the states listed above to be called. If you only want the module to operate in some states, get rid of this function and set it up manually.

`setupRandomSeed` creates some random streams and stores them in this module

### experimentPostOpenScreen

experimentPostOpenScreen is the first state that occurs AFTER the PTB screen is opened. It does not get called *within* a trial. it is only called once in an experimental protocol (immediately after opening the screen). A lot happens in this state. We set up the default arguments and instantiate the objects that will make up the stimulus.

```matlab
% --- handles that depend on pldaps being totally set up
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        % --- set up default parameters
        defaultArgs = {...
            'bgColor',                  0.5, ...
            'fixPointRadius',           0.3, ...
            'fixPointDim',              0.1, ...
            'fixWinRadius',             1.8, ...
            'fixFlashCnt',              round(0.250*p.trial.display.frate), ...
            'maxRewardCnt',             4, ...
            'rewardLevels',             [.2 .4 .8 1 1.2 1.4], ...
            'rewardForObtainFixation',  false, ...
            'rewardFaceDuration',       0.2, ...
            'showGUI',                  true, ...
            };
        
```
The section above assigns default values to all parameters (only some are shown here to save space). Below, the state checks if the variables already exist and assigns them to have the default values if they don't.

```matlab
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end 
        end
```        

The final section of this state creates the objects that will be used throughout the experiment. It first checks if they exist and then creates them if they don't.
```matlab
        %------------------------------------------------------------------
        % --- Instantiate classes
        
        % --- Fixation
        if ~(isfield(p.trial.(sn), 'hFix') && isa(p.trial.(sn).hFix, 'stimuli.objects.target'))
        	p.trial.(sn).hFix   = stimuli.objects.fixation('position', p.trial.display.ctr(1:2));
		end
        
        % --- Reward Face
        p.trial.(sn).hFace  = stimuli.objects.face(p);
        
        % --- Plotting
        if p.trial.(sn).showGUI
            p.functionHandles.fixFlashPlot = stimuli.modules.fixflash.fixFlashPlot;
        end
```

### trialSetup

trialSetup is called before every trial. This sets up the all of the parameters that govern the subsequent trial. For example, if conditions are randomized, or the timing is jittered, these variables would be set here. The example we're looking at offloads this to a seperate file.

```matlab
    % --- Called before each trial. Sets up all parameters
    case p.trial.pldaps.trialStates.trialSetup
        
        % setup the next trial
        stimuli.modules.fixflash.trialSetup(p, sn);
```

If we look at what's in that function, it is a section that updates the properties of each object and a section that controls the behavioral states of that trial. 

Updating objects:
```matlab
% --- Set Fixation Point Properties
sz = p.trial.(sn).fixPointRadius * ppd;
p.trial.(sn).hFix.radius     = sz;
p.trial.(sn).hFix.color      = ones(1,3);
% p.trial.(sn).hFix.ctrColor   = -ones(1,3);
p.trial.(sn).hFix.position      = [xpos ypos] * ppd + ctr;
p.trial.(sn).hFix.winRadius  = p.trial.(sn).fixWinRadius * ppd;
p.trial.(sn).hFix.wincolor   = p.trial.display.clut.bg_white;


% fixation duration
p.trial.(sn).fixDuration = p.trial.(sn).minFixDuration;
p.trial.(sn).fixStartOffset = 0; % offset for fixation duration -- can be used by other modules to extend fixation

% initialize some measurements of interest
p.trial.(sn).holdXY = nan(1,2); % x,y position of fixation
p.trial.(sn).holdDuration = 0;

% --- Face for reward feedback
p.trial.(sn).hFace.texSize  = 2 * p.trial.(sn).faceRadius * ppd;
p.trial.(sn).hFace.position = p.trial.(sn).hFix.position;
p.trial.(sn).hFace.id       = p.trial.(sn).faceIndex;

```
Setting up the state machine
```matlab
% -------------------------------------------------------------------------
% --- Setup trial state machine

% behavior on this module progresses through a set of states, starting with
% state 1
p.trial.(sn).states = stimuli.objects.stateControl();
p.trial.(sn).states.addState(stimuli.modules.fixflash.state0_FixWait(0))
p.trial.(sn).states.addState(stimuli.modules.fixflash.state1_FixGracePeriod(1))
p.trial.(sn).states.addState(stimuli.modules.fixflash.state2_FixHold(2))
p.trial.(sn).states.addState(stimuli.modules.fixflash.state7_BreakFixTimeout(7))
p.trial.(sn).states.addState(stimuli.modules.fixflash.state8_InterTrialInterval(8))

p.trial.(sn).states.setState(0); % initialize state machine
```

For more on states see the section under [stimuli.objects](+stimuli/+objects/#state). Some modules will have no state machine, but almost all will have a trialSetup function that sets up the properties of all stimulus objects on the following trial.


### frameUpdate

frameUpdate and framePrepareDrawing both occur *before* the actual drawing occurs. This is where the state of the trial is updated: *is it time to turn on the fixation point?*, *is the subject fixating?*, *update the animation of a motion stimulus*

In the example, our module state function uses the framePrepareDrawing state for all updates
### framePrepareDrawing
framePrepareDrawing is like frame update. I honestly don't know why we (Jonas) split it into two states. I believe one is time-critical, meaning it happens closer to the actual flipping of the PTB screen.

In our fixation example, we can see that during `framePrepareDrawing`, the fixation object (`hFix`) updates itself using the current pladaps object (`p`). We also see that the state machine (`states`) calls its `frameUpdate` method. To understand what happens when that is called, we have to understand the [stateController]() and [state]() classes. 
```matlab
    % --- Draw task semantics using info from hTrial
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        p.trial.(sn).hFix.frameUpdate(p); % update fixation object
        
        % call the state machine to update
        p.trial.(sn).states.frameUpdate(p,sn)
```

### frameDraw

`frameDraw` is when all the drawing occurs. Somewhere, a bunch of PTB `Screen()` calls are happening. At the level of our module state function, we just tell the state controller (`states`) to call its draw function:
```matlab
% --- All Screen() calls go here
    case p.trial.pldaps.trialStates.frameDraw
        
        p.trial.(sn).states.frameDraw(p,sn);
```

depending on what the current `state` is, `frameDraw` will do something different, but it's either calling `Screen()` directly, or its telling some objects (like `hFix`) to call their `frameDraw` methods (which ultimately call `Screen()`). This level of hierarchy (where the `module` calls a `stateController` that calls a `state` that tells an `object` to call some PTB code) can seem opaque, but the main goal of it is to let things be flexible. We don't want to have to paste the same code into every program that draws a fixation point. Instead, we'll let the fixation point class handle that. Additionally, if we want to replace the fixation point with a face, or a movie, we can simply replace the object with the appropriate one and the state only has to do the same thing. Everything is modular. Additionally, as will be explored in the readme on [objects](), the objects all log their own transitions (at least some of them) meaning that this code is free of any lines that are tracking when things happen.

### trialCleanupAndSave
This state is run after the trial is over. Variables of interest are curated and any post trial calculations (staircases, reward functions) or plotting (GUIs) should be called here.

In our example code, there is a staircase that is updated and a GUI function that is called.
```matlab
	% --- Cleanup and save all parameters
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        % --- Staircase parameters
        if p.trial.(sn).staircaseOn && p.trial.(sn).minFixDuration < p.trial.(sn).maxFixDuration
            
            
            lastError = p.trial.(sn).error;
                            
            switch lastError
                case 0 % staircase up
                    p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration + p.trial.(sn).staircaseStep;
                case 1 % do nothing
                    p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration;
                case 2 % staircase down
                    p.conditions{p.trial.pldaps.iTrial + 1}.(sn).minFixDuration =  p.trial.(sn).minFixDuration - .75*p.trial.(sn).staircaseStep;
            end
            
        end % staircase on
        
        if p.trial.(sn).showGUI
            stimuli.modules.fixflash.updateGUI(p, sn);
        end
```    


## states
States form the next level of **PEP**. The states are conceptually simple: at any point in a trial, the trial is in a particular state: *wait-for-fixation*, *hold-fixation*, *show-stimulus*, *reward*, etc. In each of these states, there are a number of stimuli and behaviors that have to be managed. The way behaviors are managed in **PEP** is that the state machine knows what state it is in and calls the appropriate function. These transitions are handled by two classes: `state` and `stateControl`

`state` and `stateControl` are at the core of behavioral protocols in pds-stimuli. `state` has two properties `id` that identifies it, and `sc` that points to the `stateControl` object that has control over calling it. Importantly, all `state` objects have methods `frameUpdate` and `frameDraw` that govern all the behavior that occurs in that state. 

[stimuli.modules.fixflash.state0_FixWait](../blob/master/LICENSE) is a good example of what a state does: everytime it's frameUpdate is called, it checks what time it is and whether the behavioral conditions are met to turn on specific stimuli or move to the next state. If the conditions are met, it sets the state to another state. Again, for example, in `state0_FixWait`, the state is waiting for the subject to obtain fixation. If flashes a fixation point until fixation is obtained, or until a timer runs out. If fixation is obtained, it moves the state to [stimuli.modules.fixflash.state1_FixGracePeriod](). If the timer runs out without fixation ever being obtained, it sets the state to [stimuli.modules.fixflash.state7_BreakFixTimeout](). At any given time, only one state is active.

`stateControl` is an important part of this. Together with the `state` class, it forms the pattern of behavior for a trial. stateControl can have states An example of 
```matlab
% set up a state control objects
sc = stimuli.objects.stateControl();

% initialize three states that don't do anything
sc.addState(stimuli.objects.state(0))
sc.addState(stimuli.objects.state(1))
sc.addState(stimuli.objects.state(2))

sc.setState(0); % initialize state machine
```

`stateControl` knows what the current state is. In the code above, the current state is 0.  Because that state is set, anytime `stateControl` calls a `frameUpdate` method or `frameDraw` method, it calls the appropriate one. Importantly, `stateControl` tracks any transition that occur.

## objects

The `stimuli.objects` in pds-stimuli are a set of classes that support the easy insertion of particular type of stimulus, such as **dots**, **fixation points**, **gabors**, **faces**, etc. The idea is to wrap all of the Psychtoolbox functions in a single object that makes setting up the `Screen` calls easy. Additionally, these objects will track certain things in their behavior automagically: when they turn on/ off; whether the subject is looking at them. The way it works is each of these stimulus objects is a `stimuli.stimulus` such that when they are created they inherit all of the properties and methods of `.stimulus`

For more information on how objects work and examples of specific objects, see the [readme](./+stimuli/+objects/README.md) for objects.

# Quick primer on PLDAPS

## Creating a `pldaps` class:
Typical use of the pldaps contructor includes the following inputs*:
    1. Experiment setup function
    2. Subject identifier
    3. Settings struct containing hierarchies for additional experiment components (e.g. ) and/or changes to defaultParameters (e.g. to add/change values from your 'rigPrefs' to be applied only on this particular run)

The order of inputs is somewhat flexible**, but the only officially supported order is as follows:
```Matlab
	p = pldaps( @fxnsetupFunction, 'subject', settingsStruct )
```

- __setupFunction__ must be a function handle (i.e. @fxn ) to your setup function
	- ...using a function handle here allows tab completion, which is nice
- __subject__ must be a string input.
- __settingsStruct__ must be a structure. 
	- Defining core modules/components of your experiment (i.e. hardware elements, stimulus parameters, etc...see demo code for examples)
	- Fieldnames matching fields already present in defaultParameters  [& within their respective param struct hierarchies] will take on the value in settingsStruct.
		- e.g. toggle the overlay state for this run by creating `settingsStruct.display.useOverlay = 1`. Note: you need not build every field of the .display struct into this; fieldnames will be matched/updated piecewise

- _condsCell_, a fourth input of a cell struct of parameters for each trial can also be accepted. Use of this input is relatively depreciated and should only really be used for debugging purposes. Trial specific parameters are better dealt with inside your setupFunction (when setting up p.conditions{}).

> (__*__ all inputs are _technically_ optional, but PLDAPS won't do much without them.)
> (__**__ In most—but not all—cases PLDAPS will still be able to parse disordered inputs, but lets not leave things to chance when we don't have to.)

## Running pldaps 

`p` now exists as a PLDAPS class in the workspace, but the experiment hasn't started yet, and the provided experiment function has not been called yet.

Execute the .run method to actually begin the experiment:
```Matlab
p.run
```

### pldaps.run
__`pldaps.run`__  will open the PTB screen and interface with a number of external hardware devices and will call a function each trial.

`pldaps.run` opens a Psychtoolbox window using `p.openScreen`

once the Psychtoolbox screen is created
`pldaps.run` will call the experiment function provided in the constructor call (`@functionname` described above).
This function 
- can define the functions being called each trial (later), 
- define any further colors you want to use in a datapixx dual clut scenario
- create anything that should be created before the first trial starts, 
- define any stimulus parameters that are true for all trials in `p.defaultParameters`
- and should add a cell of structs to p.conditions that that holds the changes in parameters from therse defaults for _each_trial_

note: in later versions, `p.conditions` might actually only hold information about certain conditions and another field the info of what conditions to use in each trial.

note: since the screen is already created, basic screen parameters like the backgound color must be defined before the p.run is called.

### pldaps.runTrial
unless another function is specified in the parameters as the 
`p.defaultParameters.pldaps.trialMasterFunction`
it defaults to `dv.defaultParameters.pldaps.trialMasterFunction="runTrial"`;

This is a generic trial function that takes care of the correct course of a trial.
It will run through different stages for the trial and in a loop for each frame run through stages from frameUpdate to frameFlip.

For each stage, instead of doing something itself, it calles another function, defined in
`p.defaultParameters.pldaps.trialFunction` that take the pldaps class and a numerical state number as input.

**Important:** The function specified in `p.defaultParameters.pldaps.trialFunction` is what manages the flow of each trial. This is the only function that needs to be implemented by the user to take care of the drawing of the stimulus.

note: version 4.0 had a trialMasterFunction that instead took a class as a stimulus Function and had to have methods names frameUpdate to frameFlip. This is a cleaner, but might be more difficult for a matlab novice to understand. This is the reason for the change to the state function.

### pldapsDefaultTrialFunction
all basic features of pldaps from flipping the buffers to drawing the eye position of the experimentor screen are
implemented in a function called `pldapsDefaultTrialFunction`
To make use of these, this function must simply be called by your trialFunction.

## putting it all together
ok, now you will run your first experiment and work your way back from the trialFunction
to the core of pldaps.


to start, copy the function `loadPLDAPS` to a place in your path and edit the 'dirs' to include at least the 
path to PLDAPS. Next call loadPLDAPS, so that it is included in your path.

```Matlab
loadPLDAPS
```

now load some settings that should allow to run pldaps in a small screen for now

```Matlab
> load settingsStruct;
```

next creat a pldaps object and specify to use plain.m as the experiment file
set the subject to 'test'  and pass the struct we just loaded

```Matlab
p=pldaps(@plain,'test',settingsStruct)
```

now you have a pldaps object. To start the experiment, call
```Matlab
p.run
```
After the PTB window opens, you should now see a gray screen with a white grid in degrees of visual angle. When you move the cursor of the mouse, it will be drawn at a corresponding position in cyan on that screen. The screen is full gray for a short time every 5 seconds. Hit 'd' on the keyboard to step into the debugger. Look around, you are now in the `frameUpdate` function of if the `pldapsDefaultTrialFunction` where you can see, that 'q' will quit , 'm' would give a manual reward 'p' would end the trial give you a console to change defaultParameters for the next trials. To change paramers that are defined in the conditions, you would have to manually change the cells in `p.conditions{}` accoordingly.