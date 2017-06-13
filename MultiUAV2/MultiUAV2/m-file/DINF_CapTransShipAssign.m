function [Output] = DINF_CapTransShipAssign(Input,CurrentTime)
%  AFRL/VACA
% Brandon Moore 25 AUG 03
% $Id: DINF_CapTransShipAssign.m,v 2.0.10.2.4.2 2004/05/06 12:47:24 rasmussj Exp $


global g_Debug; if(g_Debug==1),disp('DINF_CapTransShipAssign.m');end; 

global g_MaxBenefit;
global g_MaxNumberVehicles;
global g_MaxNumberTargets;

global g_VehicleMemory;
global g_Tasks;

global g_WaypointCells;
global g_CommandTurnRadius;
global g_DefaultWaypointAltitude;
global g_WaypointDefinitions;
global g_WaypointTypes;
global g_TargetStates;
global g_WaypointStartingIndex;

NewAssignmentTime = 0;

% process input vector
index=1;

step=g_MaxNumberVehicles;
ActiveVehicles=Input(index:index+step-1);
index=index+step;

step=2;
ReplanRoundIn=Input(index:index+step-1)';
index=index+step;

step=g_MaxNumberTargets;
CurrentTargetStates=Input(index:index+step-1);
index=index+step;

step=g_MaxNumberVehicles*g_MaxNumberTargets;
TaskBenefits=Input(index:index+step-1);
index=index+step;

step=g_MaxNumberVehicles*g_MaxNumberTargets;
TimeToComplete=Input(index:index+step-1);
index=index+step;

step=g_MaxNumberVehicles;
SearchBenefits=Input(index:index+step-1);
index=index+step;

step=1;
SyncSignal=Input(index:index+step-1);
index=index+step;

step=1;
ReplanTrigger=Input(index:index+step-1);
index=index+step;

step=1;
VehicleID=Input(index:index+step-1);
index=index+step;

step=g_MaxNumberTargets;
TargetStatus=Input(index:index+step-1);
index=index+step;

step=1;
WaypointCounter=Input(index:index+step-1);
index=index+step;

step=1;
PositionX=Input(index:index+step-1);
index=index+step;

step=1;
PositionY=Input(index:index+step-1);
index=index+step;

step=1;
PositionHeadingAngle = HeadingToAngle(Input(index:index+step-1));
index=index+step;




% set parameters we may want to change later
NumberOfTasks=3;    % classify,attack,verify

% grab global variables needed
TargetSchedule=g_VehicleMemory(VehicleID).CooperationManager.TargetSchedule;
if isempty(TargetSchedule)
    TargetSchedule=zeros(g_MaxNumberTargets,NumberOfTasks);
end

LastReplanRound=g_VehicleMemory(VehicleID).CooperationManager.ReplanRound;


% %debug-turns off subsequent replans
% if ReplanRoundIn(1)==1 & ReplanRoundIn(2)==2 & ReplanTrigger~=0
%     g_VehicleMemory(VehicleID).CooperationManager.PreviousTaskTarget=13;
%     ReplanRoundOut=[1 2];
%     TargetStatesOut=zeros(g_MaxNumberTargets,1);
%     SendBenefitsTrigger=0;
%     Output=[ReplanRoundOut';TargetStatesOut;SendBenefitsTrigger;NewAssignmentTime];
%     return
% end
%     
% if g_VehicleMemory(VehicleID).CooperationManager.PreviousTaskTarget==13
%         ReplanRoundOut=[1 2];
%     TargetStatesOut=zeros(g_MaxNumberTargets,1);
%     SendBenefitsTrigger=0;
%     Output=[ReplanRoundOut';TargetStatesOut;SendBenefitsTrigger;NewAssignmentTime];
%     return
% end



% if new target found or TriggerReplan message sent, reset algorithm

if ReplanTrigger~=0
    ReplanRoundOut=[ReplanRoundIn(1)+1 0];  % increment replan counter and reset iteration counter;
    TargetStatesOut=TargetStatus;           % reinject current TargetStatus back into algorithm
    SendBenefitsTrigger=1;                  
    
    g_VehicleMemory(VehicleID).CooperationManager.TargetSchedule=zeros(g_MaxNumberTargets,NumberOfTasks); %clear target schedule
    g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints = g_WaypointCells{VehicleID};    
    
    % save current waypoints for use in DINF_GetBenefits.m (only if not searching!)
    TargetedCheck=find(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(:,g_WaypointDefinitions.TargetHandle)>0);
    if isempty(TargetedCheck) 
        g_VehicleMemory(VehicleID).CooperationManager.WaypointMemory=cell(g_MaxNumberVehicles,1); 
    else
    PreviousWaypoints=cell(g_MaxNumberVehicles,1);
    PreviousWaypoints{VehicleID}=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints;
    g_VehicleMemory(VehicleID).CooperationManager.WaypointMemory=PreviousWaypoints;
    
    
    
    % keep current trajectory (because imminent assignment will probably remain the same)
    % but turn off actions so we don't get conflicts
    NotSearchIndex=find(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(:,g_WaypointDefinitions.WaypointType)~=g_WaypointTypes.Search);
    SearchIndex=ones(size(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints,1),1);
    SearchIndex(NotSearchIndex)=0;
    SearchIndex=find(SearchIndex==1);
    g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(NotSearchIndex,g_WaypointDefinitions.WaypointType)=g_WaypointTypes.Enroute;
    g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(SearchIndex,g_WaypointDefinitions.WaypointType)=g_WaypointTypes.Search;    
    g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(:,g_WaypointDefinitions.TargetHandle)=-1;

   
        g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints = g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints;
        %WaypointFlags(VehicleID)=1;  % "new" waypoints (i.e. old ones with actions turned off)
        %moved waypointflags entry to allow for process delay
        NewAssignmentTime = CurrentTime;

        
        g_WaypointStartingIndex(VehicleID)=-1; % don't reset counter
        
    end    
    
    
    
    disp(sprintf('%.2f Vehicle-%d Enters Replan #%d',CurrentTime,VehicleID,ReplanRoundOut(1)));
    Output=[ReplanRoundOut';TargetStatesOut;SendBenefitsTrigger;NewAssignmentTime];
    return
end

% still waiting on some UAV to send it's info for this iteration - don't run solver yet
if SyncSignal==0
    ReplanRoundOut=LastReplanRound;
    TargetStatesOut=zeros(g_MaxNumberTargets,1);
    SendBenefitsTrigger=0;
    Output=[ReplanRoundOut';TargetStatesOut;SendBenefitsTrigger;NewAssignmentTime];
    disp(sprintf('%.2f Vehicle-%d got new data but is not synchronized (this message will get annoying with comm delays)',...
        CurrentTime,VehicleID));
    return
end
       
% alogorithm triggered and synchronized without new information arriving - this shouldn't happen
if ReplanRoundIn==LastReplanRound
    ReplanRoundOut=ReplanRoundIn;
    TargetStatesOut=zeros(g_MaxNumberTargets,1);
    SendBenefitsTrigger=0;
    Output=[ReplanRoundOut';TargetStatesOut;SendBenefitsTrigger;NewAssignmentTime];
    disp('should not see this message - DistItCapTransShip algorithm triggered by ?');
    return
end


%%%% ready for next iteration of assignment algorithm

% ReplanRoundOut=ReplanRoundIn + [0 1];   % increment iteration counter
% g_VehicleMemory(VehicleID).CooperationManager.ReplanRound=ReplanRoundIn;
% SendBenefitsTrigger=1;                  % trigger sending out of benefits for next round when done here



% reformat benefits into a matrix and mask out dead vehicles and targets with no pending tasks 
BenefitsMatrix=reshape(TaskBenefits,g_MaxNumberTargets,g_MaxNumberVehicles);
DeadVehicles=find(~ActiveVehicles);
BenefitsMatrix(:,DeadVehicles)=0;
IgnoredTargets=find(CurrentTargetStates<=g_TargetStates.StateNotDetected ...
     | CurrentTargetStates>=g_TargetStates.StateConfirmedKill);
BenefitsMatrix(IgnoredTargets,:)=0;

BenefitsContinueToSearch=SearchBenefits;
BenefitsContinueToSearch(DeadVehicles)=g_MaxBenefit; % make sure inactive vehicles aren't assigned

% pull out benefits for each task type and then reformat as proper vector for CapTransShipMEX

ClassifyMask=CurrentTargetStates*ones(1,g_MaxNumberVehicles)==g_TargetStates.StateDetectedNotClassified;
AttackMask  =CurrentTargetStates*ones(1,g_MaxNumberVehicles)==g_TargetStates.StateClassifiedNotAttacked;
VerifyMask  =CurrentTargetStates*ones(1,g_MaxNumberVehicles)==g_TargetStates.StateKilledNotConfirmed;


BenefitsClassifyCapTransShip=reshape((BenefitsMatrix.*ClassifyMask),g_MaxNumberVehicles*g_MaxNumberTargets,1);
BenefitsAttackCapTransShip  =reshape((BenefitsMatrix.*AttackMask),  g_MaxNumberVehicles*g_MaxNumberTargets,1);
BenefitsVerifyCapTransShip  =reshape((BenefitsMatrix.*VerifyMask),  g_MaxNumberVehicles*g_MaxNumberTargets,1);




BenefitsCapTransShip = [BenefitsContinueToSearch ; 
                        BenefitsClassifyCapTransShip ;
                        BenefitsAttackCapTransShip ;
                        BenefitsVerifyCapTransShip] ;

%BenefitsCapTransShip(find(BenefitsCapTransShip==0))=-g_MaxBenefit;   % need this or is 0 low enough?

% run network flow algorithm 
[TargetAssignment,TaskAssigned,TotalBenefitsCapTransShip]...
    = CapTranShipMex(BenefitsCapTransShip,g_MaxNumberVehicles,g_MaxNumberTargets,NumberOfTasks);


% get ETA for potential assignments
PotentialAssignmentsVehicles=find(TargetAssignment~=0);
PotentialAssignmentsTargets=TargetAssignment(PotentialAssignmentsVehicles);
TimeToComplete=reshape(TimeToComplete,g_MaxNumberTargets,g_MaxNumberVehicles);

for indexVehicle=1:length(PotentialAssignmentsVehicles)
    PotentialETA(indexVehicle)...
        =TimeToComplete(PotentialAssignmentsTargets(indexVehicle),PotentialAssignmentsVehicles(indexVehicle));
end

%% choose assignment(s)

% one at a time
[ETAsAssigned,indexMinETA]=min(PotentialETA);
VehiclesAssigned=PotentialAssignmentsVehicles(indexMinETA);
TargetsAssigned=TargetAssignment(VehiclesAssigned);


% finalize assignment for each chosen vehicle
TargetStatesUpdate=CurrentTargetStates;

for indexVehicle=1:length(VehiclesAssigned)
    
    % update target states for planning
    switch CurrentTargetStates(TargetsAssigned(indexVehicle))
        
    case g_TargetStates.StateDetectedNotClassified    % detected goes to classified
        TargetStatesUpdate(TargetsAssigned(indexVehicle))=g_TargetStates.StateClassifiedNotAttacked;
        
    case g_TargetStates.StateClassifiedNotAttacked    % classified goes to attacked
        TargetStatesUpdate(TargetsAssigned(indexVehicle))=g_TargetStates.StateKilledNotConfirmed;
        
    case g_TargetStates.StateKilledNotConfirmed       % attacked goes to verified
        TargetStatesUpdate(TargetsAssigned(indexVehicle))=g_TargetStates.StateConfirmedKill;
        
    otherwise    
        error('target state not recognized');
    end
    
    
    % update target schedule   %% TODO: access this in CalculateBenefits to lengthen paths DONE?
    switch CurrentTargetStates(TargetsAssigned(indexVehicle))
        
    case g_TargetStates.StateDetectedNotClassified 
        Task=1;               
    case g_TargetStates.StateClassifiedNotAttacked
        Task=2;
    case g_TargetStates.StateKilledNotConfirmed       
        Task=3;
    otherwise    
        error('target state not recognized');
    end
    
    TargetSchedule(TargetsAssigned(indexVehicle),Task)=ETAsAssigned(indexVehicle);
    g_VehicleMemory(VehicleID).CooperationManager.TargetSchedule=TargetSchedule;
    
% debug     
% if CurrentTime>70 & VehicleID==3
%     CurrentTime;    
% end
    
    


    
    % adjust waypoints if this UAV receives assignment
    
    if VehiclesAssigned(indexVehicle)==VehicleID
        PlanMessage=sprintf('%.2f Vehicle-%d Assigned to %s-%d at %.2f sec',CurrentTime,VehicleID,...
                    g_Tasks.TaskStrings{Task+1},TargetsAssigned(indexVehicle),ETAsAssigned(indexVehicle));
        disp(PlanMessage);
                        
        
        CurrentWaypoints=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints;
        
        WaypointModes=CurrentWaypoints(:,g_WaypointDefinitions.WaypointType);
        
        % on a search pattern or enroute to one 
        % -- save current position plus undone waypoints and load waypoints to assignment
        if sum(WaypointModes~=g_WaypointTypes.Search & WaypointModes~=g_WaypointTypes.Enroute)==0   
           
            % on search so save undone waypoints
            if WaypointModes(WaypointCounter+1)==1
                          
                SearchWaypoints=CurrentWaypoints(WaypointCounter+1:end,:);
                CurrentPositionWaypoint=SearchWaypoints(1,:);
                CurrentPositionWaypoint(g_WaypointDefinitions.PositionX)=PositionX;
                CurrentPositionWaypoint(g_WaypointDefinitions.PositionY)=PositionY;
                CurrentPositionWaypoint(g_WaypointDefinitions.SegmentLength)=realmax;
                CurrentPositionWaypoint(g_WaypointDefinitions.TurnCenterX)=realmax;
                CurrentPositionWaypoint(g_WaypointDefinitions.TurnCenterY)=realmax;
                CurrentPositionWaypoint(g_WaypointDefinitions.TurnDirection)=0;
                
                %calculate segement length for turn or straight line segment
                SearchX=SearchWaypoints(1,g_WaypointDefinitions.PositionX);
                SearchY=SearchWaypoints(1,g_WaypointDefinitions.PositionY);
                if SearchWaypoints(1,g_WaypointDefinitions.TurnDirection)~=0
                    TurnX=SearchWaypoints(1,g_WaypointDefinitions.TurnCenterX);
                    TurnY=SearchWaypoints(1,g_WaypointDefinitions.TurnCenterY);
                    TurnD=SearchWaypoints(1,g_WaypointDefinitions.TurnDirection);
                    TurnAngle=mod(TurnD*(atan2(SearchY-TurnY,SearchX-TurnX)-atan2(PositionY-TurnY,PositionX-TurnX)),2*pi);
                    SearchWaypoints(1,g_WaypointDefinitions.SegmentLength)=TurnAngle*g_CommandTurnRadius;                
                else
                    SearchWaypoints(1,g_WaypointDefinitions.SegmentLength)=sqrt((SearchX-PositionX)^2+(SearchY-PositionY)^2);
                end
                
                g_VehicleMemory(VehicleID).RouteManager.AlternateWaypoints=[CurrentPositionWaypoint;SearchWaypoints];
                g_VehicleMemory(VehicleID).RouteManager.AlternateWaypointIndex=1;
                g_VehicleMemory(VehicleID).RouteManager.LastSearchX=PositionX;
                g_VehicleMemory(VehicleID).RouteManager.LastSearchY=PositionY;
                g_VehicleMemory(VehicleID).RouteManager.LastSearchPsi=PositionHeadingAngle;
                
            end % save undone search pattern
            
            % replace waypoints in WaypointMemory with current untargeted ones or else GetBenefits.m may not function properly
            g_VehicleMemory(VehicleID).CooperationManager.WaypointMemory{VehicleID}=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints;
                                 
            
            % overwrite current waypoints with those for assignment
            g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints=g_VehicleMemory(VehicleID).RouteManager.SaveWaypoints{TargetsAssigned(indexVehicle)};
            
            % add a waypoint for vehicle's current position (be lazy-just use straight line distance)
            PresentSpot=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(1,:);
            PresentSpot([g_WaypointDefinitions.PositionX, g_WaypointDefinitions.PositionY])=[PositionX, PositionY];
            g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints=[PresentSpot;g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints];
            g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(2,g_WaypointDefinitions.SegmentLength)=...
                sqrt(sum(diff(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(1:2,[g_WaypointDefinitions.PositionX, g_WaypointDefinitions.PositionY])).^2));
            
            %add a tail in case next assignment takes a while to complete
            TailWaypoint=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(end,:);
            LastTurn=find(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(:,g_WaypointDefinitions.TurnDirection)~=0);
            if isempty(LastTurn)
                FinalAngle=atan2(diff(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(end-1:end,g_WaypointDefinitions.PositionY)),...
                    diff(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(end-1:end,g_WaypointDefinitions.PositionX)));
            else
                LastTurn=LastTurn(end);
                FinalAngle=atan2(diff(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurn,[g_WaypointDefinitions.TurnCenterY g_WaypointDefinitions.PositionY])),...
                    diff(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurn,[g_WaypointDefinitions.TurnCenterX g_WaypointDefinitions.PositionX])))...
                    +(pi/2)*g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurn,g_WaypointDefinitions.TurnDirection);
            end
            TailWaypoint(g_WaypointDefinitions.PositionX)=TailWaypoint(g_WaypointDefinitions.PositionX)+10^4*cos(FinalAngle);
            TailWaypoint(g_WaypointDefinitions.PositionY)=TailWaypoint(g_WaypointDefinitions.PositionY)+10^4*sin(FinalAngle);
            TailWaypoint(g_WaypointDefinitions.TurnDirection)=0;
            TailWaypoint(g_WaypointDefinitions.TurnCenterX)=realmax;
            TailWaypoint(g_WaypointDefinitions.TurnCenterY)= realmax;
            TailWaypoint(g_WaypointDefinitions.SegmentLength)=10^4;
            
            g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints=[g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints;TailWaypoint];
            
            g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints = g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints;
            %WaypointFlags(VehicleID)=1; % tell sim there's a whole new set of waypoints
            %moved waypointflags entry to allow for process delay
            NewAssignmentTime = CurrentTime;

            g_WaypointStartingIndex(VehicleID)=1; % reset waypoint counter TO ZERO since first waypoint is delayed position not current position
            WaypointCounter=1; %this line doesn't affect sim, but this script needs to know that WaypointCounter is 1 now...
            
        % already received an assignment this round
        % -- tack on the next one (correct? yes.  working yet?)
        else
            %take off that tail
            CurrentWaypoints=CurrentWaypoints(1:end-1,:);
            
            
            g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints=[CurrentWaypoints;...
                                    g_VehicleMemory(VehicleID).RouteManager.SaveWaypoints{TargetsAssigned(indexVehicle)}];
                            
                            
            %add a tail in case next assignment takes a while to complete
                TailWaypoint=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(end,:);
                LastTurn=find(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(:,g_WaypointDefinitions.TurnDirection)~=0);
                if isempty(LastTurn)
                    FinalAngle=atan2(diff(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(end-1:end,g_WaypointDefinitions.PositionY)),...
                        diff(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(end-1:end,g_WaypointDefinitions.PositionX)));
                else
                    LastTurn=LastTurn(end);
                    FinalAngle=atan2(diff(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurn,[g_WaypointDefinitions.TurnCenterY g_WaypointDefinitions.PositionY])),...
                                     diff(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurn,[g_WaypointDefinitions.TurnCenterX g_WaypointDefinitions.PositionX])))...
                                     +(pi/2)*g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurn,g_WaypointDefinitions.TurnDirection);
                end
                TailWaypoint(g_WaypointDefinitions.PositionX)=TailWaypoint(g_WaypointDefinitions.PositionX)+10^4*cos(FinalAngle);
                TailWaypoint(g_WaypointDefinitions.PositionY)=TailWaypoint(g_WaypointDefinitions.PositionY)+10^4*sin(FinalAngle);
                TailWaypoint(g_WaypointDefinitions.TurnDirection)=0;
                TailWaypoint(g_WaypointDefinitions.TurnCenterX)=realmax;
                TailWaypoint(g_WaypointDefinitions.TurnCenterY)= realmax;
                TailWaypoint(g_WaypointDefinitions.SegmentLength)=10^4;
                  
                g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints = g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints;
                g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints=[g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints;TailWaypoint];
                
            %WaypointFlags(VehicleID)=1; % tell sim there's new waypoints...
            %moved waypointflags entry to allow for process delay
            NewAssignmentTime = CurrentTime;

            g_WaypointStartingIndex(VehicleID)=-1; % ... but don't reset the waypoint counter
        end %how to add waypoints for assignment
    end %this vehicle gets assignment
end %all assignments made

% debug line
% if CurrentTime>50 & VehicleID==8;
%     CurrentTime;    
% end



% not done yet, go to next iteration
if sum(TargetStatesUpdate>g_TargetStates.StateNotDetected...
        & TargetStatesUpdate<g_TargetStates.StateConfirmedKill)~=0
    
    ReplanRoundOut=ReplanRoundIn+[0 1];
    g_VehicleMemory(VehicleID).CooperationManager.ReplanRound=ReplanRoundIn;
    TargetStatesOut=TargetStatesUpdate;
    SendBenefitsTrigger=1;
    
% done with planning, add return to search waypoints to all trajectory for everyone not already searching    
else
    ReplanRoundOut=ReplanRoundIn;
    g_VehicleMemory(VehicleID).CooperationManager.ReplanRound=ReplanRoundIn;
    TargetStatesOut=zeros(g_MaxNumberTargets,1);
    SendBenefitsTrigger=0;
    
    % still searching - return to search waypoints not needed
    if sum(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(WaypointCounter+1:end,g_WaypointDefinitions.WaypointType)~=g_WaypointTypes.Search)==0
        NeedToDoThis=0;  
    % been assigned at least one target - need return to search waypoints from last assignment    
    elseif g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(end,g_WaypointDefinitions.TargetHandle)~=-1
        %take off that tail waypoint!
        g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(1:end-1,:);
    
        FromX=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(end,g_WaypointDefinitions.PositionX);
        FromY=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(end,g_WaypointDefinitions.PositionY);
        TurnIndexs=find(g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(:,g_WaypointDefinitions.TurnDirection)~=0);
        if isempty(TurnIndexs)
            FromPsi=PositionHeadingAngle*pi/180;
        else
            LastTurnIndex=TurnIndexs(end);
            LastTurnDirection=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurnIndex,g_WaypointDefinitions.TurnDirection);
            A=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurnIndex,g_WaypointDefinitions.TurnCenterX);
            B=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurnIndex,g_WaypointDefinitions.TurnCenterY);
            C=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurnIndex,g_WaypointDefinitions.PositionX);
            D=g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(LastTurnIndex,g_WaypointDefinitions.PositionY);
            FromPsi=mod(pi/2-(atan2(B-D,A-C)-LastTurnDirection*pi/2),2*pi);  % find the final heading
            NeedToDoThis=1;
            
        end
        NeedToDoThis=1;
        WaypointResetBackToSearch=-1;  % ... but don't reset the waypoint counter

    % had an assignment before but wound up without one this planning round 
    % - need return to search waypoints from current position    
    else
        g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints=[]; %clear what you've got
        WaypointResetBackToSearch=1; %reset the waypoint counter
        FromX=PositionX;
        FromY=PositionY;
        FromPsi=PositionHeadingAngle*pi/180;
        NeedToDoThis=1;    
    end
    
    
    if NeedToDoThis==1
        %%>> Get data from stored search pattern
        LastSearchWaypoint=g_VehicleMemory(VehicleID).RouteManager.AlternateWaypointIndex;
        SearchWaypoints=g_VehicleMemory(VehicleID).RouteManager.AlternateWaypoints(LastSearchWaypoint:end,:);
        LastX=g_VehicleMemory(VehicleID).RouteManager.LastSearchX;
        LastY=g_VehicleMemory(VehicleID).RouteManager.LastSearchY;
        LastPsi=g_VehicleMemory(VehicleID).RouteManager.LastSearchPsi;
        
        %%>> Plan trajectory back to search
        VehicleState = [VehicleID;FromX;FromY;g_DefaultWaypointAltitude;FromPsi;0;g_CommandTurnRadius;1;0];
        ReturnPoint = [-1;LastX;LastY;0;1;0];
        [ReturnWaypoints,dummy,dummy] = TrajectoryMEX(VehicleState,ReturnPoint,LastPsi*pi/180,0);   
        ReturnWaypoints(:,g_WaypointDefinitions.WaypointType)=g_WaypointTypes.Enroute; % set type to Enroute
        
        % stacks too many waypoints on top of one another ??? SearchWaypoints(1,g_WaypointDefinitions.SegmentLength)=0;            
        SearchWaypoints=SearchWaypoints(2:end,:);
        
              
        g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints = g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints;
        %%>> Save waypoints
        g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints=[g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints;ReturnWaypoints;SearchWaypoints];
        
        %WaypointFlags(VehicleID)=1; % tell sim there's new waypoints...
        %moved waypointflags entry to allow for process delay
        NewAssignmentTime = CurrentTime;

        if VehiclesAssigned(indexVehicle)~=VehicleID   
            g_WaypointStartingIndex(VehicleID)=WaypointResetBackToSearch;
        else
            g_WaypointStartingIndex(VehicleID); 
            % should already be set properly if vehicle picked up an assignment on the last round
        end
      
    end
    
    
    
    
    
    
end






% remove this when you get this function working
% ReplanRoundOut=ReplanRoundIn;
% g_VehicleMemory(VehicleID).CooperationManager.ReplanRound=ReplanRoundIn;
% TargetStatesOut=zeros(g_MaxNumberTargets,1);
% SendBenefitsTrigger=0;

Output=[ReplanRoundOut';TargetStatesOut;SendBenefitsTrigger;NewAssignmentTime];

return; 



%%%%%%%%%%

% END OF CODE

%%%%%%%%%%%%%%%%%
