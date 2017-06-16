function [wd, T, wn, zeta] = eigparam(lambda)

% [wd, T, wn, zeta] = eigparam(lambda)
%
% Return the parameters of a complex eigenvalue
% Inputs:
%   lambda = a complex eigenvalue
% Outputs:
%   wd = the damped natural frequency
%   T = the period
%   wn = the natural frequency
%   zeta = the damping

a = real(lambda);
b = imag(lambda);

wd = abs(b);
T = 2*pi/wd;

wn = (a^2 + b^2)^0.5;
zeta = -a/wn;