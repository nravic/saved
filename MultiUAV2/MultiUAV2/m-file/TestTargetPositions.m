function TestTargetPositions(varargin)
% Test location of randomly distributed targets in kill-box.
%
%  Inputs: (varargin)
%    #                 Description
%    0 - default, generate 100 random target locations, then plot.
%    1 - generate arg1 random target locations, then plot.
%    2 - as #1, but plot the data as it is generated, i.e. build-up.
%
%  Outputs:
%    <just a plot>
%
%  Notes:
%    0. Set your distribution type/info in InitializeGlobals.m
%    1. plotting as you go is several orders of mag slower than after
%
% $Id: TestTargetPositions.m,v 2.1.18.2 2004/05/06 12:47:27 rasmussj Exp $

global g_Debug; if(g_Debug==1),disp('TestTargetPositions.m');end; 

global g_TargetMemory;
global g_SearchSpace;
global g_TargetSpace;
global g_ActiveTargets;
global g_PlotAxesLimits;
global g_TargetDistributionData;
global g_MonteCarloMetrics; % needed to improve speed of test

lmax = 100;
if( nargin > 0 )
	lmax = varargin{1};
end

isShowAsYouGo = 0;
if( nargin > 1 )
	isShowAsYouGo = varargin{2};
end

SimulationFunctions('InitializeSimulation');

PrintToFiles = 0;	%PrintToFiles = 1, to print to tiff files.

hFig = figure(29);
orient landscape;
set(hFig,'PaperPositionMode','auto');

clf

hold on

%%========================================================================
%% Plot Search Space and target Space Rectangles (from PlotOutput.m)
%%========================================================================
SearchSpaceWidth = (g_SearchSpace(2) - g_SearchSpace(1));
SearchSpaceHeight = (g_SearchSpace(4) - g_SearchSpace(3));
rectangle('Position',[g_SearchSpace(1),g_SearchSpace(3), ...
           SearchSpaceWidth,SearchSpaceHeight], ...
				'Curvature',[0,0],...
				'LineStyle','--', ...
				'LineWidth',2, ...
				'EdgeColor',[0.0,0.0,1.0]);

TargetSpaceWidth = (g_TargetSpace(2) - g_TargetSpace(1));
TargetSpaceHeight = (g_TargetSpace(4) - g_TargetSpace(3));
rectangle('Position',[g_TargetSpace(1),g_TargetSpace(3),...
          TargetSpaceWidth,TargetSpaceHeight], ...
				'Curvature',[0,0],...
				'LineStyle',':', ...
				'LineWidth',2, ...
				'EdgeColor',[0.0,1.0,0.0]);

%% axis setup
axis equal;
axis(g_PlotAxesLimits);
XTicks = [sort(0:-5280:g_PlotAxesLimits(1)) 5280:5280:g_PlotAxesLimits(2)];
YTicks = [sort(0:-5280:g_PlotAxesLimits(3)) 5280:5280:g_PlotAxesLimits(4)];
set(gca,'XTick',XTicks,'YTick',YTicks);
set(gca,'XTickLabel',num2str(XTicks'/5280),'YTickLabel',num2str(YTicks'/5280));
grid

n = g_ActiveTargets;
%x = zeros(n, lmax);
%y = zeros(n, lmax);
[x{1:lmax}] = deal([]);
[y{1:lmax}] = deal([]);
%% now plot the target positions
for l = 1:lmax
	InitializeTargets;
%	if( ~rem(l,20) )
%		disp(['l = ' num2str(l)]);
%	end

	x{l} = [g_TargetMemory(1:n).PositionX]';
	y{l} = [g_TargetMemory(1:n).PositionY]';
%	x(:,l) = [g_TargetMemory(1:n).PositionX]';
%	y(:,l) = [g_TargetMemory(1:n).PositionY]';

	if( isShowAsYouGo )
%		plot( x{l}, y{l}, 'ro', 'markersize', 3 );
		plot( x(:,l), y(:,l), 'ro', 'markersize', 3 );
		pause(0.05);
	end
end

if( ~isShowAsYouGo )
	%% the notation '[q{:}]' turns the list of column vectors q{}
	%% into a matrix of columns, i.e. [q{1} q{2} ... q{n}]
	plot( [x{:}], [y{:}], 'ro', 'markersize', 3 );
%	plot( x, y, 'ro', 'markersize', 3 );
end

xlabel('{\it X} [mi]');
ylabel('{\it Y} [mi]');
title(['Target Locations: ' num2str(l) ' sets of ' ...
       num2str(g_ActiveTargets) ' targets' ]);

% pickup up the distribution Stats
s = g_TargetDistributionData.BivariateNormalDist;
txt = str2mat( ...
 sprintf('x_{avg} = % 6.3f mi', s.mean_x/5280), ...
 sprintf('y_{avg} = % 6.3f mi', s.mean_y/5280), ...
 sprintf('\\sigma_x = % 6.3f mi', s.sig_x/5280), ...
 sprintf('\\sigma_y = % 6.3f mi', s.sig_y/5280), ...
 sprintf('\\rho = % 6.3f', s.rho) );
clear s;

text(4*5280, -0.00*5280, txt(1,:), 'fontsize', 16);
text(4*5280, -0.25*5280, txt(2,:), 'fontsize', 16);
text(4*5280, -0.50*5280, txt(3,:), 'fontsize', 16);
text(4*5280, -0.75*5280, txt(4,:), 'fontsize', 16);
text(4*5280, -1.00*5280, txt(5,:), 'fontsize', 16);

return
