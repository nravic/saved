function RouteSelection(InputVector,Time)
%RouteSelection - selects waypoints to use for the assigned action
%
%  Inputs:
%    InputVector(1) -  Vehicle's ID
%    InputVector(2) -  Vehicle's target Assignment
%    InputVector(3) -  Vehicle's task Assignment
%    InputVector(4) -  Vehicle's current waycount index
%    InputVector(5) -  Vehicle's task finished flag
%
%  Outputs:
%    OutputVector(1) - target waypoint: the waypoint corresponding to the target's location
%

%  AFRL/VACA
%  March 2001 - Created and Debugged - RAS
%  February 2003 - change calls to MinimumDistance, BDAHeading, and AttackHeading function to calls to TrajectoryMEX - RAS


global g_Debug; if(g_Debug==1),disp('RouteSelection.m');end; 

global g_WaypointCells;
global g_WaypointFlags;
global g_WaypointTypes;
global g_VehicleMemory;
global g_Tasks;
global g_OptionBackToSearch;
global g_DefaultWaypointAltitude;

ResetDynamics = 0;

[iRow,iCols]=size(InputVector);

iFirstRow = 1;
iCurrentVectorSize = 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
VehicleID = InputVector(iFirstRow:iLastRow);

iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
% Time = InputVector(iFirstRow:iLastRow);

iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
ThisVehicleTargetAssignment = InputVector(iFirstRow:iLastRow);

iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
ThisVehicleTaskAssignment = InputVector(iFirstRow:iLastRow);

iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
CurrentWaycount = (InputVector(iFirstRow:iLastRow)+1);

iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
TaskFinished = InputVector(iFirstRow:iLastRow);

iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
VehiclePostionX = InputVector(iFirstRow:iLastRow);

iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
VehiclePostionY = InputVector(iFirstRow:iLastRow);

iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
VehiclePostionZ = InputVector(iFirstRow:iLastRow);

iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
VehicleHeadingAngle = HeadingToAngle(InputVector(iFirstRow:iLastRow));

iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
CurrentVelocityNorth = InputVector(iFirstRow:iLastRow);

iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
CurrentVelocityEast = InputVector(iFirstRow:iLastRow);

iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
CommandTurnRadius = InputVector(iFirstRow:iLastRow);

iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
CurrentMachCmd = InputVector(iFirstRow:iLastRow);

TargetHandle = -1;
if(TaskFinished == 0),	% if the current task is finished then this vehicle is not assigned
	AssignedTarget = g_VehicleMemory(VehicleID).RouteManager.AssignedTarget;
	AssignedTask = g_VehicleMemory(VehicleID).RouteManager.AssignedTask;
else,	%if(TaskFinished == 0),
	AssignedTarget = 0.0;
	AssignedTask = 0.0;
end;	%if(TaskFinished == 0),

if ((AssignedTarget ~= ThisVehicleTargetAssignment)|(AssignedTask ~= ThisVehicleTaskAssignment)),
	% if already assigned to this target/task don't change any thing
	if(ThisVehicleTargetAssignment > 0 ),
		if (g_VehicleMemory(VehicleID).RouteManager.AssignedTarget == 0), %save original search waypoints
			if (CurrentWaycount > g_VehicleMemory(VehicleID).RouteManager.OffsetToAlternateIndex),
				g_VehicleMemory(VehicleID).RouteManager.AlternateWaypointIndex = g_VehicleMemory(VehicleID).RouteManager.AlternateWaypointIndex + (CurrentWaycount - g_VehicleMemory(VehicleID).RouteManager.OffsetToAlternateIndex) - 1;
				g_VehicleMemory(VehicleID).RouteManager.LastSearchX = VehiclePostionX;
				g_VehicleMemory(VehicleID).RouteManager.LastSearchY = VehiclePostionY;
				g_VehicleMemory(VehicleID).RouteManager.LastSearchZ = VehiclePostionZ;
				g_VehicleMemory(VehicleID).RouteManager.LastSearchPsi = VehicleHeadingAngle;
			end;
		end;	%if (g_VehicleMemory(VehicleID).RouteManager.AssignedTarget == 0),
		g_VehicleMemory(VehicleID).RouteManager.AssignedTarget = ThisVehicleTargetAssignment;
		g_VehicleMemory(VehicleID).RouteManager.AssignedTask = ThisVehicleTaskAssignment;
		g_WaypointCells{VehicleID} = g_VehicleMemory(VehicleID).RouteManager.SaveWaypoints{ThisVehicleTargetAssignment};
		g_WaypointFlags(VehicleID) = 1;
		OutTaskString = g_Tasks.TaskStrings{ThisVehicleTaskAssignment+1};
		AssignedString = sprintf('%3.2f Vehicle #%d, Assigned Target #%d to: %s',Time,VehicleID,ThisVehicleTargetAssignment,OutTaskString);
		disp(AssignedString);
	else,	%if(ThisVehicleTargetAssignment > 0 ),
		% if the vehicle does not have an assignment, but was previously assigned implement alternate route waypoints
		if(g_VehicleMemory(VehicleID).RouteManager.AssignedTarget > 0),
			g_VehicleMemory(VehicleID).RouteManager.AssignedTarget = 0;
			g_VehicleMemory(VehicleID).RouteManager.AssignedTask = 0;
			PlotCircles = 0.0;
			SensorStandOff = 0.0;
			ToLastSearchAngle = (g_VehicleMemory(VehicleID).RouteManager.LastSearchPsi*pi/180.0);
			
			WayPointsBackToSearch = [];
			
			WaypointID = VehicleID;
			
			switch(g_OptionBackToSearch),
			case 1,			% return to search at the Y coodinate point where left search and current X coodinate of the vehicle
				TargetPositionX = VehiclePostionX;
				TargetPositionY = g_VehicleMemory(VehicleID).RouteManager.LastSearchY;
			case 2,				% special return to search for vehicle 8, the default for other vehicles
				if(VehicleID==8),
					WaypointID = 5;
					TargetPositionX = 7000.0;
					TargetPositionY = -8000.0;
				else,	%if(VehicleID==8)
					TargetPositionX = g_VehicleMemory(VehicleID).RouteManager.LastSearchX;
					TargetPositionY = g_VehicleMemory(VehicleID).RouteManager.LastSearchY;
				end;	%if(VehicleID==8)
			otherwise,			% return to search at the point where left search
				TargetPositionX = g_VehicleMemory(VehicleID).RouteManager.LastSearchX;
				TargetPositionY = g_VehicleMemory(VehicleID).RouteManager.LastSearchY;
			end;		%switch(g_OptionBackToSearch),
			
			
			VehicleType = 1;	%1-Munition, 2-UAV
			CurrentETA = 0.0;
			CurrentHeading = VehicleHeadingAngle;
			CommandSensorStandOff = -1;		%-1 use default
			VehicleState = [VehicleID;VehiclePostionX;VehiclePostionY;g_DefaultWaypointAltitude;CurrentHeading;CommandSensorStandOff;CommandTurnRadius;VehicleType;CurrentETA];
			
			TargetID = -1;	% no name required
			TargetHeading = 0;
			Task = g_Tasks.ContinueSearching;
			TargetScheduleLength = 0.0;
			TargetState = [TargetID;TargetPositionX;TargetPositionY;TargetHeading;Task;TargetScheduleLength];
			
			TargetDesiredHeadings = ToLastSearchAngle;
			LengthenPaths = 0;
			[WayPointsBackToSearch,MinDistance,FinalHeading] = TrajectoryMEX(VehicleState,TargetState,TargetDesiredHeadings,LengthenPaths);
			WayPointsBackToSearch = WayPointsBackToSearch([2:end],:);
			
			InitialWayPoint = [VehiclePostionX,VehiclePostionY,VehiclePostionZ,CurrentMachCmd,1,realmax,realmax,realmax,0,g_WaypointTypes.StartPoint,TargetHandle,ResetDynamics];	% starting position (only used as a place holder)
			if(~isempty(WayPointsBackToSearch)),
				SaveWaypoints = [InitialWayPoint;WayPointsBackToSearch];
			else,
				SaveWaypoints = InitialWayPoint;
			end;
			g_WaypointFlags(VehicleID) = 1;
			[iRows,iCols] = size(g_VehicleMemory(WaypointID).RouteManager.AlternateWaypoints);
			[iRowsNewWaypoints,iColsNewWaypoints] = size(SaveWaypoints);
			g_VehicleMemory(VehicleID).RouteManager.OffsetToAlternateIndex = iRowsNewWaypoints;
			g_WaypointCells{VehicleID} = [SaveWaypoints; ...
					g_VehicleMemory(WaypointID).RouteManager.AlternateWaypoints(((g_VehicleMemory(WaypointID).RouteManager.AlternateWaypointIndex):iRows),:)];
			OutTaskString = g_Tasks.TaskStrings{g_Tasks.ContinueSearching+1};
			AssignedString = sprintf('%3.2f Vehicle #%d, assigned to: %s',Time,VehicleID,OutTaskString);
			disp(AssignedString);
		end;	%(g_VehicleMemory(VehicleID).RouteManager.AssignedTarget > 0)
	end;	%if(ThisVehicleTargetAssignment > 0 )
end;	%if ((AssignedTarget ~= ThisVehicleTargetAssignment)|(AssignedTask ~= ThisVehicleTaskAssignment)),
return;		%RouteSelection

