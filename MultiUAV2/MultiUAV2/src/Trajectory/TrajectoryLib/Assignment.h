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
// Assignment.h: interface for the CAssignment class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ASSIGNMENT_H__CA36AC9A_0A3D_4110_9E0F_7BA1B4C76258__INCLUDED_)
#define AFX_ASSIGNMENT_H__CA36AC9A_0A3D_4110_9E0F_7BA1B4C76258__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "TrajectoryDefinitions.h"
#include "Waypoint.h"

class CAssignment
{
public:
	CAssignment(double dDistancePrevious=0.0)
	{
		m_wayPoints.clear();
		m_iNumberAssignments = 0;
		m_dHeadingFinal_rad = 0.0;
		dGetDistancePrevious() = dDistancePrevious;
	};

	CAssignment(double dPositionX_ft,double dPositionY_ft,double dPositionZ_ft,double dHeadingFinal,double dDistancePrevious=0.0)
	{
		m_wayPoints.clear();
		m_wayPoints.push_back(CWaypoint(dPositionX_ft,dPositionY_ft,dPositionZ_ft));
		m_iNumberAssignments = 0;
		m_dHeadingFinal_rad = dHeadingFinal;
		dGetDistancePrevious() = dDistancePrevious;
	};

	virtual ~CAssignment(){};

	// copy constructer
	CAssignment(const CAssignment& rhs)
	{
		m_wayPoints = rhs.m_wayPoints;
		m_iNumberAssignments = rhs.m_iNumberAssignments;
		m_dHeadingFinal_rad = rhs.m_dHeadingFinal_rad;
		dGetDistancePrevious() = rhs.dGetDistancePrevious();
	};

	void operator=(const CAssignment& rhs)
	{
		m_wayPoints = rhs.m_wayPoints;
		m_iNumberAssignments = rhs.m_iNumberAssignments;
		m_dHeadingFinal_rad = rhs.m_dHeadingFinal_rad;
		dGetDistancePrevious() = rhs.dGetDistancePrevious();
	};

public:
	void Reset(){m_wayPoints.clear();m_iNumberAssignments = 0;};

	const double dGetDistanceTotal() const 
	{
		double dTotalDistance_ft = 0.0;
		if(m_wayPoints.size() > 0)
		{
			for(V_WAYPOINT_CONST_IT_t itWaypoint=m_wayPoints.begin();itWaypoint!=m_wayPoints.end();itWaypoint++)
			{
				dTotalDistance_ft += itWaypoint->dGetSegmentLength();
			}
		}
		return(dTotalDistance_ft+dGetDistancePrevious());
	};

	const int& iGetNumberAssignments() const {return(m_iNumberAssignments);};
	void SetNumberAssignments(int iNumberAssignments){m_iNumberAssignments=iNumberAssignments;};

	V_WAYPOINT_t& vwayGetWaypoints(){return(m_wayPoints);};
	const V_WAYPOINT_t& vwayGetWaypoints()const {return(m_wayPoints);};

	int iGetNumberWaypoints(){return(m_wayPoints.size());};

	const CWaypoint& wayGetWaypoint(int iIndex) const {return(vwayGetWaypoints()[iIndex]);};
	CWaypoint& wayGetWaypoint(int iIndex) {return(vwayGetWaypoints()[iIndex]);};

	V_WAYPOINT_CONST_IT_t itGetWaypointFirst() const {return(vwayGetWaypoints().begin());};
	V_WAYPOINT_IT_t itGetWaypointFirst() {return(vwayGetWaypoints().begin());};

	V_WAYPOINT_CONST_IT_t itGetWaypointEnd() const {return(vwayGetWaypoints().end());};
	V_WAYPOINT_IT_t itGetWaypointEnd() {return(vwayGetWaypoints().end());};

	const CWaypoint& wayGetWaypointLast() const {return(vwayGetWaypoints().back());};
	CWaypoint& wayGetWaypointLast() {return(vwayGetWaypoints().back());};

	V_WAYPOINT_IT_t itGetWaypoint(int iIndex) {return( V_WAYPOINT_IT_t( &vwayGetWaypoints()[iIndex]) ); };

	void operator +=(const CAssignment& rhs)
	{
		m_wayPoints.insert(itGetWaypointEnd(),rhs.itGetWaypointFirst(),rhs.itGetWaypointEnd());
		SetNumberAssignments(rhs.iGetNumberAssignments());
		SetHeadingFinal(rhs.dGetHeadingFinal());
	}

	const double dGetHeadingFinal() const {return(m_dHeadingFinal_rad);};
	void SetHeadingFinal(double dHeadingFinal_rad){m_dHeadingFinal_rad=dHeadingFinal_rad;};

	const CPosition& posGetPositionAssignedLast() const {return(wayGetWaypointLast().posGetPosition());};
	CPosition& posGetPositionAssignedLast() {return(wayGetWaypointLast().posGetPosition());};

	const double& dGetDistancePrevious() const {return(m_dDistanceTotalPrevious_ft);};
	double& dGetDistancePrevious() {return(m_dDistanceTotalPrevious_ft);};

	void EraseWaypoints(int iIndex1,int iIndex2)
	{
		vwayGetWaypoints().erase(itGetWaypoint(iIndex1),itGetWaypoint(iIndex2));
	};
	void EraseWaypoints(int iIndex)
	{
		vwayGetWaypoints().erase(itGetWaypoint(iIndex),itGetWaypointEnd());
	};

protected:
	V_WAYPOINT_t m_wayPoints;
	int m_iNumberAssignments;
	double m_dHeadingFinal_rad;
	double m_dDistanceTotalPrevious_ft;
};

#endif // !defined(AFX_ASSIGNMENT_H__CA36AC9A_0A3D_4110_9E0F_7BA1B4C76258__INCLUDED_)
