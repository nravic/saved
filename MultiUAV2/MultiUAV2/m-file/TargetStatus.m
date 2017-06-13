function [OutputVector] = TargetStatus(InputVector)
%TargetStatus - monitors the status of the targets. 
%  Replan is necessary if any new targets are discovered
%
%  Inputs:
%    InputVector(1) - vehicle identification number
%    InputVector(...) - a 'vectorized' matrix that contains each targets status
%      and desired angle and whether or not the status, for any of the targets tracked
%      by the vehicle, has changed 
%    InputVector(...) - a 'vectorized' matrix containing truth information about 
%      all of the targets 
%
%  Outputs:
%    OutputVector(1:g_MaxNumberTargets) - a vector containing the status for each target.
%       0 - unknown target
%       1 to 10 - Estimated Target Type
%       -1 - confirmed dead
%    OutputVector(g_MaxNumberTargets+1:2*g_MaxNumberTargets) - a vector containing the desired encounter angle for each target.
%    OutputVector(2*g_MaxNumberTargets+1) - a flag indicating that a target has changed status.
%
%

%  AFRL/VACA
%  March 2001 - Created and Debugged - RAS
%  September 2001 - modified to allow for multiple attacks - RAS


global g_Debug; if(g_Debug==1),disp('TargetStatus.m');end; 

global g_MaxNumberVehicles;
global g_MaxNumberTargets;
global g_Tasks;
global g_TargetStates;
global g_VehicleMemory;

global g_CommunicationMemory;	%here for dubuging only 

OutputSize = g_MaxNumberTargets+1;
OutputVector = zeros(OutputSize,1); 

iCurrentRow = 1;
iCurrentVectorSize = 1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
VehicleID = InputVector(iCurrentRow:iLastRow);

iCurrentRow = iLastRow + 1;
iCurrentVectorSize = 1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
VehicleTime = InputVector(iCurrentRow:iLastRow);

% last task this vehicle has completed - assigned target
iCurrentRow = iLastRow + 1;
iCurrentVectorSize = 1;	
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
LastTaskTarget = InputVector(iCurrentRow:iLastRow);

% last task this vehicle has completed - assigned task
iCurrentRow = iLastRow + 1;
iCurrentVectorSize = 1;	
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
LastTaskTask = InputVector(iCurrentRow:iLastRow);

% valid number of desired headings
iCurrentRow = iLastRow + 1;
iCurrentVectorSize = g_MaxNumberTargets;	
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
NumberValidHeadings = InputVector(iCurrentRow:iLastRow);

iCurrentRow = iLastRow + 1;
iCurrentVectorSize = g_MaxNumberTargets;	
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
CombinedATRVector = InputVector(iCurrentRow:iLastRow);

iCurrentRow = iLastRow + 1;
iCurrentVectorSize = g_MaxNumberTargets;	
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
BDAVector = InputVector(iCurrentRow:iLastRow);

iCurrentRow = iLastRow + 1;
iCurrentVectorSize = (g_MaxNumberTargets * g_MaxNumberVehicles);	
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
TargetStatusVector = InputVector(iCurrentRow:iLastRow);
TargetStatusMatrix = reshape(TargetStatusVector,g_MaxNumberTargets,g_MaxNumberVehicles);

%TargetsAttackedVector is a signal from each of the vehicles reporting an attack on any of the targets
iCurrentRow = iLastRow + 1;
iCurrentVectorSize = g_MaxNumberVehicles;	
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
TargetsAttackedVector = InputVector(iCurrentRow:iLastRow);
TargetsAttackedVector = TargetsAttackedVector(TargetsAttackedVector > 0);%only save for targets that have been attack
if (isempty(TargetsAttackedVector)),
	TargetsAttackedVector = 0;
end;

if((VehicleID == 6)),
	DebugStop=1;
end;
OutputVector(OutputSize) = 0;	%check to see if any target on tracked by this vehicle has changed status
for iCountTarget=1:g_MaxNumberTargets,
	
	% assuming all of the vehicle's assessments of the targets status are correct save hiiCountTargete for each target
	[NewStatus,iIndex] = max(TargetStatusMatrix(iCountTarget,:));
	OutputVector(iCountTarget) = NewStatus;
	StateInputValue = rem(NewStatus,g_TargetStates.IncAttack);
	StateInputNumberAttacks = fix(rem(NewStatus,g_TargetStates.IncReset)/g_TargetStates.IncAttack);
	StateInputResetNumber = fix(NewStatus/g_TargetStates.IncReset);
	
	CheckStatus = 0;
	
	% check to see if any of the vehicles have attacked this target
	ThisTargetAttacked = find(TargetsAttackedVector==iCountTarget);
	NumberAttacks = length(ThisTargetAttacked);
	LastTaskCompleted = g_Tasks.Undefined;
	if(NumberAttacks > g_VehicleMemory(VehicleID).TargetManager.TotalAttacks(iCountTarget)),
		g_VehicleMemory(VehicleID).TargetManager.TotalAttacks(iCountTarget) = NumberAttacks;
		if(StateInputValue <= g_TargetStates.StateAttackedNotKilled),
			CheckStatus = 1;
		end;	%if(NewStatus < g_Tasks.Attack),
		LastTaskCompleted = g_Tasks.Attack;
	end;	%if(exist('ThisTargetAttacked')),
	
	%check to see if the local vehicle has completed a task with respect to this target
	if(LastTaskTarget == iCountTarget),
		if(LastTaskTask ~= g_VehicleMemory(VehicleID).TargetManager.LastCompletedTask),
			g_VehicleMemory(VehicleID).TargetManager.LastCompletedTask = LastTaskTask;
			CheckStatus = 1;
		end;
		if(LastTaskTask > LastTaskCompleted),
			LastTaskCompleted = LastTaskTask;
		end;
	end;	%if(LastTaskTarget == iCountTarget),
	
	if((NewStatus <= TargetStatusMatrix(iCountTarget,VehicleID))|(CheckStatus)), 
		%if status wasn't increase by another vehicle , calculate it here 
		%(also calculate if the target was attacked and the status is less than attacked)
		%run State Target Status State Machine 
		[StateInputValue,ExtraAttacks,ResetToLowerState] = TargetStatusState(VehicleID,iCountTarget,StateInputValue,CombinedATRVector(iCountTarget), ...
			LastTaskCompleted,NumberAttacks,BDAVector(iCountTarget), ...
			StateInputNumberAttacks,VehicleTime,NumberValidHeadings(iCountTarget));
		StateInputResetNumber = StateInputResetNumber + ResetToLowerState;
		NewStatus = (StateInputResetNumber*g_TargetStates.IncReset) + (ExtraAttacks*g_TargetStates.IncAttack) + StateInputValue;
		OutputVector(iCountTarget) = NewStatus;
	end;	%if(NewStatus(iCountTarget) <= TargetStatusMatrix(iCountTarget,VehicleID)),
% 	OldTargetState = TargetStatusMatrix(iCountTarget,VehicleID);
	OldTargetState = g_VehicleMemory(VehicleID).TargetManager.LastReportedState(iCountTarget);
	if(OldTargetState ~= NewStatus),
		g_VehicleMemory(VehicleID).TargetManager.LastReportedState(iCountTarget) = NewStatus;
		OutputVector(OutputSize) = 1;	%target has changed status for this vehicle
		
		g_VehicleMemory(VehicleID).MonteCarloMetrics.TargetStateTimes(iCountTarget,StateInputValue) = VehicleTime;
		%% print out message for state change
		if(StateInputValue > 0),
			StringTemp = g_TargetStates.StateStrings{StateInputValue};
		else,
			StringTemp = 'Unknown State';
		end;
		DisplayString = ' ';
		switch(StateInputValue),
		case g_TargetStates.StateNotDetected,
			DisplayString = sprintf('%3.2f Vehicle#%d: Target #%d''s state has been changed to: "%s".', ...
				VehicleTime,VehicleID,iCountTarget,StringTemp);
		case g_TargetStates.StateDetectedNotClassified,
			DisplayString = sprintf('%3.2f Vehicle#%d: Target #%d''s state has been changed to: "%s". ATR Metric = %g', ...
				VehicleTime,VehicleID,iCountTarget,StringTemp,CombinedATRVector(iCountTarget));
		case g_TargetStates.StateClassifiedNotAttacked,
			DisplayString = sprintf('%3.2f Vehicle#%d: Target #%d''s state has been changed to: "%s". ATR Metric = %g', ...
				VehicleTime,VehicleID,iCountTarget,StringTemp,CombinedATRVector(iCountTarget));
		case g_TargetStates.StateAttackedNotKilled,
			DisplayString = sprintf('%3.2f Vehicle#%d: Target #%d''s state has been changed to: "%s".', ...
				VehicleTime,VehicleID,iCountTarget,StringTemp);
		case g_TargetStates.StateKilledNotConfirmed,
			DisplayString = sprintf('%3.2f Vehicle#%d: Target #%d''s state has been changed to: "%s".', ...
				VehicleTime,VehicleID,iCountTarget,StringTemp);
		case g_TargetStates.StateConfirmedKill,
			DisplayString = sprintf('%3.2f Vehicle#%d: Target #%d''s state has been changed to: "%s".', ...
				VehicleTime,VehicleID,iCountTarget,StringTemp);
		otherwise,	
			DisplayString = sprintf('%3.2f Vehicle#%d: Target #%d''s state has been changed to: "%s".', ...
				VehicleTime,VehicleID,iCountTarget,StringTemp);
		end;	%switch(MajorStateNew),
		disp(DisplayString);
	end;	%if(TargetStatusMatrix(iCountTarget,VehicleID) ~= NewStatus),
end;	%for iCountTarget=1:g_MaxNumberTargets

return;	%InputVector


