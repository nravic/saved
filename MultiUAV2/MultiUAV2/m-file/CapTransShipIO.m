function [OutputVector] = CapTransShipIO(action,InputVector,CurrentTime)
%CapTransShipIO - used to setup the inputs to the CapTransShip s-function 
%
%  Inputs:
%    action - The type of function call. Implemented values are:
%      'Input' - create a input vector for the Capacitative Transshipment 
%        Solver based on the InputVector.
%    InputVector - the data in the InputVector changes based on the value of "action"  
%      action-> 'Input'
%        InputVector(1) - current time
%        InputVector(2) - vehicle ID number for the current vehicle
%        InputVector(...) - a vector contaninig the time each vehicle last replanned
%        InputVector(...) - a vectorized matrix containing the estimated time of arrival
%          for each vehicle to each target.
%        InputVector(...) - a vectorized matrix contaning the cost for each vehicle to 
%          each target.
%          Note: cost is currently not being used in the assignment calculations
%
%
%  Outputs:
%    OutputVector - the data contained in OutputVector changes based on the value of "action"  
%      action-> 'Input'
%        OutputVector(1) - number vehicles in the assignment
%        OutputVector(2) - number targets in the assignment
%        OutputVector(3) - number tasks in the assignment
%        OutputVector(4:4+number vehicles) - benefit of assigning each vehicle to 
%                      continue to search
%        OutputVector(...:...) - benefit of assigning vehicle 1 to 
%                      each target for task 1
%           .
%           .
%           .
%        OutputVector(...:...) - benefit of assigning vehicle n to 
%                      each target for task 1
%           .
%           .
%           .
%        OutputVector(...:...) - benefit of assigning vehicle 1 to 
%                      each target for task m
%           .
%           .
%           .
%        OutputVector(...:...) - benefit of assigning vehicle n to 
%                      each target for task m
%

%  AFRL/VACA
%  March 2001 - Created and Debugged - RAS
%  July 2001 - Modification - SCHUMACHER
%  August 2003 - Added check to make sure vehicle is enabled before calculating bennefits for it


global g_Debug; if(g_Debug==1),disp('CapTransShipIO.m');end; 

global g_MaxNumberVehicles;
global g_MaxNumberTargets;
global g_TargetMemory;	%truth information
global g_TargetTypes;
global g_EnableVehicle;
global g_VehicleMemory;
global g_Tasks;
global g_OptionAssignmentWeight;
switch action
	
case 'Input'
	%current vehicle ID
	iFirstRow = 1;
	iCurrentVectorSize = 1;
	VehicleID = InputVector(iFirstRow);
	
	%Target Status/desired heading
	iFirstRow = iFirstRow + iCurrentVectorSize;
	iCurrentVectorSize = g_MaxNumberTargets;
	iLastRow = iFirstRow + iCurrentVectorSize - 1;
	TargetStatus = InputVector(iFirstRow:iLastRow);
	
	%time for vehicle to get to each known target
	iFirstRow = iLastRow + 1;
	iCurrentVectorSize = (g_MaxNumberVehicles * g_MaxNumberTargets * 3) + g_MaxNumberVehicles;
	iLastRow = iFirstRow + iCurrentVectorSize - 1;
	TimeCostETAVector = InputVector(iFirstRow:iLastRow);
	TimeCostETAMatrix = reshape(TimeCostETAVector,(g_MaxNumberTargets*3)+1,g_MaxNumberVehicles);
	
	%check to see if each vehicle has attacked a target (is it dead?)
	iFirstRow = iFirstRow + iCurrentVectorSize;
	iCurrentVectorSize = g_MaxNumberVehicles;
	iLastRow = iFirstRow + iCurrentVectorSize - 1;
	VehicleAttackStatus = InputVector(iFirstRow:iLastRow);
	
	iFirstRow = 1;
	ReplanTimes = TimeCostETAMatrix(1,:)';
	[iRowsTimes,iColsTimes]=size(ReplanTimes);
	
	iFirstRow = 2;
	iCurrentVectorSize = g_MaxNumberTargets;
	iLastRow = iFirstRow + iCurrentVectorSize - 1;
	CostMatrix = TimeCostETAMatrix(iFirstRow:iLastRow,:)';
	iFirstRow = iLastRow + 1;
	iLastRow = iFirstRow + iCurrentVectorSize - 1;
	ETAMatrix = TimeCostETAMatrix(iFirstRow:iLastRow,:)';
	iFirstRow = iLastRow + 1;
	iLastRow = iFirstRow + iCurrentVectorSize - 1;
	TargetToSearchMatrix = TimeCostETAMatrix(iFirstRow:iLastRow,:)';
	
	
	TimeDelay = g_VehicleMemory(VehicleID).CooperationManager.AssignmentTimeDelay;
	
	% find the vehicles that are eligble for reassignment
	for iCount = 1:iRowsTimes
		VehicleTime = ReplanTimes(iCount);
		if ((VehicleTime < 0)|((VehicleTime < (CurrentTime - TimeDelay))|(VehicleTime > CurrentTime)))
			CostMatrix(iCount,:) = realmax;
			ETAMatrix(iCount,:) = realmax;
		end   
	end
	
	
	OutputVector = zeros(3 + g_MaxNumberVehicles + g_MaxNumberVehicles*g_MaxNumberTargets*g_Tasks.NumberTasks,1); %defaults all values to 0
	
	OutputIndex = 1;
	OutputVector(OutputIndex) = g_MaxNumberVehicles;
	OutputIndex = OutputIndex + 1;
	OutputVector(OutputIndex) = g_MaxNumberTargets;
	OutputIndex = OutputIndex + 1;
	OutputVector(OutputIndex) = g_Tasks.NumberTasks;
	
	DebugVehicle = 1; 
	%DebugVehicle = 10000; % don't do debug
	if(VehicleID == DebugVehicle),
		iDebugFlag = 1.0;
	else
		iDebugFlag = 0.0;
	end;
	
	if (iDebugFlag),	% save data file for debugging
		% save test file for comparison
		FID = fopen('CTPSave.txt','w+');
		fprintf(FID,'%d %d \r\n',g_MaxNumberVehicles,g_MaxNumberTargets);
		fprintf(FID,'\r\n\r\n');
	end;	%if (iDebugFlag),
	
	ContinueToSearchBennifit = 1.0;
	% Modification by Corey Schumacher 7/3/01:
	OutputScale = 1e4;
%		???????????????????????????????????????????????????????
	OutputIndex = OutputIndex + 1;
	for iCountVehicles = 1:g_MaxNumberVehicles,
		%  orkoorkoooooooooooooooooooooooooooooooooooooooooooooo
		%******************** Dunkel's modification to Search Benefit *****************************
		SearchTask = g_Tasks.ContinueSearching;      
		OutputVector(OutputIndex) = TaskBenefit(CurrentTime,SearchTask,1,1,1,ETAMatrix,1)*OutputScale;
		%***************************** End Dunkel Mod, 21 Nov 2001 ********************************
		
		%ORKOOOOOOOOOOOOOOOOOOOOOOOOOOOO
		%         %	OutputVector(OutputIndex) = CalculateBenefit(iCountVehicles,0,0);
		% 		% ************** Corey's modifiction to Search Benefit ********************
		% 		Tf = 5*60;
		% 		Tf = 15*60;
		% 		OutputVector(OutputIndex)=SearchBenefit(iCountVehicles,Tf)*OutputScale;
		% 		% 
		% 		%OutputVector(OutputIndex) = ContinueToSearchBennifit;
		% 		% ***************************************************************************
		if (iDebugFlag),	% save data file for debugging
			fprintf(FID,'%d %d %d %d \r\n',iCountVehicles,0.0,0.0,round(OutputVector(OutputIndex)));
		end;	%if (iDebugFlag),
		OutputIndex = OutputIndex + 1;
	end;	%for iCountVehicles = 1:g_MaxNumberVehicles,
	
	for iCountTasks = 1:(g_Tasks.NumberTasks-1),	% don't include continue to search here
		for iCountVehicles = 1:g_MaxNumberVehicles,
			if ((VehicleAttackStatus(iCountVehicles)==0)&(g_EnableVehicle(iCountVehicles)~=0))	% if this vehicle attacked a target then it is dead.
				for iCountTargets = 1:g_MaxNumberTargets,
					%OutputVector(OutputIndex) = CalculateBenefit(iCountVehicles,iCountTargets,iCountTasks);
					RequiredTask = FindRequiredTask(TargetStatus(iCountTargets));
					if (RequiredTask == iCountTasks ),
						% TODO:: call function to calculate bennifit here
						
						%********** Modified so that benefits are calculated using sensed information instead ****************
						%********** of truth information.  Dunkel, 11 Oct 2001                                ****************
						TargetTruth = g_TargetMemory(iCountTargets);
						TargetTypestruct = g_TargetTypes(TargetTruth.Type);
						g_VehicleMemory(iCountVehicles).TargetManager.SensedTargetType(iCountTargets) = 1.0;
						%??????????????????????????????????????????????????????????????????????????????????????????????????
						%???????????????????This is not correct, the "sensed" target type needs to be passed on the wires.
						%SensedTargetType = g_VehicleMemory(iCountVehicles).TargetManager.SensedTargetType(iCountTargets);
						%??????????????????????????????????????????????????????????????????????????????????????????????????
						%Check to make sure SensedTargetType is not 0.  If it is, set TargetTypestruct equal 
						%to a non-target.  Dunkel, 17 Oct 2001
% 						if SensedTargetType ~= 0
% 							TargetTypestruct = g_TargetTypes(SensedTargetType);
% 						else
% 							TargetTypestruct = g_TargetTypes(4);
% 						end
						%********************************* End Dunkel mod, 11 Oct 2001 **************************************  
						
						% 						TargetTruth = g_TargetMemory(iCountTargets);         ORKOOOOOOOOOOO
						% 						TargetTypestruct = TargetTypes(TargetTruth.Type);   ORKOOOOOOOOOOO
						%                   
						% Modifications (Corey Schumacher) 7/3/01      
						%if ((RequiredTask~=g_Tasks.Attack)|(TargetTypestruct.IsTarget == 1))
						%if (ETAMatrix(iCountVehicles,iCountTargets) == 0),
						%OutputVector(OutputIndex) = OutputScale;
						%else,
						%OutputVector(OutputIndex) = (1.0/ETAMatrix(iCountVehicles,iCountTargets))*OutputScale;
						%end;	%if (ETAMatrix(iCountVehicles,iCountTargets) == 0),
						%else,	%if ((RequiredTask~=g_Tasks.Attack)|(TargetTypestruct.IsTarget == 1))
						%OutputVector(OutputIndex) = 0.0;
						%end;	%if ((RequiredTask~=g_Tasks.Attack)|(TargetTypestruct.IsTarget == 1))
						% Insert function to calculate Value of different tasks here (Schumacher 
						switch(g_OptionAssignmentWeight),
						case 1,
							if(RequiredTask == g_Tasks.Verify),
								if((iCountVehicles==8)),
									switch(iCountTargets),
									case 1,
										BDAMultiplier = 1.0;
									case 2,
										BDAMultiplier = 1.5;
									case 3,
										BDAMultiplier = 2.0;
									otherwise,
										BDAMultiplier = 1.0;
									end;	%switch(iCountTargets),
									
									%OutputVector(OutputIndex) = TaskBenefit(RequiredTask,iCountVehicles,iCountTargets,TargetTypestruct,ETAMatrix,TargetToSearchMatrix)*OutputScale;
									OutputVector(OutputIndex) = BDAMultiplier * TaskBenefit(CurrentTime,RequiredTask,iCountVehicles,iCountTargets,TargetTypestruct,ETAMatrix,TargetToSearchMatrix)*OutputScale;
								else,	%if((iCountVehicles==VerifyVehicle)|(AllVehiclesVerify)),
									OutputVector(OutputIndex) = 0.0;
								end;	%if((iCountVehicles==VerifyVehicle)|(AllVehiclesVerify)),
							else,	%if(RequiredTask == g_Tasks.Verify),
								OutputVector(OutputIndex) = TaskBenefit(CurrentTime,RequiredTask,iCountVehicles,iCountTargets,TargetTypestruct,ETAMatrix,TargetToSearchMatrix)*OutputScale;
							end;	%if(RequiredTask == g_Tasks.Verify),
						otherwise, 
							OutputVector(OutputIndex) = TaskBenefit(CurrentTime,RequiredTask,iCountVehicles,iCountTargets,TargetTypestruct,ETAMatrix,TargetToSearchMatrix)*OutputScale;
						end;	%switch(g_OptionAssignmentWeight),
						
					else,	%if (RequiredTask == iCountTasks ),
						OutputVector(OutputIndex) = 0.0;
					end;	%if (RequiredTask == iCountTasks ),
					if (iDebugFlag),	% save data file for debugging
						fprintf(FID,'%d %d %d %d \r\n',iCountVehicles,iCountTargets,iCountTasks,round(OutputVector(OutputIndex)));
					end;	%if (iDebugFlag),
					OutputIndex = OutputIndex + 1;
				end;	%for iCountTargets = 1:g_MaxNumberTargets,
			else,	%if (VehicleAttackStatus(iCountVehicles)~=1)
				OutputIndex = OutputIndex + g_MaxNumberTargets;
			end;	%if (VehicleAttackStatus(iCountVehicles)~=1)
		end;	%for iCountVehicles = 1:g_MaxNumberVehicles,
	end;	%for iCountTasks = 1:g_Tasks.NumberTasks,
	if(VehicleID==1)|(VehicleID==3),
		debugstop=1;
	end;
	if (iDebugFlag),	% save data file for debugging
		fprintf(FID,'-1 \r\n');
		fclose(FID);
	end;	%if (iSetUpFlag),
	%case 'Input'
	
otherwise,
	%error
end; %switch action

return;	%CapTransShipIO
