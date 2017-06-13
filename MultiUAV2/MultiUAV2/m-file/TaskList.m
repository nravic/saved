 function [UnassignedTaskFlag] = TaskList(InputVector)
 %TaskList - used to setup the inputs to the MultiTaskAssign function 
 %
 %  Inputs:
 %    InputVector - the status of every target 
 %
 %
 %  Outputs:
 %    UnassignedTaskFlag - This flag is set if there are any unassigned tasks after the update
 %
 
 %  AFRL/VACA
 %  July 2002 - Created and Debugged - RAS
 
 
 
 global g_Debug; if(g_Debug==1),disp('TaskList.m');end; 
 
 global g_MaxNumberTargets;
 global g_VehicleMemory;
 global g_Tasks;
 
UnassignedTaskFlag = 0;

 % Vehicle ID
 iCurrentRow = 1;
 iCurrentVectorSize = 1;
 iLastRow = iCurrentRow + iCurrentVectorSize - 1;
 VehicleID = InputVector(iCurrentRow:iLastRow);
 
  if(VehicleID<=0),		%I don't know exactly why the VehicleID is zero, but I suspect it is a problem turning off the vehicle when it is killed
	 return;
 end;
 
 
%Target Status (state)- 
 iCurrentRow = iLastRow+1;
 iCurrentVectorSize = g_MaxNumberTargets;
 iLastRow = iCurrentRow + iCurrentVectorSize - 1;
 TargetStatusVector = InputVector(iCurrentRow:iLastRow);
 
 for (iCountTargets = 1:g_MaxNumberTargets),
	RequiredTask = FindRequiredTask(TargetStatusVector(iCountTargets));	
	if(RequiredTask > g_Tasks.ContinueSearching),
		if((RequiredTask-1) > 0),
			g_VehicleMemory(VehicleID).CooperationManager.TaskList(iCountTargets,[1:RequiredTask-1]) = g_Tasks.Completed;
		end;
		if(g_VehicleMemory(VehicleID).CooperationManager.TaskList(iCountTargets,RequiredTask) == g_Tasks.NotInPlay),
			g_VehicleMemory(VehicleID).CooperationManager.TaskList(iCountTargets,[RequiredTask:end]) = g_Tasks.Unassigned;
		elseif(g_VehicleMemory(VehicleID).CooperationManager.TaskList(iCountTargets,RequiredTask) == g_Tasks.Unassigned),
			UnassignedFlag = 0;
		end;
	end;	%if(RequiredTask > g_Tasks.ContinueSearching),
	 
 end;	%for (iCountTargets = 1:g_MaxNumberTargets),
UnassignedTaskFlag = +(~isempty(find(g_VehicleMemory(VehicleID).CooperationManager.TaskList == g_Tasks.Unassigned)));	 
 
return; %TaskList
