function dir = supportDataDir()
%SUPPORTDATADIR Summary of this function goes here
%   Detailed explanation goes here

    dir=mfilename('fullpath');
    fname=mfilename();
    
    dir=[dir(1:end-length(fname)) 'supportData'];
end

