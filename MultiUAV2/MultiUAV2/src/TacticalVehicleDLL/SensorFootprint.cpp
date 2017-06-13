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
// SensorFootprint.cpp: implementation of the CSensorFootprint class.
//
//////////////////////////////////////////////////////////////////////

#include "SensorFootprint.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CSensorFootprint::CSensorFootprint()
{

	m_pvTargets = new V_TARGETS_t();
	dGetTargetSensorTolerance() = 5.0*_DEG_TO_RAD;	// tolerance for bank angle +/- degrees
	dGetTargetSensorOffsetX() = 0.0;
	dGetTargetSensorOffsetY() = 0.0;
	bGetSensorOn() = TRUE;
}

CSensorFootprint::~CSensorFootprint()
{
	delete m_pvTargets;
	m_pvTargets = 0;
}


void CSensorFootprint::SetTargetPostion(int iIndex,double dPositionNorth,double dPositionEast)
{
	if(iIndex < vGetTargets().size())
	{
		vGetTargets()[iIndex].dGetPositionNorth() = dPositionNorth;
		vGetTargets()[iIndex].dGetPositionEast() = dPositionEast;
	}
}



void CSensorFootprint::Sensor(const double dElapsedTime,const int iVehicleID,
								const double dVehiclePositionNorth_ft,const double dVehiclePositionEast_ft,
								const double dVehiclePsi_rad,const double dVehiclePhi_rad
								,stringstream& sstrMessage,const enSensorType sensorType)
{
	// If a target is inside the FOV, this sensor provides perfect data on 
	// position and type.

	bGetSensorOn() = TRUE;
	if(fabs(dVehiclePhi_rad) >	dGetTargetSensorTolerance())
	{
		bGetSensorOn() = FALSE;
	}

	switch(sensorType)
	{
	case stRoundSensor:
		{
			// The vehicle round sensor's field of view (FOV) is implemented as a fixed radius circle a fixed 
			// distance away from the vehicle.
			#define SCAN_CENTER_DISTANCE_FEET 3280.839895	// 1000 meters
			#define SCAN_RADIUS_FEET 984.2519685	// 300 meters

			//TODO:: NEEED TO CHECK TO MAKE SURE THE SENSOR POSITION IS CORRECT IN THE NEXT TO LINES
			double dSensorCenterNorth_ft = dVehiclePositionNorth_ft + dGetTargetSensorOffsetX()*sin(dVehiclePsi_rad) + dGetTargetSensorOffsetY()*cos(dVehiclePsi_rad);
			double dSensorCenterEast_ft = dVehiclePositionEast_ft + dGetTargetSensorOffsetX()*cos(dVehiclePsi_rad) + dGetTargetSensorOffsetY()*sin(dVehiclePsi_rad);

			for(V_TARGETS_IT_t itTarget=itGetTargetsBegin();itTarget!=itGetTargetsEnd();itTarget++)
			{
				if(itTarget->iGetID())	// is target alive
				{       
					if(bGetSensorOn())
					{
						double dErrorNorth = dSensorCenterNorth_ft - itTarget->dGetPositionNorth();
						double dErrorEast = dSensorCenterEast_ft - itTarget->dGetPositionEast();
						if(sqrt(dErrorNorth*dErrorNorth + dErrorEast*dErrorEast) < SCAN_RADIUS_FEET)
						{
							if(!itTarget->bGetInSensorFootprint())
							{
								sstrMessage << dElapsedTime << " :VEHICLE " << iVehicleID << ": Found Target ID# " << itTarget->iGetID() << endl << ends;
							}
							itTarget->bGetInSensorFootprint() = TRUE;
						}
						else
						{
							itTarget->bGetInSensorFootprint() = FALSE;
						}
					}
					else // if(bGetSensorOn)
					{
						itTarget->bGetInSensorFootprint() = FALSE;
					} // if(bGetSensorOn)
				} // end if (target exists)
			}  // end for (all possible targets)
		}
		break;

	default:
	case stRectangularSensor:
		{
			// The vehicle retangular sensor's field of view (FOV) is a rectangle on the ground.  Length is
			// 250m and width if 600m. The center of the leading edge of this rectangle is 1000m 
			// on the ground in front of the vehicles postion.
			#define	SCAN_WIDTH_O_2 (984.2519685)	//600m / 2.0 = 300m
			#define	SCAN_OFFSET_MIN (2460.62992125)	// 750m
			#define	SCAN_OFFSET_MAX (3280.839895)	//1000m

			for(V_TARGETS_IT_t itTarget=itGetTargetsBegin();itTarget!=itGetTargetsEnd();itTarget++)
			{
				if(itTarget->iGetID())
				{ 
					if(bGetSensorOn())
					{
						double dCosPsi = cos(-dVehiclePsi_rad);
						double dSinPsi = sin(-dVehiclePsi_rad);
						double dLengthX = itTarget->dGetPositionNorth() - dVehiclePositionNorth_ft;
						double dLengthY = itTarget->dGetPositionEast() - dVehiclePositionEast_ft;
						double dNewTargetCoodX = dLengthX*dCosPsi - dLengthY*dSinPsi;
						double dNewTargetCoodY = dLengthX*dSinPsi + dLengthY*dCosPsi;
						if((dNewTargetCoodY <= SCAN_WIDTH_O_2)&&(dNewTargetCoodY >= -SCAN_WIDTH_O_2)&&
											(dNewTargetCoodX >= SCAN_OFFSET_MIN)&&(dNewTargetCoodX <= SCAN_OFFSET_MAX))
						{
							if(!itTarget->bGetInSensorFootprint())
							{
								sstrMessage << dElapsedTime << " :VEHICLE " << iVehicleID 
									<< ": Found Target ID# " << itTarget->iGetID() << endl;
							}
							itTarget->bGetInSensorFootprint() = TRUE;
						}
						else
						{
							itTarget->bGetInSensorFootprint() = FALSE;
						}
					}
					else // if(bGetSensorOn)
					{
						itTarget->bGetInSensorFootprint() = FALSE;
					} // if(bGetSensorOn)
				} // if(itTarget->iGetID())
			}  // end for (all possible targets)
		}
		break;
	}	//switch(stGetSensorType())
}


