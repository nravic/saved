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
// WaypointGuidance.h: interface for the CWaypointGuidance class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_WAYPOINTGUIDANCE_H__1C112C49_3DAD_4E1C_9DF2_AE9AA8548928__INCLUDED_)
#define AFX_WAYPOINTGUIDANCE_H__1C112C49_3DAD_4E1C_9DF2_AE9AA8548928__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <vector>
#include <sstream>
using namespace std;

#include "GlobalDefines.h"

#include "Waypoint.h"

class CWaypointGuidance  
{
public:		// constructor/destructors 
	CWaypointGuidance();
	virtual ~CWaypointGuidance();

public:		// typdefs and enumerations
	typedef vector<CWaypoint> V_WAYPOINT_t;
	typedef V_WAYPOINT_t::iterator V_WAYPOINT_IT_t;

public:		// public member functions
	void WaypointGuidance(const double& dElapsedTime,const int& iVehicleID,const double& dTimeIncrement_sec,
							const double& dVehiclePositionNorth_ft,const double& dVehiclePositionEast_ft,
							const double& dVehicleHeading_rad,
							double& dCommandHeading_rad,double& dCommandAltitude_ft,double& dCommandVelocity_ftpersec,
							stringstream& sstrMessage);
	void GetCurrentAssignment(int& iAssignedTarget,int& iAssignedTask);
	void UpdateWaypointTypeAndTargetHandle();

	void NewWaypointsReset(int iStartingIndex=0)
	{
		iGetWaypointTypeLast() = -1;
		iGetWaypointTypeCurrent() = -1;
		iGetWaypointTargetHandleCurrent() = -1;
		iGetWaypointTargetHandleLast() = -1;
		if(iStartingIndex>=0)
		{
			szGetWaypointIndex() = iStartingIndex;
		}
		vGetWaypoints().clear();
	}

protected:		// protected member functions
public:		// accessors
	size_t& szGetWaypointIndex() {return(m_szWaypointIndex);};
	const size_t& szGetWaypointIndex() const {return(m_szWaypointIndex);};

	V_WAYPOINT_t& vGetWaypoints() {return(*m_pvwayWaypoints);};
	const V_WAYPOINT_t& vGetWaypoints() const {return(*m_pvwayWaypoints);};

	V_WAYPOINT_IT_t itGetWaypointsBegin() {return(vGetWaypoints().begin());};
	V_WAYPOINT_IT_t itGetWaypointsEnd() {return(vGetWaypoints().end());};
	V_WAYPOINT_IT_t itGetCurrentWaypoint(size_t szIndexOffset=0)
	{return( itGetWaypointsBegin()+szGetWaypointIndex()+szIndexOffset);};

	CWaypoint& wayGetCurrentWaypoint(size_t szIndexOffset=0){return(vGetWaypoints()[szGetWaypointIndex()+szIndexOffset]);};
	const CWaypoint& wayGetCurrentWaypoint(size_t szIndexOffset=0) const {return(vGetWaypoints()[szGetWaypointIndex()+szIndexOffset]);};

	double& dGetRabbitN(){return(m_dRabbitN_ft);};
	const double& dGetRabbitN() const {return(m_dRabbitN_ft);};

	double& dGetRabbitE(){return(m_dRabbitE_ft);};
	const double& dGetRabbitE() const {return(m_dRabbitE_ft);};

	double& dGetRabbitPsi(){return(m_dRabbitPsi_rad);};
	const double& dGetRabbitPsi() const {return(m_dRabbitPsi_rad);};

	double& dGetTotalSearchTime(){return(m_dTotalSearchTime_sec);};
	const double& dGetTotalSearchTime() const {return(m_dTotalSearchTime_sec);};

	int& iGetWaypointTypeCurrent() {return(m_iWaypointTypeCurrent);};
	const int& iGetWaypointTypeCurrent() const {return(m_iWaypointTypeCurrent);};

	int& iGetWaypointTypeLast() {return(m_iWaypointTypeLast);};
	const int& iGetWaypointTypeLast() const {return(m_iWaypointTypeLast);};

	int& iGetWaypointTargetHandleCurrent() {return(m_iWaypointTargetCurrent);};
	const int& iGetWaypointTargetHandleCurrent() const {return(m_iWaypointTargetCurrent);};

	int& iGetWaypointTargetHandleLast() {return(m_iWaypointTargetLast);};
	const int& iGetWaypointTargetHandleLast() const {return(m_iWaypointTargetLast);};

	double& dGetCommandHeading(){return(m_dCommandHeading_rad);};
	const double& dGetCommandHeading() const {return(m_dCommandHeading_rad);};

	double& dGetCommandAltitude(){return(m_dCommandAltitude_ft);};
	const double& dGetCommandAltitude() const {return(m_dCommandAltitude_ft);};

	double& dGetCommandVelocity(){return(m_dCommandVelocity_ftpersec);};
	const double& dGetCommandVelocity() const {return(m_dCommandVelocity_ftpersec);};

protected:		// member variables
	V_WAYPOINT_t* m_pvwayWaypoints;
	size_t m_szWaypointIndex;
	double m_dRabbitN_ft;
	double m_dRabbitE_ft;
	double m_dRabbitPsi_rad;

	double m_dTotalSearchTime_sec;
	int m_iWaypointTypeCurrent;
	int m_iWaypointTypeLast;
	int m_iWaypointTargetCurrent;
	int m_iWaypointTargetLast;

	// the following are for debugging
	double m_dCommandHeading_rad;
	double m_dCommandAltitude_ft;
	double m_dCommandVelocity_ftpersec;
};

#endif // !defined(AFX_WAYPOINTGUIDANCE_H__1C112C49_3DAD_4E1C_9DF2_AE9AA8548928__INCLUDED_)
