function TestPlotSummaryData(action)
%TestPlotSummaryData - 
%
%  Inputs:
%    (none) 
%
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  May 2002 - Created and Debugged - RAS


% load data files using the import wizard
%SummaryData_1_020627a = data;
%save 'SummaryData_1_020627a.mat' SummaryData_1_020627a
%save 'Target1PostionHeading.mat' Target1PostionHeading

NumberStates = 5;
NumberTargets = 3
FirstTargetFirstState = 8;
LastTargetFirstState = (NumberTargets-1)*NumberStates + FirstTargetFirstState;

if(~exist('action')),
	action='Default';
end;
PrintToFiles = 0;

switch(action),
case 'Default',
	load 'SummaryData_1_020627a.mat'
	load 'SummaryData_2_020627a.mat'
	
	[Rows1,Columns1]=size(SummaryData_2_020627a);
	[Rows2,Columns2]=size(SummaryData_2_020627a);
	if(Rows1 > Rows2),
		SummaryData1 = SummaryData_1_020627a([1:Rows2],:);
		SummaryData2 = SummaryData_2_020627a;
		Rows = Rows2;
	else
		SummaryData2 = SummaryData_2_020627a([1:Rows1],:);
		SummaryData1 = SummaryData_1_020627a;
		Rows = Rows2;
	end;
	
	TempDetectedTimeVector01 = SummaryData1(:,[FirstTargetFirstState:NumberStates:LastTargetFirstState]);
	TempDetectedTimeVector02 = SummaryData2(:,[FirstTargetFirstState:NumberStates:LastTargetFirstState]);
	TempVerifiedTimeVector01 = SummaryData1(:,[FirstTargetFirstState+(NumberStates-1):NumberStates:LastTargetFirstState+(NumberStates-1)]);
	TempVerifiedTimeVector02 = SummaryData2(:,[FirstTargetFirstState+(NumberStates-1):NumberStates:LastTargetFirstState+(NumberStates-1)]);
	VerifiedTimeVector01 = [];
	DetectedTimeVector01 = [];
	VerifiedTimeVector02 = [];
	DetectedTimeVector02 = [];
	TotalSearchTimeVector01 = [];
	TotalSearchTimeVector02 = [];
	ValidRows = [];
	for(CountRows = 1:Rows),
		if(all(TempDetectedTimeVector01(CountRows,:)>0) & ...
			all(TempVerifiedTimeVector01(CountRows,:)>0) & ...
			all(TempDetectedTimeVector02(CountRows,:)>0) & ...
			all(TempVerifiedTimeVector02(CountRows,:)>0)),
			DetectedTimeVector01 = [DetectedTimeVector01;TempDetectedTimeVector01(CountRows,:)];
			VerifiedTimeVector01 = [VerifiedTimeVector01;TempVerifiedTimeVector01(CountRows,:)];
			DetectedTimeVector02 = [DetectedTimeVector02;TempDetectedTimeVector02(CountRows,:)];
			VerifiedTimeVector02 = [VerifiedTimeVector02;TempVerifiedTimeVector02(CountRows,:)];
			TotalSearchTimeVector01 = [TotalSearchTimeVector01;SummaryData1(CountRows,6)];
			TotalSearchTimeVector02 = [TotalSearchTimeVector02;SummaryData2(CountRows,6)];
			ValidRows = [ValidRows ;CountRows];
		end;
	end;
	
	ValidRows
	DetectedTimeVector01
	VerifiedTimeVector01
	TotalSearchTimeVector01
	DetectedTimeVector02
	VerifiedTimeVector02
	TotalSearchTimeVector02
	
	MeanTotalSearchTime1 = mean(mean(TotalSearchTimeVector01))
	MeanTotalSearchTime2 = mean(mean(TotalSearchTimeVector02))
	
	ProsecutionTimeVector1 = VerifiedTimeVector01 - DetectedTimeVector01
	ProsecutionTimeVector2 = VerifiedTimeVector02 - DetectedTimeVector02
	
	ProsecutionTimeVector1 = sum(VerifiedTimeVector01 - DetectedTimeVector01,2)
	ProsecutionTimeVector2 = sum(VerifiedTimeVector02 - DetectedTimeVector02,2)
	
	MeanTotalProsecutionTime1 = mean(mean(ProsecutionTimeVector1))
	MeanTotalProsecutionTime2 = mean(mean(ProsecutionTimeVector2))
	
	StdTotalProsecutionTime1 = std(ProsecutionTimeVector1)
	StdTotalProsecutionTime2 = std(ProsecutionTimeVector2)
	
	ProsecutionTimeVectorDifference = ProsecutionTimeVector1 - ProsecutionTimeVector2
	
	MeanTotalProsecutionTimeDifference = mean(mean(ProsecutionTimeVectorDifference))
	StdTotalProsecutionTimeDifference = std(ProsecutionTimeVectorDifference)
	
	MaxTotalProsecutionTime1 = max(max(ProsecutionTimeVector1))
	MaxTotalProsecutionTime2 = max(max(ProsecutionTimeVector2))
	
	AvgMaxTotalProsecutionTime = (MaxTotalProsecutionTime1 + MaxTotalProsecutionTime2) / 2
	
	MinTotalProsecutionTime1 = min(min(ProsecutionTimeVector1))
	MinTotalProsecutionTime2 = min(min(ProsecutionTimeVector2))
	
	PerMeanTotalProsecutionTime1 = MeanTotalProsecutionTime1 / AvgMaxTotalProsecutionTime * 100
	PerMeanTotalProsecutionTime2 = MeanTotalProsecutionTime2 / AvgMaxTotalProsecutionTime * 100
	
	
% 	figure(300);
% 	hFigure = figure(300);
% 	clf;
% 	grid on;
% 	axis equal;
% 	AxisX = [-15000 35000];
% 	AxisY = [-25000 5000];
% 	axis([AxisX AxisY]);
% 	XTicks = [sort(0:-5280:AxisX(1)) 5280:5280:AxisX(2)];
% 	YTicks = [sort(0:-5280:AxisY(1)) 5280:5280:AxisY(2)];
% 	set(gca,'XTick',XTicks,'YTick',YTicks);
% 	set(gca,'XTickLabel',num2str(XTicks'/5280),'YTickLabel',num2str(YTicks'/5280));
% 	hAxes = get(hFigure,'CurrentAxes');
% 	BackgroundColor = [1.0 1.0 1.0];
% 	set(hAxes,'color',BackgroundColor);
	hold on
	
	TargetWidth = 100;
	TargetLength = 300;
	TargetRectanglePointsX = [-TargetWidth/2; TargetWidth/2; TargetWidth/2; -TargetWidth/2];
	TargetRectanglePointsY = [TargetLength/2; TargetLength/2; -TargetLength/2; -TargetLength/2];
	[iRow,iCol] = size(TargetRectanglePointsX);
	TargetRectanglePointsZ = zeros(iRow,1);
	MatrixTargetRect = [TargetRectanglePointsX,TargetRectanglePointsY,TargetRectanglePointsZ];
	
	
	load 'Target1PostionHeading.mat';
	[Rows,Columns] = size([Target1PostionHeading.ID]');
	for(CountTargets = 1:Rows),
		Rotation = pi/2 - [Target1PostionHeading(CountTargets).Psi];
		rotMatrix = [cos(Rotation) -sin(Rotation) 0 ; sin(Rotation) cos(Rotation) 0; 0 0 1];
		RotMatrixTargetRect =  MatrixTargetRect * rotMatrix;
		TargetGraphicsHandles = patch(RotMatrixTargetRect(:,1)+Target1PostionHeading(CountTargets).PositionX, ...
			RotMatrixTargetRect(:,2)+Target1PostionHeading(CountTargets).PositionY, ...
			RotMatrixTargetRect(:,3)+0.0, ...
		    'EraseMode','normal','FaceLighting','none', ...
			'FaceColor',[0.0,0.0,0.0],'EdgeColor',[0.0,0.0,0.0]);
		%    		TargetGraphicsHandles = patch(RotMatrixTargetRect(:,1), ...
		%                                                    RotMatrixTargetRect(:,2), ...
		%                                                    RotMatrixTargetRect(:,3)+0.0, ...
		%          														'FaceColor',[0.9,0.9,0.9],'EdgeColor',[0.0,0.0,0.0],'Visible','on', ...
		%                                                    'EraseMode','normal','FaceLighting','none');
	end;
	
end;	%switch(action),



LabelString = sprintf('Monte Carlo Target Positions and Headings');
title(LabelString);
if (PrintToFiles == 1)
	FileName = sprintf('.\\Summary.tiff');
	print('-dtiffn','-r300',FileName);
end;	%if (PrintToFiles == 1)


hold off   

return

