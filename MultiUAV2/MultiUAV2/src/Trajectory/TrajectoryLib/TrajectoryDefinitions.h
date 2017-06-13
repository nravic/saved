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
//

#ifndef TRAJECTORYDEFINITIONS_H
#define TRAJECTORYDEFINITIONS_H


#include "GlobalDefines.h"

#ifndef _OUPUT_CONVERSION_TEXT
//#define _OUPUT_CONVERSION_TEXT "Feet"
#define _OUPUT_CONVERSION_TEXT "Miles"
//#define _OUPUT_CONVERSION_TEXT "Meters"
//#define _OUPUT_CONVERSION_TEXT "Kilometers"
#endif

#ifndef _GRAVITY_DEFAULT
#define _GRAVITY_DEFAULT 32.17	// ft/sec^2
#endif

#ifndef _MAXTIME
#ifndef MATLAB_MEX_FILE
#define _MAXTIME 3600   // 1 hour in seconds
#else	//MATLAB_MEX_FILE
#define _MAXTIME 600
#endif	//MATLAB_MEX_FILE
#endif	//_MAXTIME

#ifndef TIME_INCREMENT
#define TIME_INCREMENT 0.01
#endif

#ifndef NUMBER_THREATS
#define NUMBER_THREATS 40
#endif
#ifndef NUMBER_TARGETS
//#define NUMBER_TARGETS 8
#define NUMBER_TARGETS 50
#endif
#ifndef NUMBER_LUVS
#define NUMBER_LUVS 6
#endif

#ifndef NUMBER_REMOTE_COMMANDS
#define NUMBER_REMOTE_COMMANDS 5
#endif

#ifndef MAX_WAYPOINTS
#ifndef MATLAB_MEX_FILE
#define MAX_WAYPOINTS 1000		//this is the maximum number of waypoints (not yet set up in original waypoint code)
#else	//MATLAB_MEX_FILE
#define MAX_WAYPOINTS 100		//this is the maximum number of waypoints (not yet set up in original waypoint code)
#endif	//MATLAB_MEX_FILE
#endif	//MAX_WAYPOINTS

// define the BOOL values (this should be set to the bool type, but is it ANSI?)
#ifndef BOOL
typedef int BOOL;
#define Bool BOOL
#endif

#ifndef NULL
#define NULL 0
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef _PLOTS_PATH
#define	_PLOTS_PATH ".\\Plots\\"
#endif
#ifndef _AVDS_DATA_PATH
#define	_AVDS_DATA_PATH ".\\AVDSData\\"
#endif


#include <limits>
#include <math.h>

namespace QXRT135
{

	enum enTurnDirection_t {turnClockwise=-1,turnNone,turnCounterclockwise};	//the +/- 1 and 0 are used in calculations

	enum n_enCaseType_t {caseUnknown,caseOne,caseTwo,caseThree,caseFour,caseFive,caseNumberEntries};
	enum n_enTaskType_t {taskSearch,taskClassify,taskAttack,taskVerify,taskFinished,taskNumberEntries};
	enum n_enWaypointType_t {waytypeSearch=1,waytypeEnroute,waytypeClassify,waytypeAttack,waytypeVerify,
									waytypeStartPoint,waytypeEndPoint,waytypeNumberEntries,
									waytypeEndTask=100,waytypeEndTaskReplan=200,waytypeQualifierMultiple};
	const int n_iVehicleDead = -1;
	enum n_enWaypointEntry_t{wayPositionX_ft,wayPositionY_ft,wayPositionZ_ft,wayMachCommand,wayMachCommandFlag,
								waySegmentLength_ft,wayTurnCenterX_ft,wayTurnCenterY_ft,wayTurnDirection,
								wayWaypointType,wayTargetHandle,wayResetVehiclePosition,wayNumberEntries};

	const double n_dAltitudeDefault_ft = 1000.0;
	
	const double n_dSensorStandOffSearch_ft = 0.0;		//
	const double n_dSensorStandOffDefault_ft = 1.3*3280.839895;		//1.3*1000 meters
	const double n_dSensorStandOffClassify_ft = 1.3*3280.839895;		//1.3*1000 meters
	const double n_dSensorStandOffAttack_ft = 0.0;		//
	const double n_dSensorStandOffVerify_ft = 1.2*3280.839895;		//1000 meters

	const double n_dFreeToTurnSearch_ft = 0.0;
	const double n_dFreeToTurnDefault_ft = 0.0;
	const double n_dFreeToTurnClassify_ft = 0.80*2460.629921;	//(reduced by 20% to make sure target changes state before vehicle reaches waypoint.750 meters (footprint is 750-1000 meters in front of vehicle) 
	const double n_dFreeToTurnAttack_ft = 0.0;
	const double n_dFreeToTurnVerify_ft = 0.80*2460.629921;	//750 meters (footprint is 750-1000 meters in front of vehicle)

	const double n_dTurnRadiusDefault_ft = 1700.0;
	const double n_dMachDefault = 0.35;
//	const double n_dMachDefault = 0.65;

}
using namespace QXRT135;


#endif	//#ifndef TRAJECTORYDEFINITIONS_H
