function [sys,x0,str,ts] = TargetStatusS(t,x,u,flag,MaxNumberTargets,MaxNumberVehicles)
%TargetStatusS - S-function interface to TargetStatus.
%
%  NOTE: see the function "TargetStatus" for details
%  Outputs:

%  AFRL/VACA
%  October 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('TargetStatusS.m');end; 

global g_SampleTime;


switch flag,

case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs = MaxNumberTargets + 1;
    % inputs: VehicleID(1),Time(1), LastTaskFinished(Task and Target (2)), Number Valid desired Headings,  CombinedATR(MaxNumberTargets), 
    %                       CombinedBDA(MaxNumberTargets), TargetStatus(MaxNumberTargets*MaxNumberVehicles), 
    %                       TargetAttacked(MaxNumberVehicles) 
    sizes.NumInputs = 1 + 1 + 2 + MaxNumberTargets + MaxNumberTargets + MaxNumberTargets + (MaxNumberTargets*MaxNumberVehicles) + MaxNumberVehicles;
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
    sys = TargetStatus(u);     % the function to call

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %function [sys,x0,str,ts] = TargetBombLogS(t,x,u,flag)