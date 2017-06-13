function Classification = ClassifyTarget(TrueTargetType,Pid)
% This function is called by ATRFunctions.m
%
% Classification - Determines what the vehicle classifies the target as based
%                  on the vehicle's probability of identification (Pid) and
%                  a random draw.  This is not necessarily what the target truly is.
% 
%  Inputs:
%    TrueTargetType - True type of the target
%    Pid            - Confusion matrix
%
%  Outputs:
%    Classification - What the vehicle classified the target as
%
%  AFIT/ENY
%  September 2001 - Created and Debugged - Dunkel


RandomNumber = rand;

j = TrueTargetType;                                       %Bounds is used to determine the
Bounds = [Pid(1,j); ...                                   %relation between the random number
          Pid(1,j)+Pid(2,j); ...                          %and the confusion matrix.  The elements
          Pid(1,j)+Pid(2,j)+Pid(3,j); ...                 %of bounds are simply the progressive
          Pid(1,j)+Pid(2,j)+Pid(3,j)+Pid(4,j); ...        %summation of the elements in a given column
          Pid(1,j)+Pid(2,j)+Pid(3,j)+Pid(4,j)+Pid(5,j)];  %of the confusion matrix (Pid).
                   
if RandomNumber <= Bounds(1)
   Classification = 1;
elseif RandomNumber > Bounds(1) & RandomNumber <= Bounds(2)
   Classification = 2;
elseif RandomNumber > Bounds(2) & RandomNumber <= Bounds(3)
   Classification = 3;
elseif RandomNumber > Bounds(3) & RandomNumber <= Bounds(4)
   Classification = 4;
elseif RandomNumber > Bounds(4) & RandomNumber <= Bounds(5)
   Classification = 5;
end
    
return;
