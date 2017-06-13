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
// Waypoint.h: interface for the CWaypoint class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_WAYPOINT_H__DA06D20C_1954_42EA_869B_FA06DF023D54__INCLUDED_)
#define AFX_WAYPOINT_H__DA06D20C_1954_42EA_869B_FA06DF023D54__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "TrajectoryDefinitions.h"
#include "Position.h"
#include "Circle.h"
class CWaypoint;

#include <vector>
namespace
{
	typedef std::vector<CWaypoint> V_WAYPOINT_t;
	typedef V_WAYPOINT_t::iterator V_WAYPOINT_IT_t;
	typedef V_WAYPOINT_t::const_iterator V_WAYPOINT_CONST_IT_t;
}

class CWaypoint : public CPosition
{
public:
	CWaypoint(double dPositionX_ft=0,double dPositionY_ft=0,double dPositionZ_ft=n_dAltitudeDefault_ft,
					double dMachCommand=n_dMachDefault,BOOL bMachCommandFlag=TRUE,
					double dSegmentLength_ft=0,
					double dTurnCenterX_ft=DBL_MAX,double dTurnCenterY_ft=DBL_MAX,
					double dTurnRadius_ft=DBL_MAX,enTurnDirection_t turnDirection=turnNone,
					n_enWaypointType_t typeWaypoint=waytypeEnroute,
					int iTargetHandle=-1,BOOL bResetVehiclePosition=FALSE) 
					:	CPosition(dPositionX_ft,dPositionY_ft,dPositionZ_ft), 
						m_circleTurn(dTurnCenterX_ft,dTurnCenterY_ft,dTurnRadius_ft,turnDirection)
	{
		m_dMachCommand = dMachCommand;
		m_bMachCommandFlag = bMachCommandFlag;
		m_dSegmentLength_ft = dSegmentLength_ft;
		m_typeWaypoint = typeWaypoint;
		m_iTargetHandle = iTargetHandle;
		m_bResetVehiclePosition = bResetVehiclePosition;
	};
	CWaypoint(CPosition& posPosition,
					double dMachCommand=n_dMachDefault,BOOL bMachCommandFlag=TRUE,
					double dSegmentLength_ft=0,
					double dTurnCenterX_ft=DBL_MAX,double dTurnCenterY_ft=DBL_MAX,
					double dTurnRadius_ft=DBL_MAX,enTurnDirection_t turnDirection=turnNone,
					n_enWaypointType_t typeWaypoint=waytypeEnroute,
					int iTargetHandle=-1,BOOL bResetVehiclePosition=FALSE) 
					:	CPosition(posPosition), 
						m_circleTurn(dTurnCenterX_ft,dTurnCenterY_ft,dTurnRadius_ft,turnDirection)
	{
		m_dMachCommand = dMachCommand;
		m_bMachCommandFlag = bMachCommandFlag;
		m_dSegmentLength_ft = dSegmentLength_ft;
		m_typeWaypoint = typeWaypoint;
		m_iTargetHandle = iTargetHandle;
		m_bResetVehiclePosition = bResetVehiclePosition;
	};

	virtual ~CWaypoint(){};

	// copy constructer
	CWaypoint(const CWaypoint& rhs)
		 : CPosition(rhs)
	{
		m_dMachCommand = rhs.m_dMachCommand;
		m_bMachCommandFlag = rhs.m_bMachCommandFlag;
		m_dSegmentLength_ft = rhs.m_dSegmentLength_ft;
		m_typeWaypoint = rhs.m_typeWaypoint;
		m_iTargetHandle = rhs.m_iTargetHandle;
		m_bResetVehiclePosition = rhs.m_bResetVehiclePosition;
		m_circleTurn = rhs.circleGetTurn();
	};


public:
	CCircle& circleGetTurn(){return(m_circleTurn);};
	const CCircle& circleGetTurn() const {return(m_circleTurn);};

	const double dGetMachCommand() const {return(m_dMachCommand);};
	void SetMachCommand(double dMachCommand){m_dMachCommand=dMachCommand;};

	const BOOL bGetMachCommandFlag() const {return(m_bMachCommandFlag);};
	void SetMachCommandFlag(BOOL bMachCommandFlag){m_bMachCommandFlag=bMachCommandFlag;};

	const double dGetSegmentLength() const {return(m_dSegmentLength_ft);};
	void SetSegmentLength(double dSegmentLength){m_dSegmentLength_ft=dSegmentLength;};

	const n_enWaypointType_t typeGetWaypoint() const {return(m_typeWaypoint);};
	void SetTypeWaypoint(n_enWaypointType_t typeWaypoint){m_typeWaypoint=typeWaypoint;};

	const int iGetTargetHandle() const {return(m_iTargetHandle);};
	void SetTargetHandle(int iTargetHandle){m_iTargetHandle=iTargetHandle;};

	const BOOL bGetResetVehiclePosition() const {return(m_bResetVehiclePosition);};
	void SetResetVehiclePosition(BOOL bResetVehiclePosition){m_bResetVehiclePosition=bResetVehiclePosition;};

protected:
	// position is inherited

	double m_dMachCommand;
	BOOL m_bMachCommandFlag;
	double m_dSegmentLength_ft;
	n_enWaypointType_t m_typeWaypoint;
	int m_iTargetHandle;
	BOOL m_bResetVehiclePosition;
	CCircle m_circleTurn;
};

#endif // !defined(AFX_WAYPOINT_H__DA06D20C_1954_42EA_869B_FA06DF023D54__INCLUDED_)
