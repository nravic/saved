function [TaskValue] = TaskBenefitMulti(Task,TargetValue,ETA,SearchETA,Vehicle,TargetToService,VehicleIDs,ThisVehicleID,TriggerReplanReset);  %Modified by Schumacher 5/23/02
% more information will need to be passed in about vehicle state.
% for starting purposes this information will be hard-coded here. 
% iCountVehicles, iCountTargets are placeholders signifying information about
% the vehicles and targets that may need to be passed in (such as target types). 


global g_Debug; if(g_Debug==1),disp('TaskBenefitMulti.m');end; 

global g_Tasks
global g_VehicleMemory
global g_WaypointDefinitions;
global g_Tasks;

MemoryFactor = 1.0;

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
% set to match the commanded flight speed.   % Most likely actually in m/s - should be 426
% Flight_Speed = 470;		% ft/s, nominal .. should be an input, but presently is 
Flight_Speed = g_VehicleMemory(ThisVehicleID).Dynamics.VTrueFPSInit;

ETA = ETA/Flight_Speed;
SearchETA = SearchETA/Flight_Speed;

switch Task
case g_Tasks.ContinueSearching,
   % in this case SearchBenefitMulti is called
   TaskValue = SearchBenefitMulti(Tf);
   
case g_Tasks.Classify,
   Patr = 0.6;		% previous ATR quality, should be an input, hardset here
   Pk = 0.8;		% Probability of killing a target of a given type. Hard-coded here,
   % but should be part of the target structure information.
   Val = TargetValue;
   if Val == 0
      Val = 3*(1-Patr);		%Assigns a value to verifying a potential non-target as a non-target
   end   
   %  Tclassify = ETAs(ii,jj)  + SearchETA(ii,jj);  %+60;  %
   Tclassify = ETA + SearchETA; %60;  % + SearchETA(ii,jj);  %+60;  %
   TaskValue = Patr*Pk*Val+ SearchBenefitMulti(Tf-Tclassify);
   
case g_Tasks.Attack,
   Pk = 0.8;			% Probability of killing a target of this type. Hard-set here, but
   % should be a part of target structure.
   Pid = 0.9;		% Probability of correct classification, should be an input, 
   % here set to the threshold level.
   Val = TargetValue;
   Tattack = ETA + 60;
 	TaskValue = Pid*Pk*Val;     %*(min(AttackTimes)/ETA)^(0.1);
 	TaskValue = TaskValue - SearchBenefitMulti(ETA);
 	TaskValue = TaskValue;
 
case g_Tasks.Verify,
   % Value of BDA: 
   % Based on value of attacking a target of that type, modified by the chance the target
   % survived the initial attack and the chance of successful BDA.
   Pbda = 1.0;		% Assumed initial effectiveness, could be modified for different target type	
   Pk = 0.8;
   Pid = 0.9;			% Probability of correct classification, should be an input, here set to the threshold level.
   Val = TargetValue;
   %    Tbda = ETAs(ii,jj)  +SearchETA(ii,jj);   
   Tbda = ETA + SearchETA; %60 ; 
   TaskValue = Pbda*(1-Pk)*Pid*Val + SearchBenefitMulti(Tf-Tbda);
   %TaskValue = TaskValue*2;
end

if TaskValue < 0
   TaskValue = 0;
end

VehicleID = VehicleIDs(Vehicle);
PresentTarget = -1;
PresentTaskWaypointType = 1;    %Search, in CreateStructure system
if ~isempty(g_VehicleMemory(ThisVehicleID).CooperationManager.WaypointMemory)
    temparray = cell(1,1);
    temparray = g_VehicleMemory(ThisVehicleID).CooperationManager.WaypointMemory{VehicleID};
    PresentWaypoints = temparray;  
    [n,m] = size(PresentWaypoints);
    
    indx = 1;
    while PresentTarget == -1 & indx < n+1  
        if PresentWaypoints(indx,11) ~= -1
            PresentTarget = PresentWaypoints(indx,g_WaypointDefinitions.TargetHandle);
            PresentTaskWaypointType = PresentWaypoints(indx,g_WaypointDefinitions.WaypointType);
        end %if
        indx = indx+1;
    end % While
    
end

%g_Tasks: 0 - Search; 1 - Classify; 2 - Attack; 3 - Verify
%Waypoints: 1 - Search; 2 - Enroute; 3 - Classify; 4 - Attack; 5 - Verify; 6 - Startpoint; 7 - Endpoint;...

MemoryWeight = 1.05;     %Value for Memory weighting on previously-assigned task
%MemoryWeight = 1.0;         % 1.0 means no memory

if PresentTaskWaypointType == 103,
    PresentTaskWaypointType = 3;
end

if PresentTaskWaypointType == 104,
    PresentTaskWaypointType = 4;
end

if PresentTaskWaypointType == 105,
    PresentTaskWaypointType = 5;
end


if ((TriggerReplanReset==0)&(PresentTarget == TargetToService)),
    if PresentTaskWaypointType == 3 & Task == 1
        MemoryFactor = MemoryWeight;
    end
    if PresentTaskWaypointType == 4 & Task == 2
        MemoryFactor = MemoryWeight;
    end
    if PresentTaskWaypointType == 5 & Task == 3
        MemoryFactor = MemoryWeight;
    end
end %if

TaskValue = TaskValue*MemoryFactor;		

return	%function TaskBenefit

