function TestWaypoints
%TestWaypoints - this is a simple function to debug the 'MinimumDistance'&'CalculateDistance' & WaypointsAddMinSeparation functions
%
%  Inputs:
%    (none) 
%
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS



global g_Debug; if(g_Debug==1),disp('TestWaypoints.m');end; 

global g_WaypointCells;
global g_DefaultMach;

clf;
h = gcf;
orient landscape;
rect = [1 1 20.9 20.2];
set(h,'PaperUnits','centimeters');
%set(h,'PaperPosition',rect);
set(h,'PaperPositionMode','auto');
light('Position',[-100000 10000 1000]);

TurnRadius = 2500;
SensorStandOff = 5249.343832; %1600 meters, to the front edge os the scan from the cg of the vehicle
PlotCircles = 'TRUE';
DefaultWaypointAltitude  = 2000.0;
CurrentMachCmd = g_DefaultMach;

figure(28);
clf

TestType = 'TargetHeading';
TestType = 'TargetDistance';
TestType = 'VehicleHeadingSingle';
TestType = 'VehicleHeading';

switch (TestType),
case 'TargetHeading',
	x0 = 7000;
	y0 = -6900;
	vx = 342.2572;
	vy = 0;
	xf = 8000;
	yf = -2500;
	InitialWayPoint = [x0,y0,DefaultWaypointAltitude,realmax,realmax,realmax,0];	% starting position (only used as a place holder)
	TargetWaypoint = [xf,yf,DefaultWaypointAltitude,realmax,realmax,realmax,0]; %if vehicles keep going after classifying the target they go here
	FinalWaypoint = [1e10,1e10,DefaultWaypointAltitude,realmax,realmax,realmax,0]; %if vehicles keep going after classifying the target they go here
	DistanceError = [];
   thetaf = 0;
   clf;
   hold on;
   %title('Test of Trajectory Generation and Distance with Changing Target Headings','FontSize',9);
   for iCount = 1:16,
		subplot(4,4,iCount);
		grid on;
      axis equal;
      LabelString = sprintf('Final Angle = %4.3g',thetaf);
      xlabel(LabelString,'FontSize',9);
		[MinDistance, WayPoints, FinalHeading] = MinimumDistance(x0,y0,vx,vy,xf,yf,thetaf,TurnRadius,SensorStandOff,PlotCircles);
		SaveWaypoints1 = [InitialWayPoint(:,[1:3]);WayPoints(:,[1:3]);TargetWaypoint(:,[1:3]);FinalWaypoint(:,[1:3])]; %x,y,z postions
		SaveWaypoints2 = [InitialWayPoint(:,[4:7]);WayPoints(:,[4:7]);TargetWaypoint(:,[4:7]);FinalWaypoint(:,[4:7])]; %segment length,turn center x, turn center y, turn direction
		[iRows,iCols] = size(SaveWaypoints1);
		SaveWaypoints1 = [SaveWaypoints1,(CurrentMachCmd * ones(iRows,1))];
		SaveWaypoints1 = [SaveWaypoints1,ones(iRows,1)]; %set Mach flag to one to indicate use of MachCmd
      SaveWaypoints = [SaveWaypoints1,SaveWaypoints2];
      MinimumWaypointSeparation = 1000;
      SaveWaypoints = WaypointsAddMinSeparation(SaveWaypoints,TurnRadius,MinimumWaypointSeparation);
		g_WaypointCells{1} = SaveWaypoints;
		Distance2Go = CalculateDistanceToGo(1,x0,y0,2,TurnRadius);
      DistanceError = [DistanceError;MinDistance - Distance2Go];
      thetaf = thetaf + 2*pi/16;
   end;	%for iCount = 1:8,
   DistanceError	%prints out the error vector to the matlab window
case 'TargetDistance',
	x0 = 7000;
	y0 = -6900;
	vx = 342.2572;
   vy = 0;
   TargetDistance = 10000.0;
   TargetDistance = 2000.0;
   TargetDistance = 10.0;
   TargetDistance = 0.0;
   TargetAngle = 0.0;
   xf = TargetDistance*cos(TargetAngle)+x0;
	yf = TargetDistance*sin(TargetAngle)+y0;
	InitialWayPoint = [x0,y0,DefaultWaypointAltitude,realmax,realmax,realmax,0];	% starting position (only used as a place holder)
	TargetWaypoint = [xf,yf,DefaultWaypointAltitude,realmax,realmax,realmax,0]; %if vehicles keep going after classifying the target they go here
	FinalWaypoint = [1e10,1e10,DefaultWaypointAltitude,realmax,realmax,realmax,0]; %if vehicles keep going after classifying the target they go here
	DistanceError = [];
   thetaf = 0;
   clf;
   hold on;
   %title('Test of Trajectory Generation and Distance with Changing Target Distance','FontSize',9);
   for iCount = 1:16,
		subplot(4,4,iCount);
		grid on;
      axis equal;
      LabelString = sprintf('Dist=%4.3g, Angle=%4.3g',TargetDistance,TargetAngle);
      xlabel(LabelString,'FontSize',9);
   	xf = TargetDistance*cos(TargetAngle)+x0;
		yf = TargetDistance*sin(TargetAngle)+y0;
		[MinDistance, WayPoints, FinalHeading] = MinimumDistance(x0,y0,vx,vy,xf,yf,thetaf,TurnRadius,SensorStandOff,PlotCircles);
		SaveWaypoints1 = [InitialWayPoint(:,[1:3]);WayPoints(:,[1:3]);TargetWaypoint(:,[1:3]);FinalWaypoint(:,[1:3])]; %x,y,z postions
		SaveWaypoints2 = [InitialWayPoint(:,[4:7]);WayPoints(:,[4:7]);TargetWaypoint(:,[4:7]);FinalWaypoint(:,[4:7])]; %segment length,turn center x, turn center y, turn direction
		[iRows,iCols] = size(SaveWaypoints1);
		SaveWaypoints1 = [SaveWaypoints1,(CurrentMachCmd * ones(iRows,1))];
		SaveWaypoints1 = [SaveWaypoints1,ones(iRows,1)]; %set Mach flag to one to indicate use of MachCmd
		SaveWaypoints = [SaveWaypoints1,SaveWaypoints2];
		g_WaypointCells{1} = SaveWaypoints;
      MinimumWaypointSeparation = 1000;
      SaveWaypoints = WaypointsAddMinSeparation(SaveWaypoints,TurnRadius,MinimumWaypointSeparation);
		Distance2Go = CalculateDistanceToGo(1,x0,y0,2,TurnRadius);
      DistanceError = [DistanceError;MinDistance - Distance2Go];
      TargetAngle = TargetAngle + 2*pi/16;
   end;	%for iCount = 1:8,
   DistanceError	%prints out the error vector to the matlab window
case 'VehicleHeading',
	x0 = 7000;
	y0 = -6900;
	vx = 342.2572;
   Velocity = 342.2572;
   HeadingAngle = 0.0;
   vx = Velocity*cos(HeadingAngle);
	vy = Velocity*sin(HeadingAngle);
	xf = 8000;
	yf = -2500;
	InitialWayPoint = [x0,y0,DefaultWaypointAltitude,realmax,realmax,realmax,0];	% starting position (only used as a place holder)
	TargetWaypoint = [xf,yf,DefaultWaypointAltitude,realmax,realmax,realmax,0]; %if vehicles keep going after classifying the target they go here
	FinalWaypoint = [1e10,1e10,DefaultWaypointAltitude,realmax,realmax,realmax,0]; %if vehicles keep going after classifying the target they go here
	DistanceError = [];
   thetaf = 0;
   clf;
   hold on;
   %title('Test of Trajectory Generation and Distance with Changing Vehicle Direction','FontSize',9);
   for iCount = 1:16,
		subplot(4,4,iCount);
		grid on;
      axis equal;
      LabelString = sprintf('Vehicle Direction=%4.3g',HeadingAngle);
      xlabel(LabelString,'FontSize',9);
   	vx = Velocity*cos(HeadingAngle);
		vy = Velocity*sin(HeadingAngle);
		[MinDistance, WayPoints, FinalHeading] = MinimumDistance(x0,y0,vx,vy,xf,yf,thetaf,TurnRadius,SensorStandOff,PlotCircles);
		SaveWaypoints1 = [InitialWayPoint(:,[1:3]);WayPoints(:,[1:3]);TargetWaypoint(:,[1:3]);FinalWaypoint(:,[1:3])]; %x,y,z postions
		SaveWaypoints2 = [InitialWayPoint(:,[4:7]);WayPoints(:,[4:7]);TargetWaypoint(:,[4:7]);FinalWaypoint(:,[4:7])]; %segment length,turn center x, turn center y, turn direction
		[iRows,iCols] = size(SaveWaypoints1);
		SaveWaypoints1 = [SaveWaypoints1,(CurrentMachCmd * ones(iRows,1))];
		SaveWaypoints1 = [SaveWaypoints1,ones(iRows,1)]; %set Mach flag to one to indicate use of MachCmd
		SaveWaypoints = [SaveWaypoints1,SaveWaypoints2];
      MinimumWaypointSeparation = 1000;
      SaveWaypoints = WaypointsAddMinSeparation(SaveWaypoints,TurnRadius,MinimumWaypointSeparation);
      
      [iNumWaypoints,iCols] = size(SaveWaypoints);
      RDot = 100;
      for (iCountPoints = 1:iNumWaypoints-1),
         rectangle('Position',[SaveWaypoints(iCountPoints,1)-RDot,SaveWaypoints(iCountPoints,2)-RDot,2*RDot,2*RDot],'Curvature',[1,1],'FaceColor','g');
      end;
      
   
		g_WaypointCells{1} = SaveWaypoints;
		Distance2Go = CalculateDistanceToGo(1,x0,y0,2,TurnRadius);
      DistanceError = [DistanceError;MinDistance - Distance2Go];
      HeadingAngle = HeadingAngle + 2*pi/16;
   end;	%for iCount = 1:8,
   DistanceError	%prints out the error vector to the matlab window
case 'VehicleHeadingSingle',
	x0 = 7000;
	y0 = -6900;
	vx = 342.2572;
   Velocity = 342.2572;
   HeadingAngle = 0.0;
   vx = Velocity*cos(HeadingAngle);
	vy = Velocity*sin(HeadingAngle);
	xf = 8000;
	yf = -2500;
	InitialWayPoint = [x0,y0,DefaultWaypointAltitude,realmax,realmax,realmax,0];	% starting position (only used as a place holder)
	TargetWaypoint = [xf,yf,DefaultWaypointAltitude,realmax,realmax,realmax,0]; %if vehicles keep going after classifying the target they go here
	FinalWaypoint = [1e10,1e10,DefaultWaypointAltitude,realmax,realmax,realmax,0]; %if vehicles keep going after classifying the target they go here
	DistanceError = [];
   thetaf = 0;
   clf;
   hold on;
   %title('Test of Trajectory Generation and Distance with Changing Vehicle Direction','FontSize',9);
		grid on;
      axis equal;
      HeadingAngle = 1.5*pi;
      LabelString = sprintf('Vehicle Direction=%4.3g',HeadingAngle);
      xlabel(LabelString,'FontSize',9);
   	vx = Velocity*cos(HeadingAngle);
		vy = Velocity*sin(HeadingAngle);
		[MinDistance, WayPoints, FinalHeading] = MinimumDistance(x0,y0,vx,vy,xf,yf,thetaf,TurnRadius,SensorStandOff,PlotCircles);
		SaveWaypoints1 = [InitialWayPoint(:,[1:3]);WayPoints(:,[1:3]);TargetWaypoint(:,[1:3]);FinalWaypoint(:,[1:3])]; %x,y,z postions
		SaveWaypoints2 = [InitialWayPoint(:,[4:7]);WayPoints(:,[4:7]);TargetWaypoint(:,[4:7]);FinalWaypoint(:,[4:7])]; %segment length,turn center x, turn center y, turn direction
		[iRows,iCols] = size(SaveWaypoints1);
		SaveWaypoints1 = [SaveWaypoints1,(CurrentMachCmd * ones(iRows,1))];
		SaveWaypoints1 = [SaveWaypoints1,ones(iRows,1)]; %set Mach flag to one to indicate use of MachCmd
		SaveWaypoints = [SaveWaypoints1,SaveWaypoints2];
      MinimumWaypointSeparation = 1000;
      SaveWaypoints = WaypointsAddMinSeparation(SaveWaypoints,TurnRadius,MinimumWaypointSeparation);
      
      [iNumWaypoints,iCols] = size(SaveWaypoints);
      RDot = 100;
      for (iCountPoints = 1:iNumWaypoints-1),
         rectangle('Position',[SaveWaypoints(iCountPoints,1)-RDot,SaveWaypoints(iCountPoints,2)-RDot,2*RDot,2*RDot],'Curvature',[1,1],'FaceColor','g');
      end;
      
   
		g_WaypointCells{1} = SaveWaypoints;
		Distance2Go = CalculateDistanceToGo(1,x0,y0,2,TurnRadius);
      DistanceError = [DistanceError;MinDistance - Distance2Go];
      HeadingAngle = HeadingAngle + 2*pi/16;
   	DistanceError	%prints out the error vector to the matlab window
otherwise,   
end;	%switch (TestType),




return


