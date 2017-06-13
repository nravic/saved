function [sys,x0,str,ts] = DINF_CapTransShipAssignS(t,x,u,flag,MaxNumberTargets,MaxNumberVehicles)
%CapTransShipAssignDINFS - S-function interface to CapTransShipAssignDINF().
%
% Brandon Moore 21 JUL 03

global g_Debug; if(g_Debug==1),disp('CapTransShipAssignDINFS.m');end; 

global g_SampleTime;

switch flag,

case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    % new ReplanRound, new TargetStates,  SendBenefits Trigger NewAssignment
    sizes.NumOutputs = 2+MaxNumberTargets+1+1;;
	% ActiveVehicles, ReplanRound, TargetStates, TaskBenefits, TimeToComplete, SearchBenefits, Sync, ReplanTrigger, VehicleID, TargetStatus, WaypointNumber
	sizes.NumInputs = MaxNumberVehicles+2+MaxNumberTargets+2*MaxNumberVehicles*MaxNumberTargets+MaxNumberVehicles+1+1 + 1+MaxNumberTargets+1+1+1+1;
    sizes.DirFeedthrough = 1;
    sizes.NumSampleTimes = 1;   % at least one sample time is needed
    sys = simsizes(sizes);
    x0  = [];
    str = [];
    ts  = [g_SampleTime];

    
  case 1,
    sys = [];

  case 2,
    sys = [];

  case 3,
         
    sys = DINF_CapTransShipAssign(u,t);     % the function to call

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %