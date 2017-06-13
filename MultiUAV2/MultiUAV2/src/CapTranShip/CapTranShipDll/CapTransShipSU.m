function [OutputVector] = CapTransShipSU(dummy)
%CapTransShipSU - used to setup the inputs to the CapTransShip s-function 
%
%  Inputs: - none
%
%  Outputs:
%    OutputVector(1) - number vehicles in the assignment
%    OutputVector(2) - number targets in the assignment
%    OutputVector(3) - number tasks in the assignment
%    OutputVector(4:4+number vehicles) - benefit of assigning each vehicle to 
%                      continue to search
%    OutputVector(...:...) - benefit of assigning vehicle 1 to 
%                      each target for task 1
%       .
%       .
%    OutputVector(...:...) - benefit of assigning vehicle n to 
%                      each target for task 1
%       .
%       .
%       .
%    OutputVector(...:...) - benefit of assigning vehicle 1 to 
%                      each target for task m
%       .
%       .
%    OutputVector(...:...) - benefit of assigning vehicle n to 
%                      each target for task m

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

global MaxNumberVehicles;
global MaxNumberTargets;
global MaxNumberTasks;

OutputVector = zeros(3 + MaxNumberVehicles + MaxNumberVehicles*MaxNumberTargets*MaxNumberTasks,1); %defaults all values to 0

OutputIndex = 1;
OutputVector(OutputIndex) = MaxNumberVehicles;
OutputIndex = OutputIndex + 1;
OutputVector(OutputIndex) = MaxNumberTargets;
OutputIndex = OutputIndex + 1;
OutputVector(OutputIndex) = MaxNumberTasks;

OutputIndex = OutputIndex + 1;
for iCountVehicles = 1:MaxNumberVehicles,
	OutputVector(OutputIndex) = CalculateBenefit(iCountVehicles,0,0);
	OutputIndex = OutputIndex + 1;
end;	%for iCountVehicles = 1:MaxNumberVehicles,
for iCountTasks = 1:MaxNumberTasks,
	for iCountVehicles = 1:MaxNumberVehicles,
      for iCountTargets = 1:MaxNumberTargets,
         OutputVector(OutputIndex) = CalculateBenefit(iCountVehicles,iCountTargets,iCountTasks);
         OutputIndex = OutputIndex + 1;
		end;	%for iCountTargets = 1:MaxNumberTargets,
	end;	%for iCountVehicles = 1:MaxNumberVehicles,
end;	%for iCountTasks = 1:MaxNumberTasks,

a=1;
