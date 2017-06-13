function ret = CommRunStats( d )
% returns the essential statistics of a communication history.
% For example,
%    d = CommMessageHistory; s = CommRunStats(d);
%
% $Id: CommRunStats.m,v 2.0.18.2 2004/05/06 12:47:24 rasmussj Exp $

	global g_Debug; if(g_Debug==1),disp(mfilename);end;

	ret = { min(d), max(d), mean(d), median(d), std(d) };

	return
	
