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
// PIDController.h: interface for the CPIDController class.
//
// this function implements a PID Controller
//
///////////////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_PIDCONTROLLER_H__0974B701_07D4_49CA_8B9D_B4F0679DEC94__INCLUDED_)
#define AFX_PIDCONTROLLER_H__0974B701_07D4_49CA_8B9D_B4F0679DEC94__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Dynamic.h"
#include "InputOutput.h"


template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
class CPIDController :
	public CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>   
{
public:
	CPIDController(VARIABLE_t dGainK,VARIABLE_t dGainTi,VARIABLE_t dGainTd,VARIABLE_t dGainTt,
					VARIABLE_t dLimitUpper,VARIABLE_t dLimitLower, string strLabel="",
					VARIABLE_t dSetPointWeighting=1.0,VARIABLE_t dFactorN=2.0)
	{
		dGetGainK() = dGainK;
		dGetGainTi() = dGainTi;
		dGetGainTd() = dGainTd;
		dGetGainTt() = dGainTt;
		dGetFactorN() = dFactorN;	//??
		dGetSetPointWeighting() = dSetPointWeighting;
		dGetDerivativeLast() = 0.0;	//??
		dGetFeedbackLast() = 0.0;	//??
		dGetIntegralLast() = 0.0;	//??
		dGetLimitUpper() = dLimitUpper;
		dGetLimitLower() = dLimitLower;

		// input labels
		vstrGetLabelsInput().clear();
		stringstream sstrTemp1;
		sstrTemp1 << "inPID" << strLabel << "Command";
		vstrGetLabelsInput().push_back(sstrTemp1.str());
		stringstream sstrTemp2;
		sstrTemp2 << "inPID" << strLabel << "Feedback";
		vstrGetLabelsInput().push_back(sstrTemp2.str());

		// output labels
		vstrGetLabelsOutput().clear();
		stringstream sstrTemp3;
		sstrTemp3 << "outPID" << strLabel << "Output";
		vstrGetLabelsOutput().push_back(sstrTemp3.str());

		// state labels
		vstrGetLabelsState().clear();
		// no states

		// resize input, outputs, and states
		ResizeInputs(vstrGetLabelsInput().size());
		vdGetOutputs().resize(vstrGetLabelsOutput().size(),0.0);
		szGetXSize() = vstrGetLabelsState().size();

		
	}


	virtual ~CPIDController()
	{
	};

public:
	enum enInputs
	{
		inCommand,
		inFeedback,
		inTotal
	};
	enum enOutputs
	{
		outOutput,
		outTotal
	};
public:
	// virtual overrides
	virtual void CalculateXdot(VARIABLE_t* avState, const VARIABLE_t vDeltaTime, VARIABLE_t* avStateDot,BOOL bUpdateOutputs=TRUE)
	{
	};

	virtual void UpdateOutputs(VARIABLE_t* avState, const VARIABLE_t& vDeltaTime,BOOL bIntermediateStep=FALSE)
	{
		VARIABLE_t dProportional = dGetGainK()*((dGetSetPointWeighting()*dGetInput(inCommand)) - dGetInput(inFeedback));

		VARIABLE_t dDerivative = dGetGainTd()/(dGetGainTd() + dGetFactorN()*vDeltaTime)*(dGetDerivativeLast() - 
										(dGetGainK()*dGetFactorN())*(dGetInput(inFeedback) - dGetFeedbackLast()));

		VARIABLE_t dControllerOutputV = dProportional + dGetIntegralLast() + dDerivative;
		vdGetOutputs()[outOutput] = dRAS_Limit(dControllerOutputV,dGetLimitUpper(),dGetLimitLower());

		VARIABLE_t dIntegral = dGetIntegralLast() + 
								((dGetGainK()*vDeltaTime)/dGetGainTi())*(dGetInput(inCommand) - dGetInput(inFeedback)) +
								((dGetGainK()*vDeltaTime)/dGetGainTt())*(vdGetOutputs()[outOutput] - dControllerOutputV);

		dGetDerivativeLast() = dDerivative;
		dGetFeedbackLast() = dGetInput(inFeedback);
		dGetIntegralLast() = dIntegral;
	};

	virtual BOOL bInitialize(stringstream& sstrErrorMessage)
	{
		ResetOutputs();
		return(TRUE);	//TODO!!
	};
	virtual void DefaultState(VARIABLE_t* avState)
	{
	};

public:

	VARIABLE_t& dGetGainK(){return(m_dGainK);};
	const VARIABLE_t& dGetGainK() const {return(m_dGainK);};

	VARIABLE_t& dGetGainTi(){return(m_dGainTi);};
	const VARIABLE_t& dGetGainTi() const {return(m_dGainTi);};

	VARIABLE_t& dGetGainTd(){return(m_dGainTd);};
	const VARIABLE_t& dGetGainTd() const {return(m_dGainTd);};

	VARIABLE_t& dGetGainTt(){return(m_dGainTt);};
	const VARIABLE_t& dGetGainTt() const {return(m_dGainTt);};

	VARIABLE_t& dGetFactorN(){return(m_dFactorN);};
	const VARIABLE_t& dGetFactorN() const {return(m_dFactorN);};

	VARIABLE_t& dGetSetPointWeighting(){return(m_dSetPointWeighting);};
	const VARIABLE_t& dGetSetPointWeighting() const {return(m_dSetPointWeighting);};

	VARIABLE_t& dGetDerivativeLast(){return(m_dDerivativeLast);};
	const VARIABLE_t& dGetDerivativeLast() const {return(m_dDerivativeLast);};

	VARIABLE_t& dGetFeedbackLast(){return(m_dFeedbackLast);};
	const VARIABLE_t& dGetFeedbackLast() const {return(m_dFeedbackLast);};

	VARIABLE_t& dGetIntegralLast(){return(m_dIntegralLast);};
	const VARIABLE_t& dGetIntegralLast() const {return(m_dIntegralLast);};

	VARIABLE_t& dGetLimitUpper(){return(m_dLimitUpper);};
	const VARIABLE_t& dGetLimitUpper() const {return(m_dLimitUpper);};

	VARIABLE_t& dGetLimitLower(){return(m_dLimitLower);};
	const VARIABLE_t& dGetLimitLower() const {return(m_dLimitLower);};
protected:
	// parameters
	VARIABLE_t m_dGainK;	//proportional gain
	VARIABLE_t m_dGainTi;	//integral time constant
	VARIABLE_t m_dGainTd;	//derivative time constant
	VARIABLE_t m_dGainTt;	//anti-windup time constant
	VARIABLE_t m_dFactorN;	//derivative gain????
	VARIABLE_t m_dSetPointWeighting;
	VARIABLE_t m_dDerivativeLast;
	VARIABLE_t m_dFeedbackLast;
	VARIABLE_t m_dIntegralLast;
	VARIABLE_t m_dLimitUpper;
	VARIABLE_t m_dLimitLower;

};

#endif // !defined(AFX_PIDCONTROLLER_H__0974B701_07D4_49CA_8B9D_B4F0679DEC94__INCLUDED_)
