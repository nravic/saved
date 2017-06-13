function TestTargetAngles
%TestMinimumDistance - this is a simple function to debug the target angle/template functions
%
%  Inputs:
%    (none) 
%
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  May 2001 - Created and Debugged - RAS



global g_Debug; if(g_Debug==1),disp('TestTargetAngles.m');end; 

%global g_TargetMemory;
global TargetTypes;

SimulationFunctions('InitializeSimulation');

PrintToFiles = 0;	%PrintToFiles = 1, to print to tiff files.

hFig = figure(28);
orient landscape;
set(hFig,'PaperPositionMode','auto');

clf

TestType = 'DrawTargetsAngles';

switch (TestType),
case 'DrawTargetsAngles',
	for CountType = 1:length(TargetTypes),
		if (PrintToFiles == 0),
			subplot(2,3,CountType );
		end;	%if (PrintToFiles == 0)
		
		PlotProbabilityCorrectTarget(TargetTypes(CountType));      
		LabelString = sprintf('Target Type #%d\n Length = %d, Width = %d',CountType,TargetTypes(CountType).Length,TargetTypes(CountType).Width);
		title(LabelString);
		if (PrintToFiles == 1)
			FileName = sprintf('.\\Figures\\TargetPlot%d.tiff',CountType);
			print('-dtiffn','-r300',FileName);
			FileName = sprintf('.\\Figures\\TargetPlot%d.emf',CountType);
			saveas(hFig,FileName,'emf');
		end;	%if (PrintToFiles == 0)
	end;	%	for 1:length(g_TargetMemory),   
	
	
	
	
	
otherwise,   
end;	%switch (TestType),


return


