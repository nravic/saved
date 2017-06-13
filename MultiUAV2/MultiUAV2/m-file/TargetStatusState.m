function [NewTargetState,ExtraAttacksOut,ResetToLowerState] = TargetStatusState(VehicleID,TargetID,OldTargetState,NewATRValue,LastTaskCompleted,NumberAttacks,BDAComplete,ExtraAttacksIn,CurrentTimeSeconds,NumberValidHeadings)
%TargetStatusState - calculates the state of a target based on past state and other data. 
%
%  Inputs:
%    VehicleID - vehicle identification number
%    TargetID - target identification number
%    OldTargetState - last state of this target
%    NewATRValue - latest ATR value for this target
%    LastTaskCompleted - last task that this vehicle has completed with respect to this target
%    NumberAttacks - number of times that this target has been attacked.
%    BDAComplete - flag to indicate when the BDA has been done.
%    ExtraAttacks - number of extra attacks needed for a particular target (used by BDA to cause a reattack)
%
%  Outputs:
%    NewTargetState - the calculated state of the target.

%

%  AFRL/VACA
%  March 2001 - Created and Debugged - RAS
%  September 2001 - modified to allow for multiple attacks - RAS
%  May 2002 - started colecting state transition times - RAS



global g_Debug; if(g_Debug==1),disp('TargetStatusState.m');end; 

global g_ATRThreshold;
global g_TargetStates;
global g_Tasks;
global g_VehicleMemory;

NewTargetState = OldTargetState; %defaults to current state
ExtraAttacksOut = ExtraAttacksIn;
ResetToLowerState = 0;

% check task completions to see if the state should be changed
switch (LastTaskCompleted),
case g_Tasks.ContinueSearching,
	NewTargetState = g_TargetStates.StateDetectedNotClassified;
case g_Tasks.Classify,
	NewTargetState = g_TargetStates.StateDetectedNotClassified;	%this forces the NewATRValue to be compared to the g_ATRThreshold
case g_Tasks.Attack,
	NewTargetState = g_TargetStates.StateAttackedNotKilled;		%need to account for multiple attacks, so don't change to a higher state
case g_Tasks.Verify,
	NewTargetState = g_TargetStates.StateConfirmedKill;
otherwise,
	NewTargetState = OldTargetState;
end;	%switch (LastTaskCompleted),

if((NewTargetState==g_TargetStates.StateDetectedNotClassified)&(NumberValidHeadings==0)),
	NewTargetState = g_TargetStates.StateUnknownTarget;
end;

if (NewTargetState < OldTargetState),
  disp(sprintf(['%.2f Warning::TargetStatusState.m - target status state' ...
    ' regressed!'], CurrentTimeSeconds));
	NewTargetState = OldTargetState;
end;

% run the state machine
switch(NewTargetState),
	
case g_TargetStates.StateNotDetected,
	% check to see if this vehicle has detected this target
	% if it has been detected do an ATR
	% if ATR is below threshold set state to 'DetectedNotClassified'
	% if ATR is above threshold set state to 'ClassifiedNotAttacked'
	if (NewATRValue > 0.0),
		if (NewATRValue > g_ATRThreshold),
			NewTargetState = g_TargetStates.StateClassifiedNotAttacked;
			g_VehicleMemory(VehicleID).MonteCarloMetrics.TargetStateTimes(TargetID,g_TargetStates.StateDetectedNotClassified) = CurrentTimeSeconds;
			g_VehicleMemory(VehicleID).MonteCarloMetrics.TargetStateTimes(TargetID,g_TargetStates.StateClassifiedNotAttacked) = CurrentTimeSeconds;
		else,	%if (NewATRValue > g_ATRThreshold),
			NewTargetState = g_TargetStates.StateDetectedNotClassified;
			g_VehicleMemory(VehicleID).MonteCarloMetrics.TargetStateTimes(TargetID,g_TargetStates.StateDetectedNotClassified) = CurrentTimeSeconds;
		end;	%if (NewATRValue > g_ATRThreshold),
	end;	%if (NewATRValue > 0.0),
	
case g_TargetStates.StateDetectedNotClassified,
	% if ATR is above threshold set state to 'ClassifiedNotAttacked'
	if (NewATRValue > g_ATRThreshold),
		NewTargetState = g_TargetStates.StateClassifiedNotAttacked;
		g_VehicleMemory(VehicleID).MonteCarloMetrics.TargetStateTimes(TargetID,g_TargetStates.StateClassifiedNotAttacked) = CurrentTimeSeconds;
	elseif (NumberValidHeadings==0),
		NewTargetState = g_TargetStates.StateUnknownTarget;
		g_VehicleMemory(VehicleID).MonteCarloMetrics.TargetStateTimes(TargetID,g_TargetStates.StateUnknownTarget) = CurrentTimeSeconds;
	end;
	
case g_TargetStates.StateClassifiedNotAttacked,
	%check to see if this vehicle attacked this target
	% if it has, add attack amount to cumulative attack score for the target 
	%if the attack is above the kill threshold, then set the state to 'KilledNotConfirmed'
    if(NumberAttacks > 0),
        if (NumberAttacks > 1 + ExtraAttacksIn),
            NewTargetState = g_TargetStates.StateKilledNotConfirmed;
            g_VehicleMemory(VehicleID).MonteCarloMetrics.TargetStateTimes(TargetID,g_TargetStates.StateKilledNotConfirmed) = CurrentTimeSeconds;
        else,
            NewTargetState = g_TargetStates.StateAttackedNotKilled;
		    g_VehicleMemory(VehicleID).MonteCarloMetrics.TargetStateTimes(TargetID,g_TargetStates.StateAttackedNotKilled) = CurrentTimeSeconds;
        end;
    end;	%if(NumberAttacks > 0)
	
case g_TargetStates.StateAttackedNotKilled,
	%check to see if this vehicle has done BDA on this target
	% if it has, calculate the new Total BDA number
	% if the total BDA number is greater than the threshold then:
	% if the BDA result is confirmed Kill the set the state to 'ConfirmedKill'
	% if the BDA result is not confirmed kill the set the state to 'ClassifiedNotKilled'(need to do something with the number of attacks)
	if (NumberAttacks >= 1 + ExtraAttacksIn),
		NewTargetState = g_TargetStates.StateKilledNotConfirmed; % assume one attack is enough
		g_VehicleMemory(VehicleID).MonteCarloMetrics.TargetStateTimes(TargetID,g_TargetStates.StateKilledNotConfirmed) = CurrentTimeSeconds;
	end;	%if (NumberAttacks > 1),
	
case g_TargetStates.StateKilledNotConfirmed,
	if (BDAComplete >= 1),
		NewTargetState = g_TargetStates.StateConfirmedKill;
		g_VehicleMemory(VehicleID).MonteCarloMetrics.TargetStateTimes(TargetID,g_TargetStates.StateConfirmedKill) = CurrentTimeSeconds;
	elseif (BDAComplete < 0),
		ExtraAttacksOut = ExtraAttacksOut + 1;
		NewTargetState = g_TargetStates.StateAttackedNotKilled;
		ResetToLowerState = 1;
	end;	%if (NumberAttacks > 1),
	
case g_TargetStates.StateConfirmedKill,
	% stay in this state
	NewTargetState = g_TargetStates.StateConfirmedKill;
	
case g_TargetStates.StateUnknownTarget,
	% if ATR is above threshold set state to 'ClassifiedNotAttacked'
	if (NewATRValue > g_ATRThreshold),
		NewTargetState = g_TargetStates.StateClassifiedNotAttacked;
		g_VehicleMemory(VehicleID).MonteCarloMetrics.TargetStateTimes(TargetID,g_TargetStates.StateClassifiedNotAttacked) = CurrentTimeSeconds;
		ResetToLowerState = 1;
	else,
		NewTargetState = g_TargetStates.StateUnknownTarget;
	end;
	
otherwise,
	NewTargetState = g_TargetStates.StateUndefined;
end;	%switch (TargetState),

return;		%function TargetStatusState


