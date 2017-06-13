function Probability = ProbabilityCorrectTarget(Theta,Width,Length)
%ProbabilityCorrectTarget - calculates probability of correct target report given viewing aspect angle
% This is implemented for a rectangular target
%
%  Inputs:
%    Theta - viewing aspect angle (radians)
%    Width - width of target rectangle (along the Y-Axis) 
%    Length - Length of target rectangle (along the X-Axis) 
%
%  Outputs:
%    Probability - probability of correct target report
%

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS
%  August 2002 - swaped input parmeters, Width and Length, to line up the width to point to 0 degrees heading. - RAS



global g_Debug; if(g_Debug==1),disp('ProbabilityCorrectTarget.m');end; 

PiO2 = pi/2;
ThreePiO2 = 3*pi/2;
if (Theta >= 0)&(Theta <= PiO2),
   Probability = (Width*cos(Theta)+Length*sin(Theta))/(Length + Width);
elseif (Theta > PiO2)&(Theta <= pi),
   Probability = (-Width*cos(Theta)+Length*sin(Theta))/(Length + Width);
elseif (Theta > pi)&(Theta <= ThreePiO2),
      Probability = (-Width*cos(Theta)-Length*sin(Theta))/(Length + Width);
else,
   Probability = (Width*cos(Theta)-Length*sin(Theta))/(Length + Width);
end;

ScaleFactor = 0.8/(((Width*Width+Length*Length))^0.5/(Width+Length));
Probability =  ScaleFactor * Probability;

return;	%ProbabilityCorrectTarget