function [OutputVector] = MultiTaskAssignIO(AlgorithmType,InputVector,Time)
%MultiTaskAssignIO - used to setup the inputs to the MultiTaskAssign function 
%
%  Inputs:
%    AlgorithmType - The type of algoritm to use:
%      'JacobiAuction' - use the Jacobi auction algorithm  
%      'CapTransShip' - use Capacitative Transshipment network flow algorithm
%    InputVector -   
%        InputVector(...) - a vectorized matrix containing Vehicle ID, x,y positions and psi for all the vehicles
%        InputVector(...) - a vector containing finished flag for all the vehicles
%        InputVector(...) - vehicle ID
%        InputVector(...) - a vectorized matrix containing x,y,z positions, type, psi and alive for all the targets
%        InputVector(...) - a vector containing the status of all the targets
%        InputVector(...) - "DesiredHeadingVector(1-4)" a 'vectorized' matrix containing desired headings to the targets, calculated by all of the vehicles size = (g_MaxNumberTargets*g_MaxNumberDesiredHeadings) 
%        InputVector(...) - "CommandedTurnRadius" 
%        InputVector(...) - "current waycount" 
%        InputVector(...) - "Current Waypoint Type" 
%        InputVector(...) - "TriggerReplanFlags" 
%
%
%  Outputs:
%    OutputVector - ?????????
%

%  AFRL/VACA
%  March 2002 - Created and Debugged - RAS
%  February 2003 - change calls to MinimumDistance, BDAHeading, and AttackHeading function to calls to TrajectoryMEX
% April 2004 - added new assignment time output  - RAS


global g_Debug; if(g_Debug==1),disp('MultiTaskAssignIO.m');end; 

global g_MaxNumberVehicles;
global g_MaxNumberTargets;
global g_MaxNumberDesiredHeadings;
global g_NumberTargetOutputs;
global g_TargetTypes;
global g_TargetStates;
global g_WaypointTypes;
global g_WaypointDefinitions;
global g_VehicleMemory;
global g_Tasks;
global g_OptionBackToSearch;
global g_EnableVehicle;
global g_DefaultMach;
global g_SaveAlgorithmTimeFlag;
global g_SaveAlgorithmTime;
global g_MonteCarloMetrics;

%%%%%%%%%%%%%%%%%%%%% TODO %%%%%%%%%%%%%%%%%%%%%%
global g_DefaultWaypointAltitude;
CurrentMachCmd = g_DefaultMach;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initialize output vector
NewAssignmentTime = 0;
OutputVector = [0,0,NewAssignmentTime]; %TODO:: haven't decided on output, yet. Except third value which is new assignment time.

%set up variables used to parse input vector
VehicleColumns = 4; % ID x,y positions and psi
Vehicles = zeros(g_MaxNumberVehicles,VehicleColumns); % ID x,y position, psi
VehicleFinishedFlags = zeros(g_MaxNumberVehicles,1); 

Targets = zeros(g_MaxNumberTargets,4); %x,y position, psi, value
TargetAliveFlags = zeros(g_MaxNumberTargets,1); 
TargetColumns = g_NumberTargetOutputs; %x,y,z positions, type, psi and alive
TargetState = zeros(g_MaxNumberTargets,1);

% parse input vector
%vehicles - 
iFirstRow = 1;
iCurrentVectorSize = g_MaxNumberVehicles*VehicleColumns;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
VehiclesVector = InputVector(iFirstRow:iLastRow);
VehiclesMatrix = reshape(VehiclesVector,VehicleColumns,g_MaxNumberVehicles)';
Vehicles = VehiclesMatrix;
Vehicles(:,4) = HeadingToAngle(Vehicles(:,4)) * pi/180;

%waypoint index
%iCurrentVectorSize = g_MaxNumberVehicles;
iFirstRow = iFirstRow + iCurrentVectorSize;
iCurrentVectorSize = g_MaxNumberVehicles;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
VehicleWayCounts = InputVector(iFirstRow:iLastRow);

%Trigger Replan Flags
iFirstRow = iLastRow + 1;
iCurrentVectorSize = g_MaxNumberVehicles;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
TriggerReplanFlags = InputVector(iFirstRow:iLastRow);

%vehicles - alive
iFirstRow = iFirstRow + iCurrentVectorSize;
iCurrentVectorSize = g_MaxNumberVehicles;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
VehicleFinishedFlags = InputVector(iFirstRow:iLastRow);

%vehicles ID
iFirstRow = iFirstRow + iCurrentVectorSize;
iCurrentVectorSize = 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
VehicleID = InputVector(iFirstRow:iLastRow);
if(VehicleID<=0),
    return;
end;
%targets - 
iFirstRow = iFirstRow + iCurrentVectorSize;
iCurrentVectorSize = g_MaxNumberTargets*TargetColumns;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
TargetsVector = InputVector(iFirstRow:iLastRow);
TargetsMatrix = reshape(TargetsVector,TargetColumns,g_MaxNumberTargets)';
Targets(:,1:3) = TargetsMatrix(:,[1,2,5]);  
TargetAliveFlags = TargetsMatrix(:,[6]);  

%targets - state
iFirstRow = iFirstRow + iCurrentVectorSize;
iCurrentVectorSize = g_MaxNumberTargets;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
TargetState = InputVector(iFirstRow:iLastRow);

%desired headings
iFirstRow = iFirstRow + iCurrentVectorSize;
iCurrentVectorSize = g_MaxNumberTargets * g_MaxNumberDesiredHeadings;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
DesiredHeadingVector = InputVector(iFirstRow:iLastRow);
DesiredHeadingMatrix = reshape(DesiredHeadingVector,g_MaxNumberTargets,g_MaxNumberDesiredHeadings);

%Command Turn Radius
iFirstRow = iFirstRow + iCurrentVectorSize;
iCurrentVectorSize = 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
CommandTurnRadius = InputVector(iFirstRow:iLastRow);

%Current Waycount
iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
CurrentWaycount = (InputVector(iFirstRow:iLastRow)+1);

%Current Waypoint Type
iFirstRow = iLastRow + 1;
iLastRow = iFirstRow + iCurrentVectorSize - 1;
CurrentWaypointType = InputVector(iFirstRow:iLastRow);

TargetValues = zeros(g_MaxNumberTargets,1);
for(CountTargets = 1:g_MaxNumberTargets),
    if(TargetsMatrix(CountTargets,4) ~= 0),
        TargetValues(CountTargets) = g_TargetTypes(TargetsMatrix(CountTargets,4)).TargetValue;
    else,
        TargetValues(CountTargets) = 0;
    end;
end;
Targets(:,4) = TargetValues;

%remove dead vehicles
VehiclesIn = [];
VehiclesInIndex = zeros(g_MaxNumberVehicles,1);
CountIndex = 1;
for(CountVehicles = 1:g_MaxNumberVehicles),
    if((VehicleFinishedFlags(CountVehicles)==0)&(g_EnableVehicle(CountVehicles)>0)&(Vehicles(CountVehicles,1)>0)),
        VehiclesIn = [VehiclesIn;Vehicles(CountVehicles,:)];
        VehiclesInIndex(CountVehicles) = CountIndex;
        CountIndex = CountIndex + 1;
    end;	%if(VehicleFinishedFlags(CountVehicles)==0),
end;

if( isempty(VehiclesIn) )
    disp('WARNING::MultiTaskAssignIO::No valid vehicle data found for assignment!');
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG ONLY %%%%%%%%%%%%%%%%%%%%%%%%%
% if((Time >= 5.0)&(VehicleID == 7))
% 	TempDebug = 0;
% end;
%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG ONLY %%%%%%%%%%%%%%%%%%%%%%%%%

if(g_SaveAlgorithmTimeFlag == 1), 
    tic
end;

[VehicleWayPoints,VehicleSchedule,AllAssignments,SummaryAssignmentBenefitTotal,SummaryAssignmentDistanceTotal,SummaryAssignmentExecutionTime] = ...
    MultiTaskAssign(VehiclesIn,Targets,TargetState',DesiredHeadingMatrix,CommandTurnRadius,AlgorithmType,Time,VehicleWayCounts,VehicleID,TriggerReplanFlags);

if(g_SaveAlgorithmTimeFlag == 1),
    g_SaveAlgorithmTime = [g_SaveAlgorithmTime;toc];
end;


% save data during monte carlo runs
if(g_MonteCarloMetrics.SaveMultipleTaskDataFlag),
    if((VehicleFinishedFlags(VehicleID)==0)&(Time > g_MonteCarloMetrics.LastMultipleTaskSaveTime)), 	%limit the times that this is saved.
        % MATLAB Data file
        g_MonteCarloMetrics.LastMultipleTaskSaveTime = Time;
        g_MonteCarloMetrics.MultipleTaskSaveCount = g_MonteCarloMetrics.MultipleTaskSaveCount + 1;
        NumberVehicles = size(VehiclesIn,1);
        NumberTargets = 0;
        for(CountTargets=1:g_MaxNumberTargets),
            if((TargetState(CountTargets)>=g_TargetStates.StateDetectedNotClassified)&(TargetState(CountTargets)<=g_TargetStates.StateKilledNotConfirmed)),
                NumberTargets = NumberTargets +1;
            end;
        end;
        BaseFileName = sprintf('%s_%d_%d_%d',g_MonteCarloMetrics.MultipleTaskSaveFile,NumberVehicles,NumberTargets,g_MonteCarloMetrics.MultipleTaskSaveCount);
        FileName = sprintf('%s%s.mat',g_MonteCarloMetrics.DirectoryName,BaseFileName);
        FileNameNoDir = sprintf('%s.mat',BaseFileName);
        save(FileName,'Time','VehicleID','VehiclesIn','Targets','TargetState','DesiredHeadingMatrix', ...
            'CommandTurnRadius','AlgorithmType','AllAssignments','VehicleWayPoints','VehicleSchedule', ...
            'SummaryAssignmentBenefitTotal','SummaryAssignmentDistanceTotal','SummaryAssignmentExecutionTime');
        %Graph Assignment Input File		
        FileName = sprintf('%s%s.dat',g_MonteCarloMetrics.DirectoryName,BaseFileName);
        FileNameNoDir = sprintf('%s.dat',BaseFileName);
        %add lines to the batch file to generate the trees
        fidTrees = fopen([g_MonteCarloMetrics.DirectoryName,'GenerateTrees.bat'],'a');
        fprintf(fidTrees,'call ..\\..\\TestGraphAssignment %s\r\n',FileNameNoDir);
        NewStatisticsFileName = sprintf('%s_Stat',BaseFileName);
        fprintf(fidTrees,'move Statistics.m %s.m\r\n',NewStatisticsFileName);
        NewOptimalFileName = sprintf('%s_Optimal',BaseFileName);
        fprintf(fidTrees,'move OptimalAssignment.m %s.m\r\n',NewOptimalFileName);
        fclose(fidTrees);
        fid = fopen(FileName,'a');
        fprintf(fid,'### VERSION ###\n');
        fprintf(fid,'%d\n',g_MonteCarloMetrics.MultipleTaskSaveFileVersion);
        fprintf(fid,'### VEHICLES V: ID North East Altitude Psi  ###\r\n');
        NumberVehicles = size(VehiclesIn,1);
        for(CountVehicle=1:NumberVehicles),
            fprintf(fid,'V: %d %g %g %g %g\n',VehiclesIn(CountVehicle,1),VehiclesIn(CountVehicle,2),VehiclesIn(CountVehicle,3),g_DefaultWaypointAltitude,VehiclesIn(CountVehicle,4));
        end;
        fprintf(fid,'### TARGETS T: ID North East Psi TaskRequired Heading1 Heading2 Heading3 Heading4 ###\r\n');
        NumberTargets = size(Targets,1);
        for(CountTargets=1:NumberTargets),
            if((TargetState(CountTargets)>g_TargetStates.StateNotDetected)&(TargetState(CountTargets)<g_TargetStates.StateConfirmedKill)),
                TaskRequired = FindRequiredTask(TargetState(CountTargets));
                fprintf(fid,'T: %d %g %g %g %d %g %g %g %g\r\n',CountTargets,Targets(CountTargets,1),Targets(CountTargets,2), ...
                    Targets(CountTargets,3),TaskRequired, ...
                    DesiredHeadingMatrix(CountTargets,1),DesiredHeadingMatrix(CountTargets,2), ...
                    DesiredHeadingMatrix(CountTargets,3),DesiredHeadingMatrix(CountTargets,4));
            end;
        end;		%for(CountTargets=1:NumberTargets),
        fclose(fid);
    end;		%if(Time > g_MonteCarloMetrics.LastMultipleTaskSaveTime),
end;		%if(g_MonteCarloMetrics.SaveMultipleTaskDataFlag),



g_VehicleMemory(VehicleID).RouteManager.AssignedTarget = -1;
g_VehicleMemory(VehicleID).RouteManager.AssignedTask = -1;

VehiclePostionX = Vehicles(VehicleID,2);
VehiclePostionY = Vehicles(VehicleID,3);
VehiclePostionZ = g_DefaultWaypointAltitude;
VehiclePostionPsi = Vehicles(VehicleID,4);

ThisVehicleIndex = VehiclesInIndex(VehicleID);
if(ThisVehicleIndex ~= 0.0),
    if(~isempty(VehicleWayPoints{ThisVehicleIndex})),	%has this vehicle been assigned?
        if (g_VehicleMemory(VehicleID).RouteManager.UsingOriginalSearchWaypoints~=0), %using original search waypoints? if so, save original search waypoints
            g_VehicleMemory(VehicleID).RouteManager.UsingOriginalSearchWaypoints = 0;
            if (CurrentWaycount > g_VehicleMemory(VehicleID).RouteManager.OffsetToAlternateIndex),
                g_VehicleMemory(VehicleID).RouteManager.AlternateWaypointIndex = g_VehicleMemory(VehicleID).RouteManager.AlternateWaypointIndex + (CurrentWaycount - g_VehicleMemory(VehicleID).RouteManager.OffsetToAlternateIndex) - 1;
                g_VehicleMemory(VehicleID).RouteManager.LastSearchX = VehiclePostionX;
                g_VehicleMemory(VehicleID).RouteManager.LastSearchY = VehiclePostionY;
                g_VehicleMemory(VehicleID).RouteManager.LastSearchZ = VehiclePostionZ;
                g_VehicleMemory(VehicleID).RouteManager.LastSearchPsi = VehiclePostionPsi;
            end;	%if (CurrentWaycount > g_VehicleMemory(VehicleID).RouteManager.OffsetToAlternateIndex),
        end;	%if (g_VehicleMemory(VehicleID).RouteManager.UsingOriginalSearchWaypoints~=0),
        % add back to search waypoints
        PlotCircles = 0.0;
        SensorStandOff = 0.0;
        ToLastSearchAngle = (g_VehicleMemory(VehicleID).RouteManager.LastSearchPsi);
        WayPointsBackToSearch = [];
        WaypointID = VehicleID;
        WaypointsCurrent = VehicleWayPoints{ThisVehicleIndex};
        VehiclePostionX = WaypointsCurrent(end,1);
        VehiclePostionY = WaypointsCurrent(end,2);
        FinalHeading = VehicleSchedule(3,2,ThisVehicleIndex);
        
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
        CommandSensorStandOff = -1;		%-1 use default
        VehicleState = [VehicleID;VehiclePostionX;VehiclePostionY;g_DefaultWaypointAltitude;FinalHeading;CommandSensorStandOff;CommandTurnRadius;VehicleType;CurrentETA];
        
        TargetID = -1;	% no name required
        TargetHeading = 0;
        Task = g_Tasks.ContinueSearching;
        TargetScheduleLength = 0.0;
        TargetState = [TargetID;TargetPositionX;TargetPositionY;TargetHeading;Task;TargetScheduleLength];
        
        TargetDesiredHeadings = ToLastSearchAngle;
        LengthenPaths = 0;
        [WayPointsBackToSearch,MinDistance,FinalHeading] = TrajectoryMEX(VehicleState,TargetState,TargetDesiredHeadings,LengthenPaths);
        WayPointsBackToSearch = WayPointsBackToSearch([2:end],:);
        
        WayPointsBackToSearch(:,g_WaypointDefinitions.WaypointType) = g_WaypointTypes.Search;
        SaveWaypoints = [VehicleWayPoints{ThisVehicleIndex}; WayPointsBackToSearch];
        [iRows,iCols] = size(g_VehicleMemory(WaypointID).RouteManager.AlternateWaypoints);
        [iRowsNewWaypoints,iColsNewWaypoints] = size(SaveWaypoints);
        g_VehicleMemory(VehicleID).RouteManager.OffsetToAlternateIndex = iRowsNewWaypoints;
        g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints = [SaveWaypoints; ...
                g_VehicleMemory(WaypointID).RouteManager.AlternateWaypoints(((g_VehicleMemory(WaypointID).RouteManager.AlternateWaypointIndex):iRows),:)];			
        DistanceToFirstSearchPoint = sqrt((g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(iRowsNewWaypoints+1,g_WaypointDefinitions.PositionY) - ...
            g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(iRowsNewWaypoints,g_WaypointDefinitions.PositionY))^2 +  ...
            (g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(iRowsNewWaypoints+1,g_WaypointDefinitions.PositionX) - ...
            g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(iRowsNewWaypoints,g_WaypointDefinitions.PositionX))^2);
        g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(iRowsNewWaypoints+1,g_WaypointDefinitions.SegmentLength) = DistanceToFirstSearchPoint;
        %moved waypointflags entry to allow for process delay
        %WaypointFlags(VehicleID) = 1.0;
        NewAssignmentTime = Time;
    else,	%if(~isempty(VehicleWayPoints{ThisVehicleIndex})),	%has this vehicle been assigned?
        % if the vehicle does not have an assignment, but was previously assigned implement alternate route waypoints
        if(rem(CurrentWaypointType,g_WaypointTypes.QualifierMultiple) == g_WaypointTypes.Search),
            g_VehicleMemory(VehicleID).RouteManager.UsingOriginalSearchWaypoints=1;
        end;
        if(g_VehicleMemory(VehicleID).RouteManager.UsingOriginalSearchWaypoints==0),
            g_VehicleMemory(VehicleID).RouteManager.UsingOriginalSearchWaypoints = 1;
            PlotCircles = 0.0;
            SensorStandOff = 0.0;
            %ToLastSearchAngle = pi + (g_VehicleMemory(VehicleID).RouteManager.LastSearchPsi);
            ToLastSearchAngle = g_VehicleMemory(VehicleID).RouteManager.LastSearchPsi;
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
            CommandSensorStandOff = -1;		%-1 use default
            VehicleState = [VehicleID;VehiclePostionX;VehiclePostionY;g_DefaultWaypointAltitude;VehiclePostionPsi;CommandSensorStandOff;CommandTurnRadius;VehicleType;CurrentETA];
            
            TargetID = -1;	% no name required
            TargetHeading = 0;
            Task = g_Tasks.ContinueSearching;
            TargetScheduleLength = 0.0;
            TargetState = [TargetID;TargetPositionX;TargetPositionY;TargetHeading;Task;TargetScheduleLength];
            
            TargetDesiredHeadings = ToLastSearchAngle;
            LengthenPaths = 0;
            [WayPointsBackToSearch,MinDistance,FinalHeading] = TrajectoryMEX(VehicleState,TargetState,TargetDesiredHeadings,LengthenPaths);
            WayPointsBackToSearch = WayPointsBackToSearch([2:end],:);
            
            
            InitialWayPoint = [VehiclePostionX,VehiclePostionY,VehiclePostionZ,CurrentMachCmd,1,realmax,realmax,realmax,0,g_WaypointTypes.StartPoint,-1,0];	% starting position (only used as a place holder)
            if(~isempty(WayPointsBackToSearch)),
                SaveWaypoints = [InitialWayPoint;WayPointsBackToSearch];
            else,
                SaveWaypoints = InitialWayPoint;
            end;
            SaveWaypoints(:,g_WaypointDefinitions.WaypointType) = g_WaypointTypes.Search;
            [iRows,iCols] = size(g_VehicleMemory(WaypointID).RouteManager.AlternateWaypoints);
            [iRowsNewWaypoints,iColsNewWaypoints] = size(SaveWaypoints);
            g_VehicleMemory(VehicleID).RouteManager.OffsetToAlternateIndex = iRowsNewWaypoints;
            g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints = [SaveWaypoints; ...
                    g_VehicleMemory(WaypointID).RouteManager.AlternateWaypoints(((g_VehicleMemory(WaypointID).RouteManager.AlternateWaypointIndex):iRows),:)];			
            DistanceToFirstSearchPoint = sqrt((g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(iRowsNewWaypoints+1,g_WaypointDefinitions.PositionY) - ...
                g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(iRowsNewWaypoints,g_WaypointDefinitions.PositionY))^2 + ...
                (g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(iRowsNewWaypoints+1,g_WaypointDefinitions.PositionX) - ...
                g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(iRowsNewWaypoints,g_WaypointDefinitions.PositionX))^2);
            g_VehicleMemory(VehicleID).CooperationManager.PendingWaypoints(iRowsNewWaypoints+1,g_WaypointDefinitions.SegmentLength) = DistanceToFirstSearchPoint;
            %moved waypointflags entry to allow for process delay
            %WaypointFlags(VehicleID) = 1.0;
            NewAssignmentTime = Time;
        end;	%if(g_VehicleMemory(VehicleID).RouteManager.UsingOriginalSearchWaypoints==0),
    end;	%if(~isempty(VehicleWayPoints{ThisVehicleIndex})),	%has this vehicle been assigned?
end;	%if((ThisVehicleIndex ~= 0.0)
OutputVector(3) = NewAssignmentTime;
return; %MultiTaskAssignIO
