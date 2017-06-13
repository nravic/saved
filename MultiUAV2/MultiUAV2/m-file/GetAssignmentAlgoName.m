function n = GetAssignmentAlgoName()
% returns the name of the current assignment algorithm as a text string.
% For example,
%    algo_name = GetAssignmentAlgoName();
%
% $Id: GetAssignmentAlgoName.m,v 2.0.18.2 2004/05/06 12:47:25 rasmussj Exp $

	global g_Debug; if(g_Debug==1),disp('GetAssignmentAlgoName.m');end;

	global g_TypeAssignment;
	global g_AssignmentAlgorithm;

	k = g_AssignmentAlgorithm;
	c = struct2cell(g_TypeAssignment);
	f = fieldnames(g_TypeAssignment);
	f = f(1:end-1); % drop NumberEntries.

	n = 'Invalid Assignment Algorithm';
	if( ismember(k, [c{:}]) )
		n = char(f(k));
	else
		error(n);
	end

	return;
