// Filter.h: interface for the CFilter class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_FILTER_H__5683B82B_16A3_4256_80E5_45B25E5895F6__INCLUDED_)
#define AFX_FILTER_H__5683B82B_16A3_4256_80E5_45B25E5895F6__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000


#include <sstream>
using namespace std;

#include "Dynamic.h"

template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
class CFilter :
	public CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> 
{
	// CFilter implements a general single-input/single-output transfer function. by converting to a
	//		state-space cannonical form
	//
	// requires: 
	//	- highest order coefficient of denominator is 1.0
	//	- order of numerator must be less than or equal to order of denominator
public:
	CFilter(CONTAINER_OUTPUT_t& CoefficientsNumerator,CONTAINER_OUTPUT_t& CoefficientsDenomenator,
																		stringstream& sstrErrorMessage)
	{
		// initialize the state-space coeficients
		cGetA().clear();
		//dGetB() = 0.0;
		cGetC().clear();
		dGetD() = 0.0;
		
		// convert the tranfer function to state-space

		// remove leading zeros from the numerator
		while((!CoefficientsNumerator.empty())&&(CoefficientsNumerator.front() == 0.0))
		{
			CoefficientsNumerator.erase(CoefficientsNumerator.begin());
		}
		// check for improper transfer function
		if(CoefficientsNumerator.size() == CoefficientsDenomenator.size())
		{
			dGetD() = CoefficientsNumerator.front();

			CONTAINER_OUTPUT_t::iterator itDen = (CoefficientsDenomenator.end()-1);
			for(CONTAINER_OUTPUT_t::iterator itNum=(CoefficientsNumerator.end()-1);itNum!=(CoefficientsNumerator.begin()-1);itNum--,itDen--)
			{
				cGetC().push_back((*itNum)-(*itDen)*dGetD());
			}
		}
		else if(CoefficientsNumerator.size() < CoefficientsDenomenator.size())
		{
			for(CONTAINER_OUTPUT_t::iterator itNum=(CoefficientsNumerator.end()-1);itNum!=(CoefficientsNumerator.begin()-1);itNum--)
			{
				cGetC().push_back((*itNum));
			}
		}
		else
		{
			sstrErrorMessage << "ERROR:CFilter:: can't handle improper transfer functions" << endl;
		}

		for(CONTAINER_OUTPUT_t::iterator itDen=(CoefficientsDenomenator.end()-1);itDen!=(CoefficientsDenomenator.begin());itDen--)
		{
			cGetA().push_back(-(*itDen));
		}

		int iDifference = cGetA().size() - cGetC().size();
		if(iDifference > 0)
		{
			for(int iCountElement=0;iCountElement<iDifference;iCountElement++)
			{
				cGetC().push_back(0.0);
			}
		}
		else if(iDifference < 0)
		{
			sstrErrorMessage << "ERROR:CFilter:: can't handle improper transfer functions" << endl;
		}

		// size inputs outputs and states
		ResizeInputs(inputTotal);
		vdGetOutputs().resize(outputTotal,0.0);
		szGetXSize() = cGetA().size();
	};

	virtual ~CFilter(){};

public:
	enum enOutputs 
	{
		outputY,
		outputTotal 
	};
	enum enInputs 
	{
		inputCommand,
		inputFeedback,
		inputTotal 
	};

public:
	// virtual overrides
	virtual void CalculateXdot(VARIABLE_t* avState, const VARIABLE_t vDeltaTime, VARIABLE_t* avStateDot,BOOL bUpdateOutputs=TRUE)
	{
		for(int iCountState=0;iCountState<szGetXSize();iCountState++)
		{
			if(iCountState==(szGetXSize()-1))
			{
				VARIABLE_t dTemp = 0.0;
				CONTAINER_OUTPUT_t::iterator itA = cGetA().begin();
				for(int iCountState2=0;iCountState2<szGetXSize();iCountState2++,itA++)
				{
					dTemp += (*itA)*avState[iCountState2];
				}
				dTemp += (dGetInput(inputCommand) - dGetInput(inputFeedback));	//K=1
				avStateDot[iCountState] = dTemp;
			}
			else
			{
				avStateDot[iCountState] = avState[iCountState+1];
			}
		}
	};
	virtual void UpdateOutputs(VARIABLE_t* avState, const VARIABLE_t& vDeltaTime,BOOL bIntermediateStep=FALSE)
	{
		VARIABLE_t dOutput = 0.0;
		CONTAINER_OUTPUT_t::iterator itC = cGetC().begin();
		for(int iCountState=0;iCountState<szGetXSize();iCountState++,itC++)
		{
			dOutput += (*itC)*avState[iCountState];
		}
		vdGetOutputs()[outputY] = dOutput + dGetD()*(dGetInput(inputCommand) - dGetInput(inputFeedback));
	};

	virtual BOOL bInitialize(stringstream& sstrErrorMessage)
	{
		ResetOutputs();
		return(TRUE);	//TODO!!
	};
	virtual void DefaultState(VARIABLE_t* avState)
	{
		for(int iCountState=0;iCountState<szGetXSize();iCountState++)
		{
			avState[iCountState] = 0.0;
		}
	};

protected:
	// accesors
	CONTAINER_OUTPUT_t& cGetA(){return(m_dA);};
	const CONTAINER_OUTPUT_t& cGetA() const {return(m_dA);};

//	VARIABLE_t& dGetB(){return(m_dB);};
//	const VARIABLE_t& dGetB() const {return(m_dB);};

	CONTAINER_OUTPUT_t& cGetC(){return(m_dC);};
	const CONTAINER_OUTPUT_t& cGetC() const {return(m_dC);};

	VARIABLE_t& dGetD(){return(m_dD);};
	const VARIABLE_t& dGetD() const {return(m_dD);};

protected:
	// state-space coefficients
	CONTAINER_OUTPUT_t m_dA;
	//VARIABLE_t m_dB;
	CONTAINER_OUTPUT_t m_dC;
	VARIABLE_t m_dD;

};

#endif // !defined(AFX_FILTER_H__5683B82B_16A3_4256_80E5_45B25E5895F6__INCLUDED_)


