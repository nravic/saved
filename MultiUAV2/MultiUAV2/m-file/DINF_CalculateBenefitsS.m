function [sys,x0,str,ts] = DINF_CalculateBenefitsS(t,x,u,flag,MaxNumberTargets,MaxNumberVehicles)
%  DINF_CalculateBenefitsS.m
%  S-function interface to DINF_CalculateBenefits.m
%
%  AFRL/VACA
%  July 2003 Brandon Moore


global g_Debug; if(g_Debug==1),disp('DINF_CalculateBenefits.m');end; 

global g_SampleTime;
global g_NumberTargetOutputs;
global g_MaxNumberDesiredHeadings;


switch flag,

case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    % TaskBenefits, TimeToComplete
    sizes.NumOutputs = 2*MaxNumberTargets+1;
    % Time,VehicleID,X,Y,Psi,WaypointNumber,TargetMatrix,DesiredHeadings,TargetStates, TriggerReplanFlags
	sizes.NumInputs = 6+ MaxNumberTargets*g_NumberTargetOutputs +MaxNumberTargets*g_MaxNumberDesiredHeadings +MaxNumberTargets+MaxNumberVehicles ;
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
    sys = DINF_CalculateBenefits(u);     % the function to call

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %