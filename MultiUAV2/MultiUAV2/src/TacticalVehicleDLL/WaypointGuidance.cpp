//
//	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION IS RELEASED "AS IS." THE
//	U.S.GOVERNMENT MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, CONCERNING
//	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION, INCLUDING, WITHOUT LIMITATION,
//	ANY WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
//	WILL THE U.S. GOVERNMENT BE LIABLE FOR ANY DAMAGES, INCLUDING ANY LOST PROFITS,
//	LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE,
//	OR INABILITY TO USE, THIS SOFTWARE OR ANY ACCOMPANYING DOCUMENTATION, EVEN IF
//	INFORMED IN ADVANCE OF THE POSSIBILITY OF SUCH DAMAGES.
//
// WaypointGuidance.cpp: implementation of the CWaypointGuidance class.
//
//////////////////////////////////////////////////////////////////////
#include <stdio.h>

#include "WaypointGuidance.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CWaypointGuidance::CWaypointGuidance()
{

	szGetWaypointIndex() = 0;
	dGetTotalSearchTime() = 0.0;
	iGetWaypointTypeLast() = -1;
	iGetWaypointTypeCurrent() = -1;
	iGetWaypointTargetHandleCurrent() = -1;
	iGetWaypointTargetHandleLast() = -1;

	m_pvwayWaypoints = new V_WAYPOINT_t();
}

CWaypointGuidance::~CWaypointGuidance()
{

	delete m_pvwayWaypoints;
	m_pvwayWaypoints = 0;
}


/*  
  -------------------------------------------------------------------------*/
//  
// Created 6-15-2001 by Jeff Fowler using tm_waypoints.cpp as template
//  March 2002 - Changed to add tolerance in passed waypoint check - RAS
//


#define RABBIT_LEAD 1000.0
//#define RABBIT_LEAD 500.0

#define WAYPOINT_TOLERANCE (100.0)
#define WAYPOINT_TRAJECTORY_TOLERANCE (300.0)

void
CWaypointGuidance::WaypointGuidance(const double& dElapsedTime,const int& iVehicleID,
																		const double& dTimeIncrement_sec,
																		const double& dVehiclePositionNorth_ft,
																		const double& dVehiclePositionEast_ft,
																		const double& dVehicleHeading_rad,
																		double& dCommandHeading_rad,double& dCommandAltitude_ft,
																		double& dCommandVelocity_ftpersec,
																		stringstream& sstrMessage)
{


# ifdef JWM_DEBUG
#   ifndef JWM_DEBUG_ETIME
#	    define  JWM_DEBUG_ETIME (0.4)
#   endif

	static bool is_first_time = true;
	bool we_have_nans = isnan( dVehiclePositionNorth_ft ) ||
											isnan( dVehiclePositionEast_ft ) ||
											isnan( dVehicleHeading_rad ) ||
											isnan( dCommandHeading_rad ) ||
											isnan( dCommandAltitude_ft ) ||
											isnan( dCommandVelocity_ftpersec );

	if( dElapsedTime > JWM_DEBUG_ETIME || we_have_nans )
	{
		FILE* fp = fopen("debugjwm.txt", "a");
		assert( fp != 0x0 );
	
		if( is_first_time )
		{
			fprintf(fp,"\t{iVehicleID, t, dTimeIncrement_sec, dVehiclePositionNorth_ft, "
							"dVehiclePositionEast_ft, dVehicleHeading_rad, dCommandHeading_rad, "
							"dCommandAltitude_ft, dCommandVelocity_ftpersec}\n");
			is_first_time = false;
		}
		
		if( we_have_nans ) fprintf(fp,"some NaNs found!\n");

		fprintf(fp, 
						"{%d %5.2f %.3f % 8.4e % 8.4e % 8.4e % g % g % g}\n",
						iVehicleID, dElapsedTime, dTimeIncrement_sec, dVehiclePositionNorth_ft, 
						dVehiclePositionEast_ft, dVehicleHeading_rad, dCommandHeading_rad, 
						dCommandAltitude_ft, dCommandVelocity_ftpersec);
		fflush(fp);
		fclose(fp);
		fflush(0x0);

		if( we_have_nans )
		{
			fprintf(stderr, "It's getting too weird for me!\nI QUIT!\n");
			fprintf(stderr, "__FILE__:__LINE__ - CWaypointGuidance::WaypointGuidance(...)\n");
			fflush(0x0);
			exit(EXIT_FAILURE);
		}
	}
# else
	assert( !isnan( dVehiclePositionNorth_ft ) );
	assert( !isnan( dVehiclePositionEast_ft ) );
# endif
	
	// Check whether it's time to update to next waypoint
	double dDistanceToGo = 0.0;		// Distance on trajectory to waypoint
	double Ndist = 0.0;
	double Edist = 0.0;
	double TotDist = 0.0;
	BOOL bPassedWaypoint = TRUE;	// Do the while loop at least once
	while(bPassedWaypoint)		// Don't steer based on a waypoint you've already passed
	{
		bPassedWaypoint = FALSE;	// Until proven otherwise
		if(szGetWaypointIndex() == 0)		// Automatically pass waypoint 0 because
		{						// it's the current vehicle position when the trajectory
			bPassedWaypoint = TRUE;// is first assigned
		} 
		else				// If there's a waypoint behind this one
		{
#     ifdef JWM_DEBUG  
			// Report the information for the 0th waypoint
			if( szGetWaypointIndex() == 1 )
			{
				sstrMessage << "WP#0: {Pos:{N,E}, Ctr:{N,E}, Tdir} =  {{" 
										<< vGetWaypoints()[0].dGetPositionNorth() << ", "
										<< vGetWaypoints()[0].dGetPositionEast() << "}, {" 
										<< vGetWaypoints()[0].dGetTurnCenterNorth() << ", " 
										<< vGetWaypoints()[0].dGetTurnCenterEast() << "}, "
										<< vGetWaypoints()[0].iGetTurnDirection() << "}" << endl;
			}
#     endif
			
			// Read in data for current waypoint
			double dWaypointNorth = wayGetCurrentWaypoint().dGetPositionNorth();	// Coordinates of current waypoint
			double dWaypointEast = wayGetCurrentWaypoint().dGetPositionEast();
			int iRotationDirection = wayGetCurrentWaypoint().iGetTurnDirection();		// Direction of turn: 1 for ccw, -1 for cw, 0 for straight
			double dDistanceVehicleToWaypoint = sqrt(pow((dVehiclePositionNorth_ft-dWaypointNorth),2) + pow((dVehiclePositionEast_ft-dWaypointEast),2));
 			if(iRotationDirection == 0) // If currently on a straight line
			{
				// Read in data for previous waypoint
				double Nprev = vGetWaypoints()[szGetWaypointIndex() - 1].dGetPositionNorth();	 // Coordinates of previous waypoint, if it exists;
				double Eprev = vGetWaypoints()[szGetWaypointIndex() - 1].dGetPositionEast();
				// Calculate segment length
				Ndist = Nprev - dWaypointNorth;
				Edist = Eprev - dWaypointEast;
				TotDist = sqrt(Ndist*Ndist+Edist*Edist);	// Length of segment
				// Test whether current waypoint has been passed
				// This is a dot product calculating the distance between the waypoint
				// and the projection of the vehicle onto the trajectory
				dDistanceToGo = (TotDist==0)?(0.0):((Ndist*(dVehiclePositionNorth_ft-dWaypointNorth)+Edist*(dVehiclePositionEast_ft-dWaypointEast))/TotDist);
				bPassedWaypoint = ((dDistanceToGo <= 0)&&(dDistanceVehicleToWaypoint<=WAYPOINT_TRAJECTORY_TOLERANCE));
			}
			else 	//if(iRotationDirection == 0)
			{// Circular arc
				// Read in turning center and arclength
				double Ntc = wayGetCurrentWaypoint().dGetTurnCenterNorth();	// Coordinates of turning center
				double Etc = wayGetCurrentWaypoint().dGetTurnCenterEast();
				TotDist = wayGetCurrentWaypoint().dGetSegmentLength();
				// Calculate the turning radius as distance from turning center to waypoint
				Ndist = dWaypointNorth - Ntc;
				Edist = dWaypointEast - Etc;
				double TurnRadius = sqrt(Ndist*Ndist + Edist*Edist);
				// Calculate the projection of the vehicle onto the trajectory
				double Angle = atan2(dVehiclePositionEast_ft - Etc, dVehiclePositionNorth_ft - Ntc);	// Angle from turning center
				// Translate Angle to the standard interval
				Angle = dNormalizeAngleRad(Angle,0.0);
				// The same calculation for the waypoint
				double WptAngle = atan2(Edist,Ndist);	// Angles from turning center
				// Translate WptAngle to the standard interval
				WptAngle = dNormalizeAngleRad(WptAngle,0.0);
				// The angle from the vehicle to the waypoint, measured from the turning center
				// in the direction of rotation
				double AngleToGo = 0.0;
				if(iRotationDirection >= 0)
				{
					if(WptAngle >= Angle)
					{
						AngleToGo = WptAngle - Angle;
					}
					else
					{
						AngleToGo = (_2PI - Angle) + WptAngle;
					}
				}
				else
				{
					if(WptAngle <= Angle)
					{
						AngleToGo = Angle - WptAngle;
					}
					else
					{
						AngleToGo = (_2PI - WptAngle) + Angle;
					}
				}
				#ifdef STEVETEST
					// May use the following to make sure we're not a little off
					AngleToGo += 0.02*AngleToGo;
				#endif	//#ifdef STEVETEST
				// Translate AngleToGo to the standard interval
				AngleToGo = dNormalizeAngleRad(AngleToGo,0.0);
				// Convert the angle into a remaining distance
				dDistanceToGo = AngleToGo * TurnRadius;
				// When the waypoint has been passed, the "remaining distance" is almost
				// the entire circumference and therefore larger than the segment length
				#ifdef STEVETEST
					bPassedWaypoint = ((dDistanceToGo > TotDist)&&(dDistanceVehicleToWaypoint<=WAYPOINT_TRAJECTORY_TOLERANCE));
				#else	//#ifdef STEVETEST
					bPassedWaypoint = (((dDistanceToGo>(TotDist + WAYPOINT_TOLERANCE))||(dDistanceToGo <= WAYPOINT_TOLERANCE))&&(dDistanceVehicleToWaypoint<=WAYPOINT_TRAJECTORY_TOLERANCE));
				#endif	//#ifdef STEVETEST
			} // //if(iRotationDirection == 0)
		} // if(szGetWaypointIndex() == 0)
		if (bPassedWaypoint)
		{
			sstrMessage << dElapsedTime << " :VEHICLE " << iVehicleID <<  ": cycles past waypoint # "
				<< szGetWaypointIndex() << endl;

			szGetWaypointIndex()++;
			szGetWaypointIndex() = (szGetWaypointIndex()>=vGetWaypoints().size()-1)?vGetWaypoints().size()-1:szGetWaypointIndex();
			#ifdef JEFFTEST // Report the information for the new waypoint
				sstrMessage << "Npos " << wayGetCurrentWaypoint().dGetPositionNorth() << "; Epos " << wayGetCurrentWaypoint().dGetPositionEast() << ";" << endl;
				sstrMessage << "Nctr " << wayGetCurrentWaypoint().dGetTurnCenterNorth() << "; Ectr " << wayGetCurrentWaypoint().dGetTurnCenterEast() << "; Direction " << wayGetCurrentWaypoint().iGetTurnDirection() << endl;
			#endif //JEFFTEST
			UpdateWaypointTypeAndTargetHandle();
		}  // end if (waypoint update)
	} // while

	//***************************************************************************
	//         Compute rabbit position
	//
	//

	int rabbitWayCount = szGetWaypointIndex();	// The index of the next waypoint past the rabbit
	double rabbitToGo = RABBIT_LEAD;	// Amount of the rabbit's lead remaining

	while(dDistanceToGo < rabbitToGo)	// If the current waypoint can't accomodate the lead
	{
		rabbitToGo -= dDistanceToGo;		// Use up the path length to the current waypoint
		// If there's another waypoint, use it, else we'll generate one with length 2*RABBIT_LEAD
		rabbitWayCount++;
		if (rabbitWayCount >= vGetWaypoints().size() - 1)
		{
			dDistanceToGo = 2*RABBIT_LEAD;
		} 
		else
		{
			dDistanceToGo = vGetWaypoints()[rabbitWayCount].dGetSegmentLength();
		} // if other waypoint
	} // while(dDistanceToGo < rabbitToGo)
	double excessLength = dDistanceToGo - rabbitToGo;	// Path length from the rabbit to its waypoint
	dGetRabbitN() = 0.0;
	dGetRabbitE() = 0.0;
	dGetRabbitPsi() = 0.0;
	if(rabbitWayCount >= vGetWaypoints().size() - 1)		// If past the last good waypoint
	{
		dGetRabbitN() = vGetWaypoints()[vGetWaypoints().size() - 2].dGetPositionNorth();	// Stop over the target
		dGetRabbitE() = vGetWaypoints()[vGetWaypoints().size() - 2].dGetPositionEast();
		Ndist = dGetRabbitN() - dVehiclePositionNorth_ft;
		Edist = dGetRabbitE() - dVehiclePositionEast_ft;
		dGetRabbitPsi() = atan2(Edist,Ndist);
		/*	int rabbitPrevRotDir = vGetWaypoints()[vGetWaypoints().size() - 2].iGetTurnDirection();	// The last given segment
		if(rabbitPrevRotDir == 0)	// If coming off a straight line
		{
		Ndist = rabbitNprev - vGetWaypoints()[vGetWaypoints().size() - 3].dGetPositionNorth();
		Edist = rabbitEprev - vGetWaypoints()[vGetWaypoints().size() - 3].dGetPositionEast();
		rabbitWptHdg = atan2(Edist,Ndist);	// Heading matches the straight line
		} else	// If coming off an arc
		{	// The heading is perpendicular to the radius to the vGetWaypoints()
		Ndist = rabbitNprev - vGetWaypoints()[vGetWaypoints().size() - 2].dGetTurnCenterNorth();
		Edist = rabbitEprev - vGetWaypoints()[vGetWaypoints().size() - 2].dGetTurnCenterEast();
		rabbitWptHdg = atan2(Edist,Ndist) + _PI_O_2 * vGetWaypoints()[vGetWaypoints().size() - 2].iGetTurnDirection();
		} // if last waypoint was straight
		rabbitNwpt = rabbitNprev + 2 * RABBIT_LEAD * cos(rabbitWptHdg);	// Extend the trajectory in
		rabbitEwpt = rabbitEprev + 2 * RABBIT_LEAD * sin(rabbitWptHdg);	// the calculated direction
		*/
	} 
	else	//if(rabbitWayCount >= vGetWaypoints().size() - 1)
	{	//  // There's already another segment to use, Read in its data
		int rabbitRotDir = vGetWaypoints()[rabbitWayCount].iGetTurnDirection();	// Rotation direction for the segment the rabbit is on
		double rabbitNwpt = vGetWaypoints()[rabbitWayCount].dGetPositionNorth();	// Coordinates of the waypoint immediately after the rabbit
		double rabbitEwpt = vGetWaypoints()[rabbitWayCount].dGetPositionEast();	// Coordinates of the waypoint immediately after the rabbit
		if(rabbitRotDir == 0) // If the rabbit is on a straight segment
		{
			double rabbitNprev = vGetWaypoints()[rabbitWayCount - 1].dGetPositionNorth();	// Get the heading from the previous
			double rabbitEprev = vGetWaypoints()[rabbitWayCount - 1].dGetPositionEast();	// Waypoint
			Ndist = rabbitNwpt - rabbitNprev;
			Edist = rabbitEwpt - rabbitEprev;
			double rabbitWptHdg = atan2(Edist,Ndist);	// Heading for the end of the last given segment
			// Its position is excessLength before the vGetWaypoints(), on the antiparallel of the heading
			dGetRabbitN() = rabbitNwpt - excessLength * cos(rabbitWptHdg);
			dGetRabbitE() = rabbitEwpt - excessLength * sin(rabbitWptHdg);
			dGetRabbitPsi() = rabbitWptHdg;
		} 
		else	// If the rabbit is on a curve
		{
			double rabbitNtc = vGetWaypoints()[rabbitWayCount].dGetTurnCenterNorth();	// Get the turning center
			double rabbitEtc = vGetWaypoints()[rabbitWayCount].dGetTurnCenterEast();
			Ndist = rabbitNwpt - rabbitNtc;				// Calculate the turning radius
			Edist = rabbitEwpt - rabbitEtc;
			double rabbitTurnRadius = sqrt(Ndist*Ndist + Edist*Edist);
			// Calculate the angle to the waypoint
			double rabbitWptAngle = atan2(rabbitEwpt-rabbitEtc, rabbitNwpt-rabbitNtc);	// Angle to the rabbit and its waypoint from its center
			rabbitWptAngle = dNormalizeAngleRad(rabbitWptAngle,0.0);
			// Back up a distance of excessLength in the proper direction, as an angle first
			double rabbitAngle = rabbitWptAngle - rabbitRotDir * excessLength / rabbitTurnRadius;	// Angle to the rabbit and its waypoint from its center
			rabbitAngle = dNormalizeAngleRad(rabbitAngle,0.0);

			dGetRabbitPsi() = rabbitAngle + _PI_O_2 * vGetWaypoints()[rabbitWayCount].iGetTurnDirection();
			// Convert the angle into the rabbit's position
			dGetRabbitN() = rabbitNtc + rabbitTurnRadius * cos(rabbitAngle);
			dGetRabbitE() = rabbitEtc + rabbitTurnRadius * sin(rabbitAngle);
		} // if rabbit straight
	} // if(rabbitWayCount >= vGetWaypoints().size() - 1),   if rabbit past last waypoint

	//***************************************************************************  
	//
	//         Compute steering commands 
	//
	// compute heading from the vehicle to the rabbit
	Ndist = dGetRabbitN() - dVehiclePositionNorth_ft;
	Edist = dGetRabbitE() - dVehiclePositionEast_ft;   
	double dHdgToRabbit = atan2(Edist,Ndist); 

	// Compute heading error and deal with wraparound
#ifndef STEVETEST
	double dHeadingError = dHdgToRabbit + dVehicleHeading_rad;
#else	//STEVETEST
	double dHeadingError = dHdgToRabbit - dVehicleHeading_rad;
#endif	//STEVETEST

#ifdef STEVETEST
	dHeadingError = dNormalizeAngleRad(dHeadingError);
#else	//STEVETEST
	dHeadingError = (dHeadingError<-_PI)?(dHeadingError+_2PI):((dHeadingError>=_PI)?(dHeadingError-_2PI):(dHeadingError));
#endif	//STEVETEST

#ifndef STEVETEST
	dGetCommandHeading() = dCommandHeading_rad = dHdgToRabbit;
#else	//STEVETEST
	dGetCommandHeading() = dCommandHeading_rad = 1.1*dHeadingError;
#endif	//STEVETEST
	dGetCommandAltitude() = dCommandAltitude_ft = -wayGetCurrentWaypoint().dGetPositionDown();
	dGetCommandVelocity() = dCommandVelocity_ftpersec = wayGetCurrentWaypoint().dGetVelocity();

#ifdef STEVETEST
FILE* fp = fopen( "debug.txt", "a" );
fprintf(fp,"%g \t%g \t%g \n",dHdgToRabbit,dVehicleHeading_rad,dCommandHeading_rad);
fclose(fp);
#endif	//STEVETEST

#define WAYPOINT_TYPE_SEARCH (1)
	// update total search time
	if(wayGetCurrentWaypoint().iGetType() == WAYPOINT_TYPE_SEARCH)
	{
		dGetTotalSearchTime() += dTimeIncrement_sec;
	}
	UpdateWaypointTypeAndTargetHandle();
}



void CWaypointGuidance::UpdateWaypointTypeAndTargetHandle()
{
	if(iGetWaypointTypeCurrent() != wayGetCurrentWaypoint().iGetType())
	{
		if(itGetCurrentWaypoint() != itGetWaypointsBegin())
		{
			iGetWaypointTypeLast() = iGetWaypointTypeCurrent();
		}
		else
		{
			iGetWaypointTypeLast() = wayGetCurrentWaypoint().iGetType();
		}
		iGetWaypointTypeCurrent() = wayGetCurrentWaypoint().iGetType();
	}

	if(iGetWaypointTargetHandleCurrent() != wayGetCurrentWaypoint().iGetTargetHandle())
	{
		if(itGetCurrentWaypoint() != itGetWaypointsBegin())
		{
			iGetWaypointTargetHandleLast() = iGetWaypointTargetHandleCurrent();
		}
		else
		{
			iGetWaypointTargetHandleLast() = wayGetCurrentWaypoint().iGetTargetHandle();
		}
		iGetWaypointTargetHandleCurrent() = wayGetCurrentWaypoint().iGetTargetHandle();
	}
}

void CWaypointGuidance::GetCurrentAssignment(int& iAssignedTarget,int& iAssignedTask)
{
	iAssignedTarget = -1;
	iAssignedTask = -1;
	V_WAYPOINT_IT_t itWaypoint; // for scope hack for wretched MSVC++6.
	for(itWaypoint=itGetCurrentWaypoint();itWaypoint!=itGetWaypointsEnd();itWaypoint++)
	{
		if(itWaypoint->iGetTargetHandle() > 0)
		{
			break;
		}
	}
  // ISO says this is out of scope unless you use odious MSVC++6 (see above)
	if(itWaypoint!=itGetWaypointsEnd())
	{
		iAssignedTarget = itWaypoint->iGetTargetHandle();
		iAssignedTask = itWaypoint->iGetType();
	}
}

