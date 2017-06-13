function CalculateWaypoints(Pattern,NumberVehicles,StartingPoint,StartingPsi,TurnRadius)
%CalculateWaypoints - calcluates and saves waypoints that represent initial search patterns for the vehicles
%
%  Inputs:
%    Pattern - the desired layout of the waypoints. Valid patterns are:
%      'Serpentine'
%    NumberVehicles - number of waypoint paths to create.
%    StartingPoint - [x y] coodinates of starting point
%    StartingPsi - initial heading of waypoint paths
%    TurnRadius - radius to use when calulating turns
%  Outputs:
%    (none)
%


%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS
%  May 2003 - generalized number of vehicles - RAS



global g_Debug; if(g_Debug==1),disp('CalculateWaypoints.m');end; 

global g_WaypointCells;
global g_WaypointTypes;
global g_DefaultWaypointAltitude;
global g_ActiveVehicles;
global g_MaxNumberVehicles; 
global g_CommandTurnRadius;
global g_SensorLeadingEdge_ft;
global g_SensorTrailingEdge_ft;
global g_SearchSpace;
global g_SensorWidth_ft;
global g_KillboxOffsetX;
global g_StartingPointOffsetXY; 

disp('*** CalculateWaypoints:: Initializing Search Waypoints ***');

% amount of space between vehicles
Spacing = g_SensorWidth_ft; 

%default parameters
NumberVehicles = g_ActiveVehicles;

if nargin <1,
	Pattern = 'Serpentine';
	NumberVehicles = g_ActiveVehicles;
	StartingPoint = [(g_SearchSpace(1)-(1.4*g_SensorLeadingEdge_ft)), (g_SearchSpace(4)-(g_SensorWidth_ft/2.0))] + g_StartingPointOffsetXY;
	StartingPsi = 0.5*pi;
	TurnRadius = g_CommandTurnRadius;
end

% parameters saved in the waypoints, used in the simulation
MachFlag = 0;	%using velocities in feet/sec
VelocityCMDFPS = 370;


switch Pattern
case 'Serpentine'
	Angle = pi/2 - StartingPsi;
	
	DeltaX = Spacing * cos(0.5*pi - Angle);
	if((Angle>=0.5*pi)&(Angle<1.5*pi))
		DeltaX = -DeltaX;
	end;
	
	DeltaY = Spacing * sin(pi/2-Angle);
	if(((Angle>=0)&(Angle<(0.5*pi)))|((Angle>=(1.5*pi))&(Angle<(2*pi))))
		DeltaY = -DeltaY;
	end;

	if( abs(DeltaX) < 1.0 )
		DeltaX = 0;
	end
	if( abs(DeltaY) < 1.0 )
		DeltaY = 0;
	end
	
	DeltaMajorX = NumberVehicles * DeltaX;
	DeltaMajorY = NumberVehicles * DeltaY;
	
	CosAngle = cos(Angle);
	SinAngle = sin(Angle);
	FormationOffset = -500;
	FormationOffset = -1000;
	FormationOffset = 0;	% how far to bias the starting points of the vehicles
	FormationOffsetX = FormationOffset*CosAngle;
	FormationOffsetY = FormationOffset*SinAngle;
	
	ResetVehiclePosition = 1; %This causes the vehicle to reinitialize its position using the "VehicleMemory.Dynamics" structure 
	%WayPoint Definition: [PositionX PositionY PositionZ VelocityCommand MachFlag EndOfSegmentLength EndOfSegmentTurnCenterX EndOfSegmentTurnCenterY,TurnDirection, WaypointType]
	%NOTE: EndOfSegmentTurnCenterX and Y are set equal to realmax for straight segments
	WaypointType = g_WaypointTypes.Search;
	for iCount = 1:NumberVehicles
		g_WaypointCells{iCount}=[StartingPoint(1)+((iCount-1)*DeltaX)+(iCount-1)*FormationOffsetX, ...
				StartingPoint(2)+((iCount-1)*DeltaY)+(iCount-1)*FormationOffsetY,g_DefaultWaypointAltitude,VelocityCMDFPS,MachFlag,realmax,realmax,realmax,0,WaypointType,-1,ResetVehiclePosition];
	end;
	ResetVehiclePosition = 0;
	
	SearchWidth = g_SearchSpace(2)-g_SearchSpace(1);
% 	SecondPointsOffsetX = (g_SearchSpace(2)-g_SensorLeadingEdge_ft)*CosAngle;
% 	SecondPointsOffsetY = (g_SearchSpace(2)-g_SensorLeadingEdge_ft)*SinAngle;
	SecondPointsOffsetX = (SearchWidth + 2.8*g_SensorLeadingEdge_ft)*CosAngle;		%added 0.4 to the scale to add some space for the vehicle to be wings level before rentering the search area.
	SecondPointsOffsetY = (SearchWidth + 2.8*g_SensorLeadingEdge_ft)*SinAngle;
	WaypointStartX = StartingPoint(1);
	WaypointStartY = StartingPoint(2);
	
	Hypotenuse = sqrt(2*(TurnRadius^2));
	RadiusOffX1 = Hypotenuse*cos(Angle - 0.25*pi);
	RadiusOffY1 = Hypotenuse*sin(Angle - 0.25*pi);
	RadiusOffX2 = Hypotenuse*cos(Angle + 0.25*pi);
	RadiusOffY2 = Hypotenuse*sin(Angle + 0.25*pi);
	RadiusOffX3 = Hypotenuse*cos(Angle + 0.75*pi);
	RadiusOffY3 = Hypotenuse*sin(Angle + 0.75*pi);
	RadiusOffX4 = Hypotenuse*cos(Angle + 1.25*pi);
	RadiusOffY4 = Hypotenuse*sin(Angle + 1.25*pi);
	
	% location of points in the pattern:
	%          A----------------------B
	%                                   \
	%                                    C
	%                                     |
	%                                     |
	%                                    D
	%                                   /
	%           F---------------------E
	%         /
	%        G 
	%        |
	%        |
	%        H
	%         \
	%          \
	%           A---------------------
	
	FirstPoint = ones(NumberVehicles);
	for iCount = 1:NumberVehicles
		WaypointX = WaypointStartX;
		WaypointY = WaypointStartY;
		WaypointStartX = WaypointStartX + DeltaX;
		WaypointStartY = WaypointStartY + DeltaY;
		for PositionX = StartingPoint(2):(-Spacing*NumberVehicles):g_SearchSpace(3)
			% Point A
			WaypointAX = WaypointX;
			WaypointAY = WaypointY;
			% Point B
			WaypointBX = WaypointAX + SecondPointsOffsetX - g_KillboxOffsetX;
			WaypointBY = WaypointAY + SecondPointsOffsetY;
			% Point C
			WaypointCX = WaypointBX + RadiusOffX1;
			WaypointCY = WaypointBY + RadiusOffY1;
			% Point E
			WaypointEX = WaypointBX + DeltaMajorX;
			WaypointEY = WaypointBY + DeltaMajorY;
			% Point D
			WaypointDX = WaypointEX + RadiusOffX2;
			WaypointDY = WaypointEY + RadiusOffY2;
			% Point F
			WaypointFX = WaypointAX + DeltaMajorX + g_KillboxOffsetX;
			WaypointFY = WaypointAY + DeltaMajorY;
			% Point G
			WaypointGX = WaypointFX + RadiusOffX4;
			WaypointGY = WaypointFY + RadiusOffY4;
			% Point A
			WaypointX = WaypointFX + DeltaMajorX;
			WaypointY = WaypointFY + DeltaMajorY;
			% Point H
			WaypointHX = WaypointX + RadiusOffX3;
			WaypointHY = WaypointY + RadiusOffY3;

			if FirstPoint(iCount)==1,
				FirstPoint(iCount) = 0;
			else,
				leglength = norm([LastWaypointHX-WaypointAX LastWaypointHY-WaypointAY]);
				g_WaypointCells{iCount} = [g_WaypointCells{iCount};[WaypointAX,WaypointAY,g_DefaultWaypointAltitude,VelocityCMDFPS,MachFlag,realmax,realmax,realmax,0,WaypointType,-1,0]];
			end;
			sizeWPC = size(g_WaypointCells{iCount});
			Waypoint0X = g_WaypointCells{iCount}(sizeWPC(1),1);
			Waypoint0Y = g_WaypointCells{iCount}(sizeWPC(1),2);
			leglength = norm([WaypointBX-Waypoint0X WaypointBY-Waypoint0Y]);
			g_WaypointCells{iCount} = [g_WaypointCells{iCount};[WaypointBX,WaypointBY,g_DefaultWaypointAltitude,VelocityCMDFPS,MachFlag,leglength,realmax,realmax,0,WaypointType,-1,ResetVehiclePosition]];
			leglength = norm([WaypointBX-WaypointCX WaypointBY-WaypointCY]);
			g_WaypointCells{iCount} = [g_WaypointCells{iCount};[WaypointCX,WaypointCY,g_DefaultWaypointAltitude,VelocityCMDFPS,MachFlag,leglength,realmax,realmax,0,WaypointType,-1,ResetVehiclePosition]];
			leglength = norm([WaypointDX-WaypointCX WaypointDY-WaypointCY]);
			g_WaypointCells{iCount} = [g_WaypointCells{iCount};[WaypointDX,WaypointDY,g_DefaultWaypointAltitude,VelocityCMDFPS,MachFlag,leglength,realmax,realmax,0,WaypointType,-1,ResetVehiclePosition]];
			leglength = norm([WaypointEX-WaypointDX WaypointEY-WaypointDY]);
			g_WaypointCells{iCount} = [g_WaypointCells{iCount};[WaypointEX,WaypointEY,g_DefaultWaypointAltitude,VelocityCMDFPS,MachFlag,leglength,realmax,realmax,0,WaypointType,-1,ResetVehiclePosition]];
			leglength = norm([WaypointFX-WaypointEX WaypointFY-WaypointEY]);
			g_WaypointCells{iCount} = [g_WaypointCells{iCount};[WaypointFX,WaypointFY,g_DefaultWaypointAltitude,VelocityCMDFPS,MachFlag,leglength,realmax,realmax,0,WaypointType,-1,ResetVehiclePosition]];
			leglength = norm([WaypointGX-WaypointFX WaypointGY-WaypointFY]);
			g_WaypointCells{iCount} = [g_WaypointCells{iCount};[WaypointGX,WaypointGY,g_DefaultWaypointAltitude,VelocityCMDFPS,MachFlag,leglength,realmax,realmax,0,WaypointType,-1,ResetVehiclePosition]];
			leglength = norm([WaypointHX-WaypointGX WaypointHY-WaypointGY]);
			g_WaypointCells{iCount} = [g_WaypointCells{iCount};[WaypointHX,WaypointHY,g_DefaultWaypointAltitude,VelocityCMDFPS,MachFlag,leglength,realmax,realmax,0,WaypointType,-1,ResetVehiclePosition]];
			LastWaypointHX = WaypointHX;
			LastWaypointHY = WaypointHY;
		end;	%for PositionX = StartingPoint(1):(Spacing*NumberVehicles):g_SearchSpace(4)
	end;	%for iCount = 1:NumberVehicles
otherwise
end;

WaypointDefaultX = 1.0e6;
WaypointDefaultY = 1.0e6;
leglengthDefault = 0.0;
WaypointTypeDefault = g_WaypointTypes.Search;
for(CountVehicles = (g_ActiveVehicles+1):g_MaxNumberVehicles),
	g_WaypointCells{CountVehicles} = [g_WaypointCells{CountVehicles};[WaypointDefaultX,WaypointDefaultY,g_DefaultWaypointAltitude,VelocityCMDFPS,MachFlag,leglengthDefault,realmax,realmax,0,WaypointTypeDefault,-1,ResetVehiclePosition]];
	g_WaypointCells{CountVehicles} = [g_WaypointCells{CountVehicles};[WaypointDefaultX,WaypointDefaultY,g_DefaultWaypointAltitude,VelocityCMDFPS,MachFlag,leglengthDefault,realmax,realmax,0,WaypointTypeDefault,-1,ResetVehiclePosition]];
end;
