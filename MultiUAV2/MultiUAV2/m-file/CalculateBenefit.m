function Benefit = CalculateBenefit(iVehicleID,iTargetID,iTaskID)
%CalculateBenefit - called by CapTransShip.m to calculate benefit of assignment 
%
%  Inputs:
%    iVehicleID - identification number of the vehicle
%    iTargetID - identification number of the target
%    iTaskID - identification number of the task
%
%  Outputs:
%    Benefit - calculated benefit of assigning the given vehivcle to the given
%              target to perform the given task
%

%  AFRL/VACA
%  March 2001 - Created and Debugged - RAS


% this is where the benefit should be calculated and returned

global g_Debug; if(g_Debug==1),disp('CalculateBenefit.m');end; 

Benefit = TestBenefit(iVehicleID,iTargetID,iTaskID);

