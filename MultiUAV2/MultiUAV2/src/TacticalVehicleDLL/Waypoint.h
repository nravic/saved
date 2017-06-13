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

#if !defined(AFX_WAYPOINT_H__CE91A42E_2AFF_46F1_9D41_15AD11E2A6D6__INCLUDED_)
#define AFX_WAYPOINT_H__CE91A42E_2AFF_46F1_9D41_15AD11E2A6D6__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class CWaypoint  
{
public:
	CWaypoint()
	{
		dGetPositionNorth() = 0.0;
		dGetPositionEast() = 0.0;
		dGetPositionDown() = 0.0;
		dGetTurnCenterNorth() = 0.0;
		dGetTurnCenterEast() = 0.0;
		dGetSegmentLength() = 0.0;
		dGetVelocity() = 0.0;
		iGetTurnDirection() = 0;
		iGetType() = 0;
		iGetTargetHandle() = -1;
	};
	virtual ~CWaypoint(){};

	CWaypoint(const CWaypoint& rhs)
	{
		dGetPositionNorth() = rhs.dGetPositionNorth();
		dGetPositionEast() = rhs.dGetPositionEast();
		dGetPositionDown() = rhs.dGetPositionDown();
		dGetTurnCenterNorth() = rhs.dGetTurnCenterNorth();
		dGetTurnCenterEast() = rhs.dGetTurnCenterEast();
		dGetSegmentLength() = rhs.dGetSegmentLength();
		dGetVelocity() = rhs.dGetVelocity();
		iGetTurnDirection() = rhs.iGetTurnDirection();
		iGetType() = rhs.iGetType();
		iGetTargetHandle() = rhs.iGetTargetHandle();
	};

	void operator=(const CWaypoint& rhs)
	{
		dGetPositionNorth() = rhs.dGetPositionNorth();
		dGetPositionEast() = rhs.dGetPositionEast();
		dGetPositionDown() = rhs.dGetPositionDown();
		dGetTurnCenterNorth() = rhs.dGetTurnCenterNorth();
		dGetTurnCenterEast() = rhs.dGetTurnCenterEast();
		dGetSegmentLength() = rhs.dGetSegmentLength();
		dGetVelocity() = rhs.dGetVelocity();
		iGetTurnDirection() = rhs.iGetTurnDirection();
		iGetType() = rhs.iGetType();
		iGetTargetHandle() = rhs.iGetTargetHandle();
	};

public:
	double& dGetPositionNorth(){return(m_dPositionNorth_ft);};
	const double& dGetPositionNorth() const {return(m_dPositionNorth_ft);};

	double& dGetPositionEast(){return(m_dPositionEast_ft);};
	const double& dGetPositionEast() const {return(m_dPositionEast_ft);};

	double& dGetPositionDown(){return(m_dPositionDown_ft);};
	const double& dGetPositionDown() const {return(m_dPositionDown_ft);};

	double& dGetTurnCenterNorth(){return(m_dTurnCenterNorth_ft);};
	const double& dGetTurnCenterNorth() const {return(m_dTurnCenterNorth_ft);};

	double& dGetTurnCenterEast(){return(m_dTurnCenterEast_ft);};
	const double& dGetTurnCenterEast() const {return(m_dTurnCenterEast_ft);};

	double& dGetSegmentLength(){return(m_SegmentLength_ft);};
	const double& dGetSegmentLength() const {return(m_SegmentLength_ft);};

	double& dGetVelocity(){return(m_dVelocity_ftpersec);};
	const double& dGetVelocity() const {return(m_dVelocity_ftpersec);};

	int& iGetTurnDirection(){return(m_iTurnDirection);};
	const int& iGetTurnDirection() const {return(m_iTurnDirection);};

	int& iGetType(){return(m_iType);};
	const int& iGetType() const {return(m_iType);};

	int& iGetTargetHandle(){return(m_iTargetHandle);};
	const int& iGetTargetHandle() const {return(m_iTargetHandle);};

protected:
	double m_dPositionNorth_ft;  // 3D location
	double m_dPositionEast_ft;
	double m_dPositionDown_ft;
	double m_dVelocity_ftpersec;          // commanded speed
	double m_dTurnCenterNorth_ft;	// 2D location of center of turning circle
	double m_dTurnCenterEast_ft;
	double m_SegmentLength_ft;	//length of segemnet from last waypoint to this waypoint TODO::CHECK THIS - RAS
	int m_iTurnDirection;		// Direction of turn: 1=ccw, -1=cw, 0=straight line
	int m_iType;					// type of way point i.e Enroute, Attack, Verify,.....
	int m_iTargetHandle;		// handle of target at this waypoint, -1 is for no target
};

#endif // !defined(AFX_WAYPOINT_H__CE91A42E_2AFF_46F1_9D41_15AD11E2A6D6__INCLUDED_)
