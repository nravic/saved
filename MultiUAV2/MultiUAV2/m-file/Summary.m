%Summary -- This script writes the final results of each run to a file.
%
%  Inputs:
%    (none) 
%
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  Oct 2001 - Created and Debugged - Dunkel


global g_VehicleMemory;
global g_TargetMemory;
global g_MaxNumberVehicles;
global g_MaxNumberTargets;
global g_Scenario;
global g_SimulationRunNumber;
global g_Seed;
global g_SummaryFileName;
global g_TargetStates;
global g_CommDelayMajorStepsSelf;
global g_CommDelayMajorStepsOther;
global g_CommDelayDiscHoldOrder;


%Determine which vehicle was the last vehicle alive--this vehicle will have 
%the most complete information.
LastVehicle = 1;
TotalAttacks = sum(g_VehicleMemory(1).TargetManager.TotalAttacks);
MaxAliveTimeSeconds = -1.0;
for CountVehicles = 1:g_MaxNumberVehicles
	if (g_VehicleMemory(CountVehicles).MonteCarloMetrics.AliveTimeSeconds > MaxAliveTimeSeconds),
		MaxAliveTimeSeconds = g_VehicleMemory(CountVehicles).MonteCarloMetrics.AliveTimeSeconds;
		LastVehicle = CountVehicles;
	end
end

%Determine how many targets and false targets were attacked
NumberAttackedFalseTgt = 0;
NumberAttackedTargets = 0;
for i = 1:g_MaxNumberTargets
	if g_VehicleMemory(LastVehicle).TargetManager.TotalAttacks(i) ~= 0
		if g_TargetMemory(i).Type == 4
			NumberAttackedFalseTgt = NumberAttackedFalseTgt + 1;
		else
			NumberAttackedTargets = NumberAttackedTargets + 1;
		end
	end
end

%Determine how many targets and false targets were killed
NumberKilledFalseTgt = 0;
NumberKilledTargets = 0;
for i = 1:g_MaxNumberTargets
	if g_TargetMemory(i).Alive == 0
		if g_TargetMemory(i).Type == 4
			NumberKilledFalseTgt = NumberKilledFalseTgt + 1;
		else
			NumberKilledTargets = NumberKilledTargets + 1;
		end
	end
end

%Determine how many false targets were attacked
NumberFalseTargetAttacks = 0;
for i = 1:g_MaxNumberTargets
	if (g_VehicleMemory(LastVehicle).TargetManager.TotalAttacks(i) ~= 0) & ...
			(g_TargetMemory(i).Type == 4);
		NumberFalseTargetAttacks = NumberFalseTargetAttacks + ...
			g_VehicleMemory(LastVehicle).TargetManager.TotalAttacks(i);
	end
end

%Determine the total number of attacks
NumberAttacksTargets = 0;
NumberAttacksFalseTgts = 0;
for i = 1:g_MaxNumberTargets
	if g_TargetMemory(i).Type ~= 4
		NumberAttacksTargets = NumberAttacksTargets + g_VehicleMemory(LastVehicle).TargetManager.TotalAttacks(i);
	else
		NumberAttacksFalseTgts = NumberAttacksFalseTgts + g_VehicleMemory(LastVehicle).TargetManager.TotalAttacks(i);
	end
end




%Determine the number of hits on targets of type 1 and targets of type 2
NumberAttacksTgt1 = 0;
NumberAttacksTgt2 = 0;
for i = 1:g_MaxNumberTargets
	if g_TargetMemory(i).Type == 1
		NumberAttacksTgt1 = NumberAttacksTgt1 + g_VehicleMemory(LastVehicle).TargetManager.TotalAttacks(i);
	end
	if g_TargetMemory(i).Type == 2
		NumberAttacksTgt2 = NumberAttacksTgt2 + g_VehicleMemory(LastVehicle).TargetManager.TotalAttacks(i);
	end
end

%Determine the number of verified targets
NumberVerifiedTargets = 0;
for CountTargets = 1:g_MaxNumberTargets
	if (g_VehicleMemory(LastVehicle).TargetManager.LastReportedState(CountTargets)),
		NumberVerifiedTargets = NumberVerifiedTargets + 1;
	end
end


%Calculate Total Search Time
SumTotalSearchTimeSeconds = 0;
for CountVehicles = 1:g_MaxNumberVehicles
	SumTotalSearchTimeSeconds = SumTotalSearchTimeSeconds + g_VehicleMemory(CountVehicles).MonteCarloMetrics.TotalSearchTimeSeconds;
end


%Calculate the overall value of the results
Formula = 2*NumberAttacksTgt1 + NumberAttacksTgt2 - NumberAttacksFalseTgts;




%Write information to a file
if (g_SimulationRunNumber == 1),
	permission = 'w';
else,
	permission = 'a';
end;

FID = fopen(g_SummaryFileName,permission);
if(FID==-1),
	disp(['Summary::ERROR unable to open ',g_SummaryFileName]);
else,
	
	if (g_SimulationRunNumber == 1),
    fprintf(FID, ...
			'%% g_CommDelayMajor{Steps{Self,Other},HoldOrder} = {{%d, %d}, %d} major steps;\n', ...
      g_CommDelayMajorStepsSelf, g_CommDelayMajorStepsOther, g_CommDelayDiscHoldOrder);
		fprintf(FID,'%% Scnro\tRun\tSeed\t#Attk\t');
		fprintf(FID,'#Veri\tTSrch\tForm\t');
		for (CountTargets = 1:g_MaxNumberTargets),
			fprintf(FID,'%d-D\t%d-C\t%d-A\t%d-K\t%d-V\t',CountTargets,CountTargets,CountTargets,CountTargets,CountTargets);
		end;
	end;
	fprintf(FID,'\n');
	
	fprintf(FID,'%d\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t',g_Scenario,g_SimulationRunNumber,g_Seed,...
		NumberAttackedTargets,NumberVerifiedTargets,SumTotalSearchTimeSeconds,Formula);
	for (CountTargets = 1:g_MaxNumberTargets),
		for (CountStates = 1:g_TargetStates.NumberStates-1),
			fprintf(FID,'%.2f\t',g_VehicleMemory(LastVehicle).MonteCarloMetrics.TargetStateTimes(CountTargets,CountStates));
		end;
	end;
	fprintf(FID,'\n');
	
	
	fclose(FID);
end;
return;
