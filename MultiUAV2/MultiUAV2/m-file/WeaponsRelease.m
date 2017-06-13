function [OutputVector] = WeaponsRelease(action,InputVector)
%WeaponsRelease - calculate truth results for weapons release. 
%
%  Inputs:
%    action - The type of function call. Implemented values are:
%      'Bomb' - simulated bomb drop.
%    InputVector - the data in the InputVector changes based on the value of "action"  
%      action-> 'Bomb'
%        InputVector(1) - "VehicleID", identification index of the current vehicle.
%        InputVector(2) - "TargetAttacked", the target ID of a target that was attacked,
%                         0 for no target attacked
%        InputVector(3) - "Position_x", the vehicle's current position in the x direction
%        InputVector(4) - "Position_y", the vehicle's current position in the y direction
%
%  Outputs:
%    OutputVector(1) - "BombID" a unique ID number for each bomb that is dropped.
%    OutputVector(1) - "BombType" the type of bomb dropped.
%    OutputVector(1) - "BombPositionX" the truth impact x coordinate.
%    OutputVector(1) - "BombPositionY" the truth impact y coordinate.
%

%  AFRL/VACA
%  September 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('WeaponsRelease.m');end; 

global g_VehicleMemory;

if (nargin < 1),
   action = 'Undefined';
end;	%if (narg <= 0),


switch (action),
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%% Calculate Bomb Values       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'Bomb',
	NumberOutputs = 4;

    iCurrentRow = 1;
    iCurrentVectorSize = 1;
    iLastRow = iCurrentRow + iCurrentVectorSize - 1;
    VehicleID = InputVector(iCurrentRow:iLastRow);

    iCurrentRow = iLastRow+1;
    iLastRow = iCurrentRow + iCurrentVectorSize - 1;
    TargetAttacked = InputVector(iCurrentRow:iLastRow);

    iCurrentRow = iLastRow+1;
    iLastRow = iCurrentRow + iCurrentVectorSize - 1;
    Position_x = InputVector(iCurrentRow:iLastRow);

    iCurrentRow = iLastRow+1;
    iLastRow = iCurrentRow + iCurrentVectorSize - 1;
    Position_y = InputVector(iCurrentRow:iLastRow);

    if(VehicleID > 0),  %the vehicle is alive
        if ((g_VehicleMemory(VehicleID).WeaponsManager.NumberBombsDropped == 0)&(TargetAttacked ~= 0)), %these vehicles can drop only one bomb
            g_VehicleMemory(VehicleID).WeaponsManager.NumberBombsDropped = g_VehicleMemory(VehicleID).WeaponsManager.NumberBombsDropped + 1;
            BombID = (VehicleID*100) + g_VehicleMemory(VehicleID).WeaponsManager.NumberBombsDropped;  % need a unique identifier for the bomb
            BombType = 1;   %there is only one type of bomb, at this time
            BombPositionX = Position_x; % assume bomb hits at the vehicle's current location
            BombPositionY = Position_y;
        else,   %if ((g_VehicleMemory(VehicleID).WeaponsManager.NumberBombsDropped == 0)&(TargetAttacked ~= 0)),
          BombID = -1;  % need a unique identifier for the bomb
          BombType = -1;   %there is only one type of bomb, at this time
           BombPositionX = 0; % assume bomb hits at the vehicle's current location
           BombPositionY = 0;
        end;    %if ((g_VehicleMemory(VehicleID).WeaponsManager.NumberBombsDropped == 0)&(TargetAttacked ~= 0)),
            OutputVector = [BombID;BombType;BombPositionX;BombPositionY];
    else,    %if(VehicleID > 0),  %the vehicle is alive
        OutputVector = zeros(NumberOutputs,1); %defaults all values to 0.0
   end;    %if(VehicleID > 0),  %the vehicle is alive
otherwise,
    OutputVector = zeros(NumberOutputs,1); %defaults all values to 0.0
   
end;		%switch (action),   


return;
