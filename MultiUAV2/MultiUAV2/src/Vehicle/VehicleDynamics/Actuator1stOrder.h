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
////
// Actuator1stOrder.h: interface for the CActuator1stOrder class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ACTUATOR1STORDER_H__B9518CF6_3D53_420A_ABC7_EBB194E61194__INCLUDED_)
#define AFX_ACTUATOR1STORDER_H__B9518CF6_3D53_420A_ABC7_EBB194E61194__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000


template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
class CActuator1stOrder :
	public CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> 
{
public:
	typedef typename CONTAINER_OUTPUT_t::iterator CONTAINER_OUTPUT_IT_t;

	CActuator1stOrder()
	{
		SetNumberOfActuators(1);
	};
	virtual ~CActuator1stOrder(){};

public:
	enum enOutputsPerActuator
	{
		actoutPosition,
		actoutPositionLimitUpper,
		actoutPositionLimitLower,
		actoutPositionLimitRate,
		actoutActuatorTimeConstant,
		actoutTotal
	};
public:
	// virtual overrides
	virtual void CalculateXdot(VARIABLE_t* avState, const VARIABLE_t vDeltaTime, VARIABLE_t* avStateDot,BOOL bUpdateOutputs=TRUE)
	{
		CONTAINER_OUTPUT_IT_t itLimitRate = coGetLimitRate().begin();
		CONTAINER_OUTPUT_IT_t itTimeConstant = coGetTimeConstant().begin();

		for(size_t szCountActuators=0;szCountActuators<coGetTimeConstant().size();
											szCountActuators++,itTimeConstant++,itLimitRate++)
		{
			// 1st order	y=
			avStateDot[szCountActuators] = (dGetInput(szCountActuators) - avState[szCountActuators])/(*itTimeConstant);
			avStateDot[szCountActuators] = dRAS_Limit(avStateDot[szCountActuators],(*itLimitRate),-(*itLimitRate));
		}
	};
	virtual void UpdateOutputs(VARIABLE_t* avState, const VARIABLE_t& vDeltaTime,BOOL bIntermediateStep=FALSE)
	{
		CONTAINER_OUTPUT_IT_t itLimitPositionUpper = coGetLimitPositionUpper().begin();
		CONTAINER_OUTPUT_IT_t itLimitPositionLower = coGetLimitPositionLower().begin();
		CONTAINER_OUTPUT_IT_t itLimitRate = coGetLimitRate().begin();
		CONTAINER_OUTPUT_IT_t itTimeConstant = coGetTimeConstant().begin();
		for(size_t szCountActuators=0;szCountActuators<coGetLimitPositionUpper().size();
											szCountActuators++,itLimitPositionUpper++,      
											itLimitPositionLower++,itLimitRate++,itTimeConstant++)
		{
			//This ordering is for staggered arrangement
			vdGetOutputs()[(szCountActuators*actoutTotal)+actoutPosition] = dRAS_Limit(avState[szCountActuators],(*itLimitPositionUpper),(*itLimitPositionLower));
			vdGetOutputs()[(szCountActuators*actoutTotal)+actoutPositionLimitUpper] = *itLimitPositionUpper;
			vdGetOutputs()[(szCountActuators*actoutTotal)+actoutPositionLimitLower] = *itLimitPositionLower; 
			vdGetOutputs()[(szCountActuators*actoutTotal)+actoutPositionLimitRate] = *itLimitRate;
			vdGetOutputs()[(szCountActuators*actoutTotal)+actoutActuatorTimeConstant] = *itTimeConstant;
		}
	};
	virtual BOOL bInitialize(stringstream& sstrErrorMessage)
	{
		ResetOutputs();
		return(TRUE);	//TODO!!
	};
	virtual void DefaultState(VARIABLE_t* avState){};

public:
	void UpdateOutputsWithLimits(VARIABLE_t vPositionInitial=0.0)
	{
		CONTAINER_OUTPUT_IT_t itLimitPositionUpper = coGetLimitPositionUpper().begin();
		CONTAINER_OUTPUT_IT_t itLimitPositionLower = coGetLimitPositionLower().begin();
		CONTAINER_OUTPUT_IT_t itLimitRate = coGetLimitRate().begin();
		CONTAINER_OUTPUT_IT_t itTimeConstant = coGetTimeConstant().begin();
		for(size_t szCountActuators=0;szCountActuators<coGetLimitPositionUpper().size();
											szCountActuators++,itLimitPositionUpper++,
											itLimitPositionLower++,itLimitRate++,itTimeConstant++)
		{
			//This ordering is for staggered arrangement
			vdGetOutputs()[(szCountActuators*actoutTotal)+actoutPosition] = dRAS_Limit(vPositionInitial,(*itLimitPositionUpper),(*itLimitPositionLower));
			vdGetOutputs()[(szCountActuators*actoutTotal)+actoutPositionLimitUpper] = *itLimitPositionUpper;
			vdGetOutputs()[(szCountActuators*actoutTotal)+actoutPositionLimitLower] = *itLimitPositionLower; 
			vdGetOutputs()[(szCountActuators*actoutTotal)+actoutPositionLimitRate] = *itLimitRate;
			vdGetOutputs()[(szCountActuators*actoutTotal)+actoutActuatorTimeConstant] = *itTimeConstant;
		}

	}
	void SetNumberOfActuators(size_t szNumberActuators)
	{

		// input labels
		vstrGetLabelsInput().clear();
		for(int iCountInputs=0;iCountInputs<szNumberActuators;iCountInputs++)
		{
			stringstream sstrTemp;
			sstrTemp << "inActuator" << iCountInputs;
			vstrGetLabelsInput().push_back(sstrTemp.str());
		}

		// output labels
		vstrGetLabelsOutput().clear();
		for(int iCountOutputs=0;iCountOutputs<szNumberActuators;iCountOutputs++)
		{
			stringstream sstrTemp;
			sstrTemp << iCountOutputs;
			vstrGetLabelsOutput().push_back(string("outActuatorPosition")+sstrTemp.str());
			vstrGetLabelsOutput().push_back(string("outActuatorLimitUpper")+sstrTemp.str());
			vstrGetLabelsOutput().push_back(string("outActuatorLimitLower")+sstrTemp.str());
			vstrGetLabelsOutput().push_back(string("outActuatorLimitRate")+sstrTemp.str());
			vstrGetLabelsOutput().push_back(string("outActuatorTimeConstant")+sstrTemp.str());
		}

		// state labels
		vstrGetLabelsState().clear();
		for(int iCountStates=0;iCountStates<szNumberActuators;iCountStates++)
		{
			stringstream sstrTemp;
			sstrTemp << "stateActuator" << iCountStates;
			vstrGetLabelsState().push_back(sstrTemp.str());
		}

		// resize input, outputs, and states
		ResizeInputs(vstrGetLabelsInput().size());
		vdGetOutputs().resize(vstrGetLabelsOutput().size(),0.0);
		szGetXSize() = vstrGetLabelsState().size();

		coGetLimitRate().clear();
		coGetLimitRate().resize(szNumberActuators,dLimitRate_degpersec);
		coGetLimitPositionUpper().clear();
		coGetLimitPositionUpper().resize(szNumberActuators,dLimitPositionUpper_deg);
		coGetLimitPositionLower().clear();
		coGetLimitPositionLower().resize(szNumberActuators,dLimitPositionLower_deg);
		coGetTimeConstant().clear();
		coGetTimeConstant().resize(szNumberActuators,dTimeConstantActuator_sec);
		UpdateOutputsWithLimits();
	}
	size_t szGetNumberActuators()
	{
		return(coGetTimeConstant().size());
	}
public:
	//accessors
	// rate limit
	CONTAINER_OUTPUT_t& coGetLimitRate(){return(m_coLimitRate_degpersec);};
	const CONTAINER_OUTPUT_t& coGetLimitRate() const {return(m_coLimitRate_degpersec);};
	// position limit upper
	CONTAINER_OUTPUT_t& coGetLimitPositionUpper(){return(m_coLimitPositionUpper_deg);};
	const CONTAINER_OUTPUT_t& coGetLimitPositionUpper() const {return(m_coLimitPositionUpper_deg);};
	// position limit lower
	CONTAINER_OUTPUT_t& coGetLimitPositionLower(){return(m_coLimitPositionLower_deg);};
	const CONTAINER_OUTPUT_t& coGetLimitPositionLower() const {return(m_coLimitPositionLower_deg);};
	// time constant
	CONTAINER_OUTPUT_t& coGetTimeConstant(){return(m_coTimeConstant_sec);};
	const CONTAINER_OUTPUT_t& coGetTimeConstant() const {return(m_coTimeConstant_sec);};

protected:
	CONTAINER_OUTPUT_t m_coLimitRate_degpersec;
	CONTAINER_OUTPUT_t m_coLimitPositionUpper_deg;
	CONTAINER_OUTPUT_t m_coLimitPositionLower_deg;
	CONTAINER_OUTPUT_t m_coTimeConstant_sec;

protected:
	static const VARIABLE_t dLimitRate_degpersec;
	static const VARIABLE_t dLimitPositionUpper_deg;
	static const VARIABLE_t dLimitPositionLower_deg;
	static const VARIABLE_t dTimeConstantActuator_sec;
};

//Default limits, can override these in VehicleSimulation.h
template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
const VARIABLE_t CActuator1stOrder<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>::
																	dLimitRate_degpersec = 60.0;
template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
const VARIABLE_t CActuator1stOrder<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>::
																	dLimitPositionUpper_deg = 30.0;
template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
const VARIABLE_t CActuator1stOrder<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>::
																	dLimitPositionLower_deg = -30.0;
template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
const VARIABLE_t CActuator1stOrder<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>::
																	dTimeConstantActuator_sec = 0.05;

#endif // !defined(AFX_ACTUATOR1STORDER_H__B9518CF6_3D53_420A_ABC7_EBB194E61194__INCLUDED_)
