function ModifySearchWaypoints();
%ModifySearchWaypoints - modifies search waypoints to change search scenarios
%
%  Inputs:
%
%  Outputs:
%

%  AFRL/VACA
%  July 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('ModifySearchWaypoints.m');end; 

global g_VehicleMemory;
global g_WaypointCells;

global g_OptionModifiedWaypoints;

if(~g_OptionModifiedWaypoints)
	return;   
end;

disp('*** ModifySearchWaypoints:: Using modified waypoints ***');



SearchWaypoints = cell(8,1);

for i=1:8,
   SearchWaypoints(i) = {g_VehicleMemory(i).RouteManager.AlternateWaypoints};
end;


TurnOffsetX = 3300.0;
TurnOffsetY = 3300.0;

[WaypointRows,WaypointCols]=size(SearchWaypoints{1});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%vehicle #1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CurrentVehicle = 1;	%the vehicle these waypoits will be used for
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [];
%first waypoint and first turn waypoints
WaySearch = 1;		%which search waypoints to use
WayNum = 1:3;
NewWaypoint = SearchWaypoints{WaySearch}(WayNum,:);
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];
%turn back to search

WaySearch = 6;	
WayNum = 2;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)+TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)+TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 6;
WayNum = 2;
NewWaypoint = SearchWaypoints{WaySearch}(WayNum ,:);
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 6;
WayNum = 1;
NewWaypoint = [0.0,SearchWaypoints{WaySearch}(WayNum ,2),SearchWaypoints{WaySearch}(WayNum ,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 6;
WayNum = 1;
NewWaypoint = [-TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)-TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 3;
WayNum = 6;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)-TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)+TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 3;
WayNum = 6:-1:5;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,:)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 3;
WayNum = 5;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)+TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)-TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 8;
WayNum = 5;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)+TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)+TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 8;
WayNum = 5:6;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,:)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%vehicle #2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CurrentVehicle = 2;	%the vehicle these waypoits will be used for
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [];
%first waypoint and first turn waypoints
WaySearch = 2;		%which search waypoints to use
WayNum = 1:3;
NewWaypoint = SearchWaypoints{WaySearch}(WayNum,:);
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];
%turn back to search

WaySearch = 7;	
WayNum = 2;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)+TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)+TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 7;
WayNum = 2;
NewWaypoint = SearchWaypoints{WaySearch}(WayNum ,:);
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 7;
WayNum = 1;
NewWaypoint = [0.0,SearchWaypoints{WaySearch}(WayNum ,2),SearchWaypoints{WaySearch}(WayNum ,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 7;
WayNum = 1;
NewWaypoint = [-TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)-TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 4;
WayNum = 6;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)-TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)+TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 4;
WayNum = 6:-1:5;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,:)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 4;
WayNum = 5;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)+TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)-TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 1;
WayNum = 8;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)+TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)+TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 1;
WayNum = 8:-1:7;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,:)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%vehicle #3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CurrentVehicle = 3;	%the vehicle these waypoits will be used for
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [];
%first waypoint and first turn waypoints
WaySearch = 3;		%which search waypoints to use
WayNum = 1:3;
NewWaypoint = SearchWaypoints{WaySearch}(WayNum,:);
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];
%turn back to search

WaySearch = 8;	
WayNum = 2;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)+TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)+TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 8;
WayNum = 2;
NewWaypoint = SearchWaypoints{WaySearch}(WayNum ,:);
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 8;
WayNum = 1;
NewWaypoint = [0.0,SearchWaypoints{WaySearch}(WayNum ,2),SearchWaypoints{WaySearch}(WayNum ,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 8;
WayNum = 1;
NewWaypoint = [-TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)-TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 5;
WayNum = 6;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)-TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)+TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 5;
WayNum = 6:-1:5;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,:)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 5;
WayNum = 5;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)+TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)-TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 2;
WayNum = 8;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)+TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)+TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 2;
WayNum = 8:-1:7;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,:)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%vehicle #4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CurrentVehicle = 4;	%the vehicle these waypoits will be used for
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [];
%first waypoint and first turn waypoints
WaySearch = 4;		%which search waypoints to use
WayNum = 1:3;
NewWaypoint = SearchWaypoints{WaySearch}(WayNum,:);
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];
%turn back to search

WaySearch = 1;	
WayNum = 4:7;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,:)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 6;
WayNum = 6;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)-TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)+TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 6;
WayNum = 6:-1:5;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,:)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 6;
WayNum = 5;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)+TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)-TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];


WaySearch = 3;
WayNum = 8;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,1)+TurnOffsetX,SearchWaypoints{WaySearch}(WayNum,2)+TurnOffsetY,SearchWaypoints{WaySearch}(WayNum,3:WaypointCols)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 3;
WayNum = 8:-1:7;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,:)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%vehicle #5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CurrentVehicle = 5;	%the vehicle these waypoits will be used for
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [];
%first waypoint and first turn waypoints
WaySearch = 5;		%which search waypoints to use
WayNum = 1:3;
NewWaypoint = SearchWaypoints{WaySearch}(WayNum,:);
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];
%turn back to search

WaySearch = 2;
WayNum = 4:7;
NewWaypoint = SearchWaypoints{WaySearch}(WayNum,:);
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 7;
WayNum = 5:8;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,:)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];

WaySearch = 7;
WayNum = 9:12;
NewWaypoint = [SearchWaypoints{WaySearch}(WayNum,:)];
g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints = [g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;NewWaypoint];


for (CurrentVehicle = 1:8),
	g_WaypointCells{CurrentVehicle} = g_VehicleMemory(CurrentVehicle).RouteManager.AlternateWaypoints;
end;






return;	%function ModifySearchWaypoints();

