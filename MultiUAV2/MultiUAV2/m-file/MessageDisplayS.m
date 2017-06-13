function [sys,x0,str,ts] = MessageDisplayS(t,x,u,flag,Message)
%ReplanRoutesS - S-function interface to ReplanRoutes.
%
%  NOTE: see the function "ReplanRoutes" for details
%  Outputs:

%  AFRL/VACA
%  October 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('MessageDisplayS.m');end; 

global g_SampleTime;


switch flag,

case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 0;
    sizes.NumInputs      = -1;
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
    sys = [];
    MessageDisplay(Message,u,t);     % the function to call

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %function [sys,x0,str,ts] = TargetBombLogS(t,x,u,flag)