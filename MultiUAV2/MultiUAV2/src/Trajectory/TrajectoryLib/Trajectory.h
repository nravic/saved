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
// Trajectory.h: interface for the CTrajectory class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_TRAJECTORY_H__CEA000CF_335F_408A_93A7_F7E16DF6EDFE__INCLUDED_)
#define AFX_TRAJECTORY_H__CEA000CF_335F_408A_93A7_F7E16DF6EDFE__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "TrajectoryDefinitions.h"
#include "Position.h"
#include "Vehicle.h"
#include "Target.h"
#include "Circle.h"
#include "Assignment.h"

namespace QXRT135
{
	const int n_iMaxDistanceIterations = 10;
	const double n_dDistanceTolerance_frac = 0.001;
	const double n_dDistanceInitalGuess_frac = 0.1;
	const double n_dAngleLoiterIncrement_rad = _PI_O_2;
	enum enPathType_t {pathEuclidean,pathTurnStraightTurn,pathNumber};
}
using namespace QXRT135;

class CTrajectory  
{
public:
	CTrajectory();
	virtual ~CTrajectory();

public:	//enumerations
	enum enError
	{
		errorNone,
		errorWrongDirectionsForTangent,
		errorTotal
	};
public:
	double dMinimumDistance(CVehicle& rVehicle,CTarget& rTarget,BOOL bLengthenPath=FALSE,enPathType_t pathType=pathTurnStraightTurn,BOOL bGenerateWaypoints=TRUE);
protected:
	double dMinimumDistanceEuclidean(CVehicle& rVehicle,CTarget& rTarget,BOOL bGenerateWaypoints,BOOL bLengthenPath);
	double dMinimumDistanceTurnStraightTurn(CVehicle& rVehicle,CTarget& rTarget,BOOL bGenerateWaypoints,BOOL bLengthenPath);
	size_t szMinimumDistanceCircle(CPosition posBegin,CPosition posEnd,
										CCircle& circleFirst,CCircle& circleSecond,CAssignment& rassignAssignment);
	size_t szMinimumDistanceTurnTurnTurn(CPosition posBegin,CPosition posEnd,
										CCircle& circleFirst,CCircle& circleSecond,CAssignment& rassignAssignment);
	void CalculateTaskHeading(CVehicle& rVehicle,CTarget& rTarget,V_CIRCLE_t& rvcircleVehicle);
	double dLengthenPath(CVehicle& rVehicle,CTarget& rTarget,double dDesiredDistance,CAssignment& assignMinimum);
};


#endif // !defined(AFX_TRAJECTORY_H__CEA000CF_335F_408A_93A7_F7E16DF6EDFE__INCLUDED_)
