function [OutputVector] = TargetBombed(InputVector)
%TargetBombed - calculates the status of the target, alive or dead
%
%  Inputs:
%    InputVector - total number of bombs that have been dropped
%
%  Outputs:
%    OutputVector - 
%      TargetAlive - this variable is set toone if the target is alive
%

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS
%  September 2000 - updated to use bombs - RAS
%  October 2000 - fixed bomb radius calculation - RAS



global g_Debug; if(g_Debug==1),disp('TargetBombed.m');end; 

global g_TargetMemory;
global g_TargetMainMemory;

NumberOutputs = 1;
OutputVector = zeros(NumberOutputs,1); %defaults all values to 0.0

[iNumberInputRows,iCols]=size(InputVector);



iCurrentRow = 1;
iCurrentVectorSize = 1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
TargetID = InputVector(iCurrentRow:iLastRow);

iCurrentRow = iCurrentRow + iCurrentVectorSize;
iCurrentVectorSize = 1;
iLastRow = iCurrentRow + iCurrentVectorSize - 1;
NumberBombs = InputVector(iCurrentRow:iLastRow);

if (NumberBombs > g_TargetMemory(TargetID).NumberBombsChecked),
    iNumberBombElements = 4;
    
    BombMatrix = g_TargetMainMemory.BombLog;

    while(NumberBombs > g_TargetMemory(TargetID).NumberBombsChecked),
        g_TargetMemory(TargetID).NumberBombsChecked = g_TargetMemory(TargetID).NumberBombsChecked + 1;
        g_TargetMemory(TargetID).Alive = CheckBombEffect(TargetID,BombMatrix(g_TargetMemory(TargetID).NumberBombsChecked,:));
    end;
end;        %if (NumberBombs > g_TargetMemory.[TargetID].NumberBombsChecked),


OutputVector = g_TargetMemory(TargetID).Alive;    %return the Alive flag for this target


return;     %function [OutputVector] = TargetBombed(InputVector)


function [OutputVector] = CheckBombEffect(TargetID,BombTruthVector)
%CheckBombEffect - calculates bomb's effect on a target
%
%  Inputs:
%    TargetID - the ID of this target
%    BombTruthVector - the truth information from a bomb
%
%  Outputs:
%    OutputVector - 
%      TargetAlive - this variable is set to 1 if the target is alive 0 otherwise
%

%  AFRL/VACA
%  September 2000 - Created and Debugged - RAS

global g_TargetMemory;
global g_ProbabilityOfKill; % adde by orhan 9 jan 20003

OutputVector = g_TargetMemory(TargetID).Alive;
%***************************************************************************************
%**  Modified so that whether a target is alive or dead is based on a random draw and **
%**  the vehicle's probability of hitting and killing a target.  orhan  9 jan 2003  **
%***************************************************************************************

if(g_TargetMemory(TargetID).Alive > 0),
    iIndexPositionX = 3;
    iIndexPositionY = 4;
    iKillRadius = 100;   %(feet) first guess at an appropriate value.
 
    OffsetX = g_TargetMemory(TargetID).PositionX - BombTruthVector(iIndexPositionX);
    OffsetY = g_TargetMemory(TargetID).PositionY - BombTruthVector(iIndexPositionY);

    if(sqrt(OffsetX^2 + OffsetY^2) <= iKillRadius),
        RandomNumber = rand;
        if rand < g_ProbabilityOfKill
            OutputVector = 0;
        end
    end
end

%******************************** End orhan ***************************************

% % % % if(g_TargetMemory(TargetID).Alive > 0),
% % % %     iIndexPositionX = 3;
% % % %     iIndexPositionY = 4;
% % % %  %% Radius modified to kill only one target when more targets are near / 07 Jan 03 Orhan
% % % %  %%   iKillRadius = 1000;   %(feet) first guess at an appropriate value.
% % % %     iKillRadius = 200;   %(feet) first guess at an appropriate value.
% % % % 
% % % %     OffsetX = g_TargetMemory(TargetID).PositionX - BombTruthVector(iIndexPositionX);
% % % %     OffsetY = g_TargetMemory(TargetID).PositionY - BombTruthVector(iIndexPositionY);
% % % % 
% % % %     if(sqrt((OffsetX*OffsetX)+(OffsetY*OffsetY)) <= iKillRadius),
% % % %         OutputVector = 0;
% % % %     end;
% % % % end;    %if(g_TargetMemory(TargetID).Alive > 0),
% % % % 

return;