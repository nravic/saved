%InitializeGlobals - this script sets up the MultiUAV global simulation variables and structures 
%
%  Inputs:
%    (none) 
%
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  May 2001 - Created and Debugged - RAS
%  October 2001 - added new global constants - RAS
%  September 2002 - reaaranged and added new globals - RAS

disp('*** InitializeGlobals:: Initializing Global Variables ***');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Global Constants (1) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (other constants below have ordering issue that %% must be resolved later...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global g_MilesToFeet; g_MilesToFeet = 5280; % 1 mi in ft
global g_MetersToFeet; g_MetersToFeet = 3.280839895;

%this is the distance from the vehicle to the leading edge of the sensor	NOTE: changing this number doesn't change the sensor
global g_SensorLeadingEdge_ft; g_SensorLeadingEdge_ft = 1000.0*g_MetersToFeet;	%3280.839895 ft
%this is the distance from the vehicle to the trailing edge of the sensor	NOTE: changing this number doesn't change the sensor
global g_SensorTrailingEdge_ft; g_SensorTrailingEdge_ft = 750.0*g_MetersToFeet;		%2460.62992125 ft
% Width of search footprint in meters.  This must match the value in CreateVehicleGraphic.m
global g_SensorWidth_m; g_SensorWidth_m = 600.0;		%1.968503937000000e+003 ft
global g_SensorWidth_ft; g_SensorWidth_ft = g_SensorWidth_m*g_MetersToFeet;		%1.968503937000000e+003 ft

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%  MATLAB environment specifications   %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine how to edit if we are not using the resource sucking JVM GUI...
global g_UserDefinedEditor; g_UserDefinedEditor = '';
if ~isempty( javachk('mwt', 'The MATLAB Editor') )
    if isunix 
        g_UserDefinedEditor = 'uxterm -bg black -fg lightgray -fn 10x20 -e vim';
        % NOTE: xterm does not correctly send SIGTERM when widget closes window
        %g_UserDefinedEditor = 'xterm -bg black -fg lightgray -fn 10x20 -e vim';
    else
        g_UserDefinedEditor = 'notepad';
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% Debugging and Algorithm Modification %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set g_Debug to a non-zero value to enable global debug printouts
global g_Debug; g_Debug=0;
global g_ASSERT_STATUS; g_ASSERT_STATUS=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%         Simulation Control           %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set g_PauseAfterEachTimeStep to a nonzero number to cause the simulation to go into pause mode,
% i.e. set_param('MultiUAV', 'SimulationCommand', 'pause'), at the end of each major time step.
%NOTE: Simulink will not pause if it was started with the "sim" command.
global g_PauseAfterEachTimeStep; g_PauseAfterEachTimeStep = 0;
global g_TimePrintInterval_sec; g_TimePrintInterval_sec = 10.0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%    Vehicle Setup       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% g_MaxNumberVehicles must contain number of the vehicle blocks in the simulation
global g_MaxNumberVehicles; g_MaxNumberVehicles = 8;
%set the values in g_DefaultEnableVehicle to enable or disable vehicles
global g_ActiveVehicles;	g_ActiveVehicles = 8; 
global g_EnableVehicleDefault;
g_EnableVehicleDefault = zeros(g_MaxNumberVehicles,1); g_EnableVehicleDefault([1:g_ActiveVehicles])=[1:g_ActiveVehicles];	% only enable active vehicles
%vehicles are enabled if the appropriate element of the 'enable' vector contains a non-zero ID number.
global g_EnableVehicle; g_EnableVehicle = g_EnableVehicleDefault;
global g_VehicleTypes; g_VehicleTypes = [];
%global  g_VehicleTypeDefault;   g_VehicleTypeDefault = 1;    %aircraft      %used in SimulationFunctions and GetBenefits
global  g_VehicleTypeDefault;   g_VehicleTypeDefault = 2;    %munition


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%    Search Space Setup       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is the area that will be searched [EastMin,EastMax,NorthMin,NorthMax]
global g_SearchSpace;  

%g_SearchSpace = [0.0,20000.0,0.0,60000.0];          % (0,3.78,11.3,0) mi
g_SearchSpace = [0.0,20000.0,-60000.0,0.0];	       % (0,3.78,-11.3,0) mi
%g_SearchSpace = [0.0,21120.0,-52800.0,0.0];	       % (0,4,-10,0) mi
%g_SearchSpace = [0.0,5.0,-5.0,0.0] * g_MilesToFeet; % (0,5,-5,0) mi CDC04


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%    Target Setup        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this is the area that random targets are contrained to be in 
% [EastMin,EastMax,NorthMin,NorthMax]
global g_TargetSpace;  
g_TargetSpace = g_SearchSpace - [ 0 0 -5000 0 ]; % I know, but historic...

% set the target lane width to an integral multiple of the sensor width
%SensorMultiple = g_ActiveVehicles; % target lane as wide as vehicle lanes.
% (no manip of g_TargetSpace for jwm-CDC04)
TargetLaneMultiple = 3;
g_TargetSpace(3) = g_TargetSpace(4) - TargetLaneMultiple*g_SensorWidth_ft;
clear TargetLaneMultiple;

% g_MaxNumberTargets must contain number of the target blocks in the simulation
global g_MaxNumberTargets; g_MaxNumberTargets = 10;
% storage space to be used by target functions
global g_TargetMainMemory; g_TargetMainMemory = [];
global g_TargetMemory; g_TargetMemory = [];
global g_TargetTypes; g_TargetTypes = [];

%default target/threat lethality
global g_TargetLethalRangeMax_default; g_TargetLethalRange_default = -1;   % not lethal
global g_TargetLethalRangeMin_default; g_TargetLethalRange_default = -1;   % not lethal
% global g_TargetLethalRangeMax_default; g_TargetLethalRangeMax_default = 1000.0;   %feet
% global g_TargetLethalRangeMin_default; g_TargetLethalRangeMin_default = 100.0;   %feet
global g_TargetProbKillMax_default; g_TargetProbKillMax_default = 0.2;
global g_TargetProbKillMin_default; g_TargetProbKillMin_default = 0.0;


% number of outputs from target block. Used to make it easier to be able to change number of outputs from the targets blocks 
%  and still be able to add target blocks to the simulation
global g_NumberTargetOutputs; g_NumberTargetOutputs = 6;

% enable targets
%set the values in g_DefaultEnableVehicle to enable or disable vehicles
global g_EnableTargetDefault;
global g_ActiveTargets; g_ActiveTargets = 4;
g_EnableTargetDefault = -1*ones(g_MaxNumberTargets,1); g_EnableTargetDefault([1:g_ActiveTargets])=[1:g_ActiveTargets];	% only enable targets 1 through 3
%g_EnableVehicleDefault = [1:g_MaxNumberTargets]'; % enable all targets
%targets are enabled if the appropriate element of the 'enable' vector contains a non-zero ID number.
global g_EnableTarget; g_EnableTarget = g_EnableTargetDefault;


%%=========================================================================================
%% Initialize Target Positions
%%=========================================================================================
% 'UniformDistribution' for uniformly random target positions in x, y, psi, z=0, type=1
global g_RandomTargetPosition; 
%g_RandomTargetPosition = 'PredefinedFixed';  % use everything in g_TargetPositions
g_RandomTargetPosition = 'UniformDistribution';	
%g_RandomTargetPosition = 'BivariateNormalDistribution';	
%g_RandomTargetPosition = 'TimeBasedDistribution';	

global g_RandomTargetPose;
%g_RandomTargetPose = 'PredefinedFixed';  % use target poses in g_TargetPositions
g_RandomTargetPose = 'UniformDistribution';
%g_RandomTargetPose = 'NormalDistribution';

global g_RandomTargetType;
g_RandomTargetType = 'PredefinedFixed'; % only one target type for now...

%NOTE: adjust the range of the random target positions in 'distribution data' below 

% to manually set target positions, set g_RandomTargetPosition = 0 and set up the postions in the following matrix
global g_TargetPositions;
global g_TargetPositionDefinitions; g_TargetPositionDefinitions = CreateStructure('TargetPostionDefinitions');


if(strcmp(g_RandomTargetPosition, 'PredefinedFixed')),
    g_TargetPositions = [
        4000,-0000.0,0.0,0.0*pi,1;
        6500,-4500,0.0,0.35*pi,2;
        5000,15000,0.0,0.2,1;
        5000,15000,0.0,0.2,1;
        5000,15000,0.0,0.2,1;
        5000,15000,0.0,0.2,1;
        5000,15000,0.0,0.2,1;
        5000,15000,0.0,0.2,1;
        5000,15000,0.0,0.2,1;
        5000,15000,0.0,0.2,1
    ];
elseif(strcmp(g_RandomTargetPosition, 'TimeBasedDistribution')),
    g_TargetPositions = [
        -100000,-100000,0.0,0.0*pi,1;
        -100000,-100000,0.0,0.35*pi,2;
        -100000,-100000,0.0,0.2,1;
        -100000,-100000,0.0,0.2,1;
        -100000,-100000,0.0,0.2,1;
        -100000,-100000,0.0,0.2,1;
        -100000,-100000,0.0,0.2,1;
        -100000,-100000,0.0,0.2,1;
        -100000,-100000,0.0,0.2,1;
        -100000,-100000,0.0,0.2,1
    ];
else
    g_TargetPositions = zeros(g_MaxNumberTargets, 5);
end;

% initialize target distibution data
global g_TargetDistributionData;
g_TargetDistributionData = CreateStructure('TargetDistributionData');

MinX = g_TargetSpace(1);
MaxX = g_TargetSpace(2);
MinY = g_TargetSpace(3);
MaxY = g_TargetSpace(4);

% initialize uniform distribution
s = CreateStructure('UniformDist');
s.MinX = MinX;
s.MaxX = MaxX;
s.MinY = MinY;
s.MaxY = MaxY;
g_TargetDistributionData.UniformDist = s;

% initialize normal distribution
s = CreateStructure('NormalDist');
s.mean = 0;
s.sig  = 1;
s.MaxDraws = 100;
g_TargetDistributionData.NormalDist = s;

% initialize bivariate normal distribution
s = CreateStructure('BivariateNormalDist');
s.mean_x = (MaxX - MinX) / 2;
s.mean_y = (MaxY + MinY) / 2;
s.sig_x = 0.25*s.mean_x; % x direction standard deviation
s.sig_y = 0.25*s.mean_y; % y direction standard deviation
s.rho = 0;               % x-y correlation
s.MaxDraws = 100;        % max number of draws to reject if outside target box
g_TargetDistributionData.BivariateNormalDist = s;

% other distrbutions, e.g. DistExponential, DistPoissonPolar do not
% require a structure component to operate...

% clean up target distribution initialization
clear s MinX MaxX MinY MaxY;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%    Storage Globals     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% storage space for waypoints for all of the vehicles
global g_WaypointCells;
% waypoint flags are used to indicate that the waypoints have changed in the vehicle's WaypointCell 
global g_WaypointFlags;
% this is an array of waypoint starting indicies, one for each vehicle. When new waypoints are added the vehicle will head toward the waypoint at this index.
global g_WaypointStartingIndex; g_WaypointStartingIndex = 1.0*ones(g_MaxNumberVehicles,1);

global g_VehicleMemory; g_VehicleMemory = [];

% add Object Message ID structure (creates structure to decode IDs for different type of objects
global g_ObjectMessageIDs; g_ObjectMessageIDs = CreateStructure('ObjectMessageID');
NumberInboxes = g_ObjectMessageIDs.NumberMessageIDs;

%add memory for communications
global g_CommunicationMemory; g_CommunicationMemory = [];
g_CommunicationMemory = CreateStructure('GlobalCommunicationsStorage');
for iCount = 1:NumberInboxes
    g_CommunicationMemory.InBoxes = [g_CommunicationMemory.InBoxes;CreateStructure('CommInBox')];
end
g_CommunicationMemory.InBoxAllocationMetric = zeros(NumberInboxes,1);
clear iCount;
% g_CommunicationMemory.DelayMatrix = 1.0*~eye(g_MaxNumberVehicles);
% g_CommunicationMemory.Transport.TransportType =  g_CommunicationMemory.Transport.External;
g_CommunicationMemory.Transport.TransportType =  g_CommunicationMemory.Transport.MatlabMatrix;

%add memory for truth information communications
global g_TruthMemory; g_TruthMemory = [];
g_TruthMemory = CreateStructure('GlobalTruthStorage');
for iCount = 1:NumberInboxes
    g_TruthMemory.InBoxes = [g_TruthMemory.InBoxes;CreateStructure('CommInBox')];
end
g_TruthMemory.InBoxAllocationMetric = zeros(NumberInboxes,1);
g_TruthMemory.DelayMatrix = zeros(NumberInboxes);
clear iCount, NumberInboxes;
% g_CommunicationMemory.DelayMatrix = 1.0*~eye(g_MaxNumberVehicles);
clear NumberInboxes;
% g_TruthMemory.Transport.TransportType = g_TruthMemory.Transport.External;
g_TruthMemory.Transport.TransportType = g_TruthMemory.Transport.MatlabMatrix;

% Enable/Disable different types of messages
%g_TruthMemory.Messages{g_TruthMemory.MsgIndicies.VehicleStateSaveData}.Enabled = 0;


% storage space for AVDS Outputs
global g_AVDSTargetCells; g_AVDSTargetCells = cell(g_MaxNumberTargets,1);
global g_AVDSVehicleCells; g_AVDSVehicleCells = cell(g_MaxNumberVehicles,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Monte Carlo Flag(s) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global g_isMonteCarloRun;	% if this is part of a monte Carlo run then don't initialize selected variables.
global g_isMonteCarloStop;
if(isempty(g_isMonteCarloRun)),
    g_isMonteCarloRun = 0;
    g_isMonteCarloStop = 0;
end;

%these are initialized in MonteCarlo.m so don't initalized them here if a Monte Carlo run is in progress
global g_SampleTime;
global g_StopTime;
global g_SimulationTime;
global g_TypeAssignment;
global g_AssignmentAlgorithm;
global g_LengthenPaths;
global g_SummaryFileName;
global g_Scenario;
global g_SimulationRunNumber;
global g_MonteCarloMetrics;
global g_Seed;
global g_OptionSaveDataPlot;
global g_OptionSaveDataAVDS;

if(g_isMonteCarloRun == 0),
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Simulation Time  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % this is the sample time for the Simulink simulation
    g_SampleTime = 0.1;
    % 	g_SampleTime = 0.05;
    %	g_SampleTime = 0.5;
    
    % this is the stop time for the Simulink simulation
    %g_StopTime = 80.0;
    %g_StopTime = 10.0;
    %g_StopTime = 28.0;
    %g_StopTime = 75.0;
    g_StopTime = 200.0;
    %g_StopTime = 200.0;  % jwm-cdc04
    
    % this is the current simulation time in the current run
    g_SimulationTime = 0.0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Assigment Algortithm  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    g_TypeAssignment = CreateStructure('AssignmentTypeDefinitions');
    %g_AssignmentAlgorithm = g_TypeAssignment.CapTransShip;
    g_AssignmentAlgorithm = g_TypeAssignment.ItCapTransShip;
    %g_AssignmentAlgorithm = g_TypeAssignment.ItAuctionJacobi;
    %g_AssignmentAlgorithm = g_TypeAssignment.RelativeBenefits;
    
    %START ADD FROM B.MOORE
    
    %g_AssignmentAlgorithm = g_TypeAssignment.DistItCapTransShip;
    %g_AssignmentAlgorithm = g_TypeAssignment.DistAuctItCapTransShip; 
    
    
    
    
    %globals for distributed auction algorithm
    global g_BiddingIncrement; g_BiddingIncrement=1;   %epsilon
    global g_AssignToSearchMethod;
    global g_AssignmentTypes;
    g_AssignmentTypes=struct('Individual',1,'Common',2);
    %% Individual: Each vehicle has individual search task only it can do
    %% -- guarantees asymmetric assignment problem
    %g_AssignToSearchMethod=g_AssignmentTypes.Individual
    
    %% Common: Number of search tasks limited to the number of vehicles minus the number of targets
    %% -- guarantees symmetric assignment problem if fewer targets than vehicles
    g_AssignToSearchMethod=g_AssignmentTypes.Common; 
    global g_AssignmentDelayEstimate;g_AssignmentDelayEstimate=3;
    
    %END ADD FROM B.MOORE
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Lengthen Path Algortithm  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % this constant controls whether or not to use the path lengthening algortihms
    g_LengthenPaths = 1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Summary Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    g_Scenario = 1;
    g_SimulationRunNumber = 1.0;
    g_MonteCarloMetrics = CreateStructure('MonteCarloMetrics');
    
    % save multiple task assignments
    %directory for saving results
    if(isempty(g_MonteCarloMetrics.DirectoryName)),
        g_MonteCarloMetrics.DirectoryName = ['MonteCarloData\SingleRun\'];
        % fix paths for non-Winblows.
        if isunix,
            g_MonteCarloMetrics.DirectoryName = strrep(g_MonteCarloMetrics.DirectoryName,'\','/');
        end
        mkdir(g_MonteCarloMetrics.DirectoryName);
    end;
    g_MonteCarloMetrics.SaveMultipleTaskDataFlag = 0;
    g_MonteCarloMetrics.RecalculateTrajectory = 0;	%force trajectory recalculation at every reassignment
    g_MonteCarloMetrics.MultipleTaskSaveFile = [sprintf('SaveSingle')];
    g_SummaryFileName = ['SummaryData.SingleSim.dat'];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% random number generator %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %g_Seed = 40005;	%targets did not get classified
    %g_Seed = 40007;
    %g_Seed = 40006;
    g_Seed = 20030;
    g_Seed = 20024;
    g_Seed = 20001;
    g_Seed=2108767; %classify failures --- 2 targets on DistItCapTransShip = Vehicle 4 has trouble tracking waypoints
    %g_Seed=2078790; %missed attack w/ 4 targets
    g_Seed=2092482; %premature classifies & missed attack (however that happened) w/ 3 targets
    g_Seed=2096201; %g_EnableTargetDefault(2:3)=-1; g_EnableTarget=g_EnableTargetDefault;
    
    %g_Seed=sum(1000*clock);
    
    rand('state',g_Seed);  % uniform generator
    randn('state',g_Seed); % normal generator
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Optional Data Storage %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %set g_OptionSaveDataPlot to control saving of plot data. (NOTE: Turning this off will increase simulation speed.).:
    %     0	- OFF
    %     1	- ON
    g_OptionSaveDataPlot=1;
    
    %set g_OptionSaveDataAVDS to control saving of AVDS data. (NOTE: Turning this off will increase simulation speed.).:
    %     0	- OFF
    %     1	- ON
    g_OptionSaveDataAVDS=0;
    
end;	%if(g_isMonteCarloRun == 0),


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%           Algorithm Modification     %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%tunrn on/off the benefits for verification
global g_VerificationOn; g_VerificationOn = 1;

%storage for vector of run time for the multiple assignment algoritnms
global g_SaveAlgorithmTime; g_SaveAlgorithmTime=[];
%flag to enable storing run times of the multiple task assignment algortinms
global g_SaveAlgorithmTimeFlag; g_SaveAlgorithmTimeFlag=1;

% set g_OptionModifiedWaypoints to a non-zero value to force the use of search waypoints 
%   that are modified in the function "ModifySearchWaypoints()"
global g_OptionModifiedWaypoints;	g_OptionModifiedWaypoints=0;

%set g_OptionBackToSearch to control how vehicles return to search (RouteSelection.m):
%     0	- DEFAULT, return to search at the point where left search
%     1	- return to search at the Y coodinate point where left search and current X coodinate of the vehicle
%     2	- special return to search for vehicle 8, the default for other vehicles
global g_OptionBackToSearch; g_OptionBackToSearch = 0;

%set g_OptionAssignmentWeight to control how assignment weights are calculated (CapTransShipIO.m):
%     0	- DEFAULT
%     1	- allow only vehicle 8 to do BDA
global g_OptionAssignmentWeight; g_OptionAssignmentWeight = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Global Constants (2) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% moved to top : global g_MetersToFeet; g_MetersToFeet = 3.280839895;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the confusion matrix (g_ProbabilityID)
% Each column represents the encountered target type (truth information).  Each row
% represents the declared target type.  Note:  Each column must sum to 1.0.

%         Encountered Object
%        1     2     3     4     5
% g_ProbabilityID = [0.900 0.050 0.050 0.100 0.050;...  % 1
%        0.050 0.900 0.050 0.100 0.050;...  % 2
%        0.000 0.000 0.800 0.000 0.050;...  % 3    Declared Object
%        0.050 0.050 0.050 0.800 0.050;...  % 4
%        0.000 0.000 0.050 0.000 0.800];    % 5

global g_ProbabilityID; g_ProbabilityID = eye(g_MaxNumberTargets);	%this is set to eye(size(g_TargetTypes)) in SimulationFunctions(after target have been initialized
global g_CooperativeATR; g_CooperativeATR = 1;    % Turn cooperation between vehicles on (1) or off (0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TODO: This needs to be fixed!!!!!
%global g_CommandTurnRadius; g_CommandTurnRadius = 1700;
%global g_CommandTurnRadius; g_CommandTurnRadius = 1900;
global g_CommandTurnRadius; g_CommandTurnRadius = 2000;
%global g_CommandTurnRadius; g_CommandTurnRadius = 2200;
%global g_CommandTurnRadius; g_CommandTurnRadius = 2500;
% global g_CommandTurnRadius; g_CommandTurnRadius = 3500;

%This is the abs of the roll limit for the sensor
%global g_SensorRollLimitDeg; g_SensorRollLimitDeg = 20.0;
global g_SensorRollLimitDeg; g_SensorRollLimitDeg = 30.0;
%global g_SensorRollLimitDeg; g_SensorRollLimitDeg = 90.0;  % jwm-cdc04

% sensor dimension moved to top!!!

%% This is the maximum time between reassignment
%global g_MaxReassignmentDeltaTime;	g_MaxReassignmentDeltaTime = 60.0; %seconds
global g_MaxReassignmentDeltaTime;	g_MaxReassignmentDeltaTime = 600.0; %seconds
%global g_MaxReassignmentDeltaTime;	g_MaxReassignmentDeltaTime = inf; %seconds
% this is the maximum time difference between assignment data from the current vehicle and data from other vehicles
global g_AssignmentTimeDelay; g_AssignmentTimeDelay = 2.0 * g_SampleTime;

% this is the threshold that must be met or exceeded to declare a target classified.
%global g_ATRThreshold; g_ATRThreshold = 1.9;	% classification not possible
%global g_ATRThreshold; g_ATRThreshold = 0.95;	% classification possible, but, occansionally needs extra looks at the target
global g_ATRThreshold; g_ATRThreshold = 0.9;

% this is the percentage draw (in decimal form) that the BDA sensor will provide a false report [0.0, 1.0]
global g_BDAFalseReportPercentage; g_BDAFalseReportPercentage = 0.0;

global g_DefaultWaypointAltitude; g_DefaultWaypointAltitude = 675;

global g_DefaultMach; g_DefaultMach = 0.333;

global g_ProbabilityOfKill; g_ProbabilityOfKill = 1.0;

global g_MaxNumberDesiredHeadings; g_MaxNumberDesiredHeadings  = 4;

global g_MaxBenefit; g_MaxBenefit = 100000; % maximum assignable benefit value

%% options to scale vehicle formation in killbox 
global g_KillboxOffsetX;
global g_StartingPointOffsetXY; 

% default behaviour settings:
g_KillboxOffsetX = 0.0;
g_StartingPointOffsetXY = [ 0.0 0.0 ];

% settings for jwm CDC04 paper (keeps turns in killbox)
%g_KillboxOffsetX = 2.3*g_SensorLeadingEdge_ft;
%g_StartingPointOffsetXY = [ 0.0 -2*g_SensorWidth_ft ];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Communication Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% everyone has access to DelayMatrix, but it should only be written to here 
%% or in a function called in SendMessageS.m; we initialize it here for 
%% convenience.
%%

global g_CommDelayMajorStepsSelf;
global g_CommDelayMajorStepsOther;
global g_CommDelayDiscHoldOrder;

% denominator for n sec delays in cooperation manager
global g_CoordinationDelayDen;

%if( g_isMonteCarloRun == 0 )

% should be perfect communication:
g_CommDelayMajorStepsSelf  = 0;
g_CommDelayMajorStepsOther = 0;
g_CommDelayDiscHoldOrder   = 4;

% JWM Case 1:
%  g_CommDelayMajorStepsSelf  = 0;
%  g_CommDelayMajorStepsOther = 10;
%  g_CommDelayDiscHoldOrder   = g_CommDelayMajorStepsOther;

% JWM Case 2:
% g_CommDelayMajorStepsSelf  = 0;
% g_CommDelayMajorStepsOther = 20;
% g_CommDelayDiscHoldOrder   = g_CommDelayMajorStepsOther;

% JWM Case 3:
% g_CommDelayMajorStepsSelf  = 3;
% g_CommDelayMajorStepsOther = 20;
% g_CommDelayDiscHoldOrder   = g_CommDelayMajorStepsOther;

%g_CommunicationMemory.DelayMatrix = magic(g_ObjectMessageIDs.NumberMessageIDs)/10.*~eye(g_ObjectMessageIDs.NumberMessageIDs);
%g_CommunicationMemory.DelayMatrix(1:3,1:3) = 2*reshape([1:9],3,3)'.*~eye(3);
g_CommunicationMemory.DelayMatrix = g_SampleTime * (g_CommDelayMajorStepsOther*~eye(g_ObjectMessageIDs.NumberMessageIDs) + g_CommDelayMajorStepsSelf*eye(g_ObjectMessageIDs.NumberMessageIDs) );
%ComputeMessageDelayMatrix(0, 1);

if( g_CommDelayDiscHoldOrder > 0 )
    den_tmp = zeros(1,g_CommDelayDiscHoldOrder);
    den_tmp(1) = 1;
    g_CoordinationDelayDen = den_tmp;
    
    % we modify the following value from above:
    g_AssignmentTimeDelay = g_CommDelayDiscHoldOrder * g_SampleTime;
else
    g_CoordinationDelayDen = [1 0 0];
end
clear den_tmp;

% this message makes it possible to delay the implementation of just the assignment
global g_AssignmentProcessingDelay; g_AssignmentProcessingDelay = 0.0;
%global g_AssignmentProcessingDelay; g_AssignmentProcessingDelay = g_CommDelayMajorStepsSelf*g_SampleTime;
g_TruthMemory.Messages{g_TruthMemory.MsgIndicies.ChangeAssignmentFlagSelf}.MessageDelay = g_AssignmentProcessingDelay;

% keep the runs straight:
disp('*** Communications Setup:: ***');
disp(sprintf('        g_CommDelay{MajorStep{Self,Other},DiscHoldOrder} = {{%d,%d},%d}', ...
    g_CommDelayMajorStepsSelf, g_CommDelayMajorStepsOther, g_CommDelayDiscHoldOrder));
disp(sprintf('        g_AssignmentTimeDelay = %5.2f', g_AssignmentTimeDelay));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%    Plot Setup       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isDefaultPlotLimits = 1;
if( ~isDefaultPlotLimits )
    PlotAxisXMin = g_SearchSpace(1) - 1*g_MilesToFeet;
    PlotAxisXMax = g_SearchSpace(2) + 1*g_MilesToFeet;
    PlotAxisYMin = g_SearchSpace(3) + 1*g_MilesToFeet;
    PlotAxisYMax = g_SearchSpace(4) + 1*g_MilesToFeet;
else
    PlotAxisXMin = g_SearchSpace(1)-2*g_SensorLeadingEdge_ft - 2.0*g_CommandTurnRadius;
    PlotAxisXMax = g_SearchSpace(2)+2*g_SensorLeadingEdge_ft + 2.0*g_CommandTurnRadius;
    PlotAxisYMin = 0.75*(g_SearchSpace(4) - g_SearchSpace(3)) + g_SearchSpace(3) - 2.0*g_CommandTurnRadius;
    PlotAxisYMax = g_SearchSpace(4) + g_SensorLeadingEdge_ft + 2.0*g_CommandTurnRadius;
end
clear isDefaultPlotLimits;

global g_PlotAxesLimits;  g_PlotAxesLimits = [PlotAxisXMin,PlotAxisXMax,PlotAxisYMin,PlotAxisYMax];		%these are the limits for the axes in the animated plot

clear PlotAxisXMin;
clear PlotAxisXMax;
clear PlotAxisYMin;
clear PlotAxisYMax;

% these are for plotting from saved workspace data
global g_XYPositions g_TargetPositions;

% used in conjunction w/ g_SensorRollLimitDeg, e.g.
% g_SensorRollLimitDeg=90 => sensor always on => always use pastel color
global g_isSensorAlwaysPastel; g_isSensorAlwaysPastel = 0;
if( g_SensorRollLimitDeg >= 90 )
    g_isSensorAlwaysPastel = 1;  % jwm-cdc04
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Constant Structures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% defintions for tasks are in the the g_Tasks structure
global g_Tasks; g_Tasks  = CreateStructure('TaskDefinitions');
g_Tasks.TaskStrings = { ...
        'Continue Searching';
    'Classify Target';
    'Attack Target';
    'Verify Kill';
    'Classify/Attack Target';
    'TasksCompleted';
    'Unknown Task';
};

% defintions for target states are in the the g_TargetStates structure
global g_TargetStates; g_TargetStates  = CreateStructure('TargetStateDefinitions');
g_TargetStates.StateStrings = { ...
        'Detected-Not-Classified';
    'Classified-Not-Attacked';
    'Attacked-Not-Killed';
    'Killed-Not-Confirmed';
    'Confirmed-Kill';
    'Unknown TargetState';
};

global g_EntityTypes; g_EntityTypes = CreateStructure('EntityTypeDefinitions');

global g_WaypointTypes; g_WaypointTypes = CreateStructure('WaypointTypeDefinitions');
global g_WaypointDefinitions; g_WaypointDefinitions = CreateStructure('WaypointEntryDefinitions');

global g_Colors; g_Colors  = CreateStructure('ColorDefinitions');
global g_VehicleColors; g_VehicleColors  = CreateStructure('VehicleColorDefinitions');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% one-time initialization %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~exist('g_OneTimeInitialization')),
    global g_OneTimeInitialization; g_OneTimeInitialization = 0;
end;

if(g_OneTimeInitialization == 0),
    g_OneTimeInitialization = 1;
    format long e;	% default output format
    
    % define relative top dir
    tdir = ['..', filesep];
    
    % needed to pick-up model files: MultiUAV.mdl, cooperative.mdl
    addpath([tdir, 's-model']);    
    
    % add the library path to the current path
    addpath( GetLibDir(tdir) );
    
    % setup access to various input files (needed by the vehicles)
    idir = [tdir, 'InputFiles',filesep];
    
    global g_VehicleInputFiles;
    ts1 = struct('name', {[idir,'DATCOM.dat']}, 'version', 1.0, ...
        'isSubtractBaseTables', 1 );
    ts2 = struct('name', {[idir,'Parameters.dat']}, 'version', 1.4);
    g_VehicleInputFiles = struct('datcom', ts1, 'params', ts2);
    
    % clear unnecessary locals
    clear tdir idir ts1 ts2;
    
    % open the GUI figure which calls the "SimulationFunctions('InitializeSimulation')"  intialization function.
    GUIMultiUAV;
end;

