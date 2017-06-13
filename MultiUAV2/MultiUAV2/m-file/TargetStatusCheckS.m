function [sys,x0,str,ts] = TargetStatusCheckS(t,x,u,flag)
%TargetStatusCheckS - S-function interface to TargetStatusCheck.
%
%  Inputs:
%    InputVector(...) - a 'vectorized' matrix that contains each targets status reported by each vehicle
%
%  Outputs:
%    OutputVector(1:g_MaxNumberTargets+?) - a vector containing the status for each target.
%       0 - unknown target
%       1 to 10 - Estimated Target Type
%       -1 - dead (or never alive)

%  AFRL/VACA
%  October 2001 - Created and Debugged - RAS
%  April 2004 - merged with TargetStatusCheck.m - RAS


global g_Debug; if(g_Debug==1),disp('TargetStatusCheckS.m');end; 

global g_SampleTime;
global g_MaxNumberTargets;
global g_MaxNumberVehicles;

switch flag,
    
case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs = g_MaxNumberTargets;
    sizes.NumInputs = g_MaxNumberTargets*g_MaxNumberVehicles;
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
    
    OutputVector = zeros(g_MaxNumberTargets,1); 
    iCurrentRow = 1;
    iCurrentVectorSize = (g_MaxNumberTargets * g_MaxNumberVehicles);	
    iLastRow = iCurrentRow + iCurrentVectorSize - 1;
    TargetStatusVector = u(iCurrentRow:iLastRow);
    TargetStatusMatrix = reshape(TargetStatusVector,g_MaxNumberTargets,g_MaxNumberVehicles);
    
    for iTargetCount=1:g_MaxNumberTargets
        StatusTemp = max(TargetStatusMatrix(iTargetCount,:));
        OutputVector(iTargetCount) = StatusTemp;    
    end;
    sys = OutputVector;
    
    
case 4,
    sys = t + g_SampleTime;
    
case 9,
    sys = [];
    
otherwise
    error(['Unhandled flag = ',num2str(flag)]);
    
end;

return; %function [sys,x0,str,ts] = TargetStatusCheckS(t,x,u,flag)