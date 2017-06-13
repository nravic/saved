function [TargetState] = FindTargetState(RequiredTask);
%FindTargetState - this function returns a target state based on the required task for the state
%
%  Inputs:
%    RequiredTask - task required to change the target's state.
%
%  Outputs:
%    TargetState - state of the target 
%

%  AFRL/VACA
%  September 2003 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('FindTargetState.m');end; 

global g_Tasks;
global g_TargetStates;

switch (RequiredTask),
case g_Tasks.ContinueSearching,
	TargetState = g_TargetStates.StateNotDetected;
case g_Tasks.Classify,
	TargetState = g_TargetStates.StateDetectedNotClassified;
case g_Tasks.Attack,
	TargetState = g_TargetStates.StateClassifiedNotAttacked;
case g_Tasks.Attack,
	TargetState = g_TargetStates.StateAttackedNotKilled;
case g_Tasks.Verify,
	TargetState = g_TargetStates.StateKilledNotConfirmed;
case g_Tasks.TasksComplete,
	TargetState = g_TargetStates.StateConfirmedKill;
otherwise,
	fprintf('ERROR(FindTargetState): Unknown required task encountered (%d)',Task);
	TargetState = g_TargetStates.StateNotDetected;
end;	%switch TargetState,

return;	%FindRequiredTask
