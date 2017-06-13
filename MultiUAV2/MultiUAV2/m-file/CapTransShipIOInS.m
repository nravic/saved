function [sys,x0,str,ts] = CapTransShipIOInS(t,x,u,flag,MaxNumberTargets,MaxNumberVehicles,NumberTasks)
%CapTransShipIOInS - S-function interface to CapTransShipIO('Input',u).
%
%  NOTE: see the function "CapTransShipIO" for details
%  Outputs:

%  AFRL/VACA
%  October 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('CapTransShipIOInS.m');end; 

global g_SampleTime;


switch flag,

case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs = 3 + MaxNumberVehicles + MaxNumberVehicles*MaxNumberTargets*NumberTasks;
	% VehicleID, TargetStatus,ReplanETAsAndCosts, TargetAttacked 
	sizes.NumInputs = 1 + MaxNumberTargets + MaxNumberVehicles*(1+3*MaxNumberTargets) + MaxNumberVehicles;
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
    sys = CapTransShipIO('Input',u,t);     % the function to call

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %