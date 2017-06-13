function [sys,x0,str,ts] = TargetPositionS(t,x,u,flag)
%TargetPositionS - S-function interface to TargetPosition.
%
%  NOTE: see the function "TargetPosition" for details
%  Outputs:

%  AFRL/VACA
%  October 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('TargetPositionS.m');end; 

global g_SampleTime;


switch flag,

case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 5;
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
    sys = TargetPosition(u);     % the function to call

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %function [sys,x0,str,ts] = TargetPositionS(t,x,u,flag)


function [Position] = TargetPosition(TargetID)
%TargetPosition - returns the true position of a target based on its ID number
%
%  Inputs:
%    TargetID - identification number of the target
%
%  Outputs:
%    Position - true position of the target
%

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SetTargetPositions.m [X Y Z Type Alive]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global g_TargetMemory;

Position = [g_TargetMemory(TargetID).PositionX, ...
            g_TargetMemory(TargetID).PositionY, ...
      		g_TargetMemory(TargetID).PositionZ, ...
            g_TargetMemory(TargetID).Type, ...
      		g_TargetMemory(TargetID).Psi];
    
return; %function [sys,x0,str,ts] = TargetPosition(TargetID)
