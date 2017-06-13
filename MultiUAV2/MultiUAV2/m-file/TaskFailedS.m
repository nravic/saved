function [sys,x0,str,ts] = TaskFailedS(t,x,u,flag,MaxNumberTargets)
%TaskFailedS - S-function interface to TaskFailed.
%
%  NOTE: see the function "TaskFailedS" for details
%  Outputs:

%  AFRL/VACA
%  July 2002 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('TaskFailedS.m');end; 

global g_SampleTime;


switch flag,
	
case 0,
	sizes = simsizes;
	sizes.NumContStates  = 0;
	sizes.NumDiscStates  = 0;
	% outputs: UnassignedTaskFlag 
	sizes.NumOutputs = 1;
	% inputs: VehicleID TargetStatus 
	sizes.NumInputs = 4 + 2*MaxNumberTargets + 1;
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
	sys = TaskFailed(t,u);     % the function to call
case 4,
	sys = t + g_SampleTime;
	
case 9,
	sys = [];
	
otherwise
	error(['Unhandled flag = ',num2str(flag)]);
	
end;

return; %function [sys,x0,str,ts] = TaskFailedS(t,x,u,flag,MaxNumberTargets)