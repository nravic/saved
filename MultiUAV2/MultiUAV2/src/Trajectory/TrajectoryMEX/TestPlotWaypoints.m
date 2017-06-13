function TestPlotWaypoints(action,WaypointArray,PathColor)
%TestPlotWaypoints - this is a simple function that plots a trajectory based on a set of waypoints
%
%  Inputs:
%    (none) 
%
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  March 2002 - Created and Debugged - RAS

%TestPlotWaypoints(WaypointCells{1});
%TestPlotWaypoints('SinglePlot',VehicleWayPoints{4})
%WP = VehicleWayPoints{4};
%RadiusWP = ((WP(:,1)-WP(:,7)).^2 + (WP(:,2)-WP(:,8)).^2).^0.5
%global GlobalDebug; if(GlobalDebug==1),disp('TestPlotWaypoints.m');end; 

global WaypointTypes;
global WaypointCells;

PrintToFiles = 0;	%PrintToFiles = 1, to print to tiff files.

if(~exist('action')),
    action='PlotGlobalWaypoints';
end;
if(~exist('PathColor')),
    PathColor = [0.7,0.7,0.7];
end;
if(~exist('NoReset')),
    NoReset = 0.0;
end;
if(~exist('WaypointArray')),
    WaypointArray = WaypointCells;   
end;

hFig = figure(50);
switch(action),
case 'SinglePlot',
    	%clf;
case {'MultiplePlot','PlotGlobalWaypoints'},
    	%clf;
end;	%switch(action),

grid on;
axis equal;
hold on
switch(action),
case 'SinglePlot',
	PlotWaypoints(WaypointArray,PathColor);
case {'PlotGlobalWaypoints','MultiplePlot'},
	NumberPaths = size(WaypointArray,1)
	PathColor = [0.5,0.0,0.0;0.0,0.5,0.0;0.0,0.0,0.5;0.5,0.5,0.0;0.0,0.5,0.5;0.5,0.0,0.2;0.5,0.5,0.5;0.2,0.5,0.5];
	for(CountPath=1:NumberPaths),
		if(~isempty(WaypointArray{CountPath})),
			PlotWaypoints(WaypointArray{CountPath},PathColor(CountPath,:));
		end;
	end;
end;	%switch(action),



LabelString = sprintf('Trajectory');
title(LabelString);
if (PrintToFiles == 1)
    FileName = sprintf('.\\TrajectoryPlot.tiff');
    print('-dtiffn','-r300',FileName);
    %FileName = sprintf('.\\TrajectoryPlot.emf');
    %saveas(hFig,FileName,'emf');
end;	%if (PrintToFiles == 1)


hold off   

return



function PlotWaypoints(WaypointArray,PathColor)

PositionX = WaypointArray(:,1);
PositionY = WaypointArray(:,2);
PositionZ = WaypointArray(:,3);
MachCmd = WaypointArray(:,4);
MachCmdFlag = WaypointArray(:,5);
LengthSegment = WaypointArray(:,6);
TurnCenterX = WaypointArray(:,7);
TurnCenterY = WaypointArray(:,8);
TurnDirection = WaypointArray(:,9);
WaypointType = WaypointArray(:,10);
WaypointColor = [0.5,0.0,0.0;0.0,0.5,0.0;0.0,0.0,0.5;0.5,0.5,0.0;0.0,0.5,0.5;0.5,0.0,0.2;0.5,0.5,0.5;0.2,0.5,0.5];
WaypointColor = WaypointColor * 0.8/0.5;    %make colors brighter
[NumberWaypoints,Columns] = size(WaypointArray);
NumberWaypoints = NumberWaypoints;	%don't plot the last waypoint
ArcStepSize = 5.0*pi/180;
WayPointSize = 100;

   	rectangle('Position',[PositionX(1)-WayPointSize/2,PositionY(1)-WayPointSize/2,WayPointSize,WayPointSize],'Curvature',[1,1],...
        		 		'FaceColor',WaypointColor(WaypointType(1),:),'EdgeColor',[0.1,0.1,0.1]);
    text('String', num2str(0),'Position', [PositionX(1),PositionY(1)],'FontSize',18,'HorizontalAlignment','right','VerticalAlignment','bottom','Color',PathColor);
 for(CountWaypoints=2:NumberWaypoints),
    PointsX = PositionX((CountWaypoints-1):CountWaypoints);
    PointsY = PositionY((CountWaypoints-1):CountWaypoints);
	EndWaypoint = 0;
	while(WaypointType(CountWaypoints) >= 100.0),
		WaypointType(CountWaypoints) = WaypointType(CountWaypoints) - 100;
		EndWaypoint = EndWaypoint+1;
	end;
	switch(EndWaypoint),
	case 0,
		ThisWaypointColor = WaypointColor(WaypointType(CountWaypoints),:);
	case 1,
		ThisWaypointColor = [0.9,0.0,0.0];
	case 2,
		ThisWaypointColor = [0.0,0.9,0.0];
	otherwise,
		ThisWaypointColor = [0.0,0.0,0.9];
	end;
   	rectangle('Position',[PositionX(CountWaypoints)-WayPointSize/2,PositionY(CountWaypoints)-WayPointSize/2,WayPointSize,WayPointSize],'Curvature',[1,1],...
        		 		'FaceColor',ThisWaypointColor,'EdgeColor',[0.1,0.1,0.1]);
    text('String', num2str(CountWaypoints-1),'Position', [PositionX(CountWaypoints),PositionY(CountWaypoints)], ...
            'FontSize',18,'HorizontalAlignment','right','VerticalAlignment','bottom','Color',PathColor);
     if(TurnDirection(CountWaypoints) == 0),
 %  if(1),
        plot(PointsX,PointsY,'Color',PathColor);
    else,
		if(LengthSegment(CountWaypoints) < 10.0),
			continue;
		end;
        Radius = ((PositionY(CountWaypoints)-TurnCenterY(CountWaypoints))^2+(PositionX(CountWaypoints)-TurnCenterX(CountWaypoints))^2)^0.5;
		
		
% 	%plot center of circle
%    		rectangle('Position',[TurnCenterX(CountWaypoints)-WayPointSize/2,TurnCenterY(CountWaypoints)-WayPointSize/2,WayPointSize,WayPointSize], ...
% 						'Curvature',[1,1],'FaceColor',ThisWaypointColor,'EdgeColor',[0.1,0.1,0.1]);

		InitialAngle = atan2((PositionY(CountWaypoints-1)-TurnCenterY(CountWaypoints)), ...
                                (PositionX(CountWaypoints-1)-TurnCenterX(CountWaypoints)));
	    while(InitialAngle <= 0)
   	        InitialAngle = InitialAngle + 2*pi;
	    end;
	    while(InitialAngle >= 2*pi)
   	        InitialAngle = InitialAngle - 2*pi;
        end;
        FinalAngle = atan2((PositionY(CountWaypoints)-TurnCenterY(CountWaypoints)), ...
                                (PositionX(CountWaypoints)-TurnCenterX(CountWaypoints)));
	    while(FinalAngle <= 0)
   	        FinalAngle = FinalAngle + 2*pi;
	    end;
	    while(InitialAngle >= 2*pi)
   	        FinalAngle = FinalAngle - 2*pi;
        end;
        AngleDifference = 0.0;
        if(TurnDirection(CountWaypoints) > 0),
            if((FinalAngle>InitialAngle)|(FinalAngle==InitialAngle)),
                AngleDifference = FinalAngle - InitialAngle;
            else,
                AngleDifference = FinalAngle + (2*pi - InitialAngle);
            end;
        elseif(TurnDirection(CountWaypoints) < 0),
            if((FinalAngle<InitialAngle)|(FinalAngle==InitialAngle)),
                AngleDifference = InitialAngle - FinalAngle;
            else,
                AngleDifference = InitialAngle + (2*pi - FinalAngle);
            end;
        end;
        NumberSegments = floor(abs(AngleDifference)/ArcStepSize);
        LastX = PositionX(CountWaypoints-1);
        LastY = PositionY(CountWaypoints-1);
        for(CountSegment = 1:NumberSegments),
            InitialAngle = InitialAngle + (ArcStepSize*TurnDirection(CountWaypoints));
            %NewX = (cos(InitialAngle)*TurnCenterRadius(CountWaypoints)) + TurnCenterX(CountWaypoints);
            %NewY = (sin(InitialAngle)*TurnCenterRadius(CountWaypoints)) + TurnCenterY(CountWaypoints);
            NewX = (cos(InitialAngle)*Radius) + TurnCenterX(CountWaypoints);
            NewY = (sin(InitialAngle)*Radius) + TurnCenterY(CountWaypoints);
            plot([LastX;NewX],[LastY;NewY],'Color',PathColor);
            LastX = NewX;
            LastY = NewY;
        end;
        %plot([LastX;PositionX(CountWaypoints)],[LastY;PositionY(CountWaypoints)],'Color',PathColor);
    end;
end;


return;		%function PlotWaypoints(WaypointArray,PathColor,WaypointColor)