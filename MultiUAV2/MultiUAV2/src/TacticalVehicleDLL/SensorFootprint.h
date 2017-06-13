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
// SensorFootprint.h: interface for the CSensorFootprint class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_SENSORFOOTPRINT_H__65891C67_6BEF_48C0_B923_48CA6CF3105D__INCLUDED_)
#define AFX_SENSORFOOTPRINT_H__65891C67_6BEF_48C0_B923_48CA6CF3105D__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <vector>
#include <sstream>
using namespace std;

#include "GlobalDefines.h"

#include "TargetStatus.h"


class CSensorFootprint  
{
public:		// constructor/destructors 
	CSensorFootprint();
	virtual ~CSensorFootprint();

public:		// typdefs and enumerations
	enum enSensorType
	{
		stRoundSensor,
		stRectangularSensor,
		stTotal
	};

	typedef vector<CTargetStatus> V_TARGETS_t;
	typedef V_TARGETS_t::iterator V_TARGETS_IT_t;

public:		// public member functions
	void SetTargetPostion(int iIndex,double dPositonX,double dPositonY);
	void Sensor(const double dElapsedTime,const int iVehicleID,
					const double dVehiclePositionNorth_ft,const double dVehiclePositionEast_ft,
					const double dVehiclePsi_rad,const double dVehiclePhi_rad
					,stringstream& sstrMessage,const enSensorType sensorType=stRectangularSensor);

protected:		// protected member functions

public:		// accessors
	void ResetStatus();
	V_TARGETS_t& vGetTargets() {return(*m_pvTargets);};
	const V_TARGETS_t& vGetTargets() const {return(*m_pvTargets);};

	V_TARGETS_IT_t itGetTargetsBegin() {return(vGetTargets().begin());};
	V_TARGETS_IT_t itGetTargetsEnd() {return(vGetTargets().end());};

	double& dGetTargetSensorOffsetX(){return(m_dTargetSensorOffsetX_ft);};
	const double& dGetTargetSensorOffsetX() const {return(m_dTargetSensorOffsetX_ft);};

	double& dGetTargetSensorOffsetY(){return(m_dTargetSensorOffsetX_ft);};
	const double& dGetTargetSensorOffsetY() const {return(m_dTargetSensorOffsetX_ft);};

	double& dGetTargetSensorTolerance(){return(m_dTargetSensorTolerance_rad);};
	const double& dGetTargetSensorTolerance() const {return(m_dTargetSensorTolerance_rad);};

	BOOL& bGetSensorOn() {return(m_bSensorOn);};
	const BOOL& bGetSensorOn() const {return(m_bSensorOn);};

protected:		// member variables
	V_TARGETS_t* m_pvTargets;

	double m_dTargetSensorOffsetX_ft;
	double m_dTargetSensorOffsetY_ft;
	double m_dTargetSensorTolerance_rad;
	BOOL m_bSensorOn;
};

#endif // !defined(AFX_SENSORFOOTPRINT_H__65891C67_6BEF_48C0_B923_48CA6CF3105D__INCLUDED_)
