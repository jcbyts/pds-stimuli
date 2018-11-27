function path=pepRoot
% path=pepRoot
% Returns the path to the pep folder, even if it's been renamed.
% Also see PsychtoolboxRoot

path = which('pepRoot');
path = fileparts(path);
