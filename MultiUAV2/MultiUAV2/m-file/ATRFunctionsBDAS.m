function [sys,x0,str,ts] = ATRFunctionsBDAS(t,x,u,flag,MaxNumberTargets)
%ATRFunctionsBDAS - S-function interface to ATRFunctions('BDA',u).
%
%  NOTE: see the function "ATRFunctions" for details
%  Outputs:

%  AFRL/VACA
%  October 2001 - Created and Debugged - RAS



global g_Debug; if(g_Debug==1),disp('ATRFunctionsBDAS.m');end; 

global g_SampleTime;


switch flag,

case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
	sizes.NumOutputs = MaxNumberTargets;
	sizes.NumInputs = 1 + 9*MaxNumberTargets;
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
    sys = ATRFunctions('BDA',u);     % the function to call

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %