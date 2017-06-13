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
// DynamicInversion.h: interface for the CDynamicInversion class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_DYNAMICINVERSION_H__E67B71A4_73D4_4D30_8D44_E48575EF5028__INCLUDED_)
#define AFX_DYNAMICINVERSION_H__E67B71A4_73D4_4D30_8D44_E48575EF5028__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <GlobalDefines.h>

#include "Dynamic.h"
#include "InputOutput.h"
#include "DATCOMTable.h"
#include "RasMatrix.h"

#include "VehicleDynamics.h"
#include "Actuator1stOrder.h"
#include "Euminxd.h"

template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
class CDynamicInversion :
	public CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> 
{
public:
	CDynamicInversion()
	{
		szGetNumberDeltas() = 0;
	};
	virtual ~CDynamicInversion()
	{
		m_pvehicleDynamics = 0;
	};

public:
	// virtual overrides
	virtual void CalculateXdot(VARIABLE_t* avState, const VARIABLE_t vDeltaTime, VARIABLE_t* avStateDot,BOOL bUpdateOutputs=TRUE){};
	virtual void UpdateOutputs(VARIABLE_t* avState, const VARIABLE_t& vDeltaTime,BOOL bIntermediateStep=FALSE)
	{
	if(!bIntermediateStep && (vDeltaTime>0.0)) //Deflections updated only on the full time-step
		{
			RetriveDerivativesIntercepts();
			MATRIX_VARIABLE_t matInput(axisTotal,1);
			// linear program can handle 4 control axes, another matInput would have to be added
			matInput(axisPdot,0) = dGetInput(inPdotDesired_radpersec2) - 
									dGetInput(inPdotNeutral_radpersec2) -
									vehicleGetDynamics().vdGetIntercepts()[axisPdot];

			matInput(axisQdot,0) = dGetInput(inQdotDesired_radpersec2) - 
									dGetInput(inQdotNeutral_radpersec2) - 
									vehicleGetDynamics().vdGetIntercepts()[axisQdot];

			matInput(axisRdot,0) = dGetInput(inRdotDesired_radpersec2) - 
									dGetInput(inRdotNeutral_radpersec2) - 
									vehicleGetDynamics().vdGetIntercepts()[axisRdot];

			MATRIX_VARIABLE_t matOutput(iGetNumberOutputs(),1);
			CalculateDeltaCommand(matInput,matGetDerivatives(),matOutput,ctlallcGetMethod(),vDeltaTime);
			for(size_t szCoutOutputs=0;szCoutOutputs<iGetNumberOutputs();szCoutOutputs++)
			{
				vdGetOutputs()[szCoutOutputs] = matOutput(szCoutOutputs,0);
			}
		}
	};
	virtual BOOL bInitialize(stringstream& sstrErrorMessage)
	{
		szGetNumberDeltas() = datcomGetTable().iGetSizeIndVariables() - enindeltaFirstControlEffector;
		// INPUTS
		switch(ctlallcGetMethod())
		{
		default:
		case ctlallcPsuedoInverse:
			// input labels
			vstrGetLabelsInput().clear();
			vstrGetLabelsInput().push_back(string("inPdotDesired_radpersec2"));
			vstrGetLabelsInput().push_back(string("inQdotDesired_radpersec2"));
			vstrGetLabelsInput().push_back(string("inRdotDesired_radpersec2"));
			vstrGetLabelsInput().push_back(string("inPdotNeutral_radpersec2"));
			vstrGetLabelsInput().push_back(string("inQdotNeutral_radpersec2"));
			vstrGetLabelsInput().push_back(string("inRdotNeutral_radpersec2"));
			break;
		case ctlallcControlAllocationLP:
			vstrGetLabelsInput().clear();
			vstrGetLabelsInput().push_back(string("inPdotDesired_radpersec2"));
			vstrGetLabelsInput().push_back(string("inQdotDesired_radpersec2"));
			vstrGetLabelsInput().push_back(string("inRdotDesired_radpersec2"));
			vstrGetLabelsInput().push_back(string("inPdotNeutral_radpersec2"));
			vstrGetLabelsInput().push_back(string("inQdotNeutral_radpersec2"));
			vstrGetLabelsInput().push_back(string("inRdotNeutral_radpersec2"));
			for(int iCountOutputs=0;iCountOutputs<szGetNumberDeltas();iCountOutputs++)
			{
				stringstream sstrTemp;
				sstrTemp << iCountOutputs;
				vstrGetLabelsInput().push_back(string("inActuatorPosition")+sstrTemp.str());
				vstrGetLabelsInput().push_back(string("inActuatorLimitUpper")+sstrTemp.str());
				vstrGetLabelsInput().push_back(string("inActuatorLimitLower")+sstrTemp.str());
				vstrGetLabelsInput().push_back(string("inActuatorLimitRate")+sstrTemp.str());
				vstrGetLabelsInput().push_back(string("inActuatorTimeConstant")+sstrTemp.str());
			}
			break;
		};
		// OUTPUTS
		// output labels
		vstrGetLabelsOutput().clear();
		for(int iCountOutputs=0;iCountOutputs<szGetNumberDeltas();iCountOutputs++)
		{
			stringstream sstrTemp;
			sstrTemp << "outDeltaCmd_deg" << iCountOutputs;
			vstrGetLabelsOutput().push_back(sstrTemp.str());
		}
		ResetOutputs();

		// state labels
		vstrGetLabelsState().clear();

		// resize input, outputs, and states
		ResizeInputs(vstrGetLabelsInput().size());
		vdGetOutputs().resize(vstrGetLabelsOutput().size(),0.0);
		szGetXSize() = vstrGetLabelsState().size();

		
		matGetDerivatives().Resize(axisTotal,iGetNumberOutputs());
		matGetIntercepts().Resize(axisTotal,iGetNumberOutputs());
		matGetAxisWeights().Resize(1,axisTotal);
		matGetSurfaceWeights().Resize(1,szGetNumberDeltas());
		matGetPreferredDeflections().Resize(1,szGetNumberDeltas());

		//Set default User-defined variables, can be over-ridden in VehicleSimulation
		// for scope hack for reprehensible MSVC++6
		int iCountCols;
		for(iCountCols=0;iCountCols<axisTotal;iCountCols++)
		{
			matGetAxisWeights()(0,iCountCols) = 1.0;
		}
		for(iCountCols=0;iCountCols<szGetNumberDeltas();iCountCols++)
		{
			matGetSurfaceWeights()(0,iCountCols) = 0.00001;
		}

		// For other than Pseudo Inverse preferred deflections,
		//		add defaults here and remove Pseudo outputs in control allocation function
		//matGetPreferredDeflections()(0,iCountCols) = 0.0;


		return(TRUE);
	};
	virtual void DefaultState(VARIABLE_t* avState){};

public:		//ENUMS AND TYPEDEFS

	enum enAxisDefinitions // If this changes, all other enumerations need to be examined
	{
		axisPdot,
		axisQdot,
		axisRdot,
		axisTotal,
	};

	enum enInputs 
	{
		inPdotDesired_radpersec2,
		inQdotDesired_radpersec2,
		inRdotDesired_radpersec2,
		inPdotNeutral_radpersec2,
		inQdotNeutral_radpersec2,
		inRdotNeutral_radpersec2,
		inTotal,
		inFirstActuatorEntry=inTotal // Used for actuator inputs to LP
	};

	enum enForceAndMoments	//TODO:: this must be coordinated with the copy in CVehicleDynamics
	{
		fmCN_NormalForce,
		fmCM_PitchMoment,
		fmCA_AxialForce,
		fmCY_SideForce,
		fmCln_YawMoment,
		fmCll_RollMoment,
		fmTotal
	};

	enum enInputDeltas 
	{	
		enindeltaAltitude = enindvarAltitude,	//from Interpolate.h
		enindeltaBeta,
		enindeltaFirstControlEffector
	};
		
	enum enControlAllocation 
	{	
		ctlallcPsuedoInverse,
		ctlallcControlAllocationLP,
		ctlallcTotal
	};
	
	typedef CRasMatrix<VARIABLE_t> MATRIX_VARIABLE_t;
	typedef valarray<VARIABLE_t> VAL_VARIABLE_t;
	typedef CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> CVEHICLE_DYNAMICS_t;
	typedef CActuator1stOrder<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> CACTUATOR_1ST_ORDER_t;
public:
	// accessors
	CDATCOMTable& datcomGetTable(){return(vehicleGetDynamics().datcomGetTable());};
	const CDATCOMTable& datcomGetTable() const {return(vehicleGetDynamics().datcomGetTable());};

	CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>& vehicleGetDynamics(){return(*m_pvehicleDynamics);};
	const CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>& vehicleGetDynamics() const {return(*m_pvehicleDynamics);};
	CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>*& pvehicleGetDynamic(){return(m_pvehicleDynamics);};

	MATRIX_VARIABLE_t& matGetDerivatives(){return(m_matDerivatives);};
	const MATRIX_VARIABLE_t& matGetDerivatives() const {return(m_matDerivatives);};

	MATRIX_VARIABLE_t& matGetIntercepts(){return(m_matIntercepts);};
	const MATRIX_VARIABLE_t& matGetIntercepts() const {return(m_matIntercepts);};

	MATRIX_VARIABLE_t& matGetAxisWeights(){return(m_matAxisWeights);};
	const MATRIX_VARIABLE_t& matGetAxisWeights() const {return(m_matAxisWeights);};

	MATRIX_VARIABLE_t& matGetSurfaceWeights(){return(m_matSurfaceWeights);};
	const MATRIX_VARIABLE_t& matGetSurfaceWeights() const {return(m_matSurfaceWeights);};

	MATRIX_VARIABLE_t& matGetPreferredDeflections(){return(m_matPreferredDeflections);};
	const MATRIX_VARIABLE_t& matGetPreferredDeflections() const {return(m_matPreferredDeflections);};

	enControlAllocation& ctlallcGetMethod(){return(m_ctlallcMethod);};
	const enControlAllocation& ctlallcGetMethod() const {return(m_ctlallcMethod);};

	size_t& szGetNumberDeltas(){return(m_szNumberDeltas);};
	const size_t& szGetNumberDeltas() const {return(m_szNumberDeltas);};
protected:
	// vehicle dynamics needed for table look-ups and state information
	CVehicleDynamics<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>* m_pvehicleDynamics;
	MATRIX_VARIABLE_t m_matDerivatives;
	MATRIX_VARIABLE_t m_matIntercepts;
	enControlAllocation m_ctlallcMethod;
	size_t m_szNumberDeltas;
	MATRIX_VARIABLE_t m_matAxisWeights;
	MATRIX_VARIABLE_t m_matSurfaceWeights;
	MATRIX_VARIABLE_t m_matPreferredDeflections;

protected:

	void CalculateDeltaCommand(MATRIX_VARIABLE_t& matInputs,MATRIX_VARIABLE_t& matDerivatives,
									MATRIX_VARIABLE_t& matOutputs,enControlAllocation ctlallcMethod,const VARIABLE_t& vDeltaTime)
	{
		switch(ctlallcMethod)
		{
		case ctlallcPsuedoInverse:
			CalculatePsuedoInverseAllocation(matInputs,matDerivatives,matOutputs,ctlallcMethod,vDeltaTime);
			break;
		case ctlallcControlAllocationLP:
			CalculateControlAllocationLP(matInputs,matDerivatives,matOutputs,ctlallcMethod,vDeltaTime);
			break;
		};
	};

	void CalculatePsuedoInverseAllocation(MATRIX_VARIABLE_t& matInputs,MATRIX_VARIABLE_t& matDerivatives,
											MATRIX_VARIABLE_t& matOutputs,enControlAllocation ctlallcMethod,const VARIABLE_t& vDeltaTime)
	{
		//Retrieve I-matrix elements and create I-matrix
		MATRIX_VARIABLE_t matI(3,3);
		matI(0,0) = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramIxx];
		matI(1,1) = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramIyy];
		matI(2,2) = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramIzz];
		matI(2,0) = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramIzx];
		matI(0,2) = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramIzx];

		//Create inverse I-matrix
		MATRIX_VARIABLE_t matInverseI(3,3);
		matInverseI.InvertMatrix3X3(matI);

		//Multiply G_delta matrix by the inverse I matrix, creates B matrix
		MATRIX_VARIABLE_t matDimB(axisTotal,iGetNumberOutputs());
		matDimB.Product(matInverseI,matDerivatives);

		//Pseudo-Inverse Control Allocation
		MATRIX_VARIABLE_t matTranspose(iGetNumberOutputs(),axisTotal);
		MATRIX_VARIABLE_t matPInverse1(axisTotal,axisTotal);
		MATRIX_VARIABLE_t matPInverse(axisTotal,axisTotal);
		matTranspose.Transpose(matDimB);
		matPInverse1.Product(matDimB,matTranspose);
		matPInverse.InvertMatrix3X3(matPInverse1);
		matPInverse1.Product(matTranspose,matPInverse);
		matOutputs.Product(matPInverse1,matInputs);
	}

	void CalculateControlAllocationLP(MATRIX_VARIABLE_t& matInputs,MATRIX_VARIABLE_t& matDerivatives,
											MATRIX_VARIABLE_t& matOutputs,enControlAllocation ctlallcMethod,const VARIABLE_t& vDeltaTime)
	{
		CEuminxd euxdSolve;

		//Retrieve I-matrix elements and create I-matrix
		MATRIX_VARIABLE_t matI(3,3);
		matI(0,0) = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramIxx];
		matI(1,1) = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramIyy];
		matI(2,2) = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramIzz];
		matI(2,0) = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramIzx];
		matI(0,2) = vehicleGetDynamics().valdGeParameters()[CVEHICLE_DYNAMICS_t::paramIzx];

		//Create inverse I-matrix
		MATRIX_VARIABLE_t matInverseI(3,3);
		matInverseI.InvertMatrix3X3(matI);

		//Multiply G_delta matrix by the inverse I matrix, creates B matrix
		MATRIX_VARIABLE_t matDimB(axisTotal,iGetNumberOutputs());
		matDimB.Product(matInverseI,matDerivatives);

		//Create inputs to linear solver
		//Create vector from B matrix for input into linear program solver
		MATRIX_VARIABLE_t vDimB(1,axisTotal*iGetNumberOutputs());
		int iCountCols; // for scope hack for putrid MSVC++6
		for(iCountCols=0;iCountCols<szGetNumberDeltas();iCountCols++)
		{
			for(int iCountRows=0;iCountRows<axisTotal;iCountRows++)
			{
				vDimB(0,iCountCols+(iCountRows*szGetNumberDeltas())) = matDimB(iCountRows,iCountCols);
			}
		}

		VARIABLE_t dTimeStep = vDeltaTime; /*Update Time (no intermediate steps)*/ 

		//actuator positions, deflection limits, and rate limits
		MATRIX_VARIABLE_t matActuatorLimitUpper(1,szGetNumberDeltas());
		MATRIX_VARIABLE_t matActuatorLimitLower(1,szGetNumberDeltas());
		MATRIX_VARIABLE_t matActuatorLimitRate(1,szGetNumberDeltas());
		MATRIX_VARIABLE_t matActuatorTimeConstant(1,szGetNumberDeltas());
		for(size_t szCountActuator=0;szCountActuator<szGetNumberDeltas();szCountActuator++)
		{
			//staggered arrangement from actuator block
			matOutputs(szCountActuator,0) = dGetInput(inFirstActuatorEntry+((szCountActuator*CACTUATOR_1ST_ORDER_t::actoutTotal)+CACTUATOR_1ST_ORDER_t::actoutPosition));
			matActuatorLimitUpper(0,szCountActuator) = dGetInput(inFirstActuatorEntry+((szCountActuator*CACTUATOR_1ST_ORDER_t::actoutTotal)+CACTUATOR_1ST_ORDER_t::actoutPositionLimitUpper));
			matActuatorLimitLower(0,szCountActuator) = dGetInput(inFirstActuatorEntry+((szCountActuator*CACTUATOR_1ST_ORDER_t::actoutTotal)+CACTUATOR_1ST_ORDER_t::actoutPositionLimitLower));
			matActuatorLimitRate(0,szCountActuator) = dGetInput(inFirstActuatorEntry+((szCountActuator*CACTUATOR_1ST_ORDER_t::actoutTotal)+CACTUATOR_1ST_ORDER_t::actoutPositionLimitRate));
			matActuatorTimeConstant(0,szCountActuator) = dGetInput(inFirstActuatorEntry+((szCountActuator*CACTUATOR_1ST_ORDER_t::actoutTotal)+CACTUATOR_1ST_ORDER_t::actoutActuatorTimeConstant));

			//account for actuator dynamics in control allocation
			matActuatorLimitRate(0,szCountActuator) = matActuatorLimitRate(0,szCountActuator)/(1.0-exp((-1.0/matActuatorTimeConstant(0,szCountActuator))*dTimeStep));
		}

		MATRIX_VARIABLE_t matActuatorPosition(1,szGetNumberDeltas());
		for(iCountCols=0;iCountCols<szGetNumberDeltas();iCountCols++)
		{
			matActuatorPosition(0,iCountCols)=matOutputs(iCountCols,0);
		}
		
		MATRIX_VARIABLE_t vUmin(1,szGetNumberDeltas());
		MATRIX_VARIABLE_t vUmax(1,szGetNumberDeltas());
		for(iCountCols=0;iCountCols<szGetNumberDeltas();iCountCols++)
		{
			vUmin(0,iCountCols) = max(matActuatorLimitLower(0,iCountCols), ((-matActuatorLimitRate(0,iCountCols)*dTimeStep)+matActuatorPosition(0,iCountCols)));
			vUmax(0,iCountCols) = min(matActuatorLimitUpper(0,iCountCols), ((matActuatorLimitRate(0,iCountCols)*dTimeStep)+matActuatorPosition(0,iCountCols)));
		}

		//Pseudo Inverse for preferred deflections
		MATRIX_VARIABLE_t matTranspose(iGetNumberOutputs(),axisTotal);
		MATRIX_VARIABLE_t matPInverse1(axisTotal,axisTotal);
		MATRIX_VARIABLE_t matPInverse(axisTotal,axisTotal);
		MATRIX_VARIABLE_t matPseudoOutputs(iGetNumberOutputs(),1);
		matTranspose.Transpose(matDimB);
		matPInverse1.Product(matDimB,matTranspose);
		matPInverse.InvertMatrix3X3(matPInverse1);
		matPInverse1.Product(matTranspose,matPInverse);
		matPseudoOutputs.Product(matPInverse1,matInputs);
		for(iCountCols=0;iCountCols<szGetNumberDeltas();iCountCols++)
		{
			matGetPreferredDeflections()(0,iCountCols) = matPseudoOutputs(iCountCols,0);
		}

		//Call euminxd linear solver
		MATRIX_VARIABLE_t matInputCommands(1,axisTotal);
		for(iCountCols=0;iCountCols<axisTotal;iCountCols++)
		{
			matInputCommands(0,iCountCols) = matInputs(iCountCols,0);
		}

		//Linear solver function
		CEuminxd::enErrors iCtlAllocError = euxdSolve.Euminxd(axisTotal, iGetNumberOutputs(), &vDimB(0,0), &matInputCommands(0,0), &matGetAxisWeights()(0,0), &matGetSurfaceWeights()(0,0), &vUmin(0,0), &vUmax(0,0), &matGetPreferredDeflections()(0,0), &matActuatorPosition(0,0));
		//{
			// Print out any error messages from linear solver
			/*	switch (iCtlAllocError)
				{
				case CEuminxd::errorNone: // No errors
					break;
				case CEuminxd::errorNGreaterNMax: // Maximum dimension exceeded
					mexPrintf("\n Number of Controlled Axes (N) is greater than NMAX in Euminxd.cpp\n");
					mexPrintf("\n Forcing N = %d in Euminxd.cpp\n");
					//sstrErrorMessage <<"\n Number of Controlled Axes (N) is greater than NMAX in Euminxd.cpp\nForcing N = " 
						<< CEuminxd::nmax << " in Euminxd.cpp\n" << ends;
					//mexErrMsgTxt(sstrErrorMessage.str().c_str());
					break;
				case CEuminxd::errorMGreaterMMax: // Maximum dimension exceeded
					mexPrintf("\n Number of Control Surfaces (M) is greater than MMAX in Euminxd.cpp\n");
					mexPrintf("\n Forcing M = MMAX in Euminxd.cpp\n");
					//sstrErrorMessage <<"\n Number of Control Surfaces (M) is greater than MMAX in Euminxd.cpp\nForcing M = " 
						<< CEuminxd::mmax << " in Euminxd.cpp\n" << ends;
					//mexErrMsgTxt(sstrErrorMessage.str().c_str());
					break;
				case CEuminxd::errorNFGreaterNFMax: // Maximum dimension exceeded
					mexPrintf("\n NF is greater than NFMAX in Euminxd.cpp\n");
					mexPrintf("\n Forcing NF = NFMAX in Euminxd.cpp\n");
					break;
				case CEuminxd::errorUMinGreaterUMax: // Umin exceeds umax in Euminxd.cpp
					mexPrintf("\n Umin exceeds Umax in Euminxd.cpp\n");
					mexPrintf("\n Values in Umin and Umax swapped so that Umax > Umin in Euminxd.cpp\n");
					break;
				case CEuminxd::errorFMinGreaterFMax: // Fmin exceeds fmax in Euminxd.cpp
					mexPrintf("\n Fmin exceeds Fmax in Euminxd.cpp\n");
					mexPrintf("\n Values in Fmin and Fmax swapped so that Fmax > Fmin in Euminxd.cpp\n");
					break;
				case CEuminxd::errorControlsClipped: // Preferred controls clipped to the limits. Do not satisfy constraints in Euminxd.cpp
					mexPrintf("\n Preferred controls clipped to the limits. Do not satisfy constraints in Euminxd.cpp\n");
					break;
				case CEuminxd::errorMaxIterationWarning: // Warning : Maximum number of iterations reached
					mexPrintf("\n Warning : Maximum number of iterations reached\n");
					break;
				default:
					mexPrintf("\n Unknown Error in Euminxd.cpp");
					break;
				} // End switch (iError_Num)
			} // End if (iError_Num > 0)*/
		//}

		//Sends linear solver outputs back out
		for(iCountCols=0;iCountCols<szGetNumberDeltas();iCountCols++)
		{
			matOutputs(iCountCols,0)=matActuatorPosition(0,iCountCols);
		}

	}

	void RetriveDerivativesIntercepts()
	{
		for(int iCountRows=enindeltaFirstControlEffector,iMatrixRows=0;iCountRows<datcomGetTable().iGetSizeIndVariables();iCountRows++,iMatrixRows++)
		{
			matGetDerivatives()(axisPdot,iMatrixRows) = vehicleGetDynamics().vvalsGetDerivatives()[iCountRows][fmCll_RollMoment];
			matGetDerivatives()(axisQdot,iMatrixRows) = vehicleGetDynamics().vvalsGetDerivatives()[iCountRows][fmCM_PitchMoment];
			matGetDerivatives()(axisRdot,iMatrixRows) = vehicleGetDynamics().vvalsGetDerivatives()[iCountRows][fmCln_YawMoment];
		}
	};

};

#endif // !defined(AFX_DYNAMICINVERSION_H__E67B71A4_73D4_4D30_8D44_E48575EF5028__INCLUDED_)
