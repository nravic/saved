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
// VehicleDynamics.h: interface for the CVehicleDynamics class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VEHICLEDYNAMICS_H__7BD4EF7A_D715_45BE_8A2A_560E342FDB90__INCLUDED_)
#define AFX_VEHICLEDYNAMICS_H__7BD4EF7A_D715_45BE_8A2A_560E342FDB90__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000


#include <string>
#include <vector>
#include <valarray>
#include <sstream> // stringstream
using namespace std;

#include <GlobalDefines.h>

#include "Dynamic.h"
#include "InputOutput.h"
#include "DATCOMTable.h"



#define DEFAULT_DATCOM_FILE "DATCOM.dat"
#define DEFAULT_PARAMETER_FILE "Parameters.dat"
//#define PARAMETER_FILE_VERSION (double)(1.0)
//#define PARAMETER_FILE_VERSION (double)(1.1)
//#define PARAMETER_FILE_VERSION (double)(1.2)
//#define PARAMETER_FILE_VERSION (double)(1.3)
#define PARAMETER_FILE_VERSION (double)(1.4)

#define DEFAULT_UPDATE_PERIOD (0.01)
#define CONST_LIMIT_ALPHA_DEG_UPPER (70.0)
#define CONST_LIMIT_ALPHA_DEG_LOWER (-20.0)

#define DEFAULT_STATE_U_FEETPERSEC (300.0)
#define DEFAULT_STATE_V_FEETPERSEC (0.0)
#define DEFAULT_STATE_W_FEETPERSEC (10.0)
#define DEFAULT_STATE_P_RADPERSEC (0.0)
#define DEFAULT_STATE_Q_RADPERSEC (0.0)
#define DEFAULT_STATE_R_RADPERSEC (0.0)
#define DEFAULT_STATE_PHI_RAD (0.0)
#define DEFAULT_STATE_THETA_RAD (0.0)
#define DEFAULT_STATE_PSI_RAD (0.0)
#define DEFAULT_STATE_X_FEET (0.0)
#define DEFAULT_STATE_Y_FEET (0.0)
#define DEFAULT_STATE_ALTITUDE_FEET (800.0)


#define CONST_DENSITY_SEA_LEVEL (0.002376888)
#define CONST_GravityAccelerationLbsPerSec2 (32.2)



namespace RAS_VehicleDynamics
{
	typedef vector<double*> V_PDOUBLE_t;
	typedef vector<double> V_DOUBLE_t;

	typedef valarray<double> VAL_DOUBLE_t;
}
using namespace RAS_VehicleDynamics;

template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
class CVehicleDynamics  : 
	public CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>
{
	public:
		CVehicleDynamics(stringstream& sstrErrorMessage,BOOL bDATCOMSubtractBaseTables=TRUE,string strParameterFile=DEFAULT_PARAMETER_FILE,string strDataFile=DEFAULT_DATCOM_FILE):
		  m_bDATCOMSubtractBaseTables(bDATCOMSubtractBaseTables)
	{
		strGetParameterFile() = strParameterFile;
		strGetDataFile() = strDataFile;

		m_pdatcomTable = new CDATCOMTable();
		bGetFilesLoaded() = FALSE;

		// output labels
		vstrGetLabelsOutput().clear();
		vstrGetLabelsOutput().push_back(string("outputMach"));
		vstrGetLabelsOutput().push_back(string("outputVt_ftpersec"));
		vstrGetLabelsOutput().push_back(string("outputAlpha_rad"));
		vstrGetLabelsOutput().push_back(string("outputBeta_rad"));
		vstrGetLabelsOutput().push_back(string("outputAltitude_ft"));
		vstrGetLabelsOutput().push_back(string("outputPdotNeutral_radpersec2"));
		vstrGetLabelsOutput().push_back(string("outputQdotNeutral_radpersec2"));
		vstrGetLabelsOutput().push_back(string("outputRdotNeutral_radpersec2"));
		vstrGetLabelsOutput().push_back(string("outputVelocityX_feetpersec"));
		vstrGetLabelsOutput().push_back(string("outputVelocityY_feetpersec"));
		vstrGetLabelsOutput().push_back(string("outputVelocityZ_feetpersec"));
		vstrGetLabelsOutput().push_back(string("outputFlightPathAngle_rad"));

		// state labels
		vstrGetLabelsState().clear();
		vstrGetLabelsState().push_back(string("stateU_FeetPerSec"));
		vstrGetLabelsState().push_back(string("stateV_FeetPerSec"));
		vstrGetLabelsState().push_back(string("stateW_FeetPerSec"));
		vstrGetLabelsState().push_back(string("stateP_RadPerSec"));
		vstrGetLabelsState().push_back(string("stateQ_RadPerSec"));
		vstrGetLabelsState().push_back(string("stateR_RadPerSec"));
		vstrGetLabelsState().push_back(string("statePhi_Rad"));
		vstrGetLabelsState().push_back(string("stateTheta_Rad"));
		vstrGetLabelsState().push_back(string("statePsi_Rad"));
		vstrGetLabelsState().push_back(string("stateX_Feet"));
		vstrGetLabelsState().push_back(string("stateY_Feet"));
		vstrGetLabelsState().push_back(string("stateZ_Feet"));

		// resize outputs, and states
		vdGetOutputs().resize(vstrGetLabelsOutput().size(),0.0);
		szGetXSize() = vstrGetLabelsState().size();
		vdGetIntercepts().resize(rotTotal,0.0);

		bInitialize(sstrErrorMessage);
	};

	virtual ~CVehicleDynamics()
	{
		delete m_pdatcomTable;
		m_pdatcomTable = 0;
	};


public:
	enum StatesNames_t
	{
		stateU_FeetPerSec,
		stateV_FeetPerSec,
		stateW_FeetPerSec,
		stateP_RadPerSec,
		stateQ_RadPerSec,
		stateR_RadPerSec,
		statePhi_Rad,
		stateTheta_Rad,
		statePsi_Rad,
		stateX_Feet,
		stateY_Feet,
		stateZ_Feet,
		stateTotal
	};

	enum enOutputs 
	{
		outputMach,
		outputVt_ftpersec,
		outputAlpha_rad,
		outputBeta_rad,
		outputAltitude_ft,
		outputPdotNeutral_radpersec2,
		outputQdotNeutral_radpersec2,
		outputRdotNeutral_radpersec2,
		outputVelocityX_feetpersec,
		outputVelocityY_feetpersec,
		outputVelocityZ_feetpersec,
		outputFlightPathAngle_rad,
		outputTotal 
	};

	enum enDampingDerivatives
	{
		dampCNQ_NormalForceDueToQ,
		dampCMQ_PitchMomentDueToQ,
		dampCAQ_AxialForceDueToQ,
		dampCYR_SideForceDueToR,
		dampClnR_YawMomentDueToR,
		dampCllR_RollMomentDueToR,
		dampCYP_SideForceDueToP,
		dampClnP_YawMomentDueToP,
		dampCllP_RollMomentDueToR,
		dampTotal
	};

	enum enForceAndMoments
	{
		fmCN_NormalForce,
		fmStart = fmCN_NormalForce,
		fmCM_PitchMoment,
		fmCA_AxialForce,
		fmCY_SideForce,
		fmCln_YawMoment,
		fmCll_RollMoment,
		fmTotal,
		fmExternalInputsStart= fmTotal
	};

	enum enParameters
	{
		paramWeight,
		paramIxx,
		paramIyy,
		paramIzz,
		paramIzx,
		paramS_WingArea,
		paramc_Cord,
		paramb_Span,
		paramGainKP,
		paramGainTiP,
		paramGainTdP,
		paramGainTtP,
		paramGainKQ,
		paramGainTiQ,
		paramGainTdQ,
		paramGainTtQ,
		paramGainKR,
		paramGainTiR,
		paramGainTdR,
		paramGainTtR,
		paramGainKGammaPerAltErr,
		paramGainKThetaDotperGammaErr,
		paramGainKPsiDotperPsiErr,
		paramGainKCosPhiForQGain,
		paramGainKPLoop,
		paramGainKBetaLoop,
		paramGainKVLoop,
		paramMaxThrust_lbs,
		paramMinThrust_lbs,
		paramTotal
	};
	enum enAeroIndependentVariables	// this is set up for a particular formatting of the DATCOM tables
	{
		aeroindAlpha_deg,
		aeroindMach,
		aeroindAltitude_ft,
		aeroindBeta_deg,
		aeroindDeltaFirst,
		aeroindTotalRequired = aeroindDeltaFirst
	};
	enum enRotationAxes
	{
		rotP,
		rotQ,
		rotR,
		rotTotal
	};

	typedef vector<STATE_t> V_STATE;
	typedef typename V_STATE::iterator V_STATE_IT;

public:
	// virtual overrides
	virtual void CalculateXdot(VARIABLE_t* avState, const VARIABLE_t vDeltaTime, VARIABLE_t* avStateDot,BOOL bUpdateOutputs=TRUE)
	{
		CalculateXDot(avState,avStateDot,FALSE);
	};
	virtual void UpdateOutputs(VARIABLE_t* avState, const VARIABLE_t& vDeltaTime,BOOL bIntermediateStep=FALSE)
	{	
		CalculateXDot(avState,avGetStateDot(),TRUE);
	};
	virtual BOOL bInitialize(stringstream& sstrErrorMessage);
	virtual void DefaultState(VARIABLE_t* avState);

	void CalculateXDot(VARIABLE_t* avState,VARIABLE_t* avStateDot,BOOL bUpdateOutputZeroInputs);

	BOOL bReadFiles(stringstream& sstreamErrors,string strParameters=DEFAULT_PARAMETER_FILE,string strDATCOM=DEFAULT_DATCOM_FILE);


	int iGetStateTotal(){return(stateTotal);};
	int iGetOutputTotal(){return(outputTotal);};
	size_t szGetNumberForcesAndMoments(){return(fmTotal);};
	int iGetNumberExternalInputs(){return(iGetNumberInputs() - fmTotal);};
	int iGetExternalInputsStartIndex(){return(fmExternalInputsStart);};
	size_t szGetExternalInputsIndex(size_t szIndex){return(szIndex+fmExternalInputsStart);};

	CONTAINER_INPUT_t& vpdGetExternalInput(size_t szIndex){return(m_vpdInputs[szIndex+iGetExternalInputsStartIndex()]);}

	// accessors
	CDATCOMTable& datcomGetTable(){return(*m_pdatcomTable);};
	const CDATCOMTable& datcomGetTable() const {return(*m_pdatcomTable);};

	CONTAINER_OUTPUT_t& valdGeParameters(){return(m_valdParameters);};
	const CONTAINER_OUTPUT_t& valdGeParameters() const {return(m_valdParameters);};

	CONTAINER_OUTPUT_t& vdGetIntercepts(){return(m_vdIntercepts);};
	const CONTAINER_OUTPUT_t& vdGetIntercepts() const {return(m_vdIntercepts);};

	BOOL& bGetDATCOMSubtractBaseTables(){return(m_bDATCOMSubtractBaseTables);};
	const BOOL& bGetDATCOMSubtractBaseTables() const {return(m_bDATCOMSubtractBaseTables);};

	BOOL& bGetFilesLoaded(){return(m_bFilesLoaded);};
	const BOOL& bGetFilesLoaded() const {return(m_bFilesLoaded);};

	STATE_t& stGetAeroIndependentVariables(){return(m_stAeroIndependentVariables);};
	const STATE_t& stGetAeroIndependentVariables() const {return(m_stAeroIndependentVariables);};

	STATE_t& stGetAeroDeltaIncrement(){return(m_stAeroDeltaIncrement);};
	const STATE_t& stGetAeroDeltaIncrement() const {return(m_stAeroDeltaIncrement);};

	STATE_t& stGetAeroDynamicDerivative(){return(m_stAeroDynamicDerivative);};
	const STATE_t& stGetAeroDynamicDerivative() const {return(m_stAeroDynamicDerivative);};

	STATE_t& stGetAeroNominal(){return(m_stAeroNominal);};
	const STATE_t& stGetAeroNominal() const {return(m_stAeroNominal);};

	V_STATE& vvalsGetDerivatives(){return(m_vvalsDerivatives);};
	const V_STATE& vvalsGetDerivatives() const {return(m_vvalsDerivatives);};

	V_STATE& vvalsGetIntercepts(){return(m_vvalsIntercepts);};
	const V_STATE& vvalsGetIntercepts() const {return(m_vvalsIntercepts);};

	VARIABLE_t* avGetStateDot(){return((double *)&m_avStateDot);};

	string& strGetParameterFile(){return(m_strParameterFile);};
	const string& strGetParameterFile() const {return(m_strParameterFile);};

	string& strGetDataFile(){return(m_strDataFile);};
	const string& strGetDataFile() const {return(m_strDataFile);};

protected:
	CONTAINER_OUTPUT_t m_valdParameters;
	CDATCOMTable* m_pdatcomTable;
	// build input vector for table look-up 
	STATE_t m_stAeroIndependentVariables;
	// storage for table look-up values
	STATE_t m_stAeroDeltaIncrement;
	STATE_t m_stAeroDynamicDerivative;
	STATE_t m_stAeroNominal;
	//storage for state dot values
	VARIABLE_t m_avStateDot[stateTotal];
	//storage for derivatives and intercepts
	V_STATE m_vvalsDerivatives;
	V_STATE m_vvalsIntercepts;
	CONTAINER_OUTPUT_t m_vdIntercepts;

	BOOL m_bDATCOMSubtractBaseTables;
	BOOL m_bFilesLoaded;
	string m_strParameterFile;
	string m_strDataFile;
};


// START:: VehicleDynamics.cpp
#include <math.h>
#include <iostream>	//cerr
#include <ostream>	//endl
#include <fstream>	//ifstream
#include <sstream>	//stringstream
#include <limits>

/////////////////////////////////////////////////////////////////////////////////////////
////// Initialize()
////////////////////////////////////////////////////////////////////////////////////////
template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
BOOL CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>::
	bInitialize(stringstream& sstrErrorMessage)
{
	BOOL bReturn = TRUE;

	// outputs
	ResetOutputs();

	// DATCOM and Parameter files
	if(!bGetFilesLoaded())
	{
		bGetFilesLoaded() = bReturn = bReadFiles(sstrErrorMessage,strGetParameterFile(),strGetDataFile());
	}

	return(bReturn);
}

/////////////////////////////////////////////////////////////////////////////////////////
////// DefaultState()
////////////////////////////////////////////////////////////////////////////////////////
template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
void CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>::
	DefaultState(VARIABLE_t* avState)
{
	// states
	avState[stateU_FeetPerSec] = DEFAULT_STATE_U_FEETPERSEC;
	avState[stateV_FeetPerSec] = DEFAULT_STATE_V_FEETPERSEC;
	avState[stateW_FeetPerSec] = DEFAULT_STATE_W_FEETPERSEC;
	avState[stateP_RadPerSec] = DEFAULT_STATE_P_RADPERSEC;
	avState[stateQ_RadPerSec] = DEFAULT_STATE_Q_RADPERSEC;
	avState[stateR_RadPerSec] = DEFAULT_STATE_R_RADPERSEC;
	avState[statePhi_Rad] = DEFAULT_STATE_PHI_RAD;
	avState[stateTheta_Rad] = DEFAULT_STATE_THETA_RAD;
	avState[statePsi_Rad] = DEFAULT_STATE_PSI_RAD;
	avState[stateX_Feet] = DEFAULT_STATE_X_FEET;
	avState[stateY_Feet] = DEFAULT_STATE_Y_FEET;
	avState[stateZ_Feet] = -DEFAULT_STATE_ALTITUDE_FEET;
}

/////////////////////////////////////////////////////////////////////////////////////////
////// CalculateXDot(const VARIABLE_t* avState,VARIABLE_t* avStateDot)
////////////////////////////////////////////////////////////////////////////////////////
template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
void CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>::
	CalculateXDot(VARIABLE_t* avState,VARIABLE_t* avStateDot,BOOL bUpdateOutputZeroInputs)
{

	/////////////////////////////////////////////////////////////////////////
	// calculate sine and cosines of eurler angles needed in this function
	/////////////////////////////////////////////////////////////////////////
	VARIABLE_t dSinPhi = sin(avState[statePhi_Rad]);
	VARIABLE_t dCosPhi = cos(avState[statePhi_Rad]);
	VARIABLE_t dSinTheta = sin(avState[stateTheta_Rad]);
	VARIABLE_t dCosTheta = cos(avState[stateTheta_Rad]);
	VARIABLE_t dSinPsi = sin(avState[statePsi_Rad]);
	VARIABLE_t dCosPsi = cos(avState[statePsi_Rad]);

	/////////////////////////////////////////////////////////////////////////
	//% Compute airspeed, AOA, sideslip, flight-path angle
	/////////////////////////////////////////////////////////////////////////
	VARIABLE_t dVt = pow((pow(avState[stateU_FeetPerSec],2) + pow(avState[stateV_FeetPerSec],2) + pow(avState[stateW_FeetPerSec],2)),0.5);
	if(dVt == 0)
	{
		//this is an error condition, return zeros
		for(int iCountStates=0;iCountStates<stateTotal;iCountStates++)
		{
			avStateDot[iCountStates] = 0.0;
		}
		return;
	}
	VARIABLE_t dAlpha = atan2(avState[stateW_FeetPerSec],avState[stateU_FeetPerSec]);
	VARIABLE_t dBeta = asin(avState[stateV_FeetPerSec]/dVt);

	/////////////////////////////////////////////////////////////////////////
	// Atmosphere
	/////////////////////////////////////////////////////////////////////////
	//% Speed of sound calculation 
	/////////////////////////////////////////////////////////////////////////
	//TODO:: need to use mike's equations for atmosphere here
	/////////////////////////////////////////////////////////////////////////
	VARIABLE_t dTemperatureFactor = 1.0 - 0.703e-5 * (-avState[stateZ_Feet]);
	// Temperature in the isotherm
	VARIABLE_t dTemperature = 519.0*dTemperatureFactor;
	// Temperature at thermopause
	if(avState[stateZ_Feet] <= -35000.0)
	{
		dTemperature=390.0;
	}
	// Density at altitude
	VARIABLE_t dRho = CONST_DENSITY_SEA_LEVEL*pow(dTemperatureFactor,4.14);
	//Speed of sound
	VARIABLE_t dSpeedOfSoundFeetPerSec = sqrt(1.4*1716.3*dTemperature);
	// Mach number
	VARIABLE_t dMach=(dSpeedOfSoundFeetPerSec==0.0)?(0.0):(dVt/dSpeedOfSoundFeetPerSec);
	// Dynamic Pressure
	VARIABLE_t dQBar = 0.5*dRho*dVt*dVt;
	// Static Pressure 
	VARIABLE_t dStaticPressure = 1715.0*dRho*dTemperature;

	if(bUpdateOutputZeroInputs)
	{
		vdGetOutputs()[outputVt_ftpersec] = dVt;
		vdGetOutputs()[outputAlpha_rad] = dAlpha;
		vdGetOutputs()[outputBeta_rad] = dBeta;
		vdGetOutputs()[outputMach] = dMach;
		vdGetOutputs()[outputAltitude_ft] = -avState[stateZ_Feet];
	}
	/////////////////////////////////////////////////////////////////////////////////
	// Look up nominal and incremental forces and moments and dynamic derivatives
	////////////////////////////////////////////////////////////////////////////////
	stGetAeroIndependentVariables()[aeroindAlpha_deg] = dAlpha*_RAD_TO_DEG;
	stGetAeroIndependentVariables()[aeroindMach] = dMach;
	stGetAeroIndependentVariables()[aeroindAltitude_ft] = -avState[stateZ_Feet];
	stGetAeroIndependentVariables()[aeroindBeta_deg] = dBeta*_RAD_TO_DEG;

	//This is where deflections are used for table lookups
	for(size_t szCountInputs=fmExternalInputsStart,szCountVariables=aeroindDeltaFirst;
											szCountInputs<iGetNumberInputs();szCountInputs++,szCountVariables++)
	{
			stGetAeroIndependentVariables()[szCountVariables] = (bUpdateOutputZeroInputs)?(0.0):(dGetInput(szCountInputs));
	}
	// call to look-up table
	datcomGetTable().Interpolate(stGetAeroIndependentVariables(),stGetAeroDeltaIncrement(),
															stGetAeroDynamicDerivative(),stGetAeroNominal());
	//This is where deflections are used for table lookups
	if(bUpdateOutputZeroInputs)
	{
		for(size_t szCountInputs=fmExternalInputsStart,szCountVariables=aeroindDeltaFirst;
												szCountInputs<iGetNumberInputs();szCountInputs++,szCountVariables++)
		{
				stGetAeroIndependentVariables()[szCountVariables] = dGetInput(szCountInputs);
		}
		datcomGetTable().CalculateDerivatives(stGetAeroIndependentVariables(),vvalsGetDerivatives(),vvalsGetIntercepts());
	}

	//% Scale values for dynamic derivatives
	VARIABLE_t dLatitudinalScale = 0.5*valdGeParameters()[paramb_Span]/dVt; 
	VARIABLE_t dLongitudinalScale = 0.5*valdGeParameters()[paramc_Cord]/dVt;
	VARIABLE_t dPScale = avState[stateP_RadPerSec]*dLatitudinalScale; 
	VARIABLE_t dQScale = avState[stateQ_RadPerSec]*dLongitudinalScale; 
	VARIABLE_t dRScale = avState[stateR_RadPerSec]*dLatitudinalScale;
 
	//% % Scaling the dynamic derivative coefficients
	VARIABLE_t dCNQ_scale = stGetAeroDynamicDerivative()[dampCNQ_NormalForceDueToQ]*dQScale;
	VARIABLE_t dCMQ_scale = stGetAeroDynamicDerivative()[dampCMQ_PitchMomentDueToQ]*dQScale;
	VARIABLE_t dCAQ_scale = stGetAeroDynamicDerivative()[dampCAQ_AxialForceDueToQ]*dQScale;
	VARIABLE_t dCYR_scale = stGetAeroDynamicDerivative()[dampCYR_SideForceDueToR]*dRScale;
	VARIABLE_t dClnR_scale = stGetAeroDynamicDerivative()[dampClnR_YawMomentDueToR]*dRScale;
	VARIABLE_t dCllR_scale = stGetAeroDynamicDerivative()[dampCllR_RollMomentDueToR]*dRScale;
	VARIABLE_t dCYP_scale = stGetAeroDynamicDerivative()[dampCYP_SideForceDueToP]*dPScale;
	VARIABLE_t dClnP_scale = stGetAeroDynamicDerivative()[dampClnP_YawMomentDueToP]*dPScale;
	VARIABLE_t dCllP_scale = stGetAeroDynamicDerivative()[dampCllP_RollMomentDueToR]*dPScale;

	//% Fluid dynamics calculations
	VARIABLE_t dQbar = 0.5*dRho*dVt*dVt; 
	VARIABLE_t dQbarSref = dQbar*valdGeParameters()[paramS_WingArea];
	VARIABLE_t dQbarSrefbref = dQbarSref*valdGeParameters()[paramb_Span]; 
	VARIABLE_t dQbarSrefcbar = dQbarSref*valdGeParameters()[paramc_Cord];

	//dimensionalize derivatives	NOTE:: only doing moments at this time!!!!!
	if(bUpdateOutputZeroInputs)
	{
		for(V_STATE_IT itDerivative=vvalsGetDerivatives().begin(), itIntercept=vvalsGetIntercepts().begin();
						itDerivative!=vvalsGetDerivatives().end();itDerivative++,itIntercept++)
		{
			(*itDerivative)[fmCM_PitchMoment] *= dQbarSrefcbar;
			(*itIntercept)[fmCM_PitchMoment] *= dQbarSrefcbar;
			(*itDerivative)[fmCln_YawMoment] *= dQbarSrefbref;
			(*itIntercept)[fmCln_YawMoment] *= dQbarSrefbref;
			(*itDerivative)[fmCll_RollMoment] *= dQbarSrefbref;
			(*itIntercept)[fmCll_RollMoment] *= dQbarSrefbref;
		}
	}

	//% combine base, increment and dynamic derivative contributions to forces and moments
	VARIABLE_t dCA_Total = stGetAeroNominal()[fmCA_AxialForce] + stGetAeroDeltaIncrement()[fmCA_AxialForce] + dCAQ_scale;
	VARIABLE_t dCY_Total = stGetAeroNominal()[fmCY_SideForce] + stGetAeroDeltaIncrement()[fmCY_SideForce] + dCYP_scale + dCYR_scale;
	VARIABLE_t dCN_Total = stGetAeroNominal()[fmCN_NormalForce] + stGetAeroDeltaIncrement()[fmCN_NormalForce] + dCNQ_scale;

	VARIABLE_t dCll_BaseTotal = stGetAeroNominal()[fmCll_RollMoment] + dCllR_scale + dCllP_scale;
	VARIABLE_t dCm_BaseTotal = stGetAeroNominal()[fmCM_PitchMoment] + dCMQ_scale;
	VARIABLE_t dCn_BaseTotal = stGetAeroNominal()[fmCln_YawMoment] + dClnR_scale + dClnP_scale;

	VARIABLE_t dCll_Total= stGetAeroNominal()[fmCll_RollMoment] + stGetAeroDeltaIncrement()[fmCll_RollMoment] + dCllR_scale + dCllP_scale;
	VARIABLE_t dCm_Total= stGetAeroNominal()[fmCM_PitchMoment] + stGetAeroDeltaIncrement()[fmCM_PitchMoment] + dCMQ_scale;
	VARIABLE_t dCn_Total= stGetAeroNominal()[fmCln_YawMoment] + stGetAeroDeltaIncrement()[fmCln_YawMoment] + dClnR_scale + dClnP_scale;

	// dimensionalize forces and moments
	VARIABLE_t dL_BaseTotal = dQbarSrefbref*dCll_BaseTotal + dGetInput(fmCll_RollMoment);
	VARIABLE_t dM_BaseTotal = dQbarSrefcbar*dCm_BaseTotal + dGetInput(fmCM_PitchMoment);
	VARIABLE_t dN_BaseTotal = dQbarSrefbref*dCn_BaseTotal + dGetInput(fmCln_YawMoment); 

	VARIABLE_t dL_DeltaTotal = dQbarSrefbref*stGetAeroDeltaIncrement()[fmCll_RollMoment];
	VARIABLE_t dM_DeltaTotal = dQbarSrefcbar*stGetAeroDeltaIncrement()[fmCM_PitchMoment];
	VARIABLE_t dN_DeltaTotal = dQbarSrefbref*stGetAeroDeltaIncrement()[fmCln_YawMoment]; 

	VARIABLE_t dX_Total = -dQbarSref*dCA_Total + dGetInput(fmCA_AxialForce);
	VARIABLE_t dY_Total = dQbarSref*dCY_Total + dGetInput(fmCY_SideForce);
	VARIABLE_t dZ_Total = -dQbarSref*dCN_Total + dGetInput(fmCN_NormalForce);


	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//% Equations of motion     
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	//% Etkin equation (5.2,9), pp. 126
	// Euler angle accelerations
	avStateDot[statePhi_Rad] = avState[stateP_RadPerSec] + 
										dSinPhi*tan(avState[stateTheta_Rad])*avState[stateQ_RadPerSec] + 
										dCosPhi*tan(avState[stateTheta_Rad])*avState[stateR_RadPerSec];
	avStateDot[stateTheta_Rad] = dCosPhi*avState[stateQ_RadPerSec] - dSinPhi*avState[stateR_RadPerSec]; 
	avStateDot[statePsi_Rad] =  dSinPhi/cos(avState[stateTheta_Rad])*avState[stateQ_RadPerSec] + 
										dCosPhi/cos(avState[stateTheta_Rad])*avState[stateR_RadPerSec];  

	// linear accelerations
	//% derived from Etkin equation (5.8,2), pp. 149
	VARIABLE_t dMass = valdGeParameters()[paramWeight]/CONST_GravityAccelerationLbsPerSec2;
	avStateDot[stateU_FeetPerSec] = avState[stateR_RadPerSec]*avState[stateV_FeetPerSec] - avState[stateQ_RadPerSec]*avState[stateW_FeetPerSec] + 
																			dX_Total/dMass - CONST_GravityAccelerationLbsPerSec2*dSinTheta; 
	avStateDot[stateV_FeetPerSec] = -avState[stateR_RadPerSec]*avState[stateU_FeetPerSec] + avState[stateP_RadPerSec]*avState[stateW_FeetPerSec] + 
																			dY_Total/dMass + CONST_GravityAccelerationLbsPerSec2*dCosTheta*dSinPhi; 
	avStateDot[stateW_FeetPerSec] = avState[stateQ_RadPerSec]*avState[stateU_FeetPerSec] - avState[stateP_RadPerSec]*avState[stateV_FeetPerSec] + 
																			dZ_Total/dMass + CONST_GravityAccelerationLbsPerSec2*dCosTheta*dCosPhi;

	// angular accelerations
	//% derived from Etkin equation (5.8,3), pp. 149
	VARIABLE_t dIPdotTemp = (-valdGeParameters()[paramIzx]*avState[stateP_RadPerSec]*avState[stateQ_RadPerSec] - 
											(valdGeParameters()[paramIyy] - valdGeParameters()[paramIzz])*avState[stateQ_RadPerSec]*avState[stateR_RadPerSec]);
	VARIABLE_t dIQdotTemp = (-valdGeParameters()[paramIzx]*(pow(avState[stateR_RadPerSec],2) - pow(avState[stateP_RadPerSec],2)) - 
											(valdGeParameters()[paramIzz] - valdGeParameters()[paramIxx])*avState[stateR_RadPerSec]*avState[stateP_RadPerSec]);
	VARIABLE_t dIRdotTemp = (valdGeParameters()[paramIzx]*avState[stateQ_RadPerSec]*avState[stateR_RadPerSec] - 
											(valdGeParameters()[paramIxx] - valdGeParameters()[paramIyy])*avState[stateP_RadPerSec]*avState[stateQ_RadPerSec]);
	// inertial parameters
	VARIABLE_t dDeterminant = valdGeParameters()[paramIxx]*valdGeParameters()[paramIyy]*valdGeParameters()[paramIzz] - 
														valdGeParameters()[paramIyy]*pow(valdGeParameters()[paramIzx],2);
	VARIABLE_t dIxxIyy = valdGeParameters()[paramIxx]*valdGeParameters()[paramIyy];
	VARIABLE_t dIyyIzz = valdGeParameters()[paramIyy]*valdGeParameters()[paramIzz];
	VARIABLE_t dIyyIzx = valdGeParameters()[paramIyy]*valdGeParameters()[paramIzx];
	VARIABLE_t dIxxIzzMIzx_2 = valdGeParameters()[paramIxx]*valdGeParameters()[paramIzz] - pow(valdGeParameters()[paramIzx],2);

	// base angular accelerations
	VARIABLE_t dIPdotBase = dL_BaseTotal - dIPdotTemp;
	VARIABLE_t dIQdotBase = dM_BaseTotal - dIQdotTemp;
	VARIABLE_t dIRdotBase = dN_BaseTotal - dIRdotTemp;

	VARIABLE_t dPdotBase = (dIyyIzz*dIPdotBase + dIyyIzx*dIRdotBase)/dDeterminant;
	VARIABLE_t dQdotBase = (dIxxIzzMIzx_2*dIQdotBase)/dDeterminant;
	VARIABLE_t dRdotBase = (dIyyIzx*dIPdotBase + dIxxIyy*dIRdotBase)/dDeterminant;

	if(bUpdateOutputZeroInputs)
	{
		// f(w,P) for dynamic inversion
		vdGetOutputs()[outputPdotNeutral_radpersec2] = dPdotBase;
		vdGetOutputs()[outputQdotNeutral_radpersec2] = dQdotBase;
		vdGetOutputs()[outputRdotNeutral_radpersec2] = dRdotBase;

		// epsilon for dynamic inversion
		VARIABLE_t dInterceptIP = 0.0;
		VARIABLE_t dInterceptIQ = 0.0;
		VARIABLE_t dInterceptIR = 0.0;
		for(V_STATE_IT itDelta=vvalsGetIntercepts().begin();itDelta!=vvalsGetIntercepts().end();itDelta++)
		{
			dInterceptIP += (*itDelta)[fmCll_RollMoment];
			dInterceptIQ += (*itDelta)[fmCM_PitchMoment];
			dInterceptIR += (*itDelta)[fmCln_YawMoment];
		};

		vdGetIntercepts()[rotP] = (dIyyIzz*dInterceptIP + dIyyIzx*dInterceptIR)/dDeterminant;
		vdGetIntercepts()[rotQ] = (dIxxIzzMIzx_2*dInterceptIQ)/dDeterminant;
		vdGetIntercepts()[rotR] = (dIyyIzx*dInterceptIP + dIxxIyy*dInterceptIR)/dDeterminant;
	}
	// delta angular accelerations
	VARIABLE_t dIPdotDelta = dL_DeltaTotal;
	VARIABLE_t dIQdotDelta = dM_DeltaTotal;
	VARIABLE_t dIRdotDelta = dN_DeltaTotal;

	VARIABLE_t dPdotDelta = (dIyyIzz*dIPdotDelta + dIyyIzx*dIRdotDelta)/dDeterminant;
	VARIABLE_t dQdotDelta = (dIxxIzzMIzx_2*dIQdotDelta)/dDeterminant;
	VARIABLE_t dRdotDelta = (dIyyIzx*dIPdotDelta + dIxxIyy*dIRdotDelta)/dDeterminant;

	// total angular accelerations
	avStateDot[stateP_RadPerSec] = dPdotBase + dPdotDelta;
	avStateDot[stateQ_RadPerSec] = dQdotBase + dQdotDelta;
	avStateDot[stateR_RadPerSec] = dRdotBase + dRdotDelta;

	// accelerations w.r.t. the earth
	//% derived from Etkin equation (5.8,7), pp. 150
	avStateDot[stateX_Feet] = dCosTheta*dCosPsi*avState[stateU_FeetPerSec] + 
								(dSinPhi*dSinTheta*dCosPsi - dCosPhi*dSinPsi)*avState[stateV_FeetPerSec] + 
								(dCosPhi*dSinTheta*dCosPsi + dSinPhi*dSinPsi)*avState[stateW_FeetPerSec]; 
	avStateDot[stateY_Feet] = dCosTheta*dSinPsi*avState[stateU_FeetPerSec] + 
								(dSinPhi*dSinTheta*dSinPsi + dCosPhi*dCosPsi)*avState[stateV_FeetPerSec] + 
								(dCosPhi*dSinTheta*dSinPsi - dSinPhi*dCosPsi)*avState[stateW_FeetPerSec]; 
	avStateDot[stateZ_Feet] = -dSinTheta*avState[stateU_FeetPerSec] + 
								dSinPhi*dCosTheta*avState[stateV_FeetPerSec] + 
								dCosPhi*dCosTheta*avState[stateW_FeetPerSec]; 
	
	if(bUpdateOutputZeroInputs)
	{
		vdGetOutputs()[outputVelocityX_feetpersec] = avStateDot[stateX_Feet];
		vdGetOutputs()[outputVelocityY_feetpersec] = avStateDot[stateY_Feet];
		vdGetOutputs()[outputVelocityZ_feetpersec] = avStateDot[stateZ_Feet];
		VARIABLE_t vVelocityXY = pow((pow(avStateDot[stateX_Feet],2) + pow(avStateDot[stateY_Feet],2)),0.5);
		vdGetOutputs()[outputFlightPathAngle_rad] = (vVelocityXY!=0.0)?(asin(-avStateDot[stateZ_Feet]/vVelocityXY)):(_PI);
	}
}


/////////////////////////////////////////////////////////////////////////////////////////
////// bReadFiles(stringstream& sstreamErrors,string strDATCOM,string strParameters)
////////////////////////////////////////////////////////////////////////////////////////
template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
BOOL CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>::
	bReadFiles(stringstream& sstreamErrors,string strParameters,string strDATCOM)
{
	BOOL bReturn = TRUE;

	if(datcomGetTable().bReadDataFile(strDATCOM.c_str(),bGetDATCOMSubtractBaseTables()))
	{
		// resize storage for the DATCOM table variables
		// independent variable are: alpha,Mach,Altitude,beta, delta1,delta2,delta3,...

		size_t szNumberDeltas = datcomGetTable().iGetSizeIndVariables() - aeroindTotalRequired;
		vstrGetLabelsInput().clear();
		for(int iCountDeltas=0;iCountDeltas<szNumberDeltas;iCountDeltas++)
		{
			stringstream sstrTemp;
			sstrTemp << "aeroindDelta" << iCountDeltas;
			vstrGetLabelsInput().push_back(sstrTemp.str());
		}
		vstrGetLabelsInput().push_back(string("fmCN_NormalForce"));
		vstrGetLabelsInput().push_back(string("fmCM_PitchMoment"));
		vstrGetLabelsInput().push_back(string("fmCA_AxialForce"));
		vstrGetLabelsInput().push_back(string("fmCY_SideForce"));
		vstrGetLabelsInput().push_back(string("fmCln_YawMoment"));
		vstrGetLabelsInput().push_back(string("fmCll_RollMoment"));
		ResizeInputs(vstrGetLabelsInput().size());

		stGetAeroIndependentVariables().resize(datcomGetTable().iGetSizeIndVariables(),0.0);
		stGetAeroDeltaIncrement().resize(datcomGetTable().iGetSizeDepVariables(),0.0);
		stGetAeroDynamicDerivative().resize(datcomGetTable().iGetSizeDepVariablesDerivative(),0.0);
		stGetAeroNominal().resize(datcomGetTable().iGetSizeDepVariables(),0.0);

		STATE_t sTemp(0.0,datcomGetTable().iGetSizeDepVariables());
		vvalsGetDerivatives().resize(datcomGetTable().iGetSizeIndVariables(),sTemp);
		vvalsGetIntercepts().resize(datcomGetTable().iGetSizeIndVariables(),sTemp);

		char caTemp[MAX_LENGTH_LINE];
		BOOL bGoodVersion = TRUE;
		ifstream ifstrFile(strParameters.c_str());
		if(ifstrFile.is_open())
		{
			valdGeParameters().clear();
			BOOL bFoundVersion = FALSE;
			int iNumberParameters = 0;
			while(ifstrFile.peek() != EOF)
			{
				ifstrFile.getline(caTemp,MAX_LENGTH_LINE);
				istringstream istrInputLine(caTemp);
				if((istrInputLine.peek() != EOF)&&(istrInputLine.peek() != '#'))
				{
					VARIABLE_t dTemp;
					istrInputLine >> dTemp;
					if(!bFoundVersion)
					{
						bFoundVersion = TRUE;
						if(dTemp != PARAMETER_FILE_VERSION)
						{
							char caVersionRequired[32];
							sprintf(caVersionRequired,"%d",PARAMETER_FILE_VERSION);
							char caVersionObtained[32];
							sprintf(caVersionObtained,"%d",dTemp);
							sstreamErrors << "Error:CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>::bReadFiles: Wrong parameter file version, this files version: "
									<< caVersionObtained << ", should be " << caVersionRequired << endl;
							bReturn = FALSE;
							bGoodVersion = FALSE;
							break;
						}
					}
					else	//if(!bFoundVersion)
					{
						iNumberParameters++;
						valdGeParameters().resize(iNumberParameters,dTemp);
					}	//if(!bFoundVersion)
				}	//if((istrInputLine.peek() != EOF)&&(istrInputLine.peek() != '#'))
			}	//while((*pifstrFile).peek() != EOF)
			ifstrFile.close();
			if(bGoodVersion && (valdGeParameters().size() != paramTotal))
			{
				sstreamErrors << "Error:CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>::bReadFiles: Wrong number of parameters read in from file: "
							<< strParameters.c_str() << ", :" << 
							valdGeParameters().size() <<", should be " << paramTotal << endl;
				bReturn = FALSE;
			}
		}
		else	//if(ifstrFile.is_open())
		{
			sstreamErrors << "Error:CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>::bReadFiles: Error encountered while openeing parameter file: "
						<< strParameters.c_str() << endl;
			bReturn = FALSE;
		}
	}	//if(datcomGetTable().bReadDataFile(strDATCOM.c_str()))
	else
	{
		sstreamErrors << "Error:CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>::bReadFiles: Error encountered while reading DATCOMFILE: "
					<< strDATCOM.c_str()<< endl;
		bReturn = FALSE;
	}
	return(bReturn);
}

//////////////////////////////////////////////////////////////////////
////// dummy instance (necessary for compiling with MSVC++)
//////////////////////////////////////////////////////////////////////
//CVehicleDynamics<VAL_DOUBLE_t,V_PDOUBLE_t,V_DOUBLE_t,double> CVEHICLEDYNAMICS_DUMMY_NEED_TO_FORCE_COMPILER_TO_RECOGNIZE_THIS_CLASS;

#endif // !defined(AFX_VEHICLEDYNAMICS_H__7BD4EF7A_D715_45BE_8A2A_560E342FDB90__INCLUDED_)
