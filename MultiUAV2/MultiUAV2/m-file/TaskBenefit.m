function [TaskValue] = TaskBenefit(CurrentTime,RequiredTask,iCountVehicles,iCountTargets,TargetTypeStruct,ETAMatrix,TargetToSearchMatrix);
%TaskBenefit - calculate the bennefit of the specified vehicle performing a specified task on the specified target.. 
%
%  Inputs:
%    RequiredTask - task required to increase the state of the target
%    iCountVehicles - vehicle ID
%    iCountTargets - target ID
%    TargetTypeStruct - truth information for the target
%    ETAMatrix - matrix of estimated time of arrivals for all of the vehicles to all of the known targets
%    TargetToSearchMatrix - matrix of distances from each target back to the search pattern for each vehicle
%
%  Outputs:
%    TaskValue - value of this vehicle performing the required task.
%

%  AFRL/VACA
%  Summer 2001 - Created and Debugged - COREY

% more information will need to be passed in about vehicle state.
% for starting purposes this information will be hard-coded here. 
% iCountVehicles, iCountTargets are placeholders signifying information about
% the vehicles and targets that may need to be passed in (such as target types). 

% Probabilities modified by Schumacher 4/22/02
% Added Dunkel's probabilities 8/03 - RAS

global g_Debug; if(g_Debug==1),disp('TaskBenefit.m');end; 

global g_Tasks
global g_ProbabilityID;
global g_SensorWidth_m;
global g_VerificationOn;
global g_ProbabilityOfKill;
global g_StopTime;
global g_VehicleMemory;
global g_SimulationRunNumber;

Velocity = g_VehicleMemory(iCountVehicles).Dynamics.VTrueFPSInit;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%************************ New variables used by Dunkel, 21 Nov 2001 ***********************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TimeRemaining = g_StopTime - CurrentTime;
A = Velocity*g_SensorWidth_m*TimeRemaining;

%** The following parameters were manipulated to optimize the overall results.  Dunkel, 27 Nov 2001 ****
if g_SimulationRunNumber >= 1 & g_SimulationRunNumber <= 3
    Tgt2Value = 0.5;             %-1
    SearchWeight = 0;            %-1
elseif g_SimulationRunNumber >= 4 & g_SimulationRunNumber <= 6
    Tgt2Value = 0.5;             %-1
    SearchWeight = 0.5;          %+1
elseif g_SimulationRunNumber >= 7 & g_SimulationRunNumber <= 9
    Tgt2Value = 0.75;            %0
    SearchWeight = 0.25;         %0
elseif g_SimulationRunNumber >= 10 & g_SimulationRunNumber <= 12
    Tgt2Value = 1.0;             %+1
    SearchWeight = 0;            %-1
elseif g_SimulationRunNumber >= 13 & g_SimulationRunNumber <= 15
    Tgt2Value = 1.0;             %+1
    SearchWeight = 0.5;          %+1
end;


Tgt2Value = 1;
SearchWeight = 0.417295;

DensityTarget1 = 0.00774;
DensityTarget2 = 0.00774;
DensityTarget3 = 0.0;
DensityTarget4 = 0.05;
DensityTarget5 = 0.0;

%******************************* Calculated Values ***************************************
Ptr1 = g_ProbabilityID(1,1) + g_ProbabilityID(2,1) + g_ProbabilityID(3,1) + g_ProbabilityID(5,1);     % Given that real target type i is 
Ptr2 = g_ProbabilityID(1,2) + g_ProbabilityID(2,2) + g_ProbabilityID(3,2) + g_ProbabilityID(5,2);     % encountered, Ptri is the probability
Ptr3 = g_ProbabilityID(1,3) + g_ProbabilityID(2,3) + g_ProbabilityID(3,3) + g_ProbabilityID(5,3);     % that it will be declared as a target
Ptr5 = g_ProbabilityID(1,5) + g_ProbabilityID(2,5) + g_ProbabilityID(3,5) + g_ProbabilityID(5,5);     % of any type.

DensityTargets = DensityTarget1 + DensityTarget2 + DensityTarget3 + DensityTarget5;

if DensityTargets ~= 0
    Pe1 = DensityTarget1/DensityTargets;       % Given that a real target is encountered, Pei is 
    Pe2 = DensityTarget2/DensityTargets;       % the probability that it is target type i.
    Pe3 = DensityTarget3/DensityTargets;
    Pe5 = DensityTarget5/DensityTargets;
else
    Pe1 = 0;
    Pe2 = 0;
    Pe3 = 0;
    Pe5 = 0;
end

ProbabilityOfTargetReport = Ptr1*Pe1 + Ptr2*Pe2 + Ptr3*Pe3 + Ptr5*Pe5;  % Composite ProbabilityOfTargetReport based on individual Ptri's.

ProbabilityOfFalseTargetAttack = g_ProbabilityID(1,4) + g_ProbabilityID(2,4) + g_ProbabilityID(3,4) + g_ProbabilityID(5,4);   % Given that target type 4 is encountered, 
                                                    % ProbabilityOfFalseTargetAttack is the probability that it will be
                                                    % declared as a real target.

FalseTargetAttackRate = DensityTarget4 * ProbabilityOfFalseTargetAttack;    % False Target Attack Rate

ProbabilityOfRealTarget = ProbabilityOfTargetReport*DensityTargets/(ProbabilityOfTargetReport*DensityTargets + ProbabilityOfFalseTargetAttack*DensityTarget4);    % Given a target report, the 
                                                                        % probability that it is a
                                                                        % real target.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



TaskValue = 0;

% Maximum flight time: (seconds)
T_limit = 30*60;

% Time of flight remaining:
Tf = 5*60; 	% will vary for each calculation, this is just a starting value
Tf = 15*60;
% Time required to do a non-attack, non-search task (BDA,Classify):
% Should be an input based on path length to return to previous search waypoints.
% Will be hard-coded at present.

%Tbda = 2*60;
%Tclassify = Tbda;
%Velocity = 426;		% ft/s, nominal .. should be an input, but presently is 
% set to match the commanded flight speed.

ETAs = ETAMatrix/Velocity;  %Changed to 'Velocity' from 'Flight_Speed' Schulz 14 Nov 02
SearchETA = TargetToSearchMatrix/Velocity; %Changed to 'Velocity' from 'Flight_Speed' Schulz 14 Nov 02

switch (RequiredTask),
case g_Tasks.ContinueSearching,
	% 	% in this case SearchBenefit is called
	% 	TaskValue = SearchBenefit(iCountVehicles,Tf);
	%************************ Dunkel's Benefit Calculation, 21 Nov 2001 ********************************
	Pss = (g_ProbabilityOfKill*ProbabilityOfTargetReport*DensityTargets)/(FalseTargetAttackRate+ProbabilityOfTargetReport*DensityTargets)*(1-exp(-(FalseTargetAttackRate+ProbabilityOfTargetReport*DensityTargets)*A));
	TaskValue = SearchWeight*Pss;
	%***************************************************************************************************
	
case g_Tasks.Classify,
	% 	Patr = 0.6;		% previous ATR quality, should be an input, hardset here
	% 	g_ProbabilityOfKill = 0.8;		% Probability of killing a target of a given type. Hard-coded here,
	%    					% but should be part of the target structure information.
	% 	Val = TargetTypeStruct.TargetValue;
	% 	if Val == 0
	% 		Val = 3*(1-Patr);		%Assigns a value to verifying a potential non-target as a non-target
	% 	end   
	% 	%  Tclassify = ETAs(iCountVehicles,iCountTargets)  + SearchETA(iCountVehicles,iCountTargets);  %+60;  %
	% 	Tclassify = ETAs(iCountVehicles,iCountTargets) + 60;  % + SearchETA(iCountVehicles,iCountTargets);  %+60;  %
	% 	TaskValue = Patr*g_ProbabilityOfKill*Val+ SearchBenefit(iCountVehicles,Tf-Tclassify);
	%     
	%     %*************************** Dunkel's Benefit Calculation, 21 Nov 2001 ***********************
	%The classification benefit is identical to the attack benefit, thus a re-classification will only occur
	%if it is beneficial to attack the target (assuming the previous classification is correct).
	Epsilon = 0.01;
	Pss = Epsilon*(g_ProbabilityOfKill*ProbabilityOfTargetReport*DensityTargets)/(FalseTargetAttackRate+ProbabilityOfTargetReport*DensityTargets)*(1-exp(-(FalseTargetAttackRate+ProbabilityOfTargetReport*DensityTargets)*Velocity*g_SensorWidth_m*(TimeRemaining-ETAs(iCountVehicles,iCountTargets))));
	if Pss < 0
		Psa = 0;
	elseif ETAs(iCountVehicles,iCountTargets) < 8
		Psa = g_ProbabilityOfKill*ProbabilityOfRealTarget;
	else
		Psa = g_ProbabilityOfKill*ProbabilityOfTargetReport*ProbabilityOfRealTarget + Pss*(1-ProbabilityOfTargetReport)*ProbabilityOfRealTarget + Pss*(1-ProbabilityOfFalseTargetAttack)*(1-ProbabilityOfRealTarget);
	end
	NumAttacks = g_VehicleMemory(iCountVehicles).TargetManager.TotalAttacks(iCountTargets);
	if NumAttacks >= 2
		Alive = 0;
	else
		Alive = 1;
	end
	if g_VehicleMemory(iCountVehicles).TargetManager.SensedTargetType(iCountTargets) == 1
		TaskValue = (1-SearchWeight)*(1-g_ProbabilityOfKill)^NumAttacks*Psa;
		%      TaskValue = (1-SearchWeight)*(TimeRemaining-ETAs(iCountVehicles,iCountTargets))/TimeRemaining*Alive*Psa;
	end
	if g_VehicleMemory(iCountVehicles).TargetManager.SensedTargetType(iCountTargets) == 2
		TaskValue = (1-SearchWeight)*(Tgt2Value)*(1-g_ProbabilityOfKill)^NumAttacks*Psa;
		%      TaskValue = (1-SearchWeight)*(Tgt2Value)*(TimeRemaining-ETAs(iCountVehicles,iCountTargets))/TimeRemaining*Alive*Psa;
	end
	%  if g_VehicleMemory(iCountVehicles).TargetManager.SensedTargetType(iCountTargets) == 4
	if (g_VehicleMemory(iCountVehicles).TargetManager.SensedTargetType(iCountTargets) ~= 1)&(g_VehicleMemory(iCountVehicles).TargetManager.SensedTargetType(iCountTargets) ~= 2)
		TaskValue = 0;
	end
	if TaskValue < 0
		TaskValue = 0;
	end
	%*********************************************************************************************  
	
case g_Tasks.Attack,
	% 	g_ProbabilityOfKill = 0.8;			% Probability of killing a target of this type. Hard-set here, but
	%    					% should be a part of target structure.
	% 	g_ProbabilityID = 0.9;		% Probability of correct classification, should be an input, 
	% 						% here set to the threshold level.
	% 	Val = TargetTypeStruct.TargetValue;
	% 	if (ETAs(iCountVehicles,iCountTargets)==0),
	% 		TaskValue = g_ProbabilityID*g_ProbabilityOfKill*Val*1.0;
	% 	else
	% 		TaskValue = g_ProbabilityID*g_ProbabilityOfKill*Val*min(ETAs(:,iCountTargets))/ETAs(iCountVehicles,iCountTargets);
	% 	end;
	
	%*************************** Dunkel's Benefit Calculation, 21 Nov 2001 ***********************
	Epsilon = 0.01;
	Pss = Epsilon*(g_ProbabilityOfKill*ProbabilityOfTargetReport*DensityTargets)/(FalseTargetAttackRate+ProbabilityOfTargetReport*DensityTargets)*(1-exp(-(FalseTargetAttackRate+ProbabilityOfTargetReport*DensityTargets)*Velocity*g_SensorWidth_m*(TimeRemaining-ETAs(iCountVehicles,iCountTargets))));
	if Pss < 0
		Psa = 0;
	elseif (TimeRemaining-ETAs(iCountVehicles,iCountTargets)) < 8
		Psa = g_ProbabilityOfKill*ProbabilityOfRealTarget;
	else
		Psa = g_ProbabilityOfKill*ProbabilityOfTargetReport*ProbabilityOfRealTarget + Pss*(1-ProbabilityOfTargetReport)*ProbabilityOfRealTarget + Pss*(1-ProbabilityOfFalseTargetAttack)*(1-ProbabilityOfRealTarget);
	end
	NumAttacks = g_VehicleMemory(iCountVehicles).TargetManager.TotalAttacks(iCountTargets);
	if NumAttacks >= 2
		Alive = 0;
	else
		Alive = 1;
	end
	if g_VehicleMemory(iCountVehicles).TargetManager.SensedTargetType(iCountTargets) == 1
		TaskValue = (1-SearchWeight)*(1-g_ProbabilityOfKill)^NumAttacks*Psa;
		%      TaskValue = (1-SearchWeight)*(TimeRemaining-ETAs(iCountVehicles,iCountTargets))/TimeRemaining*Alive*Psa;
	end
	if g_VehicleMemory(iCountVehicles).TargetManager.SensedTargetType(iCountTargets) == 2
		TaskValue = (1-SearchWeight)*(Tgt2Value)*(1-g_ProbabilityOfKill)^NumAttacks*Psa;
		%      TaskValue = (1-SearchWeight)*(Tgt2Value)*(TimeRemaining-ETAs(iCountVehicles,iCountTargets))/TimeRemaining*Alive*Psa;
	end
	%  if g_VehicleMemory(iCountVehicles).TargetManager.SensedTargetType(iCountTargets) == 4
	if (g_VehicleMemory(iCountVehicles).TargetManager.SensedTargetType(iCountTargets) ~= 1)&(g_VehicleMemory(iCountVehicles).TargetManager.SensedTargetType(iCountTargets) ~= 2)
		TaskValue = 0;
	end
	if TaskValue < 0
		TaskValue = 0;
	end
	%*********************************************************************************************  
	
	
case g_Tasks.Verify,
	% Value of BDA: 
	% Based on value of attacking a target of that type, modified by the chance the target
	% survived the initial attack and the chance of successful BDA.
	Pbda = 1.00;		% Assumed initial effectiveness, could be modified for different
	% target type	
	%g_ProbabilityOfKill = 0.8;
	%g_ProbabilityID = 0.9;			% Probability of correct classification, should be an input, 
	% here set to the threshold level.
	Val = TargetTypeStruct.TargetValue;
	%    Tbda = ETAs(iCountVehicles,iCountTargets)  +SearchETA(iCountVehicles,iCountTargets);   
	Tbda = ETAs(iCountVehicles,iCountTargets)  + 60 ; 
	if(g_VerificationOn),
% 		TaskValue = Pbda*(1-g_ProbabilityOfKill)*g_ProbabilityID*Val + SearchBenefit(iCountVehicles,Tf-Tbda); %Commented out by Schulz 14 Nov 02. 
		TaskValue = Pbda*(1-g_ProbabilityOfKill)*Val + SearchBenefit(iCountVehicles,Tf-Tbda); %Commented out by Schulz 14 Nov 02. 
	else,
		TaskValue = 0; %see above comment Schulz 14 Nov 02   % no BDA using Steves method.
	end;
	
end

if TaskValue < 0
	TaskValue = 0;
end

if TaskValue > 9999
	TaskValue = 9999;
end

return	%function TaskBenefit

