function [TaskFailedFlag] = TaskFailed(Time,InputVector)
%TaskFailed - used to check whether or not a task has failed 
%
%  Inputs:
%    InputVector - 
%        - Target Assignment 
%        - Task Assignment 
%        - the status of all targets 
%
%
%  Outputs:
%    TaskFailedFlag - This flag is set if there are any tasks that failed
%

%  AFRL/VACA
%  July 2002 - Created and Debugged - RAS
%  May 2003 - Added last target status check - RAS



global g_Debug; if(g_Debug==1),disp('TaskFailed.m');end; 

global g_MaxNumberTargets;
global g_TargetStates;
global g_WaypointTypes;
global g_Tasks;
global g_WaypointCells;
global g_WaypointDefinitions;
global g_CommunicationMemory;

TaskFailedFlag = 0;

UnassignedTaskFlag = 0;

iCurrentRow = 1;
iCurrentVectorSize = 1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
VehicleID = InputVector(iCurrentRow:iLastRow);
if(VehicleID<=0),
	return;	%%??? is a dead vehicle trying to run this function ???
end;
% Target Assignment Last
iCurrentRow = iLastRow+1;
iCurrentVectorSize = 1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
TargetAssignmentPrevious = InputVector(iCurrentRow:iLastRow);

%Task Assignment last- 
iCurrentRow = iLastRow+1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
WaypointTypePrevious = InputVector(iCurrentRow:iLastRow);

%Task Assignment current- 
iCurrentRow = iLastRow+1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
WaypointTypeCurrent = InputVector(iCurrentRow:iLastRow);

%Target Status (state)- 
iCurrentRow = iLastRow+1;
iCurrentVectorSize = g_MaxNumberTargets;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
TargetStatusVector = InputVector(iCurrentRow:iLastRow);

%Last Target Status (state)- 
iCurrentRow = iLastRow+1;
iCurrentVectorSize = g_MaxNumberTargets;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
TargetStatusVectorLast = InputVector(iCurrentRow:iLastRow);

iCurrentRow = iLastRow+1;
iCurrentVectorSize = 1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
WaypointNumber = InputVector(iCurrentRow:iLastRow);

switch WaypointTypePrevious,
case g_WaypointTypes.Classify,
	TaskAssignmentPrevious = g_Tasks.Classify;
case g_WaypointTypes.Attack,
	TaskAssignmentPrevious = g_Tasks.Attack;
case g_WaypointTypes.Verify,
	TaskAssignmentPrevious = g_Tasks.Verify;
otherwise
	TaskAssignmentPrevious = g_Tasks.Undefined;
end

% check to see if last assigned task failed
if((TaskAssignmentPrevious~=g_Tasks.Undefined)&((TargetAssignmentPrevious > 0)&(TargetAssignmentPrevious<=g_MaxNumberTargets)))
	TargetState = TargetStatusVector(TargetAssignmentPrevious);
	TargetStateLast = TargetStatusVectorLast(TargetAssignmentPrevious);
	if(TargetState <= g_TargetStates.StateNotDetected),	%assigned target not yet detected ERROR
		TaskName = g_Tasks.TaskStrings(RequiredTaskCurrent+1);
		DisplayLine = sprintf ('%g Vehicle#%d: Is assigned to perform %s on Target#%d, but the state of this target is %d.', ...
			Time,VehicleID,TaskName{:},TargetAssignmentPrevious,TargetState);  
		disp(DisplayLine);
		return;
	end;
	if((TargetState==TargetStateLast)&(WaypointTypePrevious==WaypointTypeCurrent)),
		return;		%this happens when another target changes state
	end;
	RequiredTaskCurrent = FindRequiredTask(TargetState);	
	if(TargetState == g_TargetStates.StateUnknownTarget),
		TaskFailedFlag = g_CommunicationMemory.Messages{g_CommunicationMemory.MsgIndicies.TriggerReplan}.ReplanReset;	 
	else,
		TaskFailedFlag = g_CommunicationMemory.Messages{g_CommunicationMemory.MsgIndicies.TriggerReplan}.ReplanReset * ...
							((TaskAssignmentPrevious>g_Tasks.ContinueSearching)&(TaskAssignmentPrevious == RequiredTaskCurrent));	 
	end;
	if (TaskFailedFlag > 0),
		TaskName = g_Tasks.TaskStrings(TaskAssignmentPrevious+1);
		DisplayLine = sprintf ('%g Vehicle#%d: ** Failed %s on Target#%d',Time,VehicleID,TaskName{:},TargetAssignmentPrevious);  
		disp(DisplayLine);
	end
end;	%if((TargetAssignmentPrevious > 0)|(TargetAssignmentPrevious<=g_MaxNumberTargets))

%check to see if any of the assigned tasks were completed by another vehicle
if(WaypointNumber > 0),
	FutureWaypointIndex = WaypointNumber+2; %waypointindex is zero-based index. Need to skip the current waypoint. This assumes that if the vehicle is currently heading towards a waypoint with a task and that task gets done by a differnet vehicle, then this vehilce will also do that task.
	TasksTargets = g_WaypointCells{VehicleID}([(FutureWaypointIndex):end],[g_WaypointDefinitions.WaypointType,g_WaypointDefinitions.TargetHandle]);
	TasksTargetsIndex = find(TasksTargets(:,2)>0);
	NumberTasks = length(TasksTargetsIndex);
	if(NumberTasks>0),
		AssignedTasks = rem(TasksTargets(TasksTargetsIndex,1),g_WaypointTypes.QualifierMultiple) - 2; %!!! have to subtract 2 because of different definitions!!!!
		for(CountTasks=1:NumberTasks),
			RequiredTask = FindRequiredTask(TargetStatusVector(TasksTargets(TasksTargetsIndex(CountTasks),2)));	
			if(RequiredTask > AssignedTasks(CountTasks)),
				TaskFailedFlag = g_CommunicationMemory.Messages{g_CommunicationMemory.MsgIndicies.TriggerReplan}.ReplanNoReset;	 
				TaskName = g_Tasks.TaskStrings(RequiredTask);
				fprintf ('%g Vehicle#%d: ** %s on Target#%d was completed by another vehicle!\n',Time,VehicleID,TaskName{:},TasksTargets(TasksTargetsIndex(CountTasks),2));  
				return;
			end;
		end;
	end;
end;	%if(WaypointNumber > 0),

return; %TaskFailed
