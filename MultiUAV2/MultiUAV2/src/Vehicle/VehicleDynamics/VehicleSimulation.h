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
// VehicleSimulation.h: interface for the CVehicleSimulation class.
//
//////////////////////////////////////////////////////////////////////
//this is the top level vehicle class
#if !defined(AFX_VEHICLESIMULATION_H__A7C7DF60_C905_4A63_8E51_582DC42E0E42__INCLUDED_)
#define AFX_VEHICLESIMULATION_H__A7C7DF60_C905_4A63_8E51_582DC42E0E42__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Dynamic.h"
#include "RungeKutta4.h"
#include "VehicleDynamics.h"
#include "DynamicInversion.h"
#include "Actuator1stOrder.h"
#include "PIDController.h"
#include "CmdAltitudePsiBetaV.h"
#include "Engine1stOrder.h"

#include <vector>
#include <sstream>
using namespace std;

namespace
{
	// the following are parameters for the rate control in all three channels
//	static const double dLimitUpperAlpha_rad = 45.0*_PI/180.0;
//	static const double dLimitLowerAlpha_rad = -45.0*_PI/180.0;
	static const double dLimitUpperAlpha_rad = 25.0*_PI/180.0;
	static const double dLimitLowerAlpha_rad = -25.0*_PI/180.0;
	static const double dLimitUpperBeta_rad = 20.0*_PI/180.0;
	static const double dLimitLowerBeta_rad = -20.0*_PI/180.0;
}



template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
class CSimulationState
{
public:
	CSimulationState(int iNumberDynamic=0)
	{
		m_pvcDynamic = new V_PDYNAMIC_t();
		m_pvsAggregatedX = new STATE_t();

		vcGetDynamic().resize(iNumberDynamic);
	};
	virtual ~CSimulationState()
	{
		delete m_pvcDynamic;
		m_pvcDynamic = 0;
		delete m_pvsAggregatedX;
		m_pvsAggregatedX = 0;
	};

	CSimulationState(CSimulationState& rhs)
	{
		vcGetDynamic() = rhs.vcGetDynamic();
	};
public:
	typedef CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> DYNAMIC_t;
	typedef vector<DYNAMIC_t*> V_PDYNAMIC_t;
	typedef typename V_PDYNAMIC_t::iterator V_PDYNAMIC_IT_t;

public:
	virtual void CalculateXDot(VARIABLE_t* avState, const VARIABLE_t vDeltaTime, VARIABLE_t* avStateDot,BOOL bUpdateOutputs=TRUE)
	{
		if(bUpdateOutputs)
		{
			for(V_PDYNAMIC_IT_t itDynamic=itGetDynamicBegin();itDynamic!=itGetDynamicEnd();itDynamic++)
			{			
				(*itDynamic)->UpdateOutputs(&avState[(*itDynamic)->szGetStartIndexX()],vDeltaTime,TRUE);
			}
		}
		for(V_PDYNAMIC_IT_t itDynamic=itGetDynamicBegin();itDynamic!=itGetDynamicEnd();itDynamic++)
		{
			(*itDynamic)->CalculateXdot(&avState[(*itDynamic)->szGetStartIndexX()],
								vDeltaTime,&avStateDot[(*itDynamic)->szGetStartIndexX()]);
		}
		return;
	};

	
	void ReinitializeAggregatedStates(size_t szNumberStates)
	{
		vsGetX().resize(szNumberStates);
		vsGetX() *= 0.0;
	}

	size_t szGetNumberStates(){return(vsGetX().size());};

	STATE_t& vsGetX(){return(*m_pvsAggregatedX);};
	const STATE_t& vsGetX() const {return(*m_pvsAggregatedX);};

	V_PDYNAMIC_t& vcGetDynamic(){return(*m_pvcDynamic);};
	V_PDYNAMIC_t& vcGetDynamic() const {return(*m_pvcDynamic);};

	V_PDYNAMIC_IT_t itGetDynamicBegin(){return(vcGetDynamic().begin());};
	V_PDYNAMIC_IT_t itGetDynamicEnd(){return(vcGetDynamic().end());};

protected:
	V_PDYNAMIC_t* m_pvcDynamic;
	STATE_t* m_pvsAggregatedX;
};

namespace
{
	// the following are default parameters for the rate control in all three channels
						
	//Ziegler-Nichols' Step Response Method:	L is apparent time delay and a is the intercept of the open-loop system
	static const double dGainKP = 10.0;		//1.2/a		
	static const double dGainTiP = 15.0;		//2*L
	static const double dGainTdP = 0.5;		//L/2
	static const double dGainTtP = 0.5;			//(Ti*Td)^0.5
	static const double dLimitUpperPdot = 30000.0;
	static const double dLimitLowerPdot = -30000.0;

	static const double dGainKQ = 15.0;		//1.2/a		
	static const double dGainTiQ = 3.0;		//2*L
	static const double dGainTdQ = 0.05;		//L/2
	static const double dGainTtQ = 0.5;			//(Ti*Td)^0.5
	static const double dLimitUpperQdot = 30000.0;
	static const double dLimitLowerQdot = -30000.0;

	static const double dGainKR = 10.0;		//1.2/a		
	static const double dGainTiR = 5.0;		//2*L
	static const double dGainTdR = 0.3;		//L/2
	static const double dGainTtR = 0.5;			//(Ti*Td)^0.5
	static const double dLimitUpperRdot = 300000.0;
	static const double dLimitLowerRdot = -300000.0;

	static const int iNumberAltutudeNum = 2;
	static const double dAltitudeNum[iNumberAltutudeNum] = {0.002,0.016};
	static const int iNumberAltutudeDen = 2;
	static const double dAltutudeDen[iNumberAltutudeNum] = {1.0,8.0};

	static const int iNumberHeadingNum = 1;
	static const double dHeadingNum[iNumberHeadingNum] = {1.0};
	static const int iNumberHeadingDen = 1;
	static const double dHeadingDen[iNumberHeadingDen] = {1.0};

	static const int iNumberVelocityNum = 1;
	static const double dVelocityNum[iNumberVelocityNum] = {1.0};
	static const int iNumberVelocityDen = 1;
	static const double dVelocityDen[iNumberVelocityDen] = {1.0};

	static const int iNumberSideslipNum = 1;
	static const double dSideslipNum[iNumberSideslipNum] = {1.0};
	static const int iNumberSideslipDen = 1;
	static const double dSideslipDen[iNumberSideslipDen] = {1.0};
}


template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
class CVehicleSimulation :
		public CSimulationState<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>
{
public:
	typedef CSimulationState<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> Parent_t;
	typedef typename Parent_t::V_PDYNAMIC_IT_t V_PDYNAMIC_IT_t;

	CVehicleSimulation(stringstream& sstrErrorMessage,BOOL bDATCOMSubtractBaseTables=TRUE,
										 string strParameterFile=DEFAULT_PARAMETER_FILE,string strDataFile=DEFAULT_DATCOM_FILE) 
		: Parent_t()
	{
		m_pvehicleDynamics = new CVEHICLE_DYNAMICS_t(sstrErrorMessage,bDATCOMSubtractBaseTables,strParameterFile,strDataFile);
		// dynamic inversion must be after vehcile dynamic so it can save a pointer to the DATACOM tables
		m_pdynamicInversion = new CDYNAMIC_INVERSION_t();
		dynamicGetInversion().pvehicleGetDynamic() = m_pvehicleDynamics;

		m_prungeKutta4 = new CRUNGE_KUTTA4_t();
		m_pactuatorDelta = new CACTUATOR_1ST_ORDER_t();

		m_ppidRateP = new CPIDCONTROLLER_t(dGainKP,dGainTiP,dGainTdP,dGainTtP,dLimitUpperPdot,dLimitLowerPdot,"Pdot");
		m_ppidRateQ = new CPIDCONTROLLER_t(dGainKQ,dGainTiQ,dGainTdQ,dGainTtQ,dLimitUpperQdot,dLimitLowerQdot,"Qdot");
		m_ppidRateR = new CPIDCONTROLLER_t(dGainKR,dGainTiR,dGainTdR,dGainTtR,dLimitUpperRdot,dLimitLowerRdot,"Rdot");

		m_pAltPsiBetaVel = new CALTITUDEBETAPSIV_t();

		m_pfgpEngine1stOrder = new ENGINE1STORDER_t();

		STATE_t stateDummy;	// if size is 0, then the initialization function will use default states


		// set default command type and control alloc method 
		fcsGetType() = fcsAltPsiBetaVel;	//Default - Must be before inputs are initialized
		ctlallcGetMethod() = CDYNAMIC_INVERSION_t::ctlallcPsuedoInverse;

		// Cmd type and cntrl alloc method sent into bReinitialize function as inputs
		bReinitialize(stateDummy,fcsGetType(),ctlallcGetMethod(),sstrErrorMessage);
	}
	virtual ~CVehicleSimulation()
	{
		for(V_PDYNAMIC_IT_t itDynamic=itGetDynamicBegin();itDynamic!=itGetDynamicEnd();itDynamic++)
		{			
			(*itDynamic)->ClearInputs();
		}
		delete m_pdynamicInversion;
		m_pdynamicInversion = 0;
		delete m_pvehicleDynamics;
		m_pvehicleDynamics = 0;
		delete m_pfgpEngine1stOrder;
		m_pfgpEngine1stOrder = 0;

		delete m_pAltPsiBetaVel;
		m_pAltPsiBetaVel = 0;

		delete m_ppidRateP;
		m_ppidRateP = 0;
		delete m_ppidRateQ;
		m_ppidRateQ = 0;
		delete m_ppidRateR;
		m_ppidRateR = 0;
		delete m_pactuatorDelta;
		m_pactuatorDelta = 0;
		delete m_prungeKutta4;
		m_prungeKutta4 = 0;
	};

public:
	enum enFCStype
	{
		fcsAltPsiBetaVel,
		fcsPQRThrot,
		fcsTotal
	};
	enum enInAltPsiBetaVel 
	{
		inapbvPsi_rad,
		inapbvAltitude_ft,
		inapbvBeta_rad,
		inapbvVelocity_fps,
		inapbvTotal
	};
	enum enInPQRThrot 
	{
		inpqrtP_rps,
		inpqrtQ_rps,
		inpqrtR_rps,
		inpqrtThrottle_pct,
		inpqrtTotal
	};

	enum enRateLoops
	{
		ratePcmd,
		rateQcmd,
		rateRcmd,
		rateNumberStates,
		ratePfeedback = rateNumberStates,
		rateQfeedback,
		rateRfeedback,
		rateTotal
	};
	enum enPositionLoops
	{
		positionAltitudeCmd,
		positionHeadingCmd,
		positionVelocityCmd,
		positionSideslipCmd,
		positionNumberStates,
		positionAltitudeFeedback = positionNumberStates,
		positionHeadingFeedback,
		positionVelocityFeedback,
		positionSideslipFeedback,
		positionTotal
	};

	typedef CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> CVEHICLE_DYNAMICS_t;
	typedef CDynamicInversion<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> CDYNAMIC_INVERSION_t;
	typedef CRungeKutta4<CSimulationState<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>,VARIABLE_t> CRUNGE_KUTTA4_t;
	typedef CActuator1stOrder<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> CACTUATOR_1ST_ORDER_t;
	typedef CPIDController<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> CPIDCONTROLLER_t;
	typedef CEngine1stOrder<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> ENGINE1STORDER_t;
	typedef CCmdAltitudePsiBetaV<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> CALTITUDEBETAPSIV_t;
	typedef typename CONTAINER_INPUT_t::iterator CONTAINER_INPUT_IT_t;
	typedef typename CONTAINER_OUTPUT_t::iterator CONTAINER_OUTPUT_IT_t;

public:
	void operator=(CVehicleSimulation& rhs);
	void operator+=(CVehicleSimulation& rhs);
	CVehicleSimulation operator+(CVehicleSimulation& rhs); 
	CVehicleSimulation operator*(double dRHS); 


	CONTAINER_OUTPUT_t& cGetInputs(){return(m_cInputs);};
	const CONTAINER_OUTPUT_t& cGetInputs() const {return(m_cInputs);};
	CONTAINER_OUTPUT_IT_t itGetInput(int iIndex){return(&(cGetInputs()[iIndex]));};

	CONTAINER_OUTPUT_t& cGetOutputs(){return(m_cOutputs);};
	const CONTAINER_OUTPUT_t& cGetOutputs() const {return(m_cOutputs);};

	CONTAINER_OUTPUT_t& cGetForcesAndMoments(){return(m_cForcesAndMoments);};
	const CONTAINER_OUTPUT_t& cGetForcesAndMoments() const {return(m_cForcesAndMoments);};

	VARIABLE_t& vGetTimeLastUpdate(){return(m_TimeLastUpdate_sec);};
	const VARIABLE_t& vGetTimeLastUpdate() const {return(m_TimeLastUpdate_sec);};

	int iGetNumberInputs(){return(cGetInputs().size());};
	int iGetNumberOutputs(){return(cGetOutputs().size());};
	int iGetNumberStates(){return(szGetNumberStates());};

	// accessors
	CACTUATOR_1ST_ORDER_t& actuatorGetDelta(){return(*m_pactuatorDelta);};
	const CACTUATOR_1ST_ORDER_t& actuatorGetDelta() const {return(*m_pactuatorDelta);};
	CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>* pactuatorGetDelta(){return(m_pactuatorDelta);};

	CDYNAMIC_INVERSION_t& dynamicGetInversion(){return(*m_pdynamicInversion);};
	const CDYNAMIC_INVERSION_t& dynamicGetInversion() const {return(*m_pdynamicInversion);};
	CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>* pdynamicGetInversion(){return(m_pdynamicInversion);};

	CVEHICLE_DYNAMICS_t& vehicleGetDynamics(){return(*m_pvehicleDynamics);};
	const CVEHICLE_DYNAMICS_t& vehicleGetDynamics() const {return(*m_pvehicleDynamics);};
	CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>* pvehicleGetDynamic(){return(m_pvehicleDynamics);};

	CRUNGE_KUTTA4_t& rk4GetIntegrator(){return(*m_prungeKutta4);};
	const CRUNGE_KUTTA4_t& rk4GetIntegrator() const {return(*m_prungeKutta4);};

	enFCStype& fcsGetType(){return(m_fcsType);};
	const enFCStype& fcsGetType() const {return(m_fcsType);};

	typename CDYNAMIC_INVERSION_t::enControlAllocation& ctlallcGetMethod(){return(m_ctlallcMethod);};
	const typename CDYNAMIC_INVERSION_t::enControlAllocation& ctlallcGetMethod() const {return(m_ctlallcMethod);};

	CPIDCONTROLLER_t& pidGetRateP(){return(*m_ppidRateP);};
	const CPIDCONTROLLER_t& pidGetRateP() const {return(*m_ppidRateP);};
	CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>* ppidGetRateP(){return(m_ppidRateP);};

	CPIDCONTROLLER_t& pidGetRateQ(){return(*m_ppidRateQ);};
	const CPIDCONTROLLER_t& pidGetRateQ() const {return(*m_ppidRateQ);};
	CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>* ppidGetRateQ(){return(m_ppidRateQ);};

	CPIDCONTROLLER_t& pidGetRateR(){return(*m_ppidRateR);};
	const CPIDCONTROLLER_t& pidGetRateR() const {return(*m_ppidRateR);};
	CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>* ppidGetRateR(){return(m_ppidRateR);};

	CALTITUDEBETAPSIV_t& cGetAltPsiBetaVel(){return(*m_pAltPsiBetaVel);};
	const CALTITUDEBETAPSIV_t& cGetAltPsiBetaVel() const {return(*m_pAltPsiBetaVel);};
	CALTITUDEBETAPSIV_t* pcGetAltPsiBetaVel(){return(m_pAltPsiBetaVel);};

	ENGINE1STORDER_t& fgpGetEngine1stOrder(){return(*m_pfgpEngine1stOrder);};
	const ENGINE1STORDER_t& fgpGetEngine1stOrder() const {return(*m_pfgpEngine1stOrder);};
	ENGINE1STORDER_t* pfgpGetEngine1stOrder(){return(m_pfgpEngine1stOrder);};

	size_t vGetVehicleStateIndex(size_t szState){return(vehicleGetDynamics().vGetXIndex(szState));};
	VARIABLE_t vGetVehicleState(size_t szState){return(vsGetX()[vehicleGetDynamics().vGetXIndex(szState)]);};
	VARIABLE_t vGetVehicleOutput(size_t szOutput){return(vehicleGetDynamics().vdGetOutputs()[szOutput]);};
	VARIABLE_t vGetEngineState(size_t szState){return(vsGetX()[fgpGetEngine1stOrder().vGetXIndex(szState)]);};
	VARIABLE_t vGetEngineOutput(size_t szOutput){return(*(fgpGetEngine1stOrder().vdGetOutputs()[szOutput]));};
	
protected:
	CVEHICLE_DYNAMICS_t* m_pvehicleDynamics;

	CDYNAMIC_INVERSION_t* m_pdynamicInversion;

	CRUNGE_KUTTA4_t* m_prungeKutta4;

	CACTUATOR_1ST_ORDER_t* m_pactuatorDelta;

	CALTITUDEBETAPSIV_t* m_pAltPsiBetaVel;

	CPIDCONTROLLER_t* m_ppidRateP;
	CPIDCONTROLLER_t* m_ppidRateQ;
	CPIDCONTROLLER_t* m_ppidRateR;

	ENGINE1STORDER_t* m_pfgpEngine1stOrder;
	CONTAINER_OUTPUT_t m_cInputs;
	CONTAINER_OUTPUT_t m_cOutputs;
	CONTAINER_OUTPUT_t m_cForcesAndMoments;

	VARIABLE_t m_TimeLastUpdate_sec;

	enFCStype m_fcsType;
	typename CDYNAMIC_INVERSION_t::enControlAllocation m_ctlallcMethod;

public:
	//inline public functions
	BOOL bReinitialize(STATE_t& cState, enFCStype fcsCmdType, typename CDYNAMIC_INVERSION_t::enControlAllocation fcsCntrlAllocMeth,
							stringstream& sstrErrorMessage)
	{
		BOOL bReturn = TRUE;

		vGetTimeLastUpdate() = 0.0;

		// command type and control alloc method settings
		if (fcsCmdType==fcsAltPsiBetaVel)
		{
			fcsGetType() = fcsAltPsiBetaVel;	//Must be before inputs are initialized
		}
		else if (fcsCmdType==fcsPQRThrot)
		{
			fcsGetType() = fcsPQRThrot;	//Must be before inputs are initialized
		}
		if (fcsCntrlAllocMeth==CDYNAMIC_INVERSION_t::ctlallcPsuedoInverse)
		{
			ctlallcGetMethod() = CDYNAMIC_INVERSION_t::ctlallcPsuedoInverse;
		}
		else if (fcsCntrlAllocMeth==CDYNAMIC_INVERSION_t::ctlallcControlAllocationLP)
		{
			ctlallcGetMethod() = CDYNAMIC_INVERSION_t::ctlallcControlAllocationLP;
		}

		vcGetDynamic().clear();
		// add pointers to the dynamics objects to the simulation state vector
		vcGetDynamic().push_back(pactuatorGetDelta());
		vcGetDynamic().push_back(pvehicleGetDynamic());
		vcGetDynamic().push_back(pdynamicGetInversion());	//must be after vehicle dynamics
		vcGetDynamic().push_back(ppidGetRateP());
		vcGetDynamic().push_back(ppidGetRateQ());
		vcGetDynamic().push_back(ppidGetRateR());
		if (fcsGetType()==fcsAltPsiBetaVel)
		{
			vcGetDynamic().push_back(pcGetAltPsiBetaVel());
		}
		vcGetDynamic().push_back(pfgpGetEngine1stOrder());

		
		//set type of control allocation used, must be before object initialization
		dynamicGetInversion().ctlallcGetMethod() = ctlallcGetMethod();

		V_PDYNAMIC_IT_t itObject;  // for scope hack for repugnant MSVC++ 6
		for(itObject=vcGetDynamic().begin();itObject!=vcGetDynamic().end();itObject++)
		{
			if(!(*itObject)->bInitialize(sstrErrorMessage))
			{
				return(FALSE);
			}
		}

		// PID controller gains read here from parameter vector
		// defaults are over-ridden
		pidGetRateP().dGetGainK() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainKP];
		pidGetRateP().dGetGainTi() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainTiP];
		pidGetRateP().dGetGainTd() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainTdP];
		pidGetRateP().dGetGainTt() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainTtP];
		pidGetRateQ().dGetGainK() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainKQ];
		pidGetRateQ().dGetGainTi() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainTiQ];
		pidGetRateQ().dGetGainTd() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainTdQ];
		pidGetRateQ().dGetGainTt() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainTtQ];
		pidGetRateR().dGetGainK() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainKR];
		pidGetRateR().dGetGainTi() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainTiR];
		pidGetRateR().dGetGainTd() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainTdR];
		pidGetRateR().dGetGainTt() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainTtR];

		// altitude heading sideslip velocity control system
		cGetAltPsiBetaVel().vGetKPLoop() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainKPLoop];
		cGetAltPsiBetaVel().vGetKBetaLoop() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainKBetaLoop];
		cGetAltPsiBetaVel().vGetKVLoop() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainKVLoop];
		cGetAltPsiBetaVel().vGetKGammaPerAltErr() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainKGammaPerAltErr];
		cGetAltPsiBetaVel().vGetKThetaDotperGammaErr() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainKThetaDotperGammaErr];
		cGetAltPsiBetaVel().vGetKPsiDotperPsiErr() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainKPsiDotperPsiErr];
		cGetAltPsiBetaVel().vGetKCosPhiForQGain() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramGainKCosPhiForQGain];

		//engine #1
		fgpGetEngine1stOrder().vGetMaxThrust() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramMaxThrust_lbs];
		fgpGetEngine1stOrder().vGetMinThrust() = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramMinThrust_lbs];


		// these must be after the bInitialize() statement...
		// If weights other than the defaults are desired,
		//		then this is the place to put them, i.e:
		// dynamicGetInversion().matGetAxisWeights()(0,0) = 2.0;
		// dynamicGetInversion().matGetSurfaceWeights()(0,0) = 0.001;

		// Preferred Deflections are the outputs from a Pseudo Inverse control allocation
		// If others are desired, put defaults into the bInitialize() function in
		//		the DynamicInversion block and change them here (remove Pseudo Inverse
		//		preferred commands also)
		// dynamicGetInversion().matGetPreferredDeflections()(0,0) = 0.0;


		// based on number of control surfaces loaded with the vehicle model, set number of actuators
		actuatorGetDelta().SetNumberOfActuators(vehicleGetDynamics().iGetNumberExternalInputs());

		// If time constants and limits other than the defaults are desired,
		//		then this is the place to put them, i.e:
		// actuatorGetDelta().coGetLimitRate()[0] = 50.0;
		// actuatorGetDelta().coGetLimitPositionUpper()[2] = 2.0;
		// actuatorGetDelta().coGetLimitPositionLower()[2] = -4.5;
		// actuatorGetDelta().coGetLimitPositionLower()[0] = -5.0;
		// actuatorGetDelta().coGetTimeConstant()[1] = 0.01;
		// actuatorGetDelta().UpdateOutputsWithLimits();
		

		// after all of the pointers have been added, reset/resize the storage for the aggregated state vector
		size_t szTotalSize = 0;
		for(itObject=vcGetDynamic().begin();itObject!=vcGetDynamic().end();itObject++)
		{
			szTotalSize += (*itObject)->szGetXSize();
		}
		ReinitializeAggregatedStates(szTotalSize);


		// save pointers to the state vector and reset the states to default
		size_t szStateIndex = 0;
		// save starting index of outputs for each object
		size_t szCountOutputs = 0;
		for(itObject=vcGetDynamic().begin();itObject!=vcGetDynamic().end();itObject++)
		{
			// save starting index in vector
			(*itObject)->szGetStartIndexX() = szStateIndex;
			// increment index for next object
			szStateIndex += (*itObject)->szGetXSize();

			// set to default inital state
			(*itObject)->DefaultState(&vsGetX()[(*itObject)->szGetStartIndexX()]);

		}

		//initalize states to values passed in
		if(cState.size() == vsGetX().size())
		{
			vsGetX() = cState;
		}
		else if(cState.size() != 0)	//if there are no states entered, then use the default, i.e. if(cState.size() == 0)
		{
			bReturn = FALSE;
			sstrErrorMessage << "CVehicleSimulation::bReinitialize: Wrong number of states encountered.\n";
			return(bReturn);
		}

		// set number inputs
		// NOTE - total inputs currently not different for the command types 
		cGetInputs().clear();
		switch(fcsGetType())
		{
		case fcsAltPsiBetaVel:
			cGetInputs().resize(inapbvTotal,0.0);
			break;
		case fcsPQRThrot:
			cGetInputs().resize(inpqrtTotal,0.0);
			break;
		default:
			bReturn = FALSE;
			sstrErrorMessage << "CVehicleSimulation::bReinitialize: Command type undefined.\n";
			return(bReturn);
		}
		
		// set number outputs
		cGetOutputs().clear();
		size_t szNumberOutputs = vsGetX().size();
		for(itObject=vcGetDynamic().begin();itObject!=vcGetDynamic().end();itObject++)
		{
			//set starting index of outputs for each block
			(*itObject)->szGetStartIndexOutputs() = szNumberOutputs;
			szCountOutputs += (*itObject)->iGetNumberOutputs();
			szNumberOutputs+=(*itObject)->iGetNumberOutputs();
		}
		cGetOutputs().resize(szNumberOutputs,0.0);

		//set number direct/external forces and moments
		cGetForcesAndMoments().clear();
		cGetForcesAndMoments().resize(vehicleGetDynamics().szGetNumberForcesAndMoments(),0.0);

		//retrieve inputs and feedback based on the command type 
		switch(fcsGetType())
		{
		case fcsAltPsiBetaVel:
			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inCmdPsi_rad] = &cGetInputs()[inapbvPsi_rad];
			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inCmdAltitude_ft] = &cGetInputs()[inapbvAltitude_ft];
			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inCmdBeta_rad] = &cGetInputs()[inapbvBeta_rad];//defaults to 0.0
			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inCmdV_ftpersec] = &cGetInputs()[inapbvVelocity_fps];

			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inAltitude_ft] = &*vehicleGetDynamics().itGetOutput(CVEHICLE_DYNAMICS_t::outputAltitude_ft);
			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inPhi_rad] = &vsGetX()[vehicleGetDynamics().vGetXIndex(CVEHICLE_DYNAMICS_t::statePhi_Rad)];
			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inTheta_rad] = &vsGetX()[vehicleGetDynamics().vGetXIndex(CVEHICLE_DYNAMICS_t::stateTheta_Rad)];
			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inPsi_rad] = &vsGetX()[vehicleGetDynamics().vGetXIndex(CVEHICLE_DYNAMICS_t::statePsi_Rad)];

			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inQ_radpersec] = &vsGetX()[vehicleGetDynamics().vGetXIndex(CVEHICLE_DYNAMICS_t::stateQ_RadPerSec)];
			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inR_radpersec] = &vsGetX()[vehicleGetDynamics().vGetXIndex(CVEHICLE_DYNAMICS_t::stateR_RadPerSec)];


			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inAlpha_rad] =  &*vehicleGetDynamics().itGetOutput(CVEHICLE_DYNAMICS_t::outputAlpha_rad);
			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inBeta_rad] =  &*vehicleGetDynamics().itGetOutput(CVEHICLE_DYNAMICS_t::outputBeta_rad);
			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inV_ftpersec] = &*vehicleGetDynamics().itGetOutput(CVEHICLE_DYNAMICS_t::outputVt_ftpersec);
			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inGama_rad] =  &*vehicleGetDynamics().itGetOutput(CVEHICLE_DYNAMICS_t::outputFlightPathAngle_rad);
			cGetAltPsiBetaVel().vpdGetInputs()[CALTITUDEBETAPSIV_t::inZdot_ftpersec] =  &*vehicleGetDynamics().itGetOutput(CVEHICLE_DYNAMICS_t::outputVelocityZ_feetpersec);
		
			pidGetRateP().vpdGetInputs()[CPIDCONTROLLER_t::inCommand] = &*cGetAltPsiBetaVel().itGetOutput(CALTITUDEBETAPSIV_t::outCmdP_radpersec);
			pidGetRateQ().vpdGetInputs()[CPIDCONTROLLER_t::inCommand] = &*cGetAltPsiBetaVel().itGetOutput(CALTITUDEBETAPSIV_t::outCmdQ_radpersec);
			pidGetRateR().vpdGetInputs()[CPIDCONTROLLER_t::inCommand] = &*cGetAltPsiBetaVel().itGetOutput(CALTITUDEBETAPSIV_t::outCmdR_radpersec);
			fgpGetEngine1stOrder().vpdGetInputs()[ENGINE1STORDER_t::inThrottleCmd_pct] = &*cGetAltPsiBetaVel().itGetOutput(CALTITUDEBETAPSIV_t::outCmdThrottle_pct);
			break;
		case fcsPQRThrot:
			pidGetRateP().vpdGetInputs()[CPIDCONTROLLER_t::inCommand] =  &cGetInputs()[inpqrtP_rps];
			pidGetRateQ().vpdGetInputs()[CPIDCONTROLLER_t::inCommand] =  &cGetInputs()[inpqrtQ_rps];
			pidGetRateR().vpdGetInputs()[CPIDCONTROLLER_t::inCommand] =  &cGetInputs()[inpqrtR_rps];
			fgpGetEngine1stOrder().vpdGetInputs()[ENGINE1STORDER_t::inThrottleCmd_pct] = &cGetInputs()[inpqrtThrottle_pct];
			break;
		}

		pidGetRateP().vpdGetInputs()[CPIDCONTROLLER_t::inFeedback] = &vsGetX()[vehicleGetDynamics().vGetXIndex(CVEHICLE_DYNAMICS_t::stateP_RadPerSec)];
		pidGetRateQ().vpdGetInputs()[CPIDCONTROLLER_t::inFeedback] = &vsGetX()[vehicleGetDynamics().vGetXIndex(CVEHICLE_DYNAMICS_t::stateQ_RadPerSec)];
		pidGetRateR().vpdGetInputs()[CPIDCONTROLLER_t::inFeedback] = &vsGetX()[vehicleGetDynamics().vGetXIndex(CVEHICLE_DYNAMICS_t::stateR_RadPerSec)];

		// Dynamic Inversion controller	
		switch(dynamicGetInversion().ctlallcGetMethod())
		{
		default: //If no control allocation is chosen, this defaults to the pseudo inverse
		case CDYNAMIC_INVERSION_t::ctlallcPsuedoInverse:
			{
				dynamicGetInversion().vpdGetInputs()[(size_t)CDYNAMIC_INVERSION_t::inPdotDesired_radpersec2] = 
																				&*pidGetRateP().itGetOutput(CPIDCONTROLLER_t::outOutput);	//Note: Output from PIDController is an acceleration 
				dynamicGetInversion().vpdGetInputs()[(size_t)CDYNAMIC_INVERSION_t::inQdotDesired_radpersec2] = 
																				&*pidGetRateQ().itGetOutput(CPIDCONTROLLER_t::outOutput); //Note: Output from PIDController is an acceleration 
				dynamicGetInversion().vpdGetInputs()[(size_t)CDYNAMIC_INVERSION_t::inRdotDesired_radpersec2] = 
																				&*pidGetRateR().itGetOutput(CPIDCONTROLLER_t::outOutput); //Note: Output from PIDController is an acceleration 
				dynamicGetInversion().vpdGetInputs()[(size_t)CDYNAMIC_INVERSION_t::inPdotNeutral_radpersec2] = 
																&*vehicleGetDynamics().itGetOutput((size_t)CVEHICLE_DYNAMICS_t::outputPdotNeutral_radpersec2);
				dynamicGetInversion().vpdGetInputs()[(size_t)CDYNAMIC_INVERSION_t::inQdotNeutral_radpersec2] = 
																&*vehicleGetDynamics().itGetOutput((size_t)CVEHICLE_DYNAMICS_t::outputQdotNeutral_radpersec2);
				dynamicGetInversion().vpdGetInputs()[(size_t)CDYNAMIC_INVERSION_t::inRdotNeutral_radpersec2] = 
																&*vehicleGetDynamics().itGetOutput((size_t)CVEHICLE_DYNAMICS_t::outputRdotNeutral_radpersec2);
			}
			break;
		case CDYNAMIC_INVERSION_t::ctlallcControlAllocationLP:
			{
				dynamicGetInversion().vpdGetInputs()[(size_t)CDYNAMIC_INVERSION_t::inPdotDesired_radpersec2] = 
																				&*pidGetRateP().itGetOutput(CPIDCONTROLLER_t::outOutput); //Note: Output from PIDController is an acceleration 
				dynamicGetInversion().vpdGetInputs()[(size_t)CDYNAMIC_INVERSION_t::inQdotDesired_radpersec2] = 
																				&*pidGetRateQ().itGetOutput(CPIDCONTROLLER_t::outOutput); //Note: Output from PIDController is an acceleration 
				dynamicGetInversion().vpdGetInputs()[(size_t)CDYNAMIC_INVERSION_t::inRdotDesired_radpersec2] = 
																				&*pidGetRateR().itGetOutput(CPIDCONTROLLER_t::outOutput); //Note: Output from PIDController is an acceleration 
				dynamicGetInversion().vpdGetInputs()[(size_t)CDYNAMIC_INVERSION_t::inPdotNeutral_radpersec2] = 
																&*vehicleGetDynamics().itGetOutput((size_t)CVEHICLE_DYNAMICS_t::outputPdotNeutral_radpersec2);
				dynamicGetInversion().vpdGetInputs()[(size_t)CDYNAMIC_INVERSION_t::inQdotNeutral_radpersec2] = 
																&*vehicleGetDynamics().itGetOutput((size_t)CVEHICLE_DYNAMICS_t::outputQdotNeutral_radpersec2);
				dynamicGetInversion().vpdGetInputs()[(size_t)CDYNAMIC_INVERSION_t::inRdotNeutral_radpersec2] = 
																&*vehicleGetDynamics().itGetOutput((size_t)CVEHICLE_DYNAMICS_t::outputRdotNeutral_radpersec2);

				for(size_t szCountActuators=0;szCountActuators<actuatorGetDelta().szGetNumberActuators();szCountActuators++)
				// This loop is for a staggered arrangement of deflections and limits
				{
					dynamicGetInversion().vpdGetInputs()
						[static_cast<size_t>(CDYNAMIC_INVERSION_t::inFirstActuatorEntry+(szCountActuators*(CACTUATOR_1ST_ORDER_t::actoutTotal))+CACTUATOR_1ST_ORDER_t::actoutPosition)] = 
								&*actuatorGetDelta().itGetOutput((szCountActuators*CACTUATOR_1ST_ORDER_t::actoutTotal)+CACTUATOR_1ST_ORDER_t::actoutPosition);
					dynamicGetInversion().vpdGetInputs()
						[static_cast<size_t>(CDYNAMIC_INVERSION_t::inFirstActuatorEntry+(szCountActuators*(CACTUATOR_1ST_ORDER_t::actoutTotal))+CACTUATOR_1ST_ORDER_t::actoutPositionLimitUpper)] = 
								&*actuatorGetDelta().itGetOutput((szCountActuators*CACTUATOR_1ST_ORDER_t::actoutTotal)+CACTUATOR_1ST_ORDER_t::actoutPositionLimitUpper);
					dynamicGetInversion().vpdGetInputs()
						[static_cast<size_t>(CDYNAMIC_INVERSION_t::inFirstActuatorEntry+(szCountActuators*(CACTUATOR_1ST_ORDER_t::actoutTotal))+CACTUATOR_1ST_ORDER_t::actoutPositionLimitLower)] =
								&*actuatorGetDelta().itGetOutput((szCountActuators*CACTUATOR_1ST_ORDER_t::actoutTotal)+CACTUATOR_1ST_ORDER_t::actoutPositionLimitLower);
					dynamicGetInversion().vpdGetInputs()
						[static_cast<size_t>(CDYNAMIC_INVERSION_t::inFirstActuatorEntry+(szCountActuators*(CACTUATOR_1ST_ORDER_t::actoutTotal))+CACTUATOR_1ST_ORDER_t::actoutPositionLimitRate)] =
								&*actuatorGetDelta().itGetOutput((szCountActuators*CACTUATOR_1ST_ORDER_t::actoutTotal)+CACTUATOR_1ST_ORDER_t::actoutPositionLimitRate);
					dynamicGetInversion().vpdGetInputs()
						[static_cast<size_t>(CDYNAMIC_INVERSION_t::inFirstActuatorEntry+(szCountActuators*(CACTUATOR_1ST_ORDER_t::actoutTotal))+CACTUATOR_1ST_ORDER_t::actoutActuatorTimeConstant)] =
								&*actuatorGetDelta().itGetOutput((szCountActuators*CACTUATOR_1ST_ORDER_t::actoutTotal)+CACTUATOR_1ST_ORDER_t::actoutActuatorTimeConstant);
				}
			}
			break;
		};

		// connect outputs from the dynamic inversion to the actuator inputs
		size_t szCountActuators; // for scope hack for fetid MSVC++6
		for(szCountActuators=0;szCountActuators<actuatorGetDelta().szGetNumberActuators();szCountActuators++)
		{
			actuatorGetDelta().vpdGetInputs()[szCountActuators] = &*dynamicGetInversion().itGetOutput(szCountActuators);
		}
		// vehicle input/output connections
		CONTAINER_INPUT_IT_t itVehicleInputs=vehicleGetDynamics().vpdGetInputs().begin();
		for(CONTAINER_OUTPUT_IT_t itForcesAndMoments=cGetForcesAndMoments().begin();
											itForcesAndMoments!=cGetForcesAndMoments().end();
											itForcesAndMoments++,itVehicleInputs++)
		{
			*itVehicleInputs = &*itForcesAndMoments;
		}

		// this is for staggered arrangement of actuator outputs
		for(szCountActuators=0;szCountActuators<actuatorGetDelta().szGetNumberActuators();
																szCountActuators++,itVehicleInputs++)
		{
		
			*itVehicleInputs = &*actuatorGetDelta().itGetOutput(szCountActuators*CACTUATOR_1ST_ORDER_t::actoutTotal);
		}

		vehicleGetDynamics().vpdGetInputs()[CVEHICLE_DYNAMICS_t::fmCA_AxialForce] = &*fgpGetEngine1stOrder().itGetOutput(ENGINE1STORDER_t::outThrustX_lbs);

		for(itObject=vcGetDynamic().begin();itObject!=vcGetDynamic().end();itObject++)
		{			
			(*itObject)->UpdateOutputs(&vsGetX()[(*itObject)->szGetStartIndexX()],0.0);
		}

		return(bReturn);
	}


	BOOL bUpdate(CONTAINER_OUTPUT_t& cInputs,const VARIABLE_t vElapsedTime,
								CONTAINER_OUTPUT_t& cOutputs,stringstream& sstrErrorMessage)
	{
		if(cInputs.size() == iGetNumberInputs())
		{
			CONTAINER_OUTPUT_IT_t  itExternalInputs=cInputs.begin();
			for(CONTAINER_OUTPUT_IT_t itInputs=cGetInputs().begin();
												itInputs!=((CONTAINER_OUTPUT_t&)cGetInputs()).end();
												itInputs++,itExternalInputs++)
			{
													*itInputs = *itExternalInputs;
			}
		}
		else
		{
			sstrErrorMessage << "CVehicleSimulation::bUpdate: Wrong number of external inputs passed to update function. ";
			sstrErrorMessage << "Number inputs passed in: " << cInputs.size() << " Required: " << iGetNumberInputs() << "\n";
			return(FALSE);
		}
		
		// TODO -What???
		cGetForcesAndMoments()[2] = 40.0;

		// integrate
		VARIABLE_t vDeltaTime = vElapsedTime - vGetTimeLastUpdate();
		vGetTimeLastUpdate() = vElapsedTime;
		rk4GetIntegrator().Integrate(*this,vDeltaTime);

		V_PDYNAMIC_IT_t itObject;  // for scope hack for foul MSVC++ 6
		for(itObject=vcGetDynamic().begin();itObject!=vcGetDynamic().end();itObject++)
		{			
			(*itObject)->UpdateOutputs(&vsGetX()[(*itObject)->szGetStartIndexX()],vDeltaTime);
		}

		// check for error condition
		if((vehicleGetDynamics().vdGetOutputs()[CVEHICLE_DYNAMICS_t::outputAlpha_rad] > dLimitUpperAlpha_rad)||
					(vehicleGetDynamics().vdGetOutputs()[CVEHICLE_DYNAMICS_t::outputAlpha_rad] < dLimitLowerAlpha_rad))
		{
			sstrErrorMessage << "CVehicleSimulation::bUpdate: Alpha out of limits, alpha (deg) = "<< vehicleGetDynamics().vdGetOutputs()[CVEHICLE_DYNAMICS_t::outputAlpha_rad]*180.0/_PI << endl;
#ifdef ALPHA_BETA_LIMIT_ERROR
			vehicleGetDynamics().DefaultState(&vsGetX()[vehicleGetDynamics().szGetStartIndexX()]);
			return(FALSE);
#endif	//#ifndef NO_ALPHA_BETA_LIMITS
		}
		else if((vehicleGetDynamics().vdGetOutputs()[CVEHICLE_DYNAMICS_t::outputBeta_rad] > dLimitUpperBeta_rad)||
					(vehicleGetDynamics().vdGetOutputs()[CVEHICLE_DYNAMICS_t::outputBeta_rad] < dLimitLowerBeta_rad))
		{
			sstrErrorMessage << "CVehicleSimulation::bUpdate: Beta out of limits, beta (deg) = "<< vehicleGetDynamics().vdGetOutputs()[CVEHICLE_DYNAMICS_t::outputBeta_rad]*180.0/_PI << endl;
#ifdef ALPHA_BETA_LIMIT_ERROR
			vehicleGetDynamics().DefaultState(&vsGetX()[vehicleGetDynamics().szGetStartIndexX()]);
			return(FALSE);
#endif	//#ifndef NO_ALPHA_BETA_LIMITS
		}

		CONTAINER_OUTPUT_IT_t itOutputs = cOutputs.begin();
		for(int iCountStates=0;iCountStates<vsGetX().size();iCountStates++,itOutputs++)
		{
			(*itOutputs) = vsGetX()[iCountStates];
		}

		for(itObject=vcGetDynamic().begin();itObject!=vcGetDynamic().end();itObject++)
		{			
			for(CONTAINER_OUTPUT_IT_t itOutput=(*itObject)->itGetOutputsBegin();itOutput!=(*itObject)->itGetOutputsEnd();itOutput++,++itOutputs)
			{
				(*itOutputs) = *itOutput;
			}
		}
		return(TRUE);
	};

	void GetOutputLabels(string strPreLabel,string strPostLabel,stringstream& sstrLabels)
	{
		// for scope hack for despicable MSVC++6 
		V_PDYNAMIC_IT_t itObject;
		for(itObject=vcGetDynamic().begin();itObject!=vcGetDynamic().end();itObject++)
		{			
			(*itObject)->GetAllLabelsState(strPreLabel,strPostLabel,sstrLabels);
		}
		for(itObject=vcGetDynamic().begin();itObject!=vcGetDynamic().end();itObject++)
		{			
			(*itObject)->GetAllLabelsOutput(strPreLabel,strPostLabel,sstrLabels);
		}
	};
	void GetStateLabels(string strPreLabel,string strPostLabel,stringstream& sstrLabels)
	{
		for(itObject=vcGetDynamic().begin();itObject!=vcGetDynamic().end();itObject++)
		{			
			(*itObject)->GetAllLabelsState(strPreLabel,strPostLabel,sstrLabels);
		}
	};

};


// START:: VehicleSimulation.cpp

// VehicleSimulation.cpp: implementation of the CVehicleSimulation class.
//
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
////// dummy instance (necessary for compiling with MSVC++)
//////////////////////////////////////////////////////////////////////
//CVehicleSimulation<VAL_DOUBLE_t,V_PDOUBLE_t,V_DOUBLE_t,double> CVEHICLESIMULATION_DUMMY_NEED_TO_FORCE_COMPILER_TO_RECOGNIZE_THIS_CLASS;


#endif // !defined(AFX_VEHICLESIMULATION_H__A7C7DF60_C905_4A63_8E51_582DC42E0E42__INCLUDED_)
