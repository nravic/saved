function SimulationFunctions(action)
%SimulationFunctions - used to intialize global simulation structures 
%
%  Inputs:
%    action - this is the function to perform. Valid entries include:
%      'InitializeSimulation' - reinitializes all of the simulation variables/parameters including global constants
%      'InitializeSimulation' - reinitializes all of the simulation variables/parameters
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS
%  May 2001 - Added 'InitializeSimulation' section to reinitialize all of the simulation variables/parameters 
%    at the beginning of the simulation - RAS
%  September 2002 - Rearraanged, modified and removed functions - RAS


global g_Debug; if(g_Debug==1),disp('SimulationFunctions.m');end; 
global g_ProbabilityID;
global g_TargetTypes;

if nargin <1,
	action = 'InitializeSimulation';
end

switch action
	
case 'InitializeSimulation'
	disp(' ');
	disp('*** SimulationFunctions:: Initializing Simulation ***');
	clear functions;			% make sure any persistent variables are reset to [] this also clears any breakpoints
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% use the following lines to add breakpoints for DEBUGGING!

%     dbstop in TaskBenefitMulti.m at 33
%     dbstop in DAINF_StoreBenefitsS.m at 41
%     dbstop in DAINF_Auction.m at 139;
%     dbstop in DAINF_MessageControl at 63
%     dbstop in DAINF_IterationControl.m at 386
%     dbstop in ATRFunctions.m at 312
%     dbstop in DINF_ComparePlanS.m at 60    
%     dbstop in DINF_CapTransShipAssign.m at 452
%     dbstop in DINF_CapTransShipAssign.m at 431
%     dbstop in DINF_GetBenefits.m at 70
%      dbstop in DINF_CalculateBenefits.m at 53
%     dbstop in FuturePosition.m at 29
%     dbstop in DINF_ComparePlanS.m 80
%     dbstop in FindMessageIndex.m 14

    
    
    % 	dbstop in TaskFailed.m at 103
% 	dbstop in GetBenefits.m at 128
% 	dbstop in Case1Func.m at 108
% 	dbstop in Case2Func.m at 80
% 	dbstop in LengthenPath.m at 74
%     dbstop in MultiTaskAssignIO.m 42
%     dbstop in MultiTaskAssignIO.m 143
% 	dbstop in MultiTaskAssign.m 17
% 	dbstop in ATRFunctions.m 312
% 	dbstop in ATRFunctions.m 312
% 	dbstop in Case4Func.m 161
% 	dbstop in CaseAngleFunc.m 218
% 	dbstop in Case4Func.m 51
% 	dbstop in GetBenefits.m 80
% 	dbstop in GetBenefits.m 137
% 	dbstop in LengthenPath.m 138
% 	dbstop in SimulationControl.m 20
% 	dbstop in InitFunctionsS.m 11
% 	dbstop in TaskFailed.m 85
%  	dbstop in CapTransShipIO.m 106
%  dbstop in SendMessageS.m 259
% dbstop in InitFunctionsS.m 80
% dbstop in Summary.m 30
% dbstop in ThreatS.m 119
%   dbstop in VehicleKilledS.m 39
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	InitializeGlobals;
	
	% 	load 'Waypoints';
	InitializeWaypoints;
	InitializeVehicleTypes;
	InitializeVehicles;
	InitializeTargets;	% reinitialize target coordinates
	InitializeTargetTypes;
	g_ProbabilityID = eye(size(g_TargetTypes,1));
	
case 'ReInitializeSimulation'
	disp(' ');
	disp('*** SimulationFunctions:: Reinitializing Simulation ***');
	clear functions;			% make sure any persistent variables are reset to [] this also clears any breakpoints
	InitializeWaypoints;
	InitializeVehicles;
	InitializeTargets;	% reinitialize target coordinates
	g_ProbabilityID = eye(size(g_TargetTypes));
	disp(' ');
end;	%switch action	
return;	%SimulationFunctions


function InitializeVehicles()
global g_MaxNumberVehicles;
global g_MaxNumberTargets;
global g_VehicleMemory;
global g_WaypointCells;
global g_TargetStates;
global g_Tasks;
global g_WaypointDefinitions;
global g_EnableVehicleDefault
global g_EnableVehicle;
global g_CommunicationMemory;
global g_VehicleTypeDefault;

disp('*** SimulationFunctions::InitializeVehicles() Initializing Vehicles ***');

% reset vehicle enables to their default values
g_EnableVehicle = g_EnableVehicleDefault;
g_VehicleMemory = [];
for iCount = 1:g_MaxNumberVehicles
	g_VehicleMemory = [g_VehicleMemory;CreateStructure('Vehicle')];
end
for VehicleCount = 1:g_MaxNumberVehicles,
	g_VehicleMemory(VehicleCount).VehicleType = g_VehicleTypeDefault;
	g_VehicleMemory(VehicleCount).Dynamics.PositionXFeetInit = g_WaypointCells{VehicleCount}(1,g_WaypointDefinitions.PositionX);
	g_VehicleMemory(VehicleCount).Dynamics.PositionYFeetInit = g_WaypointCells{VehicleCount}(1,g_WaypointDefinitions.PositionY);
	g_VehicleMemory(VehicleCount).Dynamics.PositionZFeetInit = g_WaypointCells{VehicleCount}(1,g_WaypointDefinitions.PositionZ);
	g_VehicleMemory(VehicleCount).Dynamics.VTrueFPSInit = g_WaypointCells{VehicleCount}(1,g_WaypointDefinitions.MachCommand);
	XLength = g_WaypointCells{VehicleCount}(2,g_WaypointDefinitions.PositionX) - g_WaypointCells{VehicleCount}(1,g_WaypointDefinitions.PositionX);
	YLength = g_WaypointCells{VehicleCount}(2,g_WaypointDefinitions.PositionY) - g_WaypointCells{VehicleCount}(1,g_WaypointDefinitions.PositionY);
	g_VehicleMemory(VehicleCount).Dynamics.PsiDegInit = atan2(YLength,XLength)*180/pi;
	%set alternate route waypoints to the original waypoints
	g_VehicleMemory(VehicleCount).RouteManager.AlternateWaypointIndex = 1;
	g_VehicleMemory(VehicleCount).RouteManager.AlternateWaypoints = g_WaypointCells{VehicleCount};
	g_VehicleMemory(VehicleCount).CooperationManager.TaskList = -ones(g_MaxNumberTargets,g_Tasks.NumberTasks-1);	%initialize tasks on task list to unintilaized, don't include search
	g_VehicleMemory(VehicleCount).MonteCarloMetrics.TargetStateTimes = zeros(g_MaxNumberTargets,g_TargetStates.NumberStates);
end
ModifySearchWaypoints;	% this functions manipulates the search waypoints
return;	%InitializeVehicles


function InitializeWaypoints()
global g_WaypointCells;
global g_WaypointFlags;
global g_MaxNumberVehicles;
g_WaypointCells = [];
g_WaypointCells = cell(g_MaxNumberVehicles,1);
% waypoint flags set to one cause vehicle to reread waypoints
g_WaypointFlags = ones(g_MaxNumberVehicles,1);
% recalculate all of the waypoints
CalculateWaypoints;
return;	%InitializeWaypoints

