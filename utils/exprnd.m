function r = exprnd(setupRNG, tau, sz)
% Exponential distributed random number (PLDAPS OVERLOAD)
% this function exists because we need to be able to generate exprnd calls
% with random seds which is not available as of matlab 2016b
% Example Call:
%   r = exprnd(setupRNG, tau, sz)
% Inputs:
%   setupRNG@RandStream
%   tau@double    [1 x 1]      time constant of exponential decay
%   sz@double     [M,N,P, ...] size of the array
rnd = rand(setupRNG, sz);
r   = -tau .* log(rnd); % new exponential random number