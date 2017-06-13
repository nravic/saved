function MessageDisplay(Message,Arguments,Time)
%MessageDisplay - 
%
%  Inputs:
%    Message -  
%    Arguments -  
%
%  Outputs:
%    none
%

%  AFRL/VACA
%  November 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('MessageDisplay.m');end; 

if (nargin < 1),
	Message = 'Default';
end;

switch (Message),
	
case 'Replan'		% vehicle is replanning
	if(nargin == 3),
% 		Time = Arguments(1);
		VehicleID = Arguments(2);
	else,
		Time = -1;
		VehicleID = -1;
	end;
	StringDisplay = sprintf('%3.2f Vehicle #%d, Replanning',Time,VehicleID);

case 'Default',
otherwise,
end;	%switch (StructureType),


disp(StringDisplay);

return 	%MessageDisplay
