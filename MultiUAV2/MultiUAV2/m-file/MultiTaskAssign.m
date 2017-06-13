function [VehicleWayPoints,VehicleSchedule,AllAssignments,SummaryAssignmentBenefitTotal,SummaryAssignmentDistanceTotal,SummaryAssignmentExecutionTime] = ...
    MultiTaskAssign(VehiclesIn,Targets,TargetState,DesiredHeadings,CommandTurnRadius,AlgorithmType,TimeSimulation,VehicleWayCounts, ...
    ThisVehicleID,TriggerReplanFlags,SingleAlgorithmType)


global g_Debug; if(g_Debug==1),disp('MultiTaskAssign.m');end; 
global g_Tasks;                                                                            
global g_WaypointTypes;
global g_WaypointDefinitions;
global g_DefaultWaypointAltitude;
global g_TypeAssignment;
global g_TargetStates;
global g_VehicleMemory;
global g_MaxNumberVehicles;
global g_DefaultMach;
global g_AssignmentProcessingDelay;

if(isempty(VehiclesIn))
    return;
end;

Vehicles = [];
NumberVehicles = size(VehiclesIn,1);
%% algorithm to predict UAV location after planning is done.
if(g_AssignmentProcessingDelay > 0),
    for(CountVehicles = 1:NumberVehicles),
        [FutureX,FutureY,FuturePsi,FutureWaypoint]=FuturePosition(VehiclesIn(CountVehicles,1),VehiclesIn(CountVehicles,2), ...
            VehiclesIn(CountVehicles,3),VehiclesIn(CountVehicles,4), ...
            VehicleWayCounts(CountVehicles),g_AssignmentProcessingDelay);
        Vehicles = [Vehicles;[FutureX,FutureY,FuturePsi]];
    end;    %for(CountVehicles = 1:NumberVehicles),
else,   %if(g_AssignmentProcessingDelay > 0),
    Vehicles = VehiclesIn(:,2:4);
end;    %if(g_AssignmentProcessingDelay > 0),

VehicleIDs = VehiclesIn(:,1);
NumberVehicles = length(VehicleIDs);

%%%%%%%%%%%%%%%%%%%%% TODO %%%%%%%%%%%%%%%%%%%%%%
TotalFlightTime = 30.0;  
CurrentTime = 0.0;
ScaleFactor = 100;
Scaling = 1000;         %Mod by Schumacher 4/22/02

CurrentMachCmd = g_DefaultMach;

[NumberOfVehicles, NumberColumns] = size(Vehicles);
[NumberOfTargets, NumberColumns] = size(Targets);


if(~exist('SingleAlgorithmType')),
    %SingleAlgorithmType = g_TypeAssignment.ItAuctionJacobi;
    SingleAlgorithmType = g_TypeAssignment.ItCapTransShip;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SummaryAssignmentBenefitTotal = 0.0;
SummaryAssignmentDistanceTotal = 0.0;
SummaryAssignmentExecutionTime = 0.0;

NumberOfTasks = g_Tasks.NumberTasks-1;

VehicleWayPoints = cell(NumberOfVehicles,1) ; 
TargetSchedule = zeros(3,NumberOfTargets);
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

VehicleSchedule = [[reshape(Vehicles',3,1,NumberOfVehicles);zeros(1,1,NumberOfVehicles)] ...
        [reshape(Vehicles',3,1,NumberOfVehicles);zeros(1,1,NumberOfVehicles)] ...
        zeros(4,NumberOfTargets,NumberOfVehicles)];
TargetColumnRange = [3:(3+(NumberOfTargets-1))];

TotalTaskDistance = [];

switch(AlgorithmType)
case {g_TypeAssignment.ItAuctionJacobi,g_TypeAssignment.ItCapTransShip},
    %while(sum(TargetState)<(NumberOfTasks+1)*NumberOfTargets),      %add 1 to number of tasks, cause search is included in TargetState
    while(sum(TargetState)<(g_TargetStates.NumberStates)*NumberOfTargets),      %add 1 to number of tasks, cause search is included in TargetState
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Classification Assignment: Indicated by TargetState value of 1
        if ((~isempty(Vehicles))&((~isempty(find(TargetState==g_TargetStates.StateDetectedNotClassified)))| ...
                (~isempty(find(TargetState==g_TargetStates.StateClassifiedNotAttacked)))| ...
                (~isempty(find(TargetState==g_TargetStates.StateAttackedNotKilled)))| ...
                (~isempty(find(TargetState==g_TargetStates.StateKilledNotConfirmed)))))
            
            TargetsToTaskTotal = [] ;
            TaskDistanceTotal = [] ;
            CellWayPointsTotal = cell(NumberOfVehicles,NumberOfTargets) ;
            
            % Calculate the Benefits for the vehicles to do the required classifications
            [BenefitsClassify,VehicleSchedule,TargetsToClassify,CellWayPointsTotal,TaskDistance] = GetBenefits(g_Tasks.Classify,TargetState,TargetSchedule,...
                Targets,VehicleSchedule,NumberOfVehicles,ScaleFactor, DesiredHeadings,CommandTurnRadius,CurrentMachCmd,CellWayPointsTotal,VehicleIDs, ...
                VehicleWayCounts,ThisVehicleID,TriggerReplanFlags); %Modified by Schumacher 5/23/02
            
            TotalBenefits = BenefitsClassify;
            VehicleScheduleTotal = VehicleSchedule ;
            TargetsToTaskTotal = [TargetsToTaskTotal TargetsToClassify];
            TotalTaskDistance(:,:,g_Tasks.Classify) = TaskDistance;	%classify distance
            
            % Calculate the Benefits for the vehicles to do the required attacks
            [BenefitsAttack,VehicleSchedule,TargetsToAttack,CellWayPointsTotal,TaskDistance] = GetBenefits(g_Tasks.Attack,TargetState,TargetSchedule,...
                Targets,VehicleSchedule,NumberOfVehicles,ScaleFactor,DesiredHeadings,CommandTurnRadius,CurrentMachCmd,CellWayPointsTotal,VehicleIDs, ...
                VehicleWayCounts,ThisVehicleID,TriggerReplanFlags); %Modified by Schumacher 5/23/02
            
            TotalBenefits = TotalBenefits + BenefitsAttack;
            VehicleScheduleTotal(1:3,TargetColumnRange,:) = VehicleScheduleTotal(1:3,TargetColumnRange,:) + VehicleSchedule(1:3,TargetColumnRange,:) ;
            TargetsToTaskTotal = [TargetsToTaskTotal TargetsToAttack];
            TotalTaskDistance(:,:,g_Tasks.Attack) = TaskDistance;	%attack distance
            
            % Calculate the Benefits for the vehicles to do the required BDA
            [BenefitsBDA,VehicleSchedule,TargetsToBDA,CellWayPointsTotal,TaskDistance] = GetBenefits(g_Tasks.Verify,TargetState,TargetSchedule,...
                Targets,VehicleSchedule,NumberOfVehicles,ScaleFactor,DesiredHeadings,CommandTurnRadius,CurrentMachCmd,CellWayPointsTotal,VehicleIDs, ...
                VehicleWayCounts,ThisVehicleID,TriggerReplanFlags); %Modified by Schumacher 5/23/02
            TotalBenefits = TotalBenefits + BenefitsBDA;
            VehicleScheduleTotal(1:3,TargetColumnRange,:) = VehicleScheduleTotal(1:3,TargetColumnRange,:) + VehicleSchedule(1:3,TargetColumnRange,:) ;
            TargetsToTaskTotal = [TargetsToTaskTotal TargetsToBDA];
            TotalTaskDistance(:,:,g_Tasks.Verify) = TaskDistance;	%verify distance
            
            %Additions for search benefit in auction:            %Mod by Schumacher 4/22/02
            
            BenefitsContinueToSearch = eye(NumberOfVehicles)*15/30*max(Targets(:,4))*Scaling;     %Mod by Schumacher 4/22/02
            TotalBenefits = TotalBenefits*Scaling;                                                %Mod by Schumacher 4/22/02
            
            
            % Call the Jacobi Auction or CapTransShip Algorithm - switch set before main while loop
            if (AlgorithmType ==g_TypeAssignment.ItAuctionJacobi)
                
                % Use the Jacobi auction to assign vehicles to service Targets
                [TargetAssignment, VehicleAssigned] = RunJacobi(g_Tasks.Undefined,TotalBenefits,TargetsToTaskTotal, ...
                    VehicleSchedule,NumberOfVehicles,NumberOfTargets,BenefitsContinueToSearch);           %Mod by Schumacher 4/22/02
                
            elseif (AlgorithmType == g_TypeAssignment.ItCapTransShip)
                
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
                
                % Call the Capacitative TransShipment Algorithm to Compute Assignments
                % NumberOfTasks-1 don't include ClassifyAttack task
                [TargetAssignment,TaskAssigned,TotalBenefitsCapTransShip] = CapTranShipMex(BenefitsCapTransShip,NumberOfVehicles,NumberOfTargets,NumberOfTasks-1);
                VehicleAssigned = [1:1:NumberOfVehicles] ;
            else
                print('Invalid Algorithm Type Specifier in MultiAssign.m')
                return
            end % End Jacobi/CapTranShipment Algorithm Selection Section
            
            % Select the assignment with the minimum ETA
            MinETA = realmax ; VehicleIndex = 0 ; AssignedTargetState = 0 ;
            
            for CountVehicles = 1:NumberOfVehicles
                AssignTarget = TargetAssignment(CountVehicles);
                
                if (AssignTarget ~= 0)
                    %%?????????
                    AssignedETA = VehicleSchedule(FindRequiredTask(TargetState(AssignTarget)),AssignTarget+2,CountVehicles);
                    if (AssignedETA < MinETA)
                        MinETA = AssignedETA ;
                        VehicleIndex = CountVehicles;
                        AssignedTargetState = TargetState(AssignTarget) ;
                    end
                end
                %if ((MinETA == realmax)|(VehicleIndex == 0)|(AssignedTargetState == 0))
                %    continue
                %end
            end % CountVehicles = 1:NumberOfVehicles
            
            % Store the WayPoints corresponding to the assigned task: VehicleIndex = Assigned Vehicle,
            % TargetAssignment(VehicleIndex) = Assigned Target
            if (VehicleIndex ~= 0),
                VehicleWayPoints{VehicleIndex,1} = [VehicleWayPoints{VehicleIndex,1} ; CellWayPointsTotal{VehicleIndex,TargetAssignment(VehicleIndex)}] ;
            else
                break
            end	
            
            % Update the TargetState vector and TargetSchedule
            AssignedTask = FindRequiredTask(AssignedTargetState);
            if((AssignedTask >= g_Tasks.Classify)&(AssignedTask <= g_Tasks.Verify)),
                AssignedTarget = TargetAssignment(VehicleIndex);
                TargetState(AssignedTarget) = FindTargetState(AssignedTask+1);	%update as if the assigned task was completed
                
                % update temporary assignments and times/distances
                TargetSchedule(AssignedTask,AssignedTarget) = VehicleSchedule(AssignedTask,AssignedTarget+2,find(TargetAssignment == AssignedTarget));
                VehicleSchedule(4,1:2,VehicleIndex) = [AssignedTarget AssignedTask];
                VehicleSchedule(1:3,2,VehicleIndex) = [VehicleWayPoints{VehicleIndex,1}(end,1:2)';VehicleSchedule(4,AssignedTarget+2,VehicleIndex)];
                
                switch(AssignedTask),
                case {g_Tasks.ClassifyAttack}
                    TaskTime = round((TargetSchedule(g_Tasks.Attack,AssignedTarget)/g_VehicleMemory(ThisVehicleID).Dynamics.VTrueFPSInit) + TimeSimulation);
                otherwise,
                    TaskTime = round((TargetSchedule(AssignedTask,AssignedTarget)/g_VehicleMemory(ThisVehicleID).Dynamics.VTrueFPSInit) + TimeSimulation);
                end;
                %print out assignment report
                if(ThisVehicleID == VehiclesIn(VehicleIndex)),
                    switch(AssignedTask),
                    case {g_Tasks.Classify,g_Tasks.Attack,g_Tasks.Verify,g_Tasks.ClassifyAttack}
                        AssignedTaskString = g_Tasks.TaskStrings{AssignedTask+1};
                    otherwise,
                        AssignedTaskString = g_Tasks.TaskStrings{g_Tasks.Undefined+1};
                    end;
                    fprintf('%3.2f Vehicle #%d: will %s #%d at %3.2f\n',TimeSimulation,ThisVehicleID,AssignedTaskString,AssignedTarget,TaskTime);
                end;		%if(VehicleIndex == VehiclesIn(VehicleIndex)),
                
                %save summary data
                SummaryAssignmentDistanceTotal = SummaryAssignmentDistanceTotal + TotalTaskDistance(VehicleIndex,AssignedTarget,AssignedTask);
                TaskDeltaTime = TaskTime - TimeSimulation;
                if(TaskDeltaTime > SummaryAssignmentExecutionTime),
                    SummaryAssignmentExecutionTime = TaskDeltaTime;
                end;
                SummaryAssignmentBenefitTotal = SummaryAssignmentBenefitTotal + TotalBenefits(VehicleIndex,AssignedTarget);
            end;	%if((AssignedTask <= g_Tasks.Classify))&(AssignTasked <= g_Tasks.Verify)),
        else, % If ((~isempty(Vehicles))&((~isempty(find(TargetState==1)))|(~isempty(find(TargetState==2)))|(~isempty(find(TargetState==3)))))
            break;
        end % If ((~isempty(Vehicles))&((~isempty(find(TargetState==1)))|(~isempty(find(TargetState==2)))|(~isempty(find(TargetState==3)))))
        % For plotting purposes only
        NewValue = TargetAssignment(VehicleIndex)+(2*TargetAssignment(VehicleIndex)-2) ;
        AllAssignments(AssignedTargetState, VehicleIndex) = NewValue ;
    end; % End while(sum(TargetState)<4*NumberOfTargets)
case {g_TypeAssignment.RelativeBenefits},
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%   RELATIVE BENEFITS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %STEP 1: Assign all of the required classification/attacks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %STEP 1a: Calculate the Benefits for the vehicles to do the required classification/attacks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    CellWayPointsTotal = cell(NumberOfVehicles,NumberOfTargets) ;
    
    [BenefitsClassifyAttack,VehicleSchedule,TargetsToClassifyAttack,CellWayPointsTotal,TaskDistance] = GetBenefits(g_Tasks.ClassifyAttack,TargetState,TargetSchedule,...
        Targets,VehicleSchedule,NumberOfVehicles,ScaleFactor, DesiredHeadings,CommandTurnRadius,CurrentMachCmd,CellWayPointsTotal,VehicleIDs, ...
        VehicleWayCounts,ThisVehicleID,TriggerReplanFlags);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %STEP 1b: assign all of the classification/attacks with a single tour assignment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Call the Jacobi Auction or CapTransShip Algorithm - switch set before main while loop
    if (SingleAlgorithmType ==g_TypeAssignment.ItAuctionJacobi)
        % Use the Jacobi auction to assign vehicles to service Targets
        [TargetAssignment, VehicleAssigned] = RunJacobi(g_Tasks.ClassifyAttack,BenefitsClassifyAttack,TargetsToClassifyAttack, ...
            VehicleSchedule,NumberOfVehicles,NumberOfTargets);
    elseif (SingleAlgorithmType == g_TypeAssignment.ItCapTransShip)
        % In order to use the CapTransShip Algorithm, must form a row vector containing the benefits for each vehicle to service each
        % target for each task.
        
        % Number of Benefits for each task
        BenefitsClassifyAttack = BenefitsClassifyAttack * 1000;
        NumberBenefits = numel(BenefitsClassifyAttack) ;
        BenefitsContinueToSearch = ones(NumberOfVehicles,1) ;
        BenefitsClassifyCapTransShip = reshape(BenefitsClassifyAttack',NumberBenefits,1) ;
        % Form Vector : Number Of Rows = NumberOfVehicles*NumberOfTargets*NumberOfTasks + NumberOfVehicles
        BenefitsCapTransShip = [BenefitsContinueToSearch ; BenefitsClassifyCapTransShip] ;
        
        % Call the Capacitated TransShipment Algorithm to Compute Assignments
        NumberOfTasks = 1;
        [TargetAssignment,TaskAssigned,TotalBenefitsCapTransShip] = CapTranShipMex(BenefitsCapTransShip,NumberOfVehicles,NumberOfTargets,NumberOfTasks);
        VehicleAssigned = [1:1:NumberOfVehicles] ;
    else
        print('Invalid Algorithm Type Specifier in MultiAssign.m')
        return
    end % End Jacobi/CapTranShipment Algorithm Selection Section
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %STEP 1c: update waypoints and vehicle scedule with new assignments
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Store the WayPoints corresponding to the assigned task:
    AssignedVehicles = find(TargetAssignment~=0);
    for(iCountVehicle = 1:length(AssignedVehicles)),
        VehicleWayPoints{AssignedVehicles(iCountVehicle),1} = [VehicleWayPoints{AssignedVehicles(iCountVehicle),1};CellWayPointsTotal{AssignedVehicles(iCountVehicle),TargetAssignment(AssignedVehicles(iCountVehicle))}];
        
        % Update the TargetState vector and TargetSchedule
        AttackedTarget = TargetAssignment(AssignedVehicles(iCountVehicle));
        TargetState(AttackedTarget) = g_TargetStates.StateKilledNotConfirmed;
        
        TargetSchedule(2,AttackedTarget) = VehicleSchedule(2,AttackedTarget+2, ...
            find(TargetAssignment == AttackedTarget));
        
        VehicleSchedule(4,1:2,AssignedVehicles(iCountVehicle)) = [AttackedTarget 2];
        VehicleSchedule(1:3,2,AssignedVehicles(iCountVehicle)) = [VehicleWayPoints{AssignedVehicles(iCountVehicle),1}(end,1:2)'; ...
                VehicleSchedule(4,AttackedTarget+2,AssignedVehicles(iCountVehicle))];
        %print out assignment report
        if(AssignedVehicles(iCountVehicle) == ThisVehicleID),
            AssignedTaskString = g_Tasks.TaskStrings{g_Tasks.ClassifyAttack};
            TaskTime = round((TargetSchedule(2,AttackedTarget)/g_VehicleMemory(ThisVehicleID).Dynamics.VTrueFPSInit) + TimeSimulation);
            fprintf('%3.2f Vehicle #%d: will %s #%d at %3.2f\n',TimeSimulation,ThisVehicleID,AssignedTaskString,AttackedTarget,TaskTime);
        end;	%if(iCountVehicle == ThisVehicleID),
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %STEP 2: Temporarily assign all verification tasks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %STEP 2a: Calculate the Benefits for the remaining vehicles to verify targets
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    CellWayPointsTotal = cell(NumberOfVehicles,NumberOfTargets) ;
    
    [BenefitsVerify,VehicleSchedule,TargetsToClassify,CellWayPointsTotal,TaskDistance] = GetBenefits(g_Tasks.Verify,TargetState,TargetSchedule,...
        Targets,VehicleSchedule,NumberOfVehicles,ScaleFactor, DesiredHeadings,CommandTurnRadius,CurrentMachCmd,CellWayPointsTotal,VehicleIDs, ...
        VehicleWayCounts,ThisVehicleID,TriggerReplanFlags);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %STEP 2b: assign all of the verifications with a single tour assignment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Call the Jacobi Auction or CapTransShip Algorithm - switch set before main while loop
    if (SingleAlgorithmType ==g_TypeAssignment.ItAuctionJacobi)
        % Use the Jacobi auction to assign vehicles to service Targets
        [TargetAssignment, VehicleAssigned] = RunJacobi(g_Tasks.Verify,BenefitsVerify,TargetsToClassify, ...
            VehicleSchedule,NumberOfVehicles,NumberOfTargets);
    elseif (SingleAlgorithmType == g_TypeAssignment.ItCapTransShip)
        % In order to use the CapTransShip Algorithm, must form a row vector containing the benefits for each vehicle to service each
        % target for each task.
        
        % Number of Benefits for each task
        NumberBenefits = numel(BenefitsVerify) ;
        
        BenefitsContinueToSearch = ones(NumberOfVehicles,1) ;
        BenefitsVerifyCapTransShip = reshape(BenefitsVerify',NumberBenefits,1) ;
        
        % Form Vector : Number Of Rows = NumberOfVehicles*NumberOfTargets*NumberOfTasks + NumberOfVehicles
        BenefitsCapTransShip = [BenefitsContinueToSearch ; BenefitsVerifyCapTransShip] ;
        
        % Call the Capacitated TransShipment Algorithm to Compute Assignments
        NumberOfTasks = 1;
        [TargetAssignment,TaskAssigned,TotalBenefitsCapTransShip] = CapTranShipMex(BenefitsCapTransShip,NumberOfVehicles,NumberOfTargets,NumberOfTasks);
        VehicleAssigned = [1:1:NumberOfVehicles] ;
    else
        print('Invalid Algorithm Type Specifier in MultiAssign.m')
        return
    end % End Jacobi/CapTranShipment Algorithm Selection Section
    AssignedVehicles = find(TargetAssignment~=0);
    if (isempty(AssignedVehicles)),
        return;	% if no vehicles were assigned then there is nothing to do.
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %STEP 3: check relative benefits to see if assignments should be changed
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %STEP 3: Relative Bennifits loop
    %- for each assigned vehicle
    %- for each target whos state is attacked not verified
    %- calculate relative benifits
    %- find maximum relative benefit
    %- if there are benefits of a vehicle taking on a verify task (includes check for timing) make the change, if not break out of the loop
    %- if this is the first update, then freeze the prior assignment for the chossen vehicle
    %- update the changed vehicle benefits to all targets in the attacked not verified state
    %- repeat
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %STEP 3a: Build 'D' vector. This is a vector containing the calculated 
    %        distances for each assigned verification.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Vector_D = zeros(NumberOfTargets,1);
    for(iCountVehicle = 1:NumberOfVehicles),
        if(TargetAssignment(iCountVehicle) ~= 0),
            Vector_D(TargetAssignment(iCountVehicle)) = TaskDistance(iCountVehicle,TargetAssignment(iCountVehicle));
        end;
    end;
    TempAssignedPositions = zeros(NumberOfVehicles,3);
    for(iCountVehicle = 1:NumberOfVehicles),
        if(TargetAssignment(iCountVehicle) ~= 0),
            AssignedTarget = TargetAssignment(iCountVehicle);
            TempAssignedPositions(iCountVehicle,:) = [CellWayPointsTotal{iCountVehicle,AssignedTarget}(end,1:2),VehicleSchedule(4,AssignedTarget+2,iCountVehicle)];
        end;
    end;		%for(iCountVehicle = 1:NumberOfVehicles),
    while (1),
        AssignmentChanged = 0;	% has the assignment changed 0-no, 1-yes
        
        %%%%% TODO: UPDATE Vector_D
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %STEP 3.b: Build relative benefits matrix
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %build relative benefits matrix
        Matrix_b = zeros(NumberOfVehicles,NumberOfTargets);
        TempVehicleSchedule = VehicleSchedule;
        TempCellWayPointsTotal = cell(NumberOfVehicles,NumberOfTargets);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %STEP 3.b.1: calculate relative benefits based on freezing each vehicles temporary assignment.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for(iCountVehicle = 1:NumberOfVehicles),				
            if(TargetAssignment(iCountVehicle) ~= 0),
                %temporaraly freeze assignment for this vehicle
                TempTargetState = TargetState;
                TempTargetSchedule = TargetSchedule;
                % Update the TargetState vector and TargetSchedule
                AssignedTarget = TargetAssignment(iCountVehicle);
                TempTargetState(AssignedTarget) = g_TargetStates.StateConfirmedKill;
                TempTargetSchedule(g_Tasks.Verify,AssignedTarget) = VehicleSchedule(g_Tasks.Attack,AssignedTarget+2,iCountVehicle);
                TempVehicleSchedule(4,1:2,iCountVehicle) = [AssignedTarget g_Tasks.Verify];
                TempVehicleSchedule(1:3,2,iCountVehicle) = TempAssignedPositions(iCountVehicle,:);
                %only current vehicle has changed postion so only calculate benefits for it.
                TempNumberOfVehicles = 1;
                TempVehicleScheduleOne = TempVehicleSchedule(:,:,iCountVehicle);
                TempCellWayPointsTotalOne = cell(1,NumberOfTargets);
                [TempBenefitsVerify,TempVehicleScheduleOne,TempTargetsToClassify,TempCellWayPointsTotalOne,TempTaskDistance] = ...
                    GetBenefits(g_Tasks.Verify,TempTargetState,TempTargetSchedule,Targets,TempVehicleScheduleOne,TempNumberOfVehicles,ScaleFactor, ...
                    DesiredHeadings,CommandTurnRadius,CurrentMachCmd,TempCellWayPointsTotalOne,VehicleIDs,VehicleWayCounts,ThisVehicleID,TriggerReplanFlags);
                TempCellWayPointsTotal(iCountVehicle,:) = TempCellWayPointsTotalOne;
                TempVehicleSchedule(:,:,iCountVehicle)=TempVehicleScheduleOne;
                for(iCountTarget = 1:NumberOfTargets),
                    if(TempTargetState(iCountTarget) == g_TargetStates.StateKilledNotConfirmed),
                        Matrix_b(iCountVehicle,iCountTarget) = Vector_D(iCountTarget) - TempTaskDistance(1,iCountTarget);
                    end;	%if(TargetState(iCountTarget) == g_TargetStates.StateKilledNotConfirmed),
                end;	%for(iCountTarget = 1:NumberOfTargets),
            end;	%if(TargetAssignment(iCountVehicle) ~= 0),
        end;	%for(iCountVehicle = 1:NumberOfVehicles),
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %STEP 3c: Find assignment based on maximum relative benefit
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [MaxColumns_b,MaxRowIndicies_b] = max(Matrix_b);
        [Max_b,MaxTargetIndex_b] = max(MaxColumns_b);
        if(Max_b > 0),
            MaxVehicle_b = MaxRowIndicies_b(MaxTargetIndex_b);
        else,
            MaxVehicle_b = 0;
        end;
        VehicleIndex = MaxVehicle_b;
        if(VehicleIndex > 0),
            AssignmentChanged = 1;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %STEP 3d: if this vehicle was not assigned before, update waypoints for the first assignment
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if(VehicleSchedule(4,1,VehicleIndex) == 0),	% not yet assigned
                AssignedTarget = TargetAssignment(VehicleIndex);
                VehicleWayPoints{VehicleIndex,1} = [VehicleWayPoints{VehicleIndex,1};CellWayPointsTotal{VehicleIndex,AssignedTarget}];
                % Update the TargetState vector and TargetSchedule
                TargetState(AssignedTarget) = g_TargetStates.StateConfirmedKill;
                TargetSchedule(g_Tasks.Verify,AssignedTarget) = VehicleSchedule(g_Tasks.Verify,AssignedTarget+2,VehicleIndex);
                VehicleSchedule(4,1:2,VehicleIndex) = [AssignedTarget g_Tasks.Verify];
                VehicleSchedule(1:3,2,VehicleIndex) = [VehicleWayPoints{VehicleIndex,1}(end,1:2)';VehicleSchedule(4,AssignedTarget+2,VehicleIndex)];
                %print out assignment report
                if(VehicleIDs(VehicleIndex) == ThisVehicleID),
                    AssignedTaskString = g_Tasks.TaskStrings{g_Tasks.Verify};
                    TaskTime = round((TargetSchedule(g_Tasks.Verify,AssignedTarget)/g_VehicleMemory(ThisVehicleID).Dynamics.VTrueFPSInit) + TimeSimulation);
                    fprintf('%3.2f Vehicle #%d: will %s #%d at %3.2f\n',TimeSimulation,ThisVehicleID,AssignedTaskString,AssignedTarget,TaskTime);
                end;	%if(iCountVehicle == ThisVehicleID),
            end;	%if(VehicleSchedule(4,1,VehicleIndex) == 0),
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %STEP 3e: update waypoints for the assignment
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            AssignedTarget = MaxTargetIndex_b;
            %unassign old assignment
            AssignmentIndexOld = find(TargetAssignment==AssignedTarget);
            TargetAssignment(AssignmentIndexOld) = 0;
            TargetAssignment(VehicleIndex) = AssignedTarget;
            VehicleWayPoints{VehicleIndex,1} = [VehicleWayPoints{VehicleIndex,1};TempCellWayPointsTotal{VehicleIndex,AssignedTarget}];
            % Update the TargetState vector and TargetSchedule
            TargetState(AssignedTarget) = g_TargetStates.StateConfirmedKill;
            TargetSchedule(g_Tasks.Verify,AssignedTarget) = TempVehicleSchedule(g_Tasks.Verify,AssignedTarget+2,VehicleIndex);
            VehicleSchedule(4,1:2,VehicleIndex) = [AssignedTarget g_Tasks.Verify];
            VehicleSchedule(1:3,2,VehicleIndex) = [VehicleWayPoints{VehicleIndex,1}(end,1:2)';TempVehicleSchedule(4,AssignedTarget+2,VehicleIndex)];
            TempAssignedPositions(VehicleIndex,:) =  [VehicleWayPoints{VehicleIndex,1}(end,1:2),TempVehicleSchedule(4,AssignedTarget+2,VehicleIndex)];
            %print out assignment report
            if(VehicleIDs(VehicleIndex) == ThisVehicleID),
                AssignedTaskString = g_Tasks.TaskStrings{g_Tasks.Verify};
                TaskTime = round((TargetSchedule(g_Tasks.Verify,AssignedTarget)/g_VehicleMemory(ThisVehicleID).Dynamics.VTrueFPSInit) + TimeSimulation);
                fprintf('%3.2f Vehicle #%d: will %s #%d at %3.2f\n',TimeSimulation,ThisVehicleID,AssignedTaskString,AssignedTarget,TaskTime);
            end;	%if(iCountVehicle == ThisVehicleID),
        else,	%if(VehicleIndex > 0),
            %if there are any verifies not assigned, assign them
            for(iCountVehicle = 1:NumberOfVehicles),				
                if((VehicleSchedule(4,1,iCountVehicle) == 0)&(TargetAssignment(iCountVehicle) ~= 0)),
                    AssignedTarget = TargetAssignment(iCountVehicle);
                    VehicleWayPoints{iCountVehicle,1} = [VehicleWayPoints{iCountVehicle,1};CellWayPointsTotal{iCountVehicle,AssignedTarget}];
                    % Update the TargetState vector and TargetSchedule
                    TargetState(AssignedTarget) = g_TargetStates.StateConfirmedKill;
                    TargetSchedule(g_Tasks.Verify,AssignedTarget) = VehicleSchedule(g_Tasks.Verify,AssignedTarget+2,iCountVehicle);
                    VehicleSchedule(4,1:2,iCountVehicle) = [AssignedTarget g_Tasks.Verify];
                    VehicleSchedule(1:3,2,iCountVehicle) = [VehicleWayPoints{iCountVehicle,1}(end,1:2)';VehicleSchedule(4,AssignedTarget+2,iCountVehicle)];
                    %print out assignment report
                    if(VehicleIDs(iCountVehicle) == ThisVehicleID),
                        AssignedTaskString = g_Tasks.TaskStrings{g_Tasks.Verify};
                        TaskTime = round((TargetSchedule(g_Tasks.Verify,AssignedTarget)/g_VehicleMemory(ThisVehicleID).Dynamics.VTrueFPSInit) + TimeSimulation);
                        fprintf('%3.2f Vehicle #%d: will %s #%d at %3.2f\n',TimeSimulation,ThisVehicleID,AssignedTaskString,AssignedTarget,TaskTime);
                    end;	%if(iCountVehicle == ThisVehicleID),
                end;	%if(VehicleSchedule(4,1,iCountVehicle) == 0),
            end;	%for(iCountVehicle = 1:NumberOfVehicles),
            AssignmentChanged = 0;	%need to break out of loop
        end;	%if(VehicleIndex > 0),
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %STEP 3f: if no assignments were made break otherwise repeat the loop
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(AssignmentChanged == 0),
            break;	%if the assignment has not changed break out of the loop
        end;
    end;	%while (1),
otherwise,	
end;	%switch(AlgorithmType)

%******************************************************************************************************
%g_VehicleMemory(ThisVehicleID).CooperationManager.WaypointMemory = VehicleWayPoints;    % modified by Schumacher 5/30/02
g_VehicleMemory(ThisVehicleID).CooperationManager.WaypointMemory = cell(g_MaxNumberVehicles,1);
for(CountVehicles=1:NumberVehicles),
    g_VehicleMemory(ThisVehicleID).CooperationManager.WaypointMemory{VehicleIDs(CountVehicles)} = VehicleWayPoints{CountVehicles};
end;
%******************************************************************************************************
NumberVehicles = size(VehicleWayPoints,1);
for(CountVehicles=1:NumberVehicles),
    if(~isempty(VehicleWayPoints{CountVehicles})),
        VehicleWayPoints{CountVehicles}(end,g_WaypointDefinitions.WaypointType) = VehicleWayPoints{CountVehicles}(end,g_WaypointDefinitions.WaypointType) + g_WaypointTypes.EndTask;
        InitialWaypoint = [Vehicles(CountVehicles,1),Vehicles(CountVehicles,2),g_DefaultWaypointAltitude,CurrentMachCmd,1,realmax,realmax,realmax,0,g_WaypointTypes.StartPoint,-1,0];
        %FinalWaypoint = AddFinalWaypoint(VehicleWayPoints{CountVehicles},CurrentMachCmd);
        FinalWaypoint = [];
        VehicleWayPoints{CountVehicles}=[InitialWaypoint;VehicleWayPoints{CountVehicles};FinalWaypoint;FinalWaypoint];
    end;
end;
return;     %MultiTaskAssign



function FinalWaypoint = AddFinalWaypoint(WaypointArray,CurrentMachCmd)
%final waypoint to give vehicle someplace to go to, without changing heading
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% calculate and save final waypoints                                 %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global g_WaypointTypes;
global g_DefaultWaypointAltitude;

WaypointPrevious = WaypointArray(end,:);
FinalWaypointX = WaypointPrevious(1) + 1e10;
FinalWaypointY = WaypointPrevious(2) + 1e10;
NumberRowsWaypoints = size(WaypointArray,1);
Denomentator = WaypointPrevious(2)-WaypointArray(end-1,2);
DifferenceWaypointX = WaypointPrevious(1)-WaypointArray(end-1,1);
DifferenceWaypointY = WaypointPrevious(2)-WaypointArray(end-1,2);
if((DifferenceWaypointX~=0)&(DifferenceWaypointY~=0)),
    if(DifferenceWaypointX~=0),
        if(DifferenceWaypointY~=0),
            Slope = DifferenceWaypointY/DifferenceWaypointX;
            FinalWaypointY = WaypointPrevious(2) + Slope*(FinalWaypointX - WaypointPrevious(1));
        else,	%if(DifferenceWaypointX~=0)
            FinalWaypointY = 0;
        end;	%if(DifferenceWaypointX~=0)
    else,	%if(DifferenceWaypointX~=0)
        FinalWaypointX = 0;
    end;	%if(DifferenceWaypointX~=0)
else,	%if((DifferenceWaypointX~=0)&(DifferenceWaypointY~=0))
    Denomentator = WaypointPrevious(2)-WaypointArray(end-2,2);
    DifferenceWaypointX = WaypointPrevious(1)-WaypointArray(end-2,1);
    DifferenceWaypointY = WaypointPrevious(2)-WaypointArray(end-2,2);
    if(DifferenceWaypointX~=0),
        if(DifferenceWaypointY~=0),
            Slope = DifferenceWaypointY/DifferenceWaypointX;
            FinalWaypointY = WaypointPrevious(2) + Slope*(FinalWaypointX - WaypointPrevious(1));
        else,	%if(DifferenceWaypointX~=0)
            FinalWaypointY = 0;
        end;	%if(DifferenceWaypointX~=0)
    else,	%if(DifferenceWaypointX~=0)
        FinalWaypointX = 0;
    end;	%if(DifferenceWaypointX~=0)
end;	%if((DifferenceWaypointX~=0)&(DifferenceWaypointY~=0))
FinalWaypoint = [FinalWaypointX,FinalWaypointY,g_DefaultWaypointAltitude,CurrentMachCmd,1,realmax,realmax,realmax,0,g_WaypointTypes.EndPoint,-1,0]; %if vehicles keep going after classifying the target they go here
return;     %AddFinalWaypoint
