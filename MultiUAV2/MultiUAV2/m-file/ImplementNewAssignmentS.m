function [sys,x0,str,ts] = ImplementNewAssignmentS(t,x,u,flag)
%ImplementNewAssignmentS - if the new assignment flag has changed set the waypoint flags.
%
%  Inputs:
%		VehicleID
%  Outputs:

%  AFRL/VACA
%  March 2004 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('ThreatS.m');end; 

global g_SampleTime;
global g_WaypointFlags;
global g_WaypointCells;
global g_VehicleMemory;

switch flag,
    
case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 0;
    sizes.NumInputs      = 1;
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
    g_WaypointFlags(u) = 1;
    g_WaypointCells{u} = g_VehicleMemory(u).CooperationManager.PendingWaypoints;
    sys = [];     % the function to call
    
case 4,
    sys = t + g_SampleTime;
    
case 9,
    sys = [];
    
otherwise
    error(['Unhandled flag = ',num2str(flag)]);
    
end;

return; %function [sys,x0,str,ts] = TargetBombLogS(t,x,u,flag)


