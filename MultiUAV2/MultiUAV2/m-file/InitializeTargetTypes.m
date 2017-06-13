function	InitializeTargetTypes()
%InitializeTargetTypes - sets the target type data in the global target type array.
%
%  Inputs:
%    None. 
%
%  Outputs:
%    None. 
%

%  AFRL/VACA
%  May 2001 - Created and Debugged - RAS
%  August 2002 - swaped input parmeters, Width and Length, in the function, BestViewingHeadings, to line up the width to point to 0 degrees heading. - RAS


global g_Debug; if(g_Debug==1),disp('InitializeTargetTypes.m');end; 

global g_TargetTypes;

g_TargetTypes = [];

TempType = CreateStructure('TargetTypeDefinitions');
TempType.Length = 20.0;
TempType.Width = 10.0;
TempType.BestViewingHeadingsRad = BestViewingHeadings(TempType.Length,TempType.Width);
TempType.IsTarget = 1;
TempType.TargetValue = 10;
g_TargetTypes = [g_TargetTypes;TempType];

TempType = CreateStructure('TargetTypeDefinitions');
TempType.Length = 30.0;
TempType.Width = 10.0;
TempType.BestViewingHeadingsRad = BestViewingHeadings(TempType.Length,TempType.Width);
TempType.IsTarget = 1;
TempType.TargetValue = 8;
g_TargetTypes = [g_TargetTypes;TempType];

TempType = CreateStructure('TargetTypeDefinitions');
TempType.Length = 40.0;
TempType.Width = 10.0;
TempType.BestViewingHeadingsRad = BestViewingHeadings(TempType.Length,TempType.Width);
TempType.IsTarget = 1;
TempType.TargetValue = 10;
g_TargetTypes = [g_TargetTypes;TempType];

TempType = CreateStructure('TargetTypeDefinitions');
TempType.Length = 20.0;
TempType.Width = 10.0;
TempType.BestViewingHeadingsRad = BestViewingHeadings(TempType.Length,TempType.Width);
TempType.IsTarget = 0;
TempType.TargetValue = 6;
g_TargetTypes = [g_TargetTypes;TempType];

TempType = CreateStructure('TargetTypeDefinitions');
TempType.Length = 60.0;
TempType.Width = 10.0;
TempType.BestViewingHeadingsRad = BestViewingHeadings(TempType.Length,TempType.Width);
TempType.IsTarget = 1;
TempType.TargetValue = 8;
g_TargetTypes = [g_TargetTypes;TempType];


return;	%InitializeTargetTypes


function ReturnAngles = BestViewingHeadings(Width,Length)
% calculates best viewing headings (towards) for a rectangle given the length and width
ReturnAngles = [];

AngleCorrection = 0.0;

ViewingAngle = atan2(Length,Width);
ViewingHeading = pi/2.0 - ViewingAngle + AngleCorrection;
while(ViewingHeading >= 2*pi),
	ViewingHeading = ViewingHeading - 2*pi;
end;
while(ViewingHeading < 0),
	ViewingHeading = ViewingHeading + 2*pi;
end;
ReturnAngles = [ReturnAngles;ViewingHeading];

ViewingAngle = atan2(-Length,Width);
ViewingHeading = pi/2.0 - ViewingAngle + AngleCorrection;
while(ViewingHeading >= 2*pi),
	ViewingHeading = ViewingHeading - 2*pi;
end;
while(ViewingHeading < 0),
	ViewingHeading = ViewingHeading + 2*pi;
end;
ReturnAngles = [ReturnAngles;ViewingHeading];

ViewingAngle = atan2(-Length,-Width);
ViewingHeading = pi/2.0 - ViewingAngle + AngleCorrection;
while(ViewingHeading >= 2*pi),
	ViewingHeading = ViewingHeading - 2*pi;
end;
while(ViewingHeading < 0),
	ViewingHeading = ViewingHeading + 2*pi;
end;
ReturnAngles = [ReturnAngles;ViewingHeading];

ViewingAngle = atan2(Length,-Width);
ViewingHeading = pi/2.0 - ViewingAngle + AngleCorrection;
while(ViewingHeading >= 2*pi),
	ViewingHeading = ViewingHeading - 2*pi;
end;
while(ViewingHeading < 0),
	ViewingHeading = ViewingHeading + 2*pi;
end;
ReturnAngles = [ReturnAngles;ViewingHeading];

return	%CalculateAngles