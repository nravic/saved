function [Output]=DINF_CalculateBenefits(Input)
% DINF_CalculateBenefits.m
% Calculates the benefits for a given target/task scenario
%
% AFRL/VACA
% July 2003 Brandon Moore

global g_MaxNumberVehicles
global g_MaxNumberTargets
global g_MaxNumberDesiredHeadings
global g_VehicleMemory
global g_DefaultWaypointAltitude
global g_WaypointTypes
global g_Debug
global g_WaypointDefinitions
global g_NumberTargetOutputs
global g_TargetTypes
global g_DefaultMach
global g_CommandTurnRadius
global g_TargetStates
global g_SampleTime
global g_AssignmentDelayEstimate
global g_WaypointFlags
global g_WaypointStartingIndex

%% process input vector

index=1;

% from CommBusIn
step=1;
CurrentTime=Input(index:index+step-1);
index=index+step;

step=1;
VehicleID=Input(index:index+step-1);
index=index+step;

step=1;
CurrentX=Input(index:index+step-1);
index=index+step;

step=1;
CurrentY=Input(index:index+step-1);
index=index+step;

step=1;
CurrentHeadingAngle=HeadingToAngle(Input(index:index+step-1));
CurrentHeadingAngle=CurrentHeadingAngle*pi/180;
index=index+step;

step=1;
WaypointNumber=Input(index:index+step-1);
index=index+step;
if g_WaypointFlags(VehicleID)==1 & g_WaypointStartingIndex(VehicleID)>=0
    WaypointNumber=g_WaypointStartingIndex(VehicleID);
end

step=g_MaxNumberTargets*g_NumberTargetOutputs;
TargetsMatrix=reshape(Input(index:index+step-1),g_NumberTargetOutputs,g_MaxNumberTargets)';
Targets=zeros(g_MaxNumberTargets,4);
Targets(:,1:3) = TargetsMatrix(:,[1,2,5]);  
TargetValues = zeros(g_MaxNumberTargets,1);
for(CountTargets = 1:g_MaxNumberTargets),
	TargetValues(CountTargets) = g_TargetTypes(TargetsMatrix(CountTargets,4)).TargetValue;
end;
Targets(:,4) = TargetValues;
index=index+step;

step=g_MaxNumberTargets * g_MaxNumberDesiredHeadings;
DesiredHeadingMatrix = reshape(Input(index:index+step-1),g_MaxNumberTargets,g_MaxNumberDesiredHeadings);
index=index+step;

% from Iteration Logic outputs
step=g_MaxNumberTargets;
CurrentTargetState=Input(index:index+step-1);
CurrentTargetState=CurrentTargetState';
index=index+step;

step=g_MaxNumberVehicles;
TriggerReplanFlags = Input(index:index+step-1);
index=index+step;

%% access vehicle memory
DefaultVelocity=g_VehicleMemory(VehicleID).Dynamics.VTrueFPSInit;
TargetSchedule=g_VehicleMemory(VehicleID).CooperationManager.TargetSchedule;
if isempty(TargetSchedule)
    TargetSchedule=zeros(3,g_MaxNumberTargets);  % 3 tasks per target (classify,attack,verify)
end

LastAssignment=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(end,g_WaypointDefinitions.TargetHandle);
LastTask=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(end,g_WaypointDefinitions.WaypointType)-2;  % so classify=1,attack=2,verify=3

if CurrentTime>100
    CurrentTime;    
end




%% algorithm to predict UAV location after planning is done.
FutureTime=CurrentTime+g_AssignmentDelayEstimate;
[FutureX,FutureY,FuturePsi,FutureWaypoint]=FuturePosition(VehicleID,CurrentX,CurrentY,CurrentHeadingAngle,WaypointNumber,g_AssignmentDelayEstimate);


%% calculate benefits

if LastTask+2==g_WaypointTypes.Attack
    TaskBenefits=zeros(g_MaxNumberTargets,1);
    TimeToComplete=realmax*ones(g_MaxNumberTargets,1);
    SearchBenefit=realmax;    
    Output=[TaskBenefits;TimeToComplete;SearchBenefit];
    return
end


% choose where to plan from 
if LastAssignment~=-1           % already received an assignment this round - go from next to last planned waypoint (ignore tail)
    X=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(end-1,g_WaypointDefinitions.PositionX);
    Y=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(end-1,g_WaypointDefinitions.PositionY);
    TurnIndexs=find(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(:,g_WaypointDefinitions.TurnDirection)~=0);
    if isempty(TurnIndexs)
        Psi=FuturePsi;
    else
        LastTurnIndex=TurnIndexs(end);
        LastTurnDirection=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurnIndex,g_WaypointDefinitions.TurnDirection);
        A=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurnIndex,g_WaypointDefinitions.TurnCenterX);
        B=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurnIndex,g_WaypointDefinitions.TurnCenterY);
        C=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurnIndex,g_WaypointDefinitions.PositionX);
        D=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurnIndex,g_WaypointDefinitions.PositionY);
        Psi=mod(pi/2-(atan2(B-D,A-C)-LastTurnDirection*pi/2),2*pi);  % all that just to find the final heading
    end
    StartTime=TargetSchedule(LastAssignment,LastTask); %time when UAV is finished with it's current plan

else                            % still in search or executing a previous plan - go from current position
    X=FutureX;
    Y=FutureY;
    Psi=FuturePsi;
    StartTime=FutureTime;
    WaypointNumber=FutureWaypoint;
end

% adjust target schedule appropriately for future planning  
TargetSchedule=(TargetSchedule-StartTime)*DefaultVelocity;
ScheduledMask=TargetSchedule>0;
TargetSchedule=TargetSchedule.*ScheduledMask;

% set up inputs to DINF_GetBenefits

VehiclesIn=[ VehicleID X Y Psi ];
VehicleSchedule=[[VehiclesIn(2:4)';0] [VehiclesIn(2:4)';0] zeros(4,g_MaxNumberTargets)];  


CellWayPointsTotal = cell(1,g_MaxNumberTargets);
VehicleWayCountIndex=zeros(g_MaxNumberVehicles,1);VehicleWayCountIndex(VehicleID)=WaypointNumber+1; % add one to get proper index
%VehicleWayCountIndex=1;

VehicleIDs=VehicleID;


%debug
if VehicleID==1
    dummy=1;
end



[TaskBenefits,VehicleSchedule,CellWayPointsTotal]...
    =DINF_GetBenefits(VehiclesIn,VehicleSchedule,CurrentTargetState,TargetSchedule',Targets,1,DesiredHeadingMatrix,...
    g_CommandTurnRadius,g_DefaultMach,CellWayPointsTotal,VehicleIDs,VehicleWayCountIndex,VehicleID,TriggerReplanFlags);




SearchBenefit=TaskBenefits(1);
TaskBenefits=reshape(TaskBenefits(2:end),10,3);


    
TaskBenefits=sum(TaskBenefits,2);    

%fix waypoints if GetBenefits was lazy --- appears I may not actually need this
for indexTarget=1:g_MaxNumberTargets
    if ~isempty(CellWayPointsTotal{indexTarget})
        if (CellWayPointsTotal{indexTarget}(1,g_WaypointDefinitions.PositionX)~=X...
                | CellWayPointsTotal{indexTarget}(1,g_WaypointDefinitions.PositionY)~=Y)
            StartingWaypoint=CellWayPointsTotal{indexTarget}(1,:);
            StartingWaypoint(1,g_WaypointDefinitions.PositionX)=X;
            StartingWaypoint(1,g_WaypointDefinitions.PositionY)=Y;
            StartingWaypoint(1,g_WaypointDefinitions.SegmentLength)=0;
            StartingWaypoint(1,g_WaypointDefinitions.TurnCenterX)=realmax;
            StartingWaypoint(1,g_WaypointDefinitions.TurnCenterY)=realmax;
            StartingWaypoint(1,g_WaypointDefinitions.TurnDirection)=0;
            StartingWaypoint(1,g_WaypointDefinitions.WaypointType)=g_WaypointTypes.Enroute;
            StartingWaypoint(1,g_WaypointDefinitions.TargetHandle)=-1;
            
            NextX=CellWayPointsTotal{indexTarget}(1,g_WaypointDefinitions.PositionX);
            NextY=CellWayPointsTotal{indexTarget}(1,g_WaypointDefinitions.PositionY);
            if CellWayPointsTotal{indexTarget}(1,g_WaypointDefinitions.TurnDirection)~=0
                TurnX=CellWayPointsTotal{indexTarget}(1,g_WaypointDefinitions.TurnCenterX);
                TurnY=CellWayPointsTotal{indexTarget}(1,g_WaypointDefinitions.TurnCenterY);
                TurnD=CellWayPointsTotal{indexTarget}(1,g_WaypointDefinitions.TurnDirection);
                TurnAngle=mod(TurnD*(atan2(NextY-TurnY,NextX-TurnX)-atan2(Y-TurnY,X-TurnX)),2*pi);
                CellWayPointsTotal{indexTarget}(1,g_WaypointDefinitions.SegmentLength)=TurnAngle*g_CommandTurnRadius;                
            else
                CellWayPointsTotal{indexTarget}(1,g_WaypointDefinitions.SegmentLength)=sqrt((NextX-X)^2+(NextY-Y)^2);
            end
            
            CellWayPointsTotal{indexTarget}=[StartingWaypoint;CellWayPointsTotal{indexTarget}];
        end
    end
end

g_VehicleMemory(VehicleID).RouteManager.SaveWaypoints=CellWayPointsTotal;         % save route info for potential targets/tasks


TasksToDo=1*(CurrentTargetState==g_TargetStates.StateDetectedNotClassified)...    % convert CurrentTargetStates    
        + 2*(CurrentTargetState==g_TargetStates.StateClassifiedNotAttacked)...    % to correspond to structure of
        + 3*(CurrentTargetState==g_TargetStates.StateKilledNotConfirmed);         % vehicle schedule
    

DistanceToComplete=zeros(g_MaxNumberTargets,1);

for indexTarget=1:g_MaxNumberTargets
    if TasksToDo(indexTarget)~=0
        % ! information in VehicleSchedule doesn't seem to be reliable -- DistanceToComplete(indexTarget)=VehicleSchedule(TasksToDo(indexTarget),2+indexTarget);
        DistanceToComplete(indexTarget)=sum(CellWayPointsTotal{indexTarget}(:,g_WaypointDefinitions.SegmentLength));
    end
end

TimeToComplete=DistanceToComplete/g_VehicleMemory(VehicleID).Dynamics.VTrueFPSInit;   % convert feet to travel time
TimeToComplete=g_SampleTime*ceil(TimeToComplete/g_SampleTime);          % round up to nearest sample time
TimeToComplete=TimeToComplete+StartTime*(TimeToComplete~=0);                  % convert to ETA

 
Output=[TaskBenefits;TimeToComplete;SearchBenefit];% 

return