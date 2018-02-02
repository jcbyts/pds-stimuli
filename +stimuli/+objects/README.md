# Objects
The `stimuli.objects` in pds-stimuli are a set of classes that support the easy insertion of particular type of stimulus, such as **dots**, **fixation points**, **gabors**, **faces**, etc. The idea is to wrap all of the Psychtoolbox functions in a single object that makes setting up the `Screen` calls easy. Additionally, these objects will track certain things in their behavior automagically: when they turn on/ off; whether the subject is looking at them. The way it works is each of these stimulus objects is a `stimuli.stimulus` such that when they are created they inherit all of the properties and methods of `.stimulus`

## Base classes
There are a number of classes in pds-stimuli that 
1. [stimulus](##stimulus): governs **ALL** stimuli (tracks when they turn on, off. Has it's own random number generator)
2. [targets](##targets): is a `stimulus`. logs all fixations that are centered on it
3. [state](##state): a trial state. Handles a single behavioral state of a trial. Can be managed by `stateControl`
4. [stateControl](##stateControl): handles the movement between states
## Stimulus examples
### targets:
1. [textures](##textures): draw a texture
	* [face](##face): Draw a marmoset face `target`
2. [fixation](##fixation): Draw a fixation point `target`
3. [fixationImg](##fixationImg): Draw a fixation point that scans over a background image. Probably should be called "porthole"
4. [dots](##dots): Random dot kinematograms
	* [dotsbase](###dotsbase): abstract. Governs all dots
	* [dotsUniform](###dotsUniform): Pasternek range stimulus. Dot directions drawn from uniform distribution with specified range.
	* [dotsVonMises](###dotsVonMises): Dot directions drawn from vonMises distribution
	* [dotsNewsome](###dotsBritten): Coherence manipulation. Signal updates with specified `dt` (As close to the Britten dots as is possible with current monitors)
	* [dotsShadlen](###dotsShadlen): Coherence manipulation. N tiers of dots, interleaved every N frames.
5. [gabors/gratings](##gabors/gratings)
	* [gaborTarget](###gaborTarget)
### stimuli: (not targets)
1. [hartley](##hartleybase): Full field flashed hartley basis
2. [ffflash](##ffflash): Full field flash (for measuring CSD in V1)
3. [butterfly](##butterfly): Moving targets (faces, single dots, currently). Can do random walks or linear trajectories.

### dots

#### dotsbase

#### dotsUniform

#### dotsVonMises




### fixationImg

## stimulus
`stimulus` governs the general tracking of what state an object is in (eg., *on*, *off*). `stimulus` is a handle class, meaning that passing it in and out of functions is (now) fast in matlab. That is because it points to the same place in memory and doesn't do a deep copy (as it would with structs). To create a stimulus, simply instantiate it by calling the constructor:

`hStim = stimuli.objects.stimulus()`

`hStim` is a stimulus object
```matlab
>> class(hStim)
ans =

	stimuli.objects.stimulus
```
#### Properties
    
`stimulus` has four important properties: **stimValue**, **rng**, **log**, **locked**

* stimValue 

	`stimValue` is a property that logs itself (record kept in `log`). If you change the value of `stimValue`, it will track the new value and when it was changed. If you set the value of `stimValue` to what it already is, it will not do anything.
    
    eg., 
    
    ```matlab
    	>> hStim.stimValue = 0;
        >> hStim.log(1,:)
        	ans =

     			1     0
		>> hStim.log(2,:)
			ans =
   				1.0e+05 *

    			8.0361    8.0413
    
    ```
    
    `hStim.log` is a [2 x n] matrix, where the first row is the value of `hStim.stimValue`, and the bottom row is the time it changed to that value (using `GetSecs`). Here, you can see that setting `stimValue` to 0 was logged. You can also see that `stimValue` initialized to 1. If we were to run the same code again, it will not be logged when set to zero, and will only be logged when it is changed.

	```matlab
    	>> hStim.stimValue = 0;
		>> hStim.log(1,:)
			ans =
            
				1     0
		>> hStim.log(2,:)
			ans =
   				1.0e+05 *

    			8.0361    8.0413
    ```
	The output is exactly the same as before because `stimValue` was not changed. 
    
    *Many of the other* `stimuli.objects` *that inherit stimulus use* `stimValue` *to govern what state they in*
    
* rng    
	`rng` is a random number generator (specifically, a [RandStream](https://www.mathworks.com/help/matlab/ref/randstream.html?requestedDomain=true)). This enforces that each stimulus object will have their own private random number generator. All `rand()` calls with in a stimulus *must* be called using this propety to ensure that we can perfectly reproduce the exact random calls that were executed during an experimental session.
    There are three ways set the seed for each trial:
    	1. let the stimulus do it randomly
			```matlab
            hStim.setRandomSeed();
            ```
		2. Pass in a specific seed
			```
            hStim.setRandomSeed(1234)
            ```
		3. Pass in a RandStream object
			```
            hStim.setRandomSeed(RandStream('twister', 'Seed', 1234)
            ```
    The default random number generator for `stimulus` is 'mt19937ar'. For more options, see [matlab documentation](https://www.mathworks.com/help/matlab/ref/randstream.list.html)
    
## targets

### face

### fixation


### butterfly

### dots

#### dotsbase

#### dotsUniform

#### dotsVonMises




### fixationImg

