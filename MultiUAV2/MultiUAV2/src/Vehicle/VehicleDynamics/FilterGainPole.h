// FilterGainPole.h: interface for the CFilterGainPole class.
//
// this function implements a multiloop control system that implements the 
// following equation for each loop: 
//
//	Y = (Gp + Gf/(s + Pole))*(U - Ufb)
//
///////////////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_FILTERGAINPOLE_H__0974B701_07D4_49CA_8B9D_B4F0679DEC94__INCLUDED_)
#define AFX_FILTERGAINPOLE_H__0974B701_07D4_49CA_8B9D_B4F0679DEC94__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Dynamic.h"
#include "InputOutput.h"



template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
class CFilterGainPole :
	public CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>   
{
public:
	typedef CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> Parent_t;
	typedef typename CONTAINER_OUTPUT_t::iterator CONTAINER_OUTPUT_IT_t;

	CFilterGainPole(CONTAINER_OUTPUT_t coPole,CONTAINER_OUTPUT_t coGainFilter,CONTAINER_OUTPUT_t coGainProportional,
									CONTAINER_OUTPUT_t coLimitUpper,CONTAINER_OUTPUT_t coLimitLower) 
		: Parent_t()
	{
		coGetPole() = coPole;
		coGetGainF() = coGainFilter;
		coGetGainP() = coGainProportional;
		coGetLimitUpper() = coLimitUpper;
		coGetLimitLower() = coLimitLower;

		ResizeInputs(2*coGetPole().size());	// need commands and feedback
		vdGetOutputs().resize(coGetPole().size(),0.0);
		szGetXSize() = coGetPole().size();
	}


	virtual ~CFilterGainPole(){};

public:
	// virtual overrides
	virtual void CalculateXdot(VARIABLE_t* avState, const VARIABLE_t vDeltaTime, VARIABLE_t* avStateDot,BOOL bUpdateOutputs=TRUE)
	{
		size_t szIndex = 0;
		for(CONTAINER_OUTPUT_IT_t itPole=coGetPole().begin(),itGainF=coGetGainF().begin();
										(itPole!=coGetPole().end())&&(itGainF!=coGetGainF().end());
										itPole++,itGainF++,szIndex++)
		{
			// 1st order	xdot = -(-pole)*x + b*u = pole*x + b*u
			VARIABLE_t vError = dGetInput(szIndex) - dGetInput(szIndex+coGetPole().size());
			avStateDot[szIndex] =  (*itGainF)*vError + (*itPole)*avState[szIndex];
		}
	};
	virtual void UpdateOutputs(VARIABLE_t* avState, const VARIABLE_t& vDeltaTime,BOOL bIntermediateStep=FALSE)
	{
		size_t szIndex = 0;
		CONTAINER_OUTPUT_IT_t itLimitUpper=coGetLimitUpper().begin();
		CONTAINER_OUTPUT_IT_t itLimitLower=coGetLimitLower().begin();
		for(CONTAINER_OUTPUT_IT_t itGainF=coGetGainP().begin();itGainF!=coGetGainP().end();
															itGainF++,szIndex++,itLimitUpper++,itLimitLower++)
		{
			// 1st order	xdot = -(-pole)*x + b*u = pole*x + b*u
			VARIABLE_t vError = dGetInput(szIndex) - dGetInput(szIndex+coGetPole().size());
			VARIABLE_t vOutput =  (*itGainF)*vError + avState[szIndex];
#ifdef STEVETEST
			vdGetOutputs()[szIndex] = vOutput;
//			vdGetOutputs()[szIndex] = 0.0;
#else	//STEVETEST
			vdGetOutputs()[szIndex] = (vOutput>(*itLimitUpper))?((*itLimitUpper)):((vOutput<(*itLimitLower))?((*itLimitLower)):(vOutput));
			avState[szIndex] = (avState[szIndex]>(*itLimitUpper))?((*itLimitUpper)):((avState[szIndex]<(*itLimitLower))?((*itLimitLower)):(avState[szIndex]));
#endif	//STEVETEST
		}
	};
	virtual BOOL bInitialize(stringstream& sstrErrorMessage)
	{
		ResetOutputs();
		return(TRUE);	//TODO!!
	};
	virtual void DefaultState(VARIABLE_t* avState)
	{
		for(size_t szCountStates=0;szCountStates<coGetPole().size();szCountStates++)
		{
			avState[szCountStates] =  0.0;
		}
	};

public:
	VARIABLE_t& vGetPole(size_t szIndex){return(m_coPole[szIndex]);};
	const VARIABLE_t& vGetPole(size_t szIndex) const {return(m_coPole[szIndex]);};
	CONTAINER_OUTPUT_t& coGetPole(){return(m_coPole);};
	const CONTAINER_OUTPUT_t& coGetPole() const {return(m_coPole);};

	VARIABLE_t& vGetGainF(size_t szIndex){return(m_coGainFilter[szIndex]);};
	const VARIABLE_t& vGetGainF(size_t szIndex) const {return(m_coGainFilter[szIndex]);};
	CONTAINER_OUTPUT_t& coGetGainF(){return(m_coGainFilter);};
	const CONTAINER_OUTPUT_t& coGetGainF() const {return(m_coGainFilter);};

	VARIABLE_t& vGetGainP(size_t szIndex){return(m_coGainProportional[szIndex]);};
	const VARIABLE_t& vGetGainP(size_t szIndex) const {return(m_coGainProportional[szIndex]);};
	CONTAINER_OUTPUT_t& coGetGainP(){return(m_coGainProportional);};
	const CONTAINER_OUTPUT_t& coGetGainP() const {return(m_coGainProportional);};

	CONTAINER_OUTPUT_t& coGetLimitUpper(){return(m_coLimitUpper);};
	const CONTAINER_OUTPUT_t& coGetLimitUpper() const {return(m_coLimitUpper);};

	CONTAINER_OUTPUT_t& coGetLimitLower(){return(m_coLimitLower);};
	const CONTAINER_OUTPUT_t& coGetLimitLower() const {return(m_coLimitLower);};

protected:
	// state-space coefficients
	CONTAINER_OUTPUT_t m_coPole;
	CONTAINER_OUTPUT_t m_coGainFilter;
	CONTAINER_OUTPUT_t m_coGainProportional;
	CONTAINER_OUTPUT_t m_coLimitUpper;
	CONTAINER_OUTPUT_t m_coLimitLower;
};
#endif // !defined(AFX_FILTERGAINPOLE_H__0974B701_07D4_49CA_8B9D_B4F0679DEC94__INCLUDED_)
