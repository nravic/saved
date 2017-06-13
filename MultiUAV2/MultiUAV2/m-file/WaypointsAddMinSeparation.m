function WaypointsOut = WaypointsAddMinSeparation(WaypointsIn,TurnRadius,MinimumWaypointSeparation)
%WaypointsAddMinSeparation - adds extra waypoints along the circular segements of the trajectory.
% In order to cause the vehicle to better track the commanded trajectory, extra
% waypoints are added to the circular portions of the trajecory.
%
%  Inputs:
%    WaypointsIn - the current list of waypoints
%    TurnRadius - radius of the turn circles
%    MinimumWaypointSeparation - minimum linear distance between waypoints during 
%      circular portions of the trajectory.
%  Outputs:
%    WaypointsOut - list of waypoints with waypoints added to maintain minimum separation.
%

%  AFRL/VACA

%  January 2001 - created and debugged - RAS


%WayPoint Definition: [PositionX PositionY PositionZ VelocityCommand MachFlag 
%								EndOfSegmentLength EndOfSegmentTurnCenterX EndOfSegmentTurnCenterY EndOfSegmentTurnDirection]
	%NOTE: EndOfSegmentTurnCenterX and Y are set equal to realmax for straight segments
   
   

global g_Debug; if(g_Debug==1),disp('WaypointsAddMinSeparation.m');end; 

WaypointsOut = [];		%error condition


[iNumberWaypoints,iColumns] = size(WaypointsIn);
PositionXIndex = 1;
PositionYIndex = 2;
PositionZIndex = 3;
VelocityCommandIndex = 4;
MachFlagIndex = 5;
EndOfSegmentLengthIndex = 6;
EndOfSegmentTurnCenterXIndex = 7;
EndOfSegmentTurnCenterYIndex = 8;
EndOfSegmentTurnDirectionIndex = 9;
TwoPI  = 2.0*pi;
SeparationArcRad = MinimumWaypointSeparation/TurnRadius;
TemplateWaypoint = WaypointsIn(1,:);	%this is the waypoint to add to the list after changing the positions
TemplateWaypoint(EndOfSegmentLengthIndex) = MinimumWaypointSeparation;
TemplateWaypoint(EndOfSegmentTurnCenterXIndex) = realmax;	%note: setting these to real max cause the CalculateDistanceToGo function to consider this a staright line segment when calculating its distance calculation
TemplateWaypoint(EndOfSegmentTurnCenterYIndex) = realmax;
TemplateWaypoint(EndOfSegmentTurnDirectionIndex) = 0;			

for iCount = 1:iNumberWaypoints-3,	%excluding the last two way points from minimum distance size
   WaypointsOut = [WaypointsOut;WaypointsIn(iCount,:)];
   CircleCenterX = WaypointsIn(iCount+1,EndOfSegmentTurnCenterXIndex);
   CircleCenterY = WaypointsIn(iCount+1,EndOfSegmentTurnCenterYIndex);
   WaypointAlphaX = WaypointsIn(iCount,PositionXIndex);
   WaypointAlphaY = WaypointsIn(iCount,PositionYIndex);
   if ((CircleCenterX < realmax)&(CircleCenterY < realmax)), %is this a turn?
      %angle for first waypoint
      Alpha = atan2((WaypointAlphaY-CircleCenterY),(WaypointAlphaX-CircleCenterX));
		while(Alpha <=0),Alpha = Alpha + 2*pi;end;while(Alpha >= 2*pi),Alpha = Alpha - 2*pi;end;
      %angle for second waypoint
		Beta = atan2((WaypointsIn(iCount+1,PositionYIndex)-CircleCenterY),(WaypointsIn(iCount+1,PositionXIndex)-CircleCenterX));
		while(Beta <= 0),Beta = Beta + 2*pi;end;while(Beta >= 2*pi),Beta = Beta - 2*pi;end;
      CircleDirection = WaypointsIn(iCount+1,EndOfSegmentTurnDirectionIndex);
      CurrentAngle = Alpha;
      if (CircleDirection==0)
         WaypointsOut = [];		%error condition
         return;	%error
      elseif (CircleDirection > 0)	%if (CircleDirection==0)
         CircleDirection = 1.0;
         CurrentAngle = Alpha + (CircleDirection*SeparationArcRad);
         EndAngle = Beta - (CircleDirection*SeparationArcRad);
			while(EndAngle <= 0),EndAngle = EndAngle + 2*pi;end;while(EndAngle >= 2*pi),EndAngle = EndAngle - 2*pi;end;
			if((Alpha > EndAngle)),
            while(CurrentAngle < TwoPI),
               PositionX = TurnRadius*cos(CurrentAngle) + CircleCenterX;
               PositionY = TurnRadius*sin(CurrentAngle) + CircleCenterY;
               TemplateWaypoint(PositionXIndex) = PositionX;
               TemplateWaypoint(PositionYIndex) = PositionY;
					WaypointsOut = [WaypointsOut;TemplateWaypoint];
         		CurrentAngle = CurrentAngle + (CircleDirection*SeparationArcRad);
            end;
            CurrentAngle = CurrentAngle - TwoPI;
			end;	%if(Alpha > Beta),
         while(CurrentAngle < EndAngle),
				PositionX = TurnRadius*cos(CurrentAngle) + CircleCenterX;
				PositionY = TurnRadius*sin(CurrentAngle) + CircleCenterY;
				TemplateWaypoint(PositionXIndex) = PositionX;
				TemplateWaypoint(PositionYIndex) = PositionY;
				WaypointsOut = [WaypointsOut;TemplateWaypoint];
				CurrentAngle = CurrentAngle + (CircleDirection*SeparationArcRad);
			end;
         % change the settings on the original turn termination waypoint:
         LastAngle = CurrentAngle - SeparationArcRad;
         if(Beta > LastAngle),
				AngleLeft = Beta - LastAngle;
         else,
				AngleLeft = Beta + (TwoPI - CurrentAngle);
         end;
			WaypointsIn(iCount+1,EndOfSegmentLengthIndex) = AngleLeft*TurnRadius;
			WaypointsIn(iCount+1,EndOfSegmentTurnCenterXIndex) = realmax;	%note: setting these to real max cause the CalculateDistanceToGo function to consider this a staright line segment when calculating its distance calculation
			WaypointsIn(iCount+1,EndOfSegmentTurnCenterYIndex) = realmax;
			WaypointsIn(iCount+1,EndOfSegmentTurnDirectionIndex) = 0;			
      else,	%elseif (CircleDirection > 0)	
         CircleDirection = -1.0;
         	CurrentAngle = Alpha + (CircleDirection*SeparationArcRad);
         	EndAngle = Beta - (CircleDirection*SeparationArcRad);
				while(EndAngle <= 0),EndAngle = EndAngle + 2*pi;end;while(EndAngle >= 2*pi),EndAngle = EndAngle - 2*pi;end;
				if(Alpha < EndAngle),
            	while(CurrentAngle > 0),
               	PositionX = TurnRadius*cos(CurrentAngle) + CircleCenterX;
               	PositionY = TurnRadius*sin(CurrentAngle) + CircleCenterY;
               	TemplateWaypoint(PositionXIndex) = PositionX;
               	TemplateWaypoint(PositionYIndex) = PositionY;
						WaypointsOut = [WaypointsOut;TemplateWaypoint];
         			CurrentAngle = CurrentAngle + (CircleDirection*SeparationArcRad);
            	end;
            	CurrentAngle = TwoPI + CurrentAngle;
				end;	%if(Alpha > Beta),
            while(CurrentAngle > EndAngle),
               PositionX = TurnRadius*cos(CurrentAngle) + CircleCenterX;
               PositionY = TurnRadius*sin(CurrentAngle) + CircleCenterY;
               TemplateWaypoint(PositionXIndex) = PositionX;
               TemplateWaypoint(PositionYIndex) = PositionY;
					WaypointsOut = [WaypointsOut;TemplateWaypoint];
         		CurrentAngle = CurrentAngle + (CircleDirection*SeparationArcRad);
            end;
            % change the settings on the original turn termination waypoint:
         LastAngle = CurrentAngle - (CircleDirection*SeparationArcRad);
         if(Beta < LastAngle),
				AngleLeft = LastAngle - Beta;
         else,
				AngleLeft = LastAngle + (TwoPI - Beta);
         end;
            AngleLeft = SeparationArcRad - (Beta - CurrentAngle);
				WaypointsIn(iCount+1,EndOfSegmentLengthIndex) = AngleLeft*TurnRadius;
            WaypointsIn(iCount+1,EndOfSegmentTurnCenterXIndex) = realmax;	%note: setting these to real max cause the CalculateDistanceToGo function to consider this a staright line segment when calculating its distance calculation
				WaypointsIn(iCount+1,EndOfSegmentTurnCenterYIndex) = realmax;
				WaypointsIn(iCount+1,EndOfSegmentTurnDirectionIndex) = 0;			
		end;	%if (CircleDirection==0)
   else,	%if ((CircleCenterX < realmax)&(CircleCenterY < realmax))), %is this a turn?
      %compute angle for transformation of coordinates
      dX = WaypointsIn(iCount+1,PositionXIndex) - WaypointsIn(iCount,PositionXIndex);
      dY = WaypointsIn(iCount+1,PositionYIndex) - WaypointsIn(iCount,PositionYIndex);
      LengthSegment = sqrt((dX*dX)+(dY*dY));
      EndTest = LengthSegment - MinimumWaypointSeparation;
      CurrentLength = MinimumWaypointSeparation;
      if ((EndTest > 0)&(LengthSegment < 1e5)),	% some if the lenght is very large this will take too much time
			theta = atan2(dY,dX);
      	while(theta >= 2*pi),theta = theta - 2*pi;end;while(theta < 0),theta = theta + 2*pi;end;
      	while(CurrentLength < EndTest),
				PositionX = CurrentLength*cos(theta) + WaypointAlphaX;
				PositionY = CurrentLength*sin(theta) + WaypointAlphaY;
				TemplateWaypoint(PositionXIndex) = PositionX;
				TemplateWaypoint(PositionYIndex) = PositionY;
				WaypointsOut = [WaypointsOut;TemplateWaypoint];
      		CurrentLength = CurrentLength + MinimumWaypointSeparation;
			end;
      end;	%if (EndTest > 0),
		% change the settings on the original turn termination waypoint:
		DistanceLeft = LengthSegment - (CurrentLength - MinimumWaypointSeparation) ;
		WaypointsIn(iCount+1,EndOfSegmentLengthIndex) = DistanceLeft;
		WaypointsIn(iCount+1,EndOfSegmentTurnCenterXIndex) = realmax;	%note: setting these to real max cause the CalculateDistanceToGo function to consider this a staright line segment when calculating its distance calculation
		WaypointsIn(iCount+1,EndOfSegmentTurnCenterYIndex) = realmax;
		WaypointsIn(iCount+1,EndOfSegmentTurnDirectionIndex) = 0;			
	end;	%if ((CircleCenterX < realmax)&(CircleCenterY < realmax))), %is this a turn?
end;	%for iCount = CurrentWayCount:iRows-2,
WaypointsOut = [WaypointsOut;WaypointsIn(iNumberWaypoints-2,:)];	% final waypoint
WaypointsOut = [WaypointsOut;WaypointsIn(iNumberWaypoints-1,:)];	% final waypoint
WaypointsOut = [WaypointsOut;WaypointsIn(iNumberWaypoints,:)];	% final waypoint


