function [OutputReplan] = ReplanRoutes(InputVector)
%ReplanRoutes - calculates and saves the cooperation metrics and trajectories to all of the known valid targets
%
%  Inputs:
%    InputVector(1) -  "VehicleID" ID number of this vehicle
%    InputVector(2) -  "VehicleFinished" a flag that indicates whether or not this vehicle is alive
%    InputVector(3) -  "CommandTurnRadius" the commanded turn radius for the vehicle
%    InputVector(4) - "CurrentPositionX" current vehicle state
%    InputVector(5) - "CurrentPositionY"  current vehicle state
%    InputVector(6) - "CurrentPositionZ"  current vehicle state
%    InputVector(7) - "CurrentPositionPsi"  current vehicle state
%    InputVector(8) - "CurrentVelocityNorth"  current vehicle state
%    InputVector(9) - "CurrentVelocityEast"  current vehicle state
%    InputVector(10) - "CurrentMachCmd"  current vehicle state
%    InputVector(11) - "CurrentWayCount"  the current wayppoint index
%    InputVector(13) - "TaskFinished" a flag indicating that the current vehicle has finished its assigned task
%    InputVector(...) - "TargetStatus" a 'vectorized' matrix containing truth information about all of the targets, size = (g_MaxNumberTargets*6) 
%    InputVector(...) - "DesiredHeadingVector" a 'vectorized' matrix containing desired headings to the targets, calculated by all of the vehicles size = (g_MaxNumberTargets*g_MaxNumberDesiredHeadings) 
%
%  Outputs:
%    OutputReplan(...) - a vector containing costs from the current vehicle to each target
%    OutputReplan(...) - a vector containing estimated time of arrival from the current vehicle to each target
%    OutputReplan(...) - a vector containing estimated distance from the target back to the search waypoint
%

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS
%  April 2001 - added task functions to route replanner - RAS
%  April 2001 - added estimated distance back to search from target - RAS
%  February 2003 - change calls to MinimumDistance, BDAHeading, and AttackHeading function to calls to TrajectoryMEX - RAS


global g_Debug; if(g_Debug==1),disp('ReplanRoutes.m');end; 

global g_MaxNumberTargets;
global g_MaxNumberDesiredHeadings;

global g_VehicleMemory;
global g_Tasks;
global g_DefaultWaypointAltitude;
global g_WaypointTypes;
global g_Debug;
global g_WaypointDefinitions;

if (g_Debug),
	%disp('ReplanRoutes');
end;	%g_Debug

iColumnX = 1;
iColumnY = 2;
iColumnZ = 3;
iColumnType = 4;
iColumnPsi = 5;
iColumnAlive = 6;
SizeTargetVector = 6;

NumberOutputs = g_MaxNumberTargets*3;
OutputReplan = (realmax/2.0) * ones(NumberOutputs,1); %defaults all values to realmax (very large but not maximum)
[iRow,iCols]=size(InputVector);
iCurrentRow = 1;
iCurrentVectorSize = 1;
VehicleID = InputVector(iCurrentRow);

iCurrentRow = iCurrentRow + iCurrentVectorSize;
VehicleFinished = InputVector(iCurrentRow);
if VehicleFinished == 1		%% if this vehicle has already classified and killed don't replan
	return;
end;

iCurrentRow = iCurrentRow + iCurrentVectorSize;
CommandTurnRadius = InputVector(iCurrentRow);

%get the local vehicle information
iCurrentRow = iCurrentRow + iCurrentVectorSize;
CurrentPositionX = InputVector(iCurrentRow);

iCurrentRow = iCurrentRow + iCurrentVectorSize;
CurrentPositionY = InputVector(iCurrentRow);

iCurrentRow = iCurrentRow + iCurrentVectorSize;
CurrentPositionZ = InputVector(iCurrentRow);

iCurrentRow = iCurrentRow + iCurrentVectorSize;
CurrentPositionPsi = InputVector(iCurrentRow);

iCurrentRow = iCurrentRow + iCurrentVectorSize;
CurrentVelocityNorth = InputVector(iCurrentRow);

iCurrentRow = iCurrentRow + iCurrentVectorSize;
CurrentVelocityEast = InputVector(iCurrentRow);

iCurrentRow = iCurrentRow + iCurrentVectorSize;
CurrentMachCmd = InputVector(iCurrentRow);

iCurrentRow = iCurrentRow + iCurrentVectorSize;
CurrentWayCount = InputVector(iCurrentRow)+1;	%must change this to an index based at 1

iCurrentRow = iCurrentRow + iCurrentVectorSize;
TaskFinished = InputVector(iCurrentRow);

iCurrentRow = iCurrentRow + iCurrentVectorSize;
iCurrentVectorSize = g_MaxNumberTargets;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
TargetStatus = InputVector(iCurrentRow:iLastRow);

iCurrentRow = iLastRow + 1;
iCurrentVectorSize = g_MaxNumberTargets * g_MaxNumberDesiredHeadings;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
DesiredHeadingVector = InputVector(iCurrentRow:iLastRow);
DesiredHeadingMatrix = reshape(DesiredHeadingVector,g_MaxNumberTargets,g_MaxNumberDesiredHeadings);

iCurrentRow = iCurrentRow + iCurrentVectorSize;
iCurrentVectorSize = g_MaxNumberTargets * SizeTargetVector;	% 6 columns: x y z type alive psi
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
TargetVector = InputVector(iCurrentRow:iLastRow);
TargetMatrix = reshape(TargetVector,SizeTargetVector,g_MaxNumberTargets)';
iIndex = 1;

if(TaskFinished == 0),	% if the current task is finished then this vehicle is not assigned
	AssignedTarget = g_VehicleMemory(VehicleID).RouteManager.AssignedTarget;
	AssignedTask = g_VehicleMemory(VehicleID).RouteManager.AssignedTask;
else,	%if(TaskFinished == 0),
	AssignedTarget = 0.0;
	AssignedTask = 0.0;
end;	%if(TaskFinished == 0),

ResetDynamics = 0;

for iTarget=1:g_MaxNumberTargets
	OutputReplan(iTarget) = 0;
	if (TargetStatus(iTarget) > 0),
		%% calculate costs and etas to the sensed targets that are alive here %%%
		TargetCost = 1.0;
		OutputReplan(iTarget) = TargetCost;
		RequiredTask = FindRequiredTask(TargetStatus(iTarget));
		if ((AssignedTarget ~= iTarget)|(AssignedTask ~= RequiredTask)),
			
			VehicleType = 1;	%1-Munition, 2-UAV
			CurrentETA = 0.0;	% this is for single assignments, therefore, vehicles current time doesn't matter
			CurrentHeading = CurrentPositionPsi*pi/180.0;
			CommandSensorStandOff = -1;		%-1 use default for the task
			VehicleState = [VehicleID;CurrentPositionX;CurrentPositionY;g_DefaultWaypointAltitude;CurrentHeading;CommandSensorStandOff;CommandTurnRadius;VehicleType;CurrentETA];
			
			TargetID = iTarget;
			TargetHeading = 0;
			TargetPositionX = TargetMatrix(iTarget,iColumnX);
			TargetPositionY = TargetMatrix(iTarget,iColumnY);
			TargetHeading = TargetMatrix(iTarget,iColumnPsi);
			RequiredTask = FindRequiredTask(TargetStatus(iTarget));
			TargetPrerequsiteTime = 0.0;	% this is for single assignments, therefore, target prerequsite time doesn't matter
			TargetState = [TargetID;TargetPositionX;TargetPositionY;TargetHeading;RequiredTask;TargetPrerequsiteTime];
			
			TargetDesiredHeadings = DesiredHeadingMatrix(iTarget,:)';
			LengthenPaths = 0;	% this is for single assignments, therefore, no need to lengthen paths
			[WayPoints,MinDistance,FinalHeading] = TrajectoryMEX(VehicleState,TargetState,TargetDesiredHeadings,LengthenPaths);
			WayPoints(end,g_WaypointDefinitions.WaypointType) = WayPoints(end,g_WaypointDefinitions.WaypointType) + g_WaypointTypes.EndTask;
			
			%             TargetAttackAltitude = 200.0;
			%             AttackBeginDescent = 10000;
			%             for (WayPointCount = 1:WayRows),
			%             	TargetDiff = ((xf-WayPoints(WayPointCount,1))^2+(yf-WayPoints(WayPointCount,2))^2)^0.5;
			%             	if(TargetDiff < AttackBeginDescent),
			%             		WayPoints(WayPointCount,3) = TargetAttackAltitude;
			%             	end;	%if(TargetDiff < AttackBeginDescent),
			%             end;	%for (WayPointCount = 1:WayRows),
			
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%%%%%%%%%%%%%%%% calculate the distance from the target back to the search pattern  %%%%%%%%%%%%%%%%%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			SearchWaypoints = g_VehicleMemory(VehicleID).RouteManager.AlternateWaypoints;
			SearchIndex = g_VehicleMemory(VehicleID).RouteManager.AlternateWaypointIndex+1;
			ResumeWaypoint = SearchWaypoints(SearchIndex,:);
			NumberWaypoints = size(SearchWaypoints,1);
			WaypointDirX = SearchWaypoints(SearchIndex,1) - WayPoints(end,g_WaypointDefinitions.PositionX);
			WaypointDirY = SearchWaypoints(SearchIndex,2) - WayPoints(end,g_WaypointDefinitions.PositionY);
			WaypointAngle = atan2(WaypointDirY,WaypointDirX);
			WaypointHeading = pi/2.0 - WaypointAngle;
			
			ToLastSearchAngle = pi + (g_VehicleMemory(VehicleID).RouteManager.LastSearchPsi*pi/180.0);
			
			LastWaypointPositionX = WayPoints(end,g_WaypointDefinitions.PositionX);
			LastWaypointPositionY = WayPoints(end,g_WaypointDefinitions.PositionY);
			VehicleType = 1;	%1-Munition, 2-UAV
			CurrentETA = 0.0;
			CurrentHeading = FinalHeading;
			CommandSensorStandOff = -1;		%-1 use default
			VehicleState = [VehicleID;LastWaypointPositionX;LastWaypointPositionY;g_DefaultWaypointAltitude;CurrentHeading;CommandSensorStandOff;CommandTurnRadius;VehicleType;CurrentETA];
			
			TargetID = -1;	% no name required
			TargetPositionX = g_VehicleMemory(VehicleID).RouteManager.LastSearchX;
			TargetPositionY = g_VehicleMemory(VehicleID).RouteManager.LastSearchY;
			TargetHeading = 0;
			Task = g_Tasks.ContinueSearching;
			TargetScheduleLength = 0.0;
			TargetState = [TargetID;TargetPositionX;TargetPositionY;TargetHeading;Task;TargetScheduleLength];
			
			TargetDesiredHeadings = ToLastSearchAngle;
			LengthenPaths = 0;
			[FromTargetToSearchWaypoints,FromTargetToSearchDistance,FromTargetToSearchWaypointsHeading] = TrajectoryMEX(VehicleState,TargetState,TargetDesiredHeadings,LengthenPaths);
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%%%%%%%%%%%%%%%% calculate and save final waypoints                                 %%%%%%%%%%%%%%%%%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%if vehicles keep going after classifying the target they go here
			FinalWaypointX = sin(FinalHeading)*1e10 + LastWaypointPositionX;
			FinalWaypointY = cos(FinalHeading)*1e10 + LastWaypointPositionY;
			FinalWaypoint = [FinalWaypointX,FinalWaypointY,g_DefaultWaypointAltitude,CurrentMachCmd,1,realmax,realmax,realmax,0,g_WaypointTypes.EndPoint,-1,ResetDynamics]; 
			SaveWaypoints = [WayPoints;FinalWaypoint];
			
			%MinimumWaypointSeparation = 100000;
			%SaveWaypoints = WaypointsAddMinSeparation(SaveWaypoints,CommandTurnRadius,MinimumWaypointSeparation);
			g_VehicleMemory(VehicleID).RouteManager.SaveWaypoints{iTarget} = SaveWaypoints;
			OutputReplan(iTarget+g_MaxNumberTargets) = MinDistance;
			OutputReplan(iTarget+2*g_MaxNumberTargets) = FromTargetToSearchDistance;
		else	%if ((AssignedTarget ~= AssignedTarget)&(AssignedTask ~= TargetStatus(iTarget))),
			% this vehicle is assigned to a target, so only return the distance to it's target, and unreasonable distances to the rest
			OutputReplan(iTarget+g_MaxNumberTargets) = CalculateDistanceToGo(VehicleID,CurrentPositionX,CurrentPositionY,CurrentWayCount,CommandTurnRadius); %assumes correct waypoints are in place
		end	%if ((AssignedTarget ~= AssignedTarget)&(AssignedTask ~= TargetStatus(iTarget))),
	end;
end;	%for iTarget=1:g_MaxNumberTargets