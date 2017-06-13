function [sys,x0,str,ts] = ThreatS(t,x,u,flag,MaxNumberVehicles)
%ThreatS - kills vehicles if they are within range.
%
%  Inputs:
%		Vehicle States (linear positions, angular positions)*MaxNumberVehicles
%  Outputs:

%  AFRL/VACA
%  March 2004 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('ThreatS.m');end; 

global g_SampleTime;
global g_TruthMemory;

switch flag,
    
case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 1 * MaxNumberVehicles;	% 1 - kill flag
    sizes.NumInputs      = 1 + 6 + (g_TruthMemory.Messages{g_TruthMemory.MsgIndicies.VehicleState}.NumberEntries) * MaxNumberVehicles;   %Threat ID x, y, z, type, psi, and  alive, Vehicles x, y, z positions (feet) phi, theta, psi rotations (deg)
    sizes.DirFeedthrough = 1;
    sizes.NumSampleTimes = 1;   % at least one sample time is needed
    sys = simsizes(sizes);
    x0  = [];
    str = [];
    ts  = [g_SampleTime];
    
case 1,
    sys = [];
    
case 2,
    sys = [];
    
case 3,
    sys = Threat(t,u,MaxNumberVehicles);     % the function to call
    
case 4,
    sys = t + g_SampleTime;
    
case 9,
    sys = [];
    
otherwise
    error(['Unhandled flag = ',num2str(flag)]);
    
end;

return; %function [sys,x0,str,ts] = TargetBombLogS(t,x,u,flag)


function [OutputVector] = Threat(Time,InputVector,MaxNumberVehicles)


global g_TruthMemory;

OutputVector = zeros(MaxNumberVehicles,1);

iCurrentRow = 1;
iCurrentVectorSize = 1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
TargetID = InputVector(iCurrentRow:iLastRow);

iCurrentRow = iLastRow + 1;
iCurrentVectorSize = 3;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
TargetPosition = InputVector(iCurrentRow:iLastRow);

iCurrentRow = iLastRow + 1;
iCurrentVectorSize = 1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
TargetType = InputVector(iCurrentRow:iLastRow);

iCurrentRow = iLastRow + 1;
iCurrentVectorSize = 1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
TargetPsi = InputVector(iCurrentRow:iLastRow);

iCurrentRow = iLastRow + 1;
iCurrentVectorSize = 1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
TargetAlive = InputVector(iCurrentRow:iLastRow);

if(TargetAlive <= 0),
    return;
end;

NumberRows = g_TruthMemory.Messages{g_TruthMemory.MsgIndicies.VehicleState}.NumberEntries;		%XPosition, YPosition, Altitude, Phi, Theta, Psi, Killed
iCurrentRow = iLastRow + 1;
iCurrentVectorSize = NumberRows*MaxNumberVehicles;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
VehiclesVector = InputVector(iCurrentRow:iLastRow);
VehiclesMatrix = reshape(VehiclesVector,NumberRows,MaxNumberVehicles);

for(CountVehicles = 1:MaxNumberVehicles),
    if(VehiclesMatrix(g_TruthMemory.Messages{g_TruthMemory.MsgIndicies.VehicleState}.VehicleIsDead,CountVehicles)==0),
        VehicleToTargetDistance = norm([VehiclesMatrix(g_TruthMemory.Messages{g_TruthMemory.MsgIndicies.VehicleState}.VehicleLinearPositions,CountVehicles) - TargetPosition]);
        OutputVector(CountVehicles) = CalculateKill(VehicleToTargetDistance,TargetType);
        if(OutputVector(CountVehicles)==1),
            fprintf('%5.2f Target %d killed Vehicle %d \n',Time,TargetID,CountVehicles);
        end;
    end;
end;

return;


function [Killed] = CalculateKill(VehicleToTargetDistance,TargetType)
global g_TargetTypes;

Killed = 0;

if( (VehicleToTargetDistance <= g_TargetTypes(TargetType).LethalRangeMax) & (VehicleToTargetDistance >= g_TargetTypes(TargetType).LethalRangeMin)),
    %find probability
    Distance = VehicleToTargetDistance - g_TargetTypes(TargetType).LethalRangeMin;
    Range = g_TargetTypes(TargetType).LethalRangeMax - g_TargetTypes(TargetType).LethalRangeMin;
    FractionDistance = (Range - Distance)/Range;
    KillProbability = FractionDistance*(g_TargetTypes(TargetType).ProbKillMax - g_TargetTypes(TargetType).ProbKillMin) + g_TargetTypes(TargetType).ProbKillMin;
    if(rand < KillProbability),
        Killed = 1;
    end;
    
end;    %if( VehicleToTargetDistance <= LethalRange),
return;     %CalculateKill