// Filter.cpp: implementation of the CFilter class.
//
//////////////////////////////////////////////////////////////////////
#include "Filter.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

template<class CONTAINER_TYPE,class VARIABLE_TYPE>
CFilter<CONTAINER_TYPE,VARIABLE_TYPE>::CFilter(CONTAINER_TYPE& CoefficientsNumerator,
											   CONTAINER_TYPE& CoefficientsDenomenator)
{
	m_dOutputLast = 0.0;
	// assumes highest order coefficient of denominator is 1.0
	while((!CoefficientsNumerator.empty())&&(CoefficientsNumerator.front() == 0.0))
	{
		CoefficientsNumerator.erase(CoefficientsNumerator.begin());
	}
	m_dD = 0.0;

	if(CoefficientsNumerator.size() == CoefficientsDenomenator.size())
	{
		m_dD = CoefficientsNumerator.front();

		CONTAINER_TYPE::iterator itDen = (CoefficientsDenomenator.end()-1);
		for(CONTAINER_TYPE::iterator itNum=(CoefficientsNumerator.end()-1);itNum!=(CoefficientsNumerator.begin()-1);itNum--,itDen--)
		{
			m_dC.push_back((*itNum)-(*itDen)*m_dD);
		}
	}
	else if(CoefficientsNumerator.size() < CoefficientsDenomenator.size())
	{
		for(CONTAINER_TYPE::iterator itNum=(CoefficientsNumerator.end()-1);itNum!=(CoefficientsNumerator.begin()-1);itNum--)
		{
			m_dC.push_back((*itNum));
		}
	}
	else
	{
		//this is an error can't handle improper transfer functions
	}

	for(CONTAINER_TYPE::iterator itDen=(CoefficientsDenomenator.end()-1);itDen!=(CoefficientsDenomenator.begin());itDen--)
	{
		m_dA.push_back(-(*itDen));
	}

	m_vdState.resize(m_dA.size());
	int iDifference = m_dA.size() - m_dC.size();
	if(iDifference > 0)
	{
		for(int iCountElement=0;iCountElement<iDifference;iCountElement++)
		{
			m_dC.push_back(0.0);
		}
	}
	else if(iDifference < 0)
	{
		//this is an error can't handle improper transfer functions
	}

	CONTAINER_TYPE vdStateDot(m_vdState.size(),0.0);	// assumes ?equilibrium??
}

template<class CONTAINER_TYPE,class VARIABLE_TYPE>
CFilter<CONTAINER_TYPE,VARIABLE_TYPE>::~CFilter()
{
	delete m_pIntegrator;
}


template<class CONTAINER_TYPE,class VARIABLE_TYPE>
VARIABLE_TYPE
CFilter<CONTAINER_TYPE,VARIABLE_TYPE>::dUpdate(VARIABLE_TYPE dInput, VARIABLE_TYPE dDeltaTimeSec)
{
	CONTAINER_TYPE vdStateDot;
	int iCountState = 0;
	for(CONTAINER_TYPE::iterator itState=m_vdState.begin();itState!=m_vdState.end();itState++,iCountState++)
	{
		if(itState==m_vdState.end()-1)
		{
			VARIABLE_TYPE varTemp = 0.0;
			CONTAINER_TYPE::iterator itA = m_dA.begin();
			for(CONTAINER_TYPE::iterator itState1=m_vdState.begin();itState1!=m_vdState.end();itState1++,itA++)
			{
				varTemp += (*itA)*(*itState1);
			}
			varTemp += dInput;
			vdStateDot.push_back(varTemp);
		}
		else
		{
			vdStateDot.push_back((*(itState+1)));
		}
	}

	m_pIntegrator->Integrate(vdStateDot,m_vdState,dDeltaTimeSec);

	VARIABLE_TYPE dOutput = 0.0;
	CONTAINER_TYPE::iterator itC = m_dC.begin();
	for(itState=m_vdState.begin();itState!=m_vdState.end();itState++,itC++)
	{
		dOutput += ((*itC)*(*itState));
	}
	m_dOutputLast = dOutput + m_dD*dInput;
	return(m_dOutputLast);
}

// The following line create an instance of this class which causes the compiler to create an instance of the templated class
// it can be taken out if one uses a good compiler
//CFilter<std::vector<double>,double> FakeCFilterDoubleTypeBlahBlahBlah(vector<double>(0),vector<double>(0));
