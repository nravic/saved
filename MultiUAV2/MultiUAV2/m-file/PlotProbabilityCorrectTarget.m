function PlotProbabilityCorrectTarget(InputTargetType)
%PlotProbabilityCorrectTarget - plots the probability correct target for rectangular targets
%
%  Inputs:
%    InputTargetType - the target type to plot 
%
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS



global g_Debug; if(g_Debug==1),disp('PlotProbabilityCorrectTarget.m');end; 

ScaleProbability = 1.0;
ScaleRectangle = 1.0/40.0;

if nargin <1,
	Length = 30*ScaleRectangle;
   Width = 10*ScaleRectangle;
   BestViewingHeadingsRad = [];
   StandAlonePlot = 1;
else,
	Length = InputTargetType.Length*ScaleRectangle;
   Width = InputTargetType.Width*ScaleRectangle;
   BestViewingHeadingsRad = InputTargetType.BestViewingHeadingsRad;
   StandAlonePlot = 0;
end;

Increment = pi/30;
incTheta = [0:Increment:2*pi]';
incProbability = [];
for iTheta = 0:Increment:2*pi
	incProbability = [incProbability;ScaleProbability*ProbabilityCorrectTarget(iTheta,Length,Width)];
end;
YValues = incProbability .* sin(incTheta); 
XValues = incProbability .* cos(incTheta); 

[iRows,iCols] = size(incTheta);
Ones = ones(iRows,1)*ScaleProbability;

if (StandAlonePlot == 1),
   figure(30);
   clf;
end;

polar(incTheta,Ones);
hold on
rectangle('Position',[-Width/2,-Length/2,Width,Length],'FaceColor',[0.5,0.5,0.5]);

LineLength = 60.0*ScaleRectangle;
NumberAngles = length(BestViewingHeadingsRad);
for (CountAngle = 1:NumberAngles),
	DesiredAngle = pi/2 - BestViewingHeadingsRad(CountAngle);
   PlotY = [0.0, (LineLength*sin(DesiredAngle))]; 
   PlotX = [0.0, (LineLength*cos(DesiredAngle))]; 
   plot(PlotX,PlotY,'Color',[0.5,0.1,0.1],'LineWidth',2);
end;

PolarHandle = polar(incTheta,incProbability);
hold off
return;

   
% the following line were used to plot the target rectangle on top of the probability plot
plot(YValues,XValues,'Color',[0.1,0.5,0.1],'LineWidth',2);
rectangle('Position',[-Length/2,-Width/2,Length,Width],'FaceColor',[0.5,0.5,0.5]);
   
   

