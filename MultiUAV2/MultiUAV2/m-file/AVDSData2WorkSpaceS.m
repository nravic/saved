function [sys,x0,str,ts] = AVDSData2WorkSpaceS(t,x,u,flag)
%AVDSData2WorkSpaceS - S-function interface to AVDSData2WorkSpace(u).
%
%  NOTE: see the function "AVDSData2WorkSpaceS" for details
%  Outputs:

%  AFRL/VACA
%  October 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('AVDSData2WorkSpaceS.m');end; 

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
    AVDSData2WorkSpace(u);     % the function to call
    sys = [];

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %function [sys,x0,str,ts] = TargetBombLogS(t,x,u,flag)