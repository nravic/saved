function [Angle] = HeadingToAngle(Heading,Units);
%HeadingToAngle - [autological] converts a heading to and angle
%
%  Inputs:
%    Heading -  
%    Units - 'deg' or 'rad' (default is degrees)
%
%  Outputs:
%    Angle - 
%

%  AFRL/VACA
%  April 2004 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('HeadingToAngle.m');end; 

if(~exist('Units')),
    Units = 'deg';
end;

switch (Units),
case 'deg',
	Angle = 90.0 - Heading;
case 'rad',
	Angle = pi/2.0 - Heading;
otherwise,
	error('Unknown units requested during HeadingToAngle conversion.');
end;	%switch (Units),

return;	%HeadingToAngle
