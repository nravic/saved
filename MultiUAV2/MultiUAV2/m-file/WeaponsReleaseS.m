function [sys,x0,str,ts] = WeaponsReleaseS(t,x,u,flag,pAction)
%WeaponsReleaseS - S-function interface to WeaponsRelease.
%
%  NOTE: see the function "WeaponsRelease" for details
%  Outputs:

%  AFRL/VACA
%  October 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('WeaponsReleaseS.m');end; 
if(g_Debug==1),disp(['WeaponsReleaseS.m:flag=[',num2str(flag),']']);end; 


global g_SampleTime;


switch flag,

case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;

    switch(pAction),
    case 'Bomb',
        sizes.NumOutputs = 4;
        sizes.NumInputs = 4;
    otherwise,
        sizes.NumOutputs = -1;
        sizes.NumInputs = -1;
    end;    %switch(pAction),

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
    sys = WeaponsRelease(pAction,u);     % the function to call

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %function [sys,x0,str,ts] = TargetBombLogS(t,x,u,flag)