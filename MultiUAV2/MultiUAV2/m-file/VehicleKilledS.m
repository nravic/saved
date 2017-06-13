function [sys,x0,str,ts] = VehicleKilledS(t,x,u,flag,MaxNumberVehicles, MaxNumberTargets)
%VehicleKilledS - checks to see if vehicle has be killed.
%
%  Inputs:
%		Vehicle ID
%		Vehicle killed matrix from targets
%  Outputs:

%  AFRL/VACA
%  March 2004 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('ThreatS.m');end; 

global g_SampleTime;

switch flag,
	
case 0,
	sizes = simsizes;
	sizes.NumContStates  = 0;
	sizes.NumDiscStates  = 0;
	sizes.NumOutputs     = 1;	% 1 - kill flag
	sizes.NumInputs      = 1 + MaxNumberTargets * MaxNumberVehicles;   %Vehicle ID Vehicle Killed vehiclesXtargets
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
	sys = VehicleKilled(t,u,MaxNumberVehicles,MaxNumberTargets);     % the function to call
	
case 4,
	sys = t + g_SampleTime;
	
case 9,
	sys = [];
	
otherwise
	error(['Unhandled flag = ',num2str(flag)]);
	
end;

return; %function [sys,x0,str,ts] = TargetBombLogS(t,x,u,flag)


function [Output] = VehicleKilled(Time,InputVector,MaxNumberVehicles,MaxNumberTargets)

Output = 0;

iCurrentRow = 1;
iCurrentVectorSize = 1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
VehicleID = InputVector(iCurrentRow:iLastRow);

if(VehicleID > 0),	%is vehicle alive?
	
	iCurrentRow = iLastRow + 1;
	iCurrentVectorSize = MaxNumberVehicles*MaxNumberTargets;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	VehicleKilledVector = InputVector(iCurrentRow:iLastRow);
	VehicleKilledMatrix = reshape(VehicleKilledVector,MaxNumberVehicles,MaxNumberTargets);
	
	Output = max(VehicleKilledMatrix(VehicleID,:));
end;		%if(VehicleID > 0),
return;