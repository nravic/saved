function [BenefitsCapTransShip,VehicleSchedule,CellWayPointsTotal]=DINF_GetBenefits...
    (VehiclesIn, VehicleSchedule,TargetState,TargetSchedule,Targets,NumberOfVehicles,...
    DesiredHeadings,CommandTurnRadius,CurrentMachCmd,CellWayPointsTotal,VehicleIDs,...
    VehicleWayCounts,ThisVehicleID,TriggerReplanFlags)



global g_Debug; if(g_Debug==1),disp('MultiTaskAssign.m');end; 
global g_Tasks;                                                                            
global g_DefaultWaypointAltitude;
global g_DefaultMach;


Vehicles = VehiclesIn(:,2:4);

%%>> Remove these later?
TotalFlightTime = 30.0;  
CurrentTime = 0.0;
ScaleFactor =100;
Scaling = 1000;         %Mod by Schumacher 4/22/02

CurrentMachCmd = g_DefaultMach;

%[NumberOfVehicles, NumberColumns] = size(Vehicles);
[NumberOfTargets, NumberColumns] = size(Targets);

NumberOfVehicles=length(VehicleIDs);


NumberOfTasks = g_Tasks.NumberTasks-1;

VehicleWayPoints = cell(NumberOfVehicles,1) ; 
%TargetSchedule = zeros(3,NumberOfTargets);
AllAssignments = zeros(NumberOfTasks, NumberOfVehicles);

% Create arrays to keep track of target and vehicle scheduling. VehicleSchedule is an array of the form:
% Orig(x)         Current(x)       T1,t1 T2,t1 ... Tm,t1;
% Orig(y)         Current(y)       T1,t2 T2,t2 ... Tm,t2;
% Orig(Heading)   Current(Heading) T1,t3 T2,t3 ... Tm,t3;
% Current(Target) Current(Task)    0     0     ... 0;
% TargetSchedule is an array of the form:
% T1,t1 T2,t1 ... Tm,t1;
% T1,t2 T2,t2 ... Tm,t2;
% T1,t3 T2,t3 ... Tm,t2;
% where Tm = the mth target and t1,t2,t3, are the Classify, Attack, and BDA tasks, respectively.
% Tm,t1 indicate the time at which target m will be Classified.
RowVehicleScheduleClassify = 1;
RowVehicleScheduleAttack = 2;
RowVehicleScheduleVerify = 3;
RowVehicleScheduleHeading = 4;

VehicleSchedule = [[reshape(Vehicles',3,1,1);zeros(1,1,1)] ...
		[reshape(Vehicles',3,1,1);zeros(1,1,1)] ...
		zeros(4,NumberOfTargets,1)];
TargetColumnRange = [3:(3+(NumberOfTargets-1))];

TotalTaskDistance = [];

TargetsToTaskTotal = [] ;
TaskDistanceTotal = [] ;

% Calculate the Benefits for the vehicles to do the required classifications
[BenefitsClassify,VehicleSchedule,TargetsToClassify,CellWayPointsTotal,TaskDistance] = GetBenefits(g_Tasks.Classify,TargetState,TargetSchedule,...
    Targets,VehicleSchedule,NumberOfVehicles,ScaleFactor, DesiredHeadings,CommandTurnRadius,CurrentMachCmd,CellWayPointsTotal,VehicleIDs,VehicleWayCounts,ThisVehicleID,TriggerReplanFlags); %Modified by Schumacher 5/23/02

TotalBenefits = BenefitsClassify;
VehicleScheduleTotal = VehicleSchedule ;
TargetsToTaskTotal = [TargetsToTaskTotal TargetsToClassify];
TotalTaskDistance(:,:,g_Tasks.Classify) = TaskDistance;	%classify distance

% Calculate the Benefits for the vehicles to do the required attacks
[BenefitsAttack,VehicleSchedule,TargetsToAttack,CellWayPointsTotal,TaskDistance] = GetBenefits(g_Tasks.Attack,TargetState,TargetSchedule,...
    Targets,VehicleSchedule,NumberOfVehicles,ScaleFactor,DesiredHeadings,CommandTurnRadius,CurrentMachCmd,CellWayPointsTotal,VehicleIDs,VehicleWayCounts,ThisVehicleID,TriggerReplanFlags); %Modified by Schumacher 5/23/02

TotalBenefits = TotalBenefits + BenefitsAttack;
VehicleScheduleTotal(1:3,TargetColumnRange,:) = VehicleScheduleTotal(1:3,TargetColumnRange,:) + VehicleSchedule(1:3,TargetColumnRange,:) ;
TargetsToTaskTotal = [TargetsToTaskTotal TargetsToAttack];
TotalTaskDistance(:,:,g_Tasks.Attack) = TaskDistance;	%attack distance

% Calculate the Benefits for the vehicles to do the required BDA
[BenefitsBDA,VehicleSchedule,TargetsToBDA,CellWayPointsTotal,TaskDistance] = GetBenefits(g_Tasks.Verify,TargetState,TargetSchedule,...
    Targets,VehicleSchedule,NumberOfVehicles,ScaleFactor,DesiredHeadings,CommandTurnRadius,CurrentMachCmd,CellWayPointsTotal,VehicleIDs,VehicleWayCounts,ThisVehicleID,TriggerReplanFlags); %Modified by Schumacher 5/23/02
TotalBenefits = TotalBenefits + BenefitsBDA;
VehicleScheduleTotal(1:3,TargetColumnRange,:) = VehicleScheduleTotal(1:3,TargetColumnRange,:) + VehicleSchedule(1:3,TargetColumnRange,:) ;
TargetsToTaskTotal = [TargetsToTaskTotal TargetsToBDA];
TotalTaskDistance(:,:,g_Tasks.Verify) = TaskDistance;	%verify distance


% In order to use the CapTransShip Algorithm, must form a row vector containing the benefits for each vehicle to service each
% target for each task.

% Number of Benefits for each task
NumberBenefits = numel(TotalBenefits) ;

BenefitsContinueToSearch = ones(NumberOfVehicles,1)*15/30*max(Targets(:,4))*Scaling; %Mod by Schumacher 4/22/02
BenefitsClassifyCapTransShip = reshape(BenefitsClassify',NumberBenefits,1)*Scaling;
BenefitsAttackCapTransShip = reshape(BenefitsAttack',NumberBenefits,1)*Scaling;
BenefitsBDACapTransShip = reshape(BenefitsBDA',NumberBenefits,1)*Scaling;

% Form Vector : Number Of Rows = NumberOfVehicles*NumberOfTargets*NumberOfTasks + NumberOfVehicles
BenefitsCapTransShip = [BenefitsContinueToSearch ; BenefitsClassifyCapTransShip ; BenefitsAttackCapTransShip ; BenefitsBDACapTransShip] ;


return