function [r,th] = DistPoissonPolar(Rmax, lambda, varargin)
% Compute value(s) for stationary two-dimensional (polar) Poisson process
%
% Algorithm: 'Introduction to Probability Models' by Ross, 4th ed.; \S 5.2
%
%  Outputs: (r,\theta) in distribution
%  Inputs:
%    Rmax   = maximum radius
%    lambda = intensity or rate
%
%  Optional Args:
%    'plot' = show a plot of the distribution w/ stat info
%
%  Notes:
%    1. we assume rand has been initialized.
%
% $Id: DistPoissonPolar.m,v 2.1 2004/02/20 18:15:12 mitchejw Exp $

	if( isempty(Rmax) | Rmax == 0 )
		error('Rmax incorrectly specified.');
	end

	if( isempty(lambda) | lambda == 0 )
		error('Intensity lambda incorrectly specified.');
	end

	c = lambda*pi*Rmax^2;

	% generate independent exponentials (conservative k) to find N(\lambda)
	m = floor(2*(1+c)); % on avg require 1+\lambda\pi r^2 exponentials
	X = cumsum(DistExponential(1,m)); % cumulative sum of m exponentials of unit rate

	l = find( X > c ); % l(end) is max( X(:,k) < c )
	if( isempty(l) )
		error(['computed draw fell short increase m above.']);
	end
	N = l(1) - 1;

	r = zeros(N,1);
	for k = 1:N
		r(k) = sqrt( sum(X(1:k)) / (pi*lambda) );
	end
	
	th = 2*pi*rand(N,1);

	if( nargin > 2 & strcmp(varargin{1}, 'plot') )
		plot(r.*cos(th),r.*sin(th),'o'),grid;
		axis(Rmax*[-1 1 -1 1]);
		title(['Polar Poisson: {\itr} < ' num2str(Rmax) 'mi' ...
					 ', \lambda = ' num2str(lambda) ...
					 ', {\itA} = ' num2str(pi*Rmax^2) ' mi^2'...
					 ', \lambda{\itA} = ' num2str(floor(lambda*pi*Rmax^2)) ''...
					 ', {\itN} = ' num2str(length(r)) ]);
		xlabel('{\itX} [mi]');
		ylabel('{\itY} [mi]');
	end
	
	return

function usage
	
	disp(sprintf('\nusage:'));
	disp('  DistPoissonPolar(s,n) - return points randomly distributed in (polar)');
	disp('                          plane by Poisson process of rate lambda');
	disp('');

	return
