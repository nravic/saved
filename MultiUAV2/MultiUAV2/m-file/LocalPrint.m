function LocalPrint( fname, flag )
%
% Handle local figure plotting preferences.
%	 (you need to change this as you see fit...)
%
%  NOTE(s):  
%    0. uses gcf, so expects the current plot to be the output target.
%    1. if flag > 0, then printing occurs, e.g.
%         >> pflag = 1;
%         >> LocalPrint('myplot', pflag);
%
% $Id: LocalPrint.m,v 2.2.14.2 2004/05/06 12:47:25 rasmussj Exp $
%==========================================================================
	global g_Debug; if(g_Debug==1),disp('LocalPlot.m');end;

	h = gcf;
	if( flag > 0 )
		if( exist('latexprint', 'file') == 2 )
		  latexprint(h, fname, 'coloreps', 'epslvl2', 'mathticklabels', ...
		             'asonscreen', 'nofigcopy', 'graphicx');
		else
			print(h, '-depsc2', fname);
		end
	end

  return;
