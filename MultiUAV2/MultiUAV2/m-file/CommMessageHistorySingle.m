function ret = CommMessageHistorySingle( msg_list, sz, dt )
%
% Get the message history (doubles requires) at each major
% model update.
%
% $Id: CommMessageHistorySingle.m,v 2.0.10.1.8.2 2004/05/06 12:47:23 rasmussj Exp $

	global g_Debug; if(g_Debug==1),disp('CommMessageHistorySingle.m');end;
	
	ret = spalloc(sz,1,sz);
	msg_dbls = msg_list.NumberEntries;
	l = msg_list.IndexStorageTimeStamp;
	k_max = msg_list.LastMessageIndex;
	for k = 1:k_max,
		msg = msg_list.Data(:,k);
		m = floor(msg(l)/dt) + 1;
		ret(m) = ret(m) + msg_dbls;
	end

	return;
