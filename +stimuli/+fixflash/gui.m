%Alexis Sietins
%11-16-2011


%gui_class_example
%
% This exmaple shows how to use a MATLAB CLASSDEF to create, maintain, and
% destroy a gui. 

% I chose to use one of the standard MATLAB guide default gui examples,
% this allows you to see the differences between the two methods.

% I prefer using classes to control gui's because as the project gets
% larger, I find it much easier to maintain, understand, and debug using a
% class bases sytem than using the traditional gui based system. 

% Also, this method is great for passing data between elements of the gui.
% Since the class managed the gui, all gui elems are within memory scope of
% the class.

% Almost everything is the same between managing a gui through the gui
% mfile and a class. There are 2 main differences that I've noticed.

% 1. With the class based system, you do not need to store and set the
% guidata to obtain and pass data along

% 2. Cleanup is harder using the Class based system. There are 2 objects in
% memory, the gui itself and the class. These must be linked in some way
% that if one is closed or destroyed, the other is taken care of. I show
% one solution to this siutation here by adding a closerequestfcn to the
% figure. This function then calls the class's delete function to clean up
% the memory (preventing memory leaks). 


%class deffinition - I parent class the desired class to the handle class.
%This allows for better memory management by Matlab. 
classdef gui < handle  
    
    %class properties - access is private so nothing else can access these
    %variables. Useful in different sitionations
    properties (Access = private)
        
        density = 0;
        volume = 0;
        
        gui_h;
    end
    
    %Open class methods - in this case, it is restricted to the class
    %constructor. These functions can be accessed by calling the class
    %name. 
    %Ex M = gui_class_example(); calls the class contructor
    %
    %M.sub_function() would call the function sub_fnction, in this example,
    %there is no such function defined.
    methods
        
        %function - class constructor - creates and init's the gui
        function this = gui
            
            %make the gui handle and store it locally
            this.gui_h = guihandles(fixFlashPlot);
            
            %sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(this.gui_h.figure1,  'closerequestfcn', @(src,event) Close_fcn(this, src, event));
            

        end
        
        function update(this, p, sn)
            
            if nargin < 3
                sn = 'stimulus';
            end
            
            outcomes = cellfun(@(x) x.(sn).hTrial.error, p.data);
            errs = [0 1 2];
            n = numel(errs);
            num = zeros(n,1);
            for i = 1:n
                num(i) = sum(outcomes == errs(i)); 
            end
            
            bar(this.gui_h.TrialOutcomes, errs, num, 'FaceColor', .5*[1 1 1]);
        
            histogram(this.gui_h.HoldTime, cellfun(@(x) x.(sn).hTrial.fixDuration, p.data), 'FaceColor', .5*[1 1 1]);
            
            
        end
        
    end
    
    
    %Private Class Methods - these functions can only be access by the
    %class itself.
    methods (Access = private)
        
        %class deconstructor - handles the cleaning up of the class &
        %figure. Either the class or the figure can initiate the closing
        %condition, this function makes sure both are cleaned up
        function delete(this)
            %remove the closerequestfcn from the figure, this prevents an
            %infitie loop with the following delete command
            set(this.gui_h.figure1,  'closerequestfcn', '');
            %delete the figure
            delete(this.gui_h.figure1);
            %clear out the pointer to the figure - prevents memory leaks
            this.gui_h = [];
        end
        
        %function - Close_fcn
        %
        %this is the closerequestfcn of the figure. All it does here is
        %call the class delete function (presented above)
        function this = Close_fcn(this, src, event)
            delete(this);
        end
        
        

        
    end
    
end