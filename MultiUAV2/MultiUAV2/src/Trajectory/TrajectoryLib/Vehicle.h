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
// Vehicle.h: interface for the CVehicle class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VEHICLE_H__301D6590_12D0_4F65_8B3F_89B507DCC41F__INCLUDED_)
#define AFX_VEHICLE_H__301D6590_12D0_4F65_8B3F_89B507DCC41F__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <vector>
using namespace std;

#include "TrajectoryDefinitions.h"
#include "BaseObject.h"
#include "Assignment.h"

class CVehicle;


namespace QXRT135
{
	enum n_enVehicleType_t {envehicleUnknown,envehicleMunition,envehicleUAV,envehicleNumberEntries};

	typedef std::vector<CVehicle> V_VEHICLE_t;
	typedef V_VEHICLE_t::iterator V_VEHICLE_IT_t;
	typedef V_VEHICLE_t::const_iterator V_VEHICLE_CONST_IT_t;
}
using namespace QXRT135;

class CVehicle  : public CBaseObject, public CAssignment
{
public:
	CVehicle(int iID,double dPositionX_ft,double dPositionY_ft,double dPositionZ_ft,double dPsi_rad,
							double dCommandSensorStandOff_ft=n_dSensorStandOffDefault_ft,
							double dCommandTurnRadius_ft=n_dTurnRadiusDefault_ft,
							n_enVehicleType_t vehicleType=envehicleMunition,double dDistanceTotalDefault=0.0):
		CAssignment(dPositionX_ft,dPositionY_ft,dPositionZ_ft,dPsi_rad,dDistanceTotalDefault)
	{
		SetID(iID);
		SetHeading(dPsi_rad);
		SetPosition(CPosition(dPositionX_ft,dPositionY_ft,dPositionZ_ft));
		SetCommandSensorStandOff(dCommandSensorStandOff_ft);
		SetCommandTurnRadius(dCommandTurnRadius_ft);
		vehicleGetType() = vehicleType;
	};

	virtual ~CVehicle(){};

	// copy constructer
	CVehicle(const CVehicle& rhs)
		:	CBaseObject(rhs), CAssignment(rhs)
	{
		SetCommandSensorStandOff(rhs.dGetCommandSensorStandOff());
		SetCommandTurnRadius(rhs.dGetCommandTurnRadius());
		vehicleGetType() = rhs.vehicleGetType();
	};
	// operator =
	void operator=(const CVehicle& rhs)
	{
		CBaseObject::operator =(rhs);
		CAssignment::operator =(rhs);
		SetCommandSensorStandOff(rhs.dGetCommandSensorStandOff());
		SetCommandTurnRadius(rhs.dGetCommandTurnRadius());
		vehicleGetType() = rhs.vehicleGetType();
	};


public:
	double dGetTimeCurrent(){return(dGetDistanceTotal());};

	const double& dGetCommandSensorStandOff() const {return(m_dCommandSensorStandOff_ft);};
	void SetCommandSensorStandOff(const double dCommandSensorStandOff_ft){m_dCommandSensorStandOff_ft=dCommandSensorStandOff_ft;};

	const double& dGetCommandTurnRadius() const {return(m_dCommandTurnRadius_ft);};
	void SetCommandTurnRadius(const double dCommandTurnRadius_ft){m_dCommandTurnRadius_ft=dCommandTurnRadius_ft;};

	void operator +=(const CAssignment& rhs){CAssignment::operator +=(rhs);}
	
	const n_enVehicleType_t& vehicleGetType() const {return(m_vehicleType);};
	n_enVehicleType_t& vehicleGetType() {return(m_vehicleType);};

protected:
	double m_dCommandSensorStandOff_ft;
	double m_dCommandTurnRadius_ft;
	n_enVehicleType_t m_vehicleType;
};



#endif // !defined(AFX_VEHICLE_H__301D6590_12D0_4F65_8B3F_89B507DCC41F__INCLUDED_)
