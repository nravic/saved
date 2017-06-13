function [dummy] = DebugShowData(t)
%DebugShowData - show desired data at top of simulink loop for debugging.
%
%  Inputs:
%     t - current simulation time.
%  Outputs:
%     dummy - must have output for MATLAB FCN blocks; stupid.
%
%  AFRL/VACA
%  May 2003 - Created and Debugged - JWM
%  $CVSId$

	dummy = 0;

	return;

	global g_CommunicationMemory;

	persistent ilst;

	if( t == 0.0 )
		ilst = 1; 
	end
	
	icur = size(g_CommunicationMemory.InBoxes(1).MessageHeaders, 2);
	
	if( icur > ilst )
		format short;
		diary 00comm_debug.txt;
		
		disp(sprintf('Current sim time: t = % .2f',  t));
		disp(sprintf('# messages in box= %d', icur))
		
		disp('InBoxen(1).MessageHeaders:');
		g_CommunicationMemory.InBoxes(1).MessageHeaders(:,ilst:icur)

		diary off;

		ilst = icur;
	end

	% pause;

	return;
