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
The first argument is an active pldaps object. The second is a state value, and the third is a string that is the name of the module (as it was setup in the active pldaps object).




