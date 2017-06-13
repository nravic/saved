function [OutputVector] = TargetBombLog(InputVector)
%TargetBombLog - tracks bomb drops. 
%
%  Inputs:
%        InputVector(...) - "BombsDropped", a matrix containing the truth information for 
%                           bombs dropped from all of the vehicles
%
%  Outputs:
%        OutputVector(...) - total number of bomb dropped
%

%  AFRL/VACA
%  September 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('TargetBombLog.m');end; 

global g_MaxNumberVehicles;
global g_TargetMainMemory;

iNumberBombElements = 4;

iCurrentRow = 1;
iCurrentVectorSize = g_MaxNumberVehicles*iNumberBombElements;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
BombDropVector = InputVector([iCurrentRow:iLastRow],:);
BombDropMatrix = reshape(BombDropVector,iNumberBombElements,g_MaxNumberVehicles)';

for(iCountVehicle = 1:g_MaxNumberVehicles),
    VehicleBombDrop = BombDropMatrix(iCountVehicle,:);
    if(VehicleBombDrop(1)>0),           %valid ID means this is a bomb drop
        if(~isempty(g_TargetMainMemory.BombLog)),
            BombDropExisting = find(VehicleBombDrop(1)==g_TargetMainMemory.BombLog(:,1));
            if(isempty(BombDropExisting)),
                g_TargetMainMemory.BombLog = [g_TargetMainMemory.BombLog;VehicleBombDrop];
            end;
        else,   %if(~isempty(g_TargetMainMemory.BombLog)),
            g_TargetMainMemory.BombLog = [g_TargetMainMemory.BombLog;VehicleBombDrop];
        end;    %if(~isempty(g_TargetMainMemory.BombLog)),
    end;    %if((VehicleBombDrop(1)>0)&(isempty(g_TargetMainMemory.BombLog))),
end;

[iNumberBombs,iColumns] = size(g_TargetMainMemory.BombLog);
OutputVector = iNumberBombs;

return;
