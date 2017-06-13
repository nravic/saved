function assert( bool, fname )
%  Perform assert checking similar to the C assert() macro.  The function is
%  controlled by the global variable g_ASSERT_STATUS.
%  
%       g_ASSERT_STATUS = 0 => assertions are ignored.
%       g_ASSERT_STATUS = 1 => assertions are not ignored.
%
%  Example:
%       assert( k > 0, mfilename );
%       assert( k == 1, mfilename );
%       assert( k > 2 & k < 8, mfilename );
%       assert( k > 9 | k < 15, mfilename );
%
%  NOTE: Do not translate 'mfilename'; its use is literal.  
%        See 'help mfilename'
%
% $Id: assert.m,v 2.0.18.2 2004/05/06 12:47:28 rasmussj Exp $

	global g_Debug; if(g_Debug==1),disp(mfilename);end;

	global g_ASSERT_STATUS;

	if( g_ASSERT_STATUS )
		if( ~bool )
			disp('Call Stack:');
			s = dbstack;
			for k = 2:length(s),
				file = strrep(s(k).name, [pwd,'/'],'');
				disp( sprintf('  L: % d  F: %s', s(k).line, file));
			end
			error(fname);
		end
	end

	return;
