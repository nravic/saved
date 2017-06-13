function CommPlot(varargin)
%
% Plot a message history's data rates.
%
% $Id: CommPlot.m,v 2.0.18.2 2004/05/06 12:47:23 rasmussj Exp $

	global g_Debug; if(g_Debug==1),disp('CommPlot.m');end;

	global g_StopTime;
	global g_SampleTime


	assert( nargin == 1, mfilename );
	assert( varargin{1} == 0, mfilename );

	dbl_to_kbits = 8*8/1024;
	d = CommMessageHistory*dbl_to_kbits / g_SampleTime;
	s = CommRunStats(d);
	[d_min, d_max, d_avg, d_med, d_std] = deal(s{:});

	figure;
	clf;
	% seems like magic for the sparse to plot with full vector...
	ph = plot(0:g_SampleTime:g_StopTime, d );
	grid;
	xlabel('Time [sec]');
	ylabel('Data Rate [kb/s]');

	title([GetAssignmentAlgoName, ' Communication Data Rate: max:' num2str(d_max), ...
				 ' kb/s, avg:', num2str(d_avg), ' kb/s']);

	disp('Communication Stats:');
	disp(sprintf('  min: % 6.2f kb/s', numeric(d_min)));
	disp(sprintf('  max: % 6.2f kb/s', numeric(d_max)));
	disp(sprintf('  avg: % 6.2f kb/s', numeric(d_avg)));
	disp(sprintf('  med: % 6.2f kb/s', numeric(d_med)));
	disp(sprintf('  std: % 6.2f kb/s', numeric(d_std)));
	
	return;
