function CommPlotMonte( data, varargin )
%
% Plot history's data rates for MonteCarlo runs.
%	 (you need to change this as you see fit...)
%
%  Input(s):
%    1. data: is an N length structure with each entry containing a
%       g_CommunicationMemory block to be processed.
%
%    2. varargin: any additional arguments cause isPrint = 1.
%
%  NOTE(s):  
%      0. local print settings/method is handled by function 
%         LocalPrint.m.
%      1. MATLAB 6.5+ seems completely broken w.r.t sparse data.
%         So, at every location, we grab sparse data and full-ify it on
%         its way to various broken functions...6.1 worked just fine.
%
% $Id: CommPlotMonte.m,v 2.3.6.1.6.2 2004/05/06 12:47:23 rasmussj Exp $
%==========================================================================

	global g_Debug; if(g_Debug==1),disp('CommPlotMonte.m');end;

	global g_SampleTime;
	global dbl_to_kbits; dbl_to_kbits = 8*8/1024;

	k_max = length(data);

	%for k=1:k_max,
	%	do_plot( data{k} );
	%	pause;
	%end

	%% check if we've externally requested print control
	if( nargin > 1 )
		isPrint = 1;
	else
		isPrint = 0;
	end

	figno = 314;

	s = [];
	y = [];
	for k=1:k_max,
		s(k,:) = cell2mat( CommRunStats(lfixup_full(data{k}.CommMsgHist)) );
		y = [y lfixup_full(data{k}.CommMsgHist)]; % collect data as columns per run
	end
	
	% convert from raw number of matlab doubles to kbits/s
	y = y*dbl_to_kbits / g_SampleTime;
	s = s*dbl_to_kbits / g_SampleTime;

	d_max = s(:,2);
	d_avg = s(:,3);
	d_sig = s(:,5);

	d_max_max = max(d_max);
	d_max_min = min(d_max);
	d_max_avg = mean(d_max);
	d_max_med = median(d_max);
	d_max_cov = cov(d_max);

	colors = get(0,'DefaultAxesColorOrder');
	figure(figno); figno = figno + 1; clf;
	ph = plot( [d_max d_avg ]);
	if(~isPrint), legend('max rate', 'avg rate'); end;
	subplot(211);
	plot( d_max );
	grid;
	title([GetAssignmentAlgoName, ': Max Data Rate']); 
	ylabel('Data Rate [kbits/s]');
	subplot(212)
	%	plot( d_avg, 'Color', colors(2,:) );
	%	title('Avg Data Rate');
	cavg = [];
	cdev = [];
	r = length(d_max);
	for k = 1:r
		cavg(k) = mean(d_max(1:k));
		cdev(k) = std(d_max(1:k));
	end
	plot( cavg+cdev, 'Color', colors(3,:) );
	hold on;
	plot( cavg-cdev, 'Color', colors(3,:) );
	plot( cavg, 'Color', colors(2,:) );
	hold off;
	title([GetAssignmentAlgoName, ': Running Avg Max Data Rate']); 
	grid;
	ylabel('Data Rate [kbits/s]');
	xlabel('Scenario');
	hold off;
	LocalPrint('cumulative-average-c', isPrint);

	figure(figno); figno = figno + 1; clf;
	hist(d_max);
	grid;
	xlabel('Data Rate [kbits/s]');
	ylabel('Frequency');
	title([GetAssignmentAlgoName, ': Max Data Rate Frequency']); 
	LocalPrint('frequency-c', isPrint);


	disp('Maximum Data Rate Cumulative Average Stats:');
	disp(sprintf('max = %.2f', d_max_max));
	disp(sprintf('min = %.2f', d_max_min));
	disp(sprintf('avg = %.2f', d_max_avg));
	disp(sprintf('med = %.2f', d_max_med));
	k = 35;
	disp(sprintf('%dth run %% of final avg: %.2f %%', k, abs(1-d_max(k)/cavg(end))));

	figure(figno); figno = figno + 1; clf;
	tmp = cavg./cavg(end);
	plot(tmp);
	grid;
	%x = 0.02;
	%hl = hline(1+[-x x],'-');
	%for k = 1:2
	%  set(hl(k), 'color', colors(3,:));
	%end
	xlabel('Scenario');
	ylabel('Cumulative Avg Ratio');
	%lh = legend(hl(1),['_{\pm ', num2str(x*100), '% of {\itX}^{*}_{max}}'],4);
	%set(lh,'fontsize',14);
	%ax = axis;
	%axis([ax(1:2) -.5 .5]);
	title([GetAssignmentAlgoName, ': Running Cumulative Avg Ratio']); 
	LocalPrint('cumulative-percent-c', isPrint);
	%save lc.mat tmp;

	figure(figno); figno = figno + 1; clf;
	[c,h]=contour(corrcoef(y).*(ones(k_max) - eye(k_max)));
	if(~isPrint)
		title([GetAssignmentAlgoName, ': Data Rate Correlation: \rho_{ij}, \rho_{ii} = 0']); 
	end
	title('');
	xlabel('Scenario');
	ylabel('Scenario');
	colormap(jet);
	colorbar;
	%clabel(c,h);
	%LocalPrint('corrcoef-c', isPrint);
	if( isPrint ), print -depsc2 corrcoef-c.eps; end;

	figure(figno); figno = figno + 1; clf;
	%h=surfc(corrcoef(y).*(ones(k_max)-eye(k_max)),'facecolor','interp','facelighting','phong');
	dd=corrcoef(y).*(ones(k_max)-eye(k_max));
	h=surfc(dd,'facecolor','interp',...
					'facelighting','phong', 'facealpha','flat','alphadatamapping', ...
					'scaled','alphadata',gradient(dd),'edgecolor','none' );
	view(-22,28);
	axis([0 50 0 50 -0.20 0.5]);
	alpha(0.5);
	if(~isPrint)
		title([GetAssignmentAlgoName, ': Data Rate Correlation: \rho_{ij}, \rho_{ii}\equiv 0']); 
	end
	xlabel('Scenario');
	ylabel('Scenario');
	zlabel('Magnitude: \rho_{ij}\in\Re[0,1]');
	colormap(jet);
	%colorbar;
	%LocalPrint('corrcoef-c', isPrint);
	%if( isPrint ), print -depsc2 corrcoef-c.eps; end;

	% find interesting min, max, med, avg, senarios to plot
	x = find(d_max==d_max_max);
	y = find(d_max==d_max_min);
	k_max=x(1);
	k_min=y(1);

	% median is harder
	[x,k] = sort(d_max);
	l = find(x>=d_max_med);
	k_med=k(l(1));

	%k_avg=40; % by inspecting the graph!

	figno = figno + 1;
	do_plot( figno, data{k_max} );
	LocalPrint('max-comm-c', isPrint);

	figno = figno + 1;
	do_plot( figno, data{k_min} );
	LocalPrint('min-comm-c', isPrint);

	figno = figno + 1;
	do_plot( figno, data{k_med} );
	LocalPrint('med-comm-c', isPrint);

	%figno = figno + 1;
	%do_plot( figno, data{k_avg} );
	%LocalPrint('avg-comm-c', isPrint);

	return;

%==========================================================================
function do_plot( figno, msgbox )

	global g_Debug; if(g_Debug==1),disp('CommPlotMonte::do_plot');end;

	global g_StopTime;
	global g_SampleTime
	global dbl_to_kbits; 

	d = lfixup_full(msgbox.CommMsgHist)*dbl_to_kbits / g_SampleTime;
	%d = lfixup_full(msgbox.CommMsgHist); % just raw # doubles
	s = CommRunStats(d);
	[d_min, d_max, d_avg, d_med, d_std] = deal(s{:});

	figure(figno); clf;
	% seems like magic for the sparse to plot with full vector...
	% (of course, it is broken w.r.t MATLAB v6.5.)
	x = [0:g_SampleTime:g_StopTime]';
	ph = plot(x, d );
	grid;
	xlabel('Time [sec]');
	ylabel('Data Rate [kbits/s]');

	algo_name = strrep( GetAssignmentAlgoName, 'CapTransShip', 'CTP' );
	title([algo_name, ' Seed:',num2str(msgbox.seed),' Communication Data Rate: max:', ...
				 num2str(d_max), ' kbits/s, avg:', num2str(d_avg), ' kbits/s']);

	disp(['Communication Stats (seed:',num2str(msgbox.seed),'):']);
	disp(sprintf('	min: % 6.2f kbits/s', d_min));
	disp(sprintf('	max: % 6.2f kbits/s', d_max));
	disp(sprintf('	avg: % 6.2f kbits/s', d_avg));
	disp(sprintf('	med: % 6.2f kbits/s', d_med));
	disp(sprintf('	std: % 6.2f kbits/s', d_std));

	return;

%%=========================================================================
%% Function(s) to take care of local MATLAB 6.5 fixups
%%=========================================================================
function A = lfixup_full( X )
 
  A = full(X);

	return;
