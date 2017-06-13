function [sys,x0,str,ts] = ATRFunctionsSingleS(t,x,u,flag,MaxNumberTargets)
%ATRFunctionsSingleS - S-function interface to ATRFunctions('Single',u).
%
%  NOTE: see the function "ATRFunctions" for details
%  Outputs:

%  AFRL/VACA
%  October 2001 - Created and Debugged - RAS



global g_Debug; if(g_Debug==1),disp('ATRFunctionsSingleS.m');end; 

global g_SampleTime;


switch flag,

case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
	sizes.NumOutputs = MaxNumberTargets*4;
	% inputs: ATRTime(1),VehicleID(1),PsiFilteredDeg(1),SensedTargets(MaxNumberTargets),g_TargetMemory(MaxNumberTargets),
	sizes.NumInputs = 1 + 1 + 1 + MaxNumberTargets + MaxNumberTargets;
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
    sys = ATRFunctions('Single',u);     % the function to call

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %