function [Heading] = AngleToHeading(Angle,Units);
%AngleToHeading - [autological] converts an angle to a heading
%
%  Inputs:
%    Angle - 
%    Units - 'deg' or 'rad' (default is degrees)
%
%  Outputs:
%    Heading -  
%

%  AFRL/VACA
%  April 2004 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('AngleToHeading.m');end; 

if(~exist('Units')),
    Units = 'deg';
end;

switch (Units),
case 'deg',
	Heading = 90.0 - Angle;
case 'rad',
	Heading = pi/2.0 - Angle;
otherwise,
	error('Unknown units requested during AngleToHeading conversion.');
end;	%switch (Units),

return;	%AngleToHeading
