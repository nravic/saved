function ret = CommMessageHistory(varargin)
%
% Build the message history for each message, and sum as you go.
%
% $Id: CommMessageHistory.m,v 2.0.18.2 2004/05/06 12:47:23 rasmussj Exp $
		

	global g_Debug; if(g_Debug==1),disp('CommMessageHistory.m');end;

	global g_SampleTime;
	global g_StopTime;
	global g_CommunicationMemory;

	msg_mem = [];
	switch(nargin),
	 case 1,
		msg_mem = varargin{:};
	 otherwise,
		msg_mem = g_CommunicationMemory;
	end

	k_max = msg_mem.NumberMessages;
	assert( k_max == length(msg_mem.Messages), mfilename );

	sz = floor(g_StopTime/g_SampleTime) + 1;
	ret = spalloc(sz,1,sz);
	for k = 1:k_max
		ret = ret + CommMessageHistorySingle( msg_mem.Messages{k}, sz, ...
																					g_SampleTime );
	end
	
	%assert( max(ret) > 0, mfilename );

	return;
	
