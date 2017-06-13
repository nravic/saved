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
// Engine1stOrder.h: interface for the CEngine1stOrder class.
//
//
///////////////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_ENGINE1STORDER_H__0974B701_07D4_49CA_8B9D_B4F0679DEC94__INCLUDED_)
#define AFX_ENGINE1STORDER_H__0974B701_07D4_49CA_8B9D_B4F0679DEC94__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Dynamic.h"
#include "InputOutput.h"


namespace
{

	static const double dMaxThrust_lbs = 50.0;
	static const double dMinThrust_lbs = 5.0;
	static const double dTimeConstant_sec = 0.5;
	static const double dLimitUpperPowerdot_pctpersec = 1.0;
	static const double dLimitLowerPowerdot_pctpersec = -1.0;
}


template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
class CEngine1stOrder :
	public CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>   
{
public:
	CEngine1stOrder()
	{
		vGetTimeConstant() = dTimeConstant_sec;
		vGetMaxThrust() = dMaxThrust_lbs;
		vGetMinThrust() = dMinThrust_lbs;

		// input labels
		vstrGetLabelsInput().clear();
		vstrGetLabelsInput().push_back(string("inThrottleCmd_pct"));

		// output labels
		vstrGetLabelsOutput().clear();
		vstrGetLabelsOutput().push_back(string("outThrustX_lbs"));

		// state labels
		vstrGetLabelsState().clear();
		vstrGetLabelsState().push_back(string("statePowerLevel_pct"));

		// resize input, outputs, and states
		ResizeInputs(vstrGetLabelsInput().size());
		vdGetOutputs().resize(vstrGetLabelsOutput().size(),0.0);
		szGetXSize() = vstrGetLabelsState().size();
	}

	virtual ~CEngine1stOrder(){};

public:
	enum enInputs 
	{
		inThrottleCmd_pct,
		inputTotal 
	};
	enum enOutputs 
	{
		outThrustX_lbs,
		outputTotal 
	};
	enum StatesNames_t
	{
		statePowerLevel_pct,
		stateTotal
	};
public:
	// virtual overrides
	virtual void CalculateXdot(VARIABLE_t* avState, const VARIABLE_t vDeltaTime, VARIABLE_t* avStateDot,BOOL bUpdateOutputs=TRUE)
	{
		avStateDot[statePowerLevel_pct] =  (dGetInput(inThrottleCmd_pct) - avState[statePowerLevel_pct])/vGetTimeConstant();
		avStateDot[statePowerLevel_pct] =  dRAS_Limit(avStateDot[statePowerLevel_pct],dLimitUpperPowerdot_pctpersec,dLimitLowerPowerdot_pctpersec);
	};
	virtual void UpdateOutputs(VARIABLE_t* avState, const VARIABLE_t& vDeltaTime,BOOL bIntermediateStep=FALSE)
	{
		vdGetOutputs()[outThrustX_lbs] = vGetMaxThrust()*avState[statePowerLevel_pct];
		vdGetOutputs()[outThrustX_lbs] = dRAS_Limit(vdGetOutputs()[outThrustX_lbs],vGetMaxThrust(),vGetMinThrust());
	};
	virtual BOOL bInitialize(stringstream& sstrErrorMessage)
	{
		ResetOutputs();
		return(TRUE);	//TODO!!
	};
	virtual void DefaultState(VARIABLE_t* avState)
	{
		avState[statePowerLevel_pct] =  0.0;
	};

public:
	VARIABLE_t& vGetTimeConstant(){return(m_vTimeConstant_sec);};
	const VARIABLE_t& vGetTimeConstant() const {return(m_vTimeConstant_sec);};

	VARIABLE_t& vGetMaxThrust(){return(m_dMaxThrust_lbs);};
	const VARIABLE_t& vGetMaxThrust() const {return(m_dMaxThrust_lbs);};

	VARIABLE_t& vGetMinThrust(){return(m_dMinThrust_lbs);};
	const VARIABLE_t& vGetMinThrust() const {return(m_dMinThrust_lbs);};

protected:
	VARIABLE_t m_dMaxThrust_lbs;
	VARIABLE_t m_dMinThrust_lbs;
	VARIABLE_t m_vTimeConstant_sec;
};
#endif // !defined(AFX_ENGINE1STORDER_H__0974B701_07D4_49CA_8B9D_B4F0679DEC94__INCLUDED_)
