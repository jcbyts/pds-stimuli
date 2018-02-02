# Objects
The `stimuli.objects` in pds-stimuli are a set of classes that support the easy insertion of particular type of stimulus, such as **dots**, **fixation points**, **gabors**, **faces**, etc. The idea is to wrap all of the Psychtoolbox functions in a single object that makes setting up the `Screen` calls easy. Additionally, these objects will track certain things in their behavior automagically: when they turn on/ off; whether the subject is looking at them. The way it works is each of these stimulus objects is a `stimuli.stimulus` such that when they are created they inherit all of the properties and methods of `.stimulus`

## Base classes
There are a number of classes in pds-stimuli that 
1. [stimulus](#stimulus): governs **ALL** stimuli (tracks when they turn on, off. Has it's own random number generator)
2. [target](#target): is a `stimulus`. logs all fixations that are centered on it
3. [state](#state): a trial state. Handles a single behavioral state of a trial. Can be managed by `stateControl`
4. [stateControl](#stateControl): handles the movement between states
## Stimulus examples
### targets:
1. [textures](#textures): draw a texture
	* [face](#face): Draw a marmoset face `target`
2. [fixation](##fixation): Draw a fixation point `target`
3. [fixationImg](#fixationImg): Draw a fixation point that scans over a background image. Probably should be called "porthole"
4. [dots](#dots): Random dot kinematograms
	* [dotsbase](#dotsbase): abstract. Governs all dots
	* [dotsUniform](#dotsUniform): Pasternek range stimulus. Dot directions drawn from uniform distribution with specified range.
	* [dotsVonMises](#dotsVonMises): Dot directions drawn from vonMises distribution
	* [dotsNewsome](#dotsBritten): Coherence manipulation. Signal updates with specified `dt` (As close to the Britten dots as is possible with current monitors)
	* [dotsShadlen](#dotsShadlen): Coherence manipulation. N tiers of dots, interleaved every N frames.
5. [gabors/gratings](#gabors/gratings)
	* [gaborTarget](#gaborTarget): draw a drifting gabor
	* [gabordots](#gabordots): gabor reverse-correlation direction-discrimination paradigm
	* [plaids](#plaids)
### stimuli: (not targets)
1. [hartley](#hartleybase): Full field flashed hartley basis
2. [ffflash](#ffflash): Full field flash (for measuring CSD in V1)
3. [butterfly](#butterfly): Moving targets (faces, single dots, currently). Can do random walks or linear trajectories.


## stimulus
`stimulus` is a base class that governs the general tracking of what state an object is in (eg., *on*, *off*). `stimulus` is a handle class, meaning that passing it in and out of functions is quickly in matlab. That is because it points to the same place in memory and doesn't do a deep copy (as it would with structs). Stimulus mainly acts as an *abstract* class that governs some of the behavior of other objects, but it's important to get a feel for how its properties work, since almost all stimuli will use them. To create a stimulus, simply instantiate it by calling the constructor:

`hStim = stimuli.objects.stimulus()`

`hStim` is a stimulus object
```matlab
>> class(hStim)
ans =

	stimuli.objects.stimulus
```
**Properties**
    
`stimulus` has four important properties: **stimValue**, **rng**, **log**, **locked**

* stimValue 

	`stimValue` is a property that logs itself (record kept in `log`). If you change the value of `stimValue`, it will track the new value and when it was changed. If you set the value of `stimValue` to what it already is, it will not do anything.

* log

	`log` logs the value of `stimValue` and when it was changed. It is a [2 x nChanges] matrix where the first row is the value of `stimValue` and the second row is the time that it changed to that value.
    `log` has Get Access only, meaning you cannot set it yourself. The only way to change it is by changing `stimValue`
    
    eg., 
    
    
    	>> hStim.stimValue = 0;
        >> hStim.log(1,:)
        	ans =

     			1     0
		>> hStim.log(2,:)
			ans =
   				1.0e+05 *

    			8.0361    8.0413
    
    
`hStim.log` is a [2 x n] matrix, where the first row is the value of `hStim.stimValue`, and the bottom row is the time it changed to that value (using `GetSecs`). Here, you can see that setting `stimValue` to 0 was logged. You can also see that `stimValue` initialized to 1. If we were to run the same code again, it will not be logged when set to zero, and will only be logged when it is changed.

    	>> hStim.stimValue = 0;
		>> hStim.log(1,:)
			ans =
            
				1     0
		>> hStim.log(2,:)
			ans =
   				1.0e+05 *

    			8.0361    8.0413
	
The output is exactly the same as before because `stimValue` was not changed. 
    
*Many of the other* `stimuli.objects` *that inherit stimulus use* `stimValue` *to govern what state they in*
    
* rng    
	`rng` is a random number generator (specifically, a [RandStream](https://www.mathworks.com/help/matlab/ref/randstream.html?requestedDomain=true)). This enforces that each stimulus object will have their own private random number generator. All `rand()` calls with in a stimulus *must* be called using this propety to ensure that we can perfectly reproduce the exact random calls that were executed during an experimental session.
    There are three ways set the seed for each trial:
    
	1. let the stimulus do it randomly
			
            hStim.setRandomSeed();
            
	2. Pass in a specific seed
			
            hStim.setRandomSeed(1234)
            
	3. Pass in a RandStream object
			
            hStim.setRandomSeed(RandStream('twister', 'Seed', 1234)
            
    The default random number generator for `stimulus` is 'mt19937ar'. For more options, see [matlab documentation](https://www.mathworks.com/help/matlab/ref/randstream.list.html)
    
* locked

	`locked` locks the object. This is useful at the end of a trial, for example, so that no further tampering with the object can occur. In locked state, the object can only replay what already happened.
    `locked` can be set to true by running `hStim.cleanup()`. You cannot unlock a stimulus. 
    
## target
`target` is a base class that  inherits `stimulus` so it has `stimValue`, `rng`, `log`, `locked` as properties, and will log behavior of `stimValue` the same way `stimulus` did. Additionally, targets have `position`,`winRadius`,`fixlog` and `isFixated` as properties.

**Properties**
* position    
	`position` is [1 x 2] x,y position of the object (in pixels)

* winRadius    
	`winRadius` is the radius of a circular window centered on `position`. It is a scalar value (in pixels)
* isFixated    
	`isFixated` is a logical that indicates whether or not the object is currently fixated
* fixlog    
	`fixlog` is a [2 x n] log of all fixation starts, stops, and the time they occured. The first row is the fixation state. The second row is the time.

**Methods**
* isHeld(obj, xyEye)    
	`isHeld` checks whether the x,y position passed in is within `winRadius` of `position`. If it is or isn't, it updates `isFixated` and `fixlog` accordingly. This is the only way to set `isFixated` and `fixlog`
    
## state
`state` and `stateControl` are at the core of behavioral protocols in pds-stimuli. `state` has two properties `id` that identifies it, and `sc` that points to the `stateControl` object that has control over calling it. Importantly, all `state` objects have methods `frameUpdate` and `frameDraw` that govern all the behavior that occurs in that state. The blurb under `stateControl` will have some examples and hopefully make it clear what is so great about using states to control behavioral protocols.

**Properties**
* id    
	`id` is the identifier of this state (a number)
* sc    
	`sc` points to the `stateControl` object
    
**Methods**
* frameUpdate    
	`frameUpdate` is called by the `stateControl` object in the trialFunction every loop iteration and governs what happens in this state (at this time, conditioned on behavior, etc.)
* frameDraw    
	`frameDraw` is called by the `stateControl` object in the trialFunction every loop iteration and governs what is drawn to the screen

[stimuli.modules.fixflash.state0_FixWait](../blob/master/LICENSE) is a good example of what a state does: everytime it's frameUpdate is called, it checks what time it is and whether the behavioral conditions are met to turn on specific stimuli or move to the next state. If the conditions are met, it sets the state to another state. Again, for example, in `state0_FixWait`, the state is waiting for the subject to obtain fixation. If flashes a fixation point until fixation is obtained, or until a timer runs out. If fixation is obtained, it moves the state to [stimuli.modules.fixflash.state1_FixGracePeriod](). If the timer runs out without fixation ever being obtained, it sets the state to [stimuli.modules.fixflash.state7_BreakFixTimeout](). At any given time, only one state is active.

## stateControl
`stateControl` is the last base class. Together with the `state` class, it forms the pattern of behavior for a trial. stateControl can have states An example of 
```matlab
% set up a state control objects
sc = stimuli.objects.stateControl();

% initialize three states that don't do anything
sc.addState(stimuli.objects.state(0))
sc.addState(stimuli.objects.state(1))
sc.addState(stimuli.objects.state(2))
```

## textures

### face

## fixation

## fixationImg

## butterfly

## dots

### dotsbase

### dotsUniform

### dotsVonMises

## gabors/gratings






