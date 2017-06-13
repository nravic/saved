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
%%
%%	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION IS RELEASED "AS IS." THE
%%	U.S.GOVERNMENT MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, CONCERNING
%%	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION, INCLUDING, WITHOUT LIMITATION,
%%	ANY WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
%%	WILL THE U.S. GOVERNMENT BE LIABLE FOR ANY DAMAGES, INCLUDING ANY LOST PROFITS,
%%	LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE,
%%	OR INABILITY TO USE, THIS SOFTWARE OR ANY ACCOMPANYING DOCUMENTATION, EVEN IF
%%	INFORMED IN ADVANCE OF THE POSSIBILITY OF SUCH DAMAGES.
%%


% this is where the benefit should be calculated and returned
Benefit = TestBenefit(iVehicleID,iTargetID,iTaskID);

