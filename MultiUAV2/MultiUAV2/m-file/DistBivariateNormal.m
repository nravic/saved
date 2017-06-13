function [x,y] = DistBivariateNormal(s, varargin)
% Compute value(s) in bivariate normal distribution
%
%  Outputs: (x,y) in distribution
%  Required Inputs:
%    s = struct created by CreateStruct('BivariateNormalDist') with members:
%         mean_x = mean of x variate
%         mean_y = mean of y variate
%         sig_x  = standard deviation of x variate
%         sig_y  = standard deviation of y variate
%         rho    = correlation coefficient (rho\in[-1,+1])
%
%  Optional Inputs:
%    n = number of values to generate
%
%  Notes:
%    0. we assume randn has been initialized.
%
% $Id: DistBivariateNormal.m,v 2.1 2004/02/20 18:15:12 mitchejw Exp $

n = 1;
x = zeros(n,1);
y = zeros(n,1);
if( nargin > 1 )
	n = varargin{1};
end

a = randn(n,1);
b = randn(n,1);
x = s.mean_x + s.sig_x.*a;
y = s.mean_y + (s.rho*s.sig_y).*a + s.sig_y*sqrt(1 - s.rho^2).*b;

return
