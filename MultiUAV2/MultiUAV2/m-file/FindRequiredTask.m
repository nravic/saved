function [RequiredTask] = FindRequiredTask(TargetState);
%FindRequiredTask - this function returns a task type based on the given target state
%
%  Inputs:
%    TargetState - state of the target 
%
%  Outputs:
%    RequiredTask - task required to change the target's state.
%

%  AFRL/VACA
%  April 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('FindRequiredTask.m');end; 

global g_Tasks;
global g_TargetStates;

switch (rem(TargetState,g_TargetStates.IncAttack)),
case g_TargetStates.StateNotDetected,
	RequiredTask = g_Tasks.ContinueSearching;
case g_TargetStates.StateDetectedNotClassified,
	RequiredTask = g_Tasks.Classify;
case g_TargetStates.StateClassifiedNotAttacked,
	RequiredTask = g_Tasks.Attack;
case g_TargetStates.StateAttackedNotKilled,
	RequiredTask = g_Tasks.Attack;
case g_TargetStates.StateKilledNotConfirmed,
	RequiredTask = g_Tasks.Verify;
case g_TargetStates.StateConfirmedKill,
	RequiredTask = g_Tasks.TasksComplete;
case g_TargetStates.StateUnknownTarget,
	RequiredTask = g_Tasks.TasksComplete;
otherwise,
	DisplayString = sprintf('ERROR(FindRequiredTask): Unknown target state encountered (%d)',rem(TargetState,g_TargetStates.IncAttack));
	disp(DisplayString);
	RequiredTask = g_Tasks.ContinueSearching;
end;	%switch TargetState,

return;	%FindRequiredTask
