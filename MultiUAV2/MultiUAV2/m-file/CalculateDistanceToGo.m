function DistanceToGo = CalculateDistanceToGo(VehicleID,CurrentPositionX,CurrentPositionY,CurrentWayCount,TurnRadius)
%CalculateDistanceToGo - calculates the distance to the assigned target stand-off point
% calculates the distance from the vehicle's current position to the assigned target
%  stand-off point
%
%  Inputs:
%    VehicleID - initial vehicle position
%    CurrentPositionX,CurrentPositionY - current vehicle position
%    CurrentWayCount - vehicle velocity
%    TurnRadius - radius of the turn circles
%  Outputs:
%    DistanceToGo - the distance from the vehicle's current position to the 
%      assigned target stand-off point.
%

%  AFRL/VACA


%  January 2001 - created and debugged - RAS
%  August 2003 - fixed - RAS and BJM


global g_Debug; if(g_Debug==1),disp('CalculateDistanceToGo.m');end; 

global g_WaypointCells;
global g_WaypointDefinitions;

DistanceToGo = realmax;		%error condition
WayPoints = g_WaypointCells{VehicleID};
[iRows,iColumns] = size(WayPoints);

if (CurrentWayCount==0),
   return;	%error
end;

%insert the current position into the waypoint matrix
WayPoints(CurrentWayCount-1,g_WaypointDefinitions.PositionX) = CurrentPositionX;
WayPoints(CurrentWayCount-1,g_WaypointDefinitions.PositionY) = CurrentPositionY;

%WayPoint Definition: [PositionX PositionY PositionZ VelocityCommand MachFlag EndOfSegmentLength EndOfSegmentTurnCenterX EndOfSegmentTurnCenterY WaypointType TargetHandle ResetDynamics]
%NOTE: EndOfSegmentTurnCenterX and Y are set equal to realmax for straight segments
% find the waypoint that has the next target
TargetWayCount = CurrentWayCount;
for(iCount = CurrentWayCount:iRows),
	if(WayPoints(iCount,g_WaypointDefinitions.TargetHandle)>0),
		TargetWayCount = iCount;
		break;
	end;
end;
iCount = CurrentWayCount;
DistanceTemp = 0;
CircleCenterX = WayPoints(iCount,g_WaypointDefinitions.TurnCenterX);
CircleCenterY = WayPoints(iCount,g_WaypointDefinitions.TurnCenterY);
if((CircleCenterX<realmax)&(CircleCenterY<realmax)), %is this a turn?
	% calculate arc length of circle between two points
	%angle for first waypoint
	Alpha = atan2((WayPoints(iCount-1,g_WaypointDefinitions.PositionY)-CircleCenterY),(WayPoints(iCount-1,g_WaypointDefinitions.PositionX)-CircleCenterX));
	Alpha = mod(Alpha,2*pi);
	
	%angle for second waypoint
	Beta = atan2((WayPoints(iCount,g_WaypointDefinitions.PositionY)-CircleCenterY),(WayPoints(iCount,g_WaypointDefinitions.PositionX)-CircleCenterX));
	Beta = mod(Beta,2*pi);

	CircleDirection = WayPoints(iCount,g_WaypointDefinitions.TurnDirection);
	if (CircleDirection==0)
		DistanceToGo = realmax;		%error condition
		return;	%error
	end;
	if (CircleDirection > 0)
		if(Alpha > Beta)
			DistanceTurn = (2.0*pi - Alpha + Beta)*TurnRadius;
		else
			DistanceTurn = (Beta - Alpha)*TurnRadius;
		end
	else	%if (CircleDirection > 0)
		if(Alpha >= Beta)
			DistanceTurn = (Alpha - Beta)*TurnRadius;
		else
			DistanceTurn = ((2.0*pi - Beta) + Alpha)*TurnRadius;
		end
	end;	%if (CircleDirection > 0)
	TurnTolerance = pi/180.0;
	if(2.0*pi-(DistanceTurn/TurnRadius) < TurnTolerance),
		DistanceTurn = 0;
	end;
	DistanceTemp = DistanceTemp + DistanceTurn;
else,
	dx = WayPoints(iCount,g_WaypointDefinitions.PositionX) - WayPoints(iCount-1,g_WaypointDefinitions.PositionX); 
	dy = WayPoints(iCount,g_WaypointDefinitions.PositionY) - WayPoints(iCount-1,g_WaypointDefinitions.PositionY);
	DistancePoints = sqrt(dx*dx+dy*dy); 
	DistanceTemp = DistanceTemp + DistancePoints;
end;

CurrentWayCount = CurrentWayCount + 1;
DistanceTemp = DistanceTemp + sum(WayPoints([CurrentWayCount:TargetWayCount],g_WaypointDefinitions.SegmentLength));

DistanceToGo = DistanceTemp;