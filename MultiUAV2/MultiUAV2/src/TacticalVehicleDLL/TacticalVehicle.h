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
// TacticalVehicle.h: interface for the CTacticalVehicle class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_TACTICALVEHICLE_H__1214ECA0_54CD_4418_A55B_8E82D1B08E5C__INCLUDED_)
#define AFX_TACTICALVEHICLE_H__1214ECA0_54CD_4418_A55B_8E82D1B08E5C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "GlobalDefines.h"
#include <vector>
using namespace std;

#include "VehicleSimulation.h"
#include "WaypointGuidance.h"
#include "SensorFootprint.h"

		
class CTacticalVehicle  
{
public:
	enum enCommandTypes
	{
		cmdWaypoints,
		cmdVelocityHeadingAltitude,
		cmdTotal
	};
	enum enCommandsVelocityHeadingAltitude
	{
		cmdvahVelocity_fps,
		cmdvahHeading_rad,
		cmdvahAltitude_ft,
		cmdvahTotal,
	};

public:
	CTacticalVehicle( const BOOL& isSubtractBaseTables, const char* params_file, 
										const char* datcom_file,stringstream& sstrErrorMessage);
	virtual ~CTacticalVehicle();

public:

//	typedef class CVehicleSimulation<VAL_DOUBLE_t,V_PDOUBLE_t,V_DOUBLE_t,double> CVEHICLESIMULATION_t;
	typedef CDynamic<V_PDOUBLE_t,V_DOUBLE_t,double> CDYNAMIC_t;
	typedef CVehicleSimulation<VAL_DOUBLE_t,V_PDOUBLE_t,V_DOUBLE_t,double> CVEHICLESIMULATION_t;
	typedef CVehicleDynamics<VAL_DOUBLE_t,V_PDOUBLE_t,V_DOUBLE_t,double> CVEHICLEDYNAMICS_t;
	typedef CEngine1stOrder<VAL_DOUBLE_t,V_PDOUBLE_t,V_DOUBLE_t,double> CENGINE1STORDER_t;
	typedef CDynamicInversion<VAL_DOUBLE_t,V_PDOUBLE_t,V_DOUBLE_t,double> CDYNAMIC_INVERSION_t;
protected:		// protected functions


public:
	void InitializeDynamics(VAL_DOUBLE_t& valdInitialState,stringstream& sstrErrorMessage);
	void UpdateDynamics(double dElapsedTimeSec,stringstream& sstrMessage);
	void ConvertMachToFPS(const double& dMach,const double& dAltitude,double& dVelocityFPS);

	size_t szGetNumberStates(){return(vehGetVehicle().iGetNumberStates());};

public:		//accessors
	double dGetVehicleOutput(CVEHICLEDYNAMICS_t::enOutputs enOutput){return(vehGetVehicle().vGetVehicleOutput(enOutput));};
	double dGetVehicleState(CVEHICLEDYNAMICS_t::StatesNames_t vehicleState){return(vehGetVehicle().vGetVehicleState(vehicleState));};
	size_t szGetVehicleStateIndex(CVEHICLEDYNAMICS_t::StatesNames_t vehicleState){return(vehGetVehicle().vGetVehicleStateIndex(vehicleState));};
	double dGetEngineState(CENGINE1STORDER_t::StatesNames_t enState){return(vehGetVehicle().vGetEngineState(enState));};

	VAL_DOUBLE_t& valdGetState(){return(vehGetVehicle().vsGetX());};
	const VAL_DOUBLE_t& valdGetState(size_t szIndex) const{return(vehGetVehicle().vsGetX());};

	CVEHICLESIMULATION_t& vehGetVehicle() {return(*m_pVehicleSimulation);};
	const CVEHICLESIMULATION_t& vehGetVehicle() const {return(*m_pVehicleSimulation);};

	V_DOUBLE_t& vdGetInputsVehicle() {return(m_vdInputsVehicle);};
	const V_DOUBLE_t& vdGetInputsVehicle() const {return(m_vdInputsVehicle);};

	V_DOUBLE_t& vdGetOutputsVehicle() {return(m_vdOutputsVehicle);};
	const V_DOUBLE_t& vdGetOutputsVehicle() const {return(m_vdOutputsVehicle);};

	double& dGetElapsedTimeLast() {return(m_dElapsedTimeLast_sec);};
	const double& dGetElapsedTimeLast() const {return(m_dElapsedTimeLast_sec);};

	double& dGetLeftoverTime() {return(m_dLeftoverTime_sec);};
	const double& dGetLeftoverTime() const {return(m_dLeftoverTime_sec);};

	int& iGetVehicleID() {return(m_iVehicleID);};
	const int& iGetVehicleID() const {return(m_iVehicleID);};

	CSensorFootprint& sensorGetFootprint(){return(*m_psensorFootprint);};
	const CSensorFootprint& sensorGetFootprint() const {return(*m_psensorFootprint);};

	CWaypointGuidance& waypointGetGuidance(){return(*m_pwaypointGuidance);};
	const CWaypointGuidance& waypointGetGuidance() const {return(*m_pwaypointGuidance);};

	enCommandTypes& cmdGetType(){return(m_cmdType);};
	const enCommandTypes& cmdGetType() const {return(m_cmdType);};

	V_DOUBLE_t& vdGetCommands() {return(m_vdCommands);};
	const V_DOUBLE_t& vdGetCommands() const {return(m_vdCommands);};

protected:
	//vehicle dynamics
	CVEHICLESIMULATION_t* m_pVehicleSimulation;
	V_DOUBLE_t m_vdInputsVehicle;	//TODO the vehicle model also has storage for inputs and outputs!!
	V_DOUBLE_t m_vdOutputsVehicle;

	double m_dElapsedTimeLast_sec;
	double m_dLeftoverTime_sec;
	int m_iVehicleID;

	//sensor footprint
	CSensorFootprint* m_psensorFootprint;

	//waypoint guidance
	CWaypointGuidance* m_pwaypointGuidance;

	enCommandTypes m_cmdType;

	V_DOUBLE_t m_vdCommands;
};

#endif // !defined(AFX_TACTICALVEHICLE_H__1214ECA0_54CD_4418_A55B_8E82D1B08E5C__INCLUDED_)
