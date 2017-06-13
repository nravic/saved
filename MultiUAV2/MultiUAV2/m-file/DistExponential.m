function x = DistExponential(varargin)
% Sample value(s) from an exponential distribution of mean beta. 
%
% Algorithm: 'Simulation Modeling & Analysis' by Law & Kelton, 3rd ed.; \S 8.3.2
%
%  Outputs: [x] in distribution
%
%  Inputs:
%    b = distribution mean, default = 1
%    n = number of (rows) values to generate, default 1
%    m = number of (columns) values to generate, default 1
%
%  Examples:
%    DistExponential()      - one random exponential variate of mean 1.
%    DistExponential(b)     - one random exponential variate of mean b.
%    DistExponential(b,m)   - m random exponential variates of mean b.
%    DistExponential(b,m,n) - (m,n) random exponential variates of mean b.
%
%  Notes:
%    1. we assume rand has been initialized.
%
% $Id: DistExponential.m,v 2.1 2004/02/20 18:15:12 mitchejw Exp $

	if( nargin > 3 )
		usage;
		error('Incorrect arguments.');
	end

	b = 1;
	n = 1;
	m = 1;

	%% per call setup
	if( nargin > 0 )
		b = varargin{1};
	end
	if( nargin > 1 )
		n = varargin{2};
	end
	if( nargin > 2 )
		m = varargin{3};
	end

	x = -b .* log(rand(n,m));

	return

function usage
	
	disp(sprintf('\nusage:'));
	disp('  DistExponential()    - one random exponential variate of mean 1');
	disp('  DistExponential(m)   - one random exponential variate of mean m');
	disp('  DistExponential(m,k) - k random exponential variates of mean m');
	disp('  DistExponential(m,k,n) - (k,m) random exponential variates of mean m');
	disp('');

	return
