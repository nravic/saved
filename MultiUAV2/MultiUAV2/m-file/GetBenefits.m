function [TaskValue,VehicleSchedule,TargetsToService,CellWayPoints,TaskDistance] = ...
									GetBenefits(Task,TargetState,TargetSchedule,Targets,VehicleSchedule,NumberOfVehicles,ScaleFactor,DesiredHeadings, ...
									CommandTurnRadius,CurrentMachCmd,CellWayPoints,VehicleIDs,VehicleWayCounts,ThisVehicleID,TriggerReplanFlags)

%GetBenefits - used to setup the inputs to the MultiTaskAssign function 
%
%  Inputs:
%    InputVector -   
%        InputVector(...) - ????
%
%
%  Outputs:
%    OutputVector - ?????????
%

%  AFRL/VACA
%  Summer 2001 - Created and Debugged
%  February 2003 - change calls to MinimumDistance, BDAHeading, and AttackHeading function to calls to TrajectoryMEX - RAS

global g_Debug; if(g_Debug==1),disp('GetBenefits.m');end; 
global g_Tasks;
global g_TargetStates;
global g_WaypointDefinitions;
global g_WaypointTypes;
global g_MaxNumberVehicles;
global g_LengthenPaths;
global g_VehicleMemory;
global g_DefaultWaypointAltitude;
global g_MonteCarloMetrics;
global g_CommunicationMemory;

WaypointType = zeros(g_MaxNumberVehicles,1);
TargetNumber = zeros(g_MaxNumberVehicles,1);
TargetWayCount = zeros(g_MaxNumberVehicles,1);

for i = 1:NumberOfVehicles
	VehicleID = VehicleIDs(i);
	if (~isempty(g_VehicleMemory(ThisVehicleID).CooperationManager.WaypointMemory))
		VWayPoints = g_VehicleMemory(ThisVehicleID).CooperationManager.WaypointMemory{VehicleID};
		[iRows,iColumns] = size(VWayPoints); 
		WaypointType(i) = 0;
		TargetNumber(i) = 0;
		TargetWayCount(i) = VehicleWayCounts(VehicleID);
		for(iCount = VehicleWayCounts(VehicleID):iRows),
			if(VWayPoints(iCount,g_WaypointDefinitions.TargetHandle)>0)
				TargetWayCount(i) = iCount; 
				TargetNumber(i) = VWayPoints(iCount,g_WaypointDefinitions.TargetHandle);
				WaypointType(i) = VWayPoints(iCount,g_WaypointDefinitions.WaypointType);
				if WaypointType(i) == (g_WaypointTypes.EndTask + g_WaypointTypes.Classify),
					WaypointType(i) = g_WaypointTypes.Classify;
				end;
				if WaypointType(i) == (g_WaypointTypes.EndTask + g_WaypointTypes.Attack),
					WaypointType(i) = g_WaypointTypes.Attack;
				end;
				if WaypointType(i) == (g_WaypointTypes.EndTask + g_WaypointTypes.Verify),
					WaypointType(i) = g_WaypointTypes.Verify;
				end;
				if((Task~=g_Tasks.ClassifyAttack)|(WaypointType(i)~=g_WaypointTypes.Classify)),	%%this was put in for relative bennefits algorithm
					break;
				end;
			end;
		end;
	end %if
end; %for


TargetValue = Targets(:,4); %10; % Hard coded value for now.
switch(Task),
case g_Tasks.Classify,
	TargetsToService = find(TargetState == g_TargetStates.StateDetectedNotClassified);
	PrevTask = g_Tasks.Classify;
	TaskFinal = g_Tasks.Classify;
case g_Tasks.Attack,
	TargetsToService = find(((TargetState == g_TargetStates.StateClassifiedNotAttacked)|(TargetState == g_TargetStates.StateAttackedNotKilled)));
	PrevTask = g_Tasks.Classify;
	TaskFinal = g_Tasks.Attack;
case g_Tasks.Verify,
	TargetsToService = find(TargetState == g_TargetStates.StateKilledNotConfirmed);
	PrevTask = g_Tasks.Attack;
	TaskFinal = g_Tasks.Verify;
case g_Tasks.ClassifyAttack,		%This will cause vehicles that are already attacking targets to classify them first!!!
	TargetsToService = find(((TargetState == g_TargetStates.StateDetectedNotClassified)| ...
		(TargetState == g_TargetStates.StateClassifiedNotAttacked)|(TargetState == g_TargetStates.StateAttackedNotKilled)));
	PrevTask = g_Tasks.Classify;
	TaskFinal = g_Tasks.Attack;
otherwise,
	TargetsToService = [];
	TaskFinal = g_Tasks.Classify;
	PrevTask = g_Tasks.Classify;
	% TODO:: ERROR MESSAGE
end;		%switch(Task),


[dummy,NumTargets] = size(TargetSchedule);
TaskValue = zeros(NumberOfVehicles,NumTargets);
OldTaskValue = 0;
TaskDistance = zeros(NumberOfVehicles,NumTargets);

global  g_VehicleTypeDefault;


for Vehicle = 1:NumberOfVehicles
	Orig = VehicleSchedule(1:3,1,Vehicle);
	CurrentPos = VehicleSchedule(1:3,2,Vehicle);
	CurrentTarget = VehicleSchedule(4,1,Vehicle);
	CurrentTask = VehicleSchedule(4,2,Vehicle);
	if ((g_VehicleTypeDefault == 1)|((CurrentTask ~= g_Tasks.Attack)&(CurrentTask ~= g_Tasks.ClassifyAttack))),
		if (CurrentTarget == 0)|(CurrentTask == g_Tasks.ContinueSearching)|(CurrentTask == g_Tasks.TasksComplete)
			CurrentETA = 0;
		else
			CurrentETA = VehicleSchedule(CurrentTask,CurrentTarget+2,Vehicle); 
		end
		for j = 1:length(TargetsToService),
			TargetToTask = Targets(TargetsToService(j),:);
			DesiredHeadingsThisTarget = DesiredHeadings(TargetsToService(j),:);
			
			VehicleID = VehicleIDs(Vehicle);
			
			% Assign Vehicles with infeasible ETAs, or that have attacked, zero benefit for doing the current task
			if (Task == g_Tasks.Classify)|(Task == g_Tasks.Verify)
				%TaskDelay = 1500;
				%TaskDelay = 1000;
				TaskDelay = 0;
			else
				TaskDelay = 0;
			end;
			TriggerReplanReset = (TriggerReplanFlags(VehicleID)==g_CommunicationMemory.Messages{g_CommunicationMemory.MsgIndicies.TriggerReplan}.ReplanReset);
			TaskInput = Task;
			TargetScheduleLength = TargetSchedule(PrevTask,TargetsToService(j))+TaskDelay;
			if ((TriggerReplanReset==0)&(CurrentETA==0.0)&(~g_MonteCarloMetrics.RecalculateTrajectory)&((TargetsToService(j) == TargetNumber(Vehicle)) &  ...
				((((Task == g_Tasks.Classify)|(Task == g_Tasks.ClassifyAttack)) & (WaypointType(Vehicle) == g_WaypointTypes.Classify)) | ...
				(((Task == g_Tasks.Attack)|((Task == g_Tasks.ClassifyAttack)&(TargetState(TargetsToService(j))==g_TargetStates.StateClassifiedNotAttacked))) & ...
				(WaypointType(Vehicle) == g_WaypointTypes.Attack)) |  ...
				((Task == g_Tasks.Verify) & (WaypointType(Vehicle) == g_WaypointTypes.Verify))))),     
				% IF this is for the next target and task assignment the vehicle has, 
				% then don't calculate new waypoints or distances, but use the old ones
				WaypointsALL = g_VehicleMemory(ThisVehicleID).CooperationManager.WaypointMemory{VehicleID};
				StartWaypoint = VehicleWayCounts(VehicleID);
				WayPoints = WaypointsALL([StartWaypoint:TargetWayCount(Vehicle)],:);
				CurrentPositionX = VehicleSchedule(1,2,Vehicle);
				CurrentPositionY = VehicleSchedule(2,2,Vehicle);
				Distance = [0,0];
				Distance1 = CalculateDist(VehicleID,CurrentPositionX,CurrentPositionY,VehicleWayCounts(VehicleID),CommandTurnRadius,ThisVehicleID); 
				Distance = [Distance1,g_VehicleMemory(ThisVehicleID).CooperationManager.SavedHeading(VehicleID,TargetsToService(j),Task)];      
			else  % if not the previously-assigned next task/target, calculate new waypoints
				if(Task==g_Tasks.ClassifyAttack),	%this was put in for relative bennefits
					TaskInput = g_Tasks.Classify;
				end;
				VehicleType = 1;
				VehicleState = [VehicleID;CurrentPos(1);CurrentPos(2);g_DefaultWaypointAltitude;CurrentPos(3);-1;CommandTurnRadius;VehicleType;CurrentETA];
				TargetID = TargetsToService(j);
				TargetState = [TargetID;TargetToTask(1,1);TargetToTask(1,2);0;TaskInput;TargetScheduleLength];
				TargetHeadings = DesiredHeadingsThisTarget';
				LengthenPaths = g_LengthenPaths;
				[WayPoints,TotalDistanceAbsolute,FinalHeading] = TrajectoryMEX(VehicleState,TargetState,TargetHeadings,LengthenPaths);
				
% 				disp('GetBenefits');VehicleState',TargetState',TargetHeadings'
				
				
				TotalDistance = TotalDistanceAbsolute - CurrentETA;
				if(Task==g_Tasks.ClassifyAttack),	%this was put in for relative bennefits algorithm
					NewETA = TotalDistanceAbsolute;
					VehicleState = [VehicleID;WayPoints(end,1);WayPoints(end,2);g_DefaultWaypointAltitude;FinalHeading;-1;CommandTurnRadius;VehicleType;NewETA];
					TargetID = TargetsToService(j);
					TaskInput = g_Tasks.Attack;
					TargetScheduleLength = TotalDistanceAbsolute;
					TargetState = [TargetID;TargetToTask(1,1);TargetToTask(1,2);0;TaskInput;TargetScheduleLength];
					TargetHeadings = DesiredHeadingsThisTarget';
					LengthenPaths = g_LengthenPaths;
					[WayPointsAttack,TotalDistanceAbsolute,FinalHeading] = TrajectoryMEX(VehicleState,TargetState,TargetHeadings,LengthenPaths);
					WayPoints = [WayPoints;WayPointsAttack([2:end],:)];
					TotalDistanceAttack = TotalDistanceAbsolute - NewETA;
					TotalDistance = TotalDistance + TotalDistanceAttack;
				end;
				Distance = [TotalDistance,FinalHeading];
			end  %if
			TaskDistance(Vehicle,TargetsToService(j)) = sum(Distance(:,1));
			
			if(~isempty(Distance)),
				VehicleSchedule(TaskFinal,TargetsToService(j)+2,Vehicle) = round(TaskDistance(Vehicle,TargetsToService(j)))+CurrentETA;
				VehicleSchedule(4,TargetsToService(j)+2,Vehicle) = Distance(1,2);
				g_VehicleMemory(ThisVehicleID).CooperationManager.SavedHeading(VehicleID,TargetsToService(j),TaskInput) = Distance(1,2);
			end;
			% Assign Vehicles with infeasible ETAs, or that have attacked, zero benefit for doing the current task
			TargetScheduleLength = TargetSchedule(PrevTask,TargetsToService(j))+TaskDelay;
			CalculatedLength = VehicleSchedule(TaskFinal,TargetsToService(j)+2,Vehicle);
			if ((Task~=g_Tasks.Classify)&(CalculatedLength < TargetScheduleLength)),
				TaskValue(Vehicle,TargetsToService(j)) = 0;
			else, 	%if (CalculatedLength < TargetScheduleLength),
				[RowsDistance, ColDistance] = size(Distance) ;
				if (RowsDistance == 1)
					Distance = [Distance ;zeros(1,ColDistance)] ;
				end
				TaskValue(Vehicle,TargetsToService(j)) = TaskBenefitMulti(TaskFinal,TargetValue(TargetsToService(j)),Distance(1,1),Distance(2,1),Vehicle,TargetsToService(j),VehicleIDs,ThisVehicleID,TriggerReplanReset);  %Modified by Schumacher 5/23/02
			end;	%if (CalculatedLength < TargetScheduleLength),
			% Place WayPoints into Cell Array for only those vehicle/target combinations which are currently under consideration
			if(~isempty(WayPoints))
				CellWayPoints{Vehicle,TargetsToService(j)} = WayPoints;
			end;
		end % End j = 1:length(TargetsToService)
	else,
		VehicleSchedule(3,3:end,Vehicle) = 0;
		TaskValue(Vehicle,:) = 0;
	end % End CurrentTask ~= 2
end % End Vehicle = 1:NumberOfVehicles
