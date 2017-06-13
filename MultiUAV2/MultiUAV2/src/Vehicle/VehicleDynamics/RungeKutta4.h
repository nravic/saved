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
// RungeKutta4.h: interface for the CRungeKutta4 class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_RUNGEKUTTA4_H__AE389576_293D_427F_B6CC_3B78D4F41D00__INCLUDED_)
#define AFX_RUNGEKUTTA4_H__AE389576_293D_427F_B6CC_3B78D4F41D00__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <valarray>
using namespace std;

template<typename INTEGRATE_STATE_t,typename VARIABLE_t>
class CRungeKutta4  
{
public:
	CRungeKutta4(){};
	virtual ~CRungeKutta4()
	{
#if 0
		// m_avalDerivative[4], and m_valTemp are 'auto' so no need to
		// delete or free their space manually; valarray doesn't have a
		// valarray::free() member specified...hmmm.
			size_t szTemp = m_avalDerivative[0].size();
			m_avalDerivative[0].free();
			szTemp = m_avalDerivative[1].size();
			m_avalDerivative[1].free();
			szTemp = m_avalDerivative[2].size();
			m_avalDerivative[2].free();
			szTemp = m_avalDerivative[3].size();
			m_avalDerivative[3].free();
			szTemp = m_avalDerivative[4].size();
			m_valTemp.free();
#endif
	};
public:		//ENUMS AND TYPEDEFS
	enum enIntegratorType
	{
		integratorRK2,
		integratorRK4,
		integratorTotal
	};

public:		//FUNCTIONS	
	void Integrate(INTEGRATE_STATE_t& cState,const VARIABLE_t vTimeDelta,const enIntegratorType integratorType=integratorRK2)
	{
		switch(integratorType)
		{
		default:
		case integratorRK2:
			IntegrateRK2(cState,vTimeDelta);
			break;
		case integratorRK4:
			IntegrateRK4(cState,vTimeDelta);
			break;
		}
	}
	void IntegrateRK4(INTEGRATE_STATE_t& cState,const VARIABLE_t vTimeDelta)
	{
		size_t szNumberStates = cState.szGetNumberStates();
		
		if(m_valTemp.size() != szNumberStates)
		{
			m_avalDerivative[0].resize(szNumberStates,0.0);
			m_avalDerivative[1].resize(szNumberStates,0.0);
			m_avalDerivative[2].resize(szNumberStates,0.0);
			m_avalDerivative[3].resize(szNumberStates,0.0);
			m_valTemp.resize(szNumberStates,0.0);
		}
		//  % Derivative at left (stage 1) Evaluate at current time and state
		VARIABLE_t vTimeIntegration = 0;
		size_t szStage = 0;
		cState.CalculateXDot(&cState.vsGetX()[0],vTimeIntegration,&m_avalDerivative[szStage][0],FALSE);

	//  % Derivative in middle (stage 2) Evaluate at time+0.5*dt, x+0.5*dt*v0
		vTimeIntegration = 0.5*vTimeDelta;
		szStage = 1;
		m_valTemp  = cState.vsGetX() + m_avalDerivative[0]*vTimeIntegration;
		cState.CalculateXDot(&m_valTemp[0],vTimeIntegration,&m_avalDerivative[szStage][0]);

	//  % Derivative in middle (stage 3)
		m_valTemp = cState.vsGetX() + m_avalDerivative[1]*vTimeIntegration;
		szStage = 2;
		cState.CalculateXDot(&m_valTemp[0],vTimeIntegration,&m_avalDerivative[szStage][0]);

	//  % Derivative at right (stage 4)
		vTimeIntegration = vTimeDelta;
		szStage = 3;
		m_valTemp = cState.vsGetX() + m_avalDerivative[2]*vTimeIntegration;
		cState.CalculateXDot(&m_valTemp[0],vTimeIntegration,&m_avalDerivative[szStage][0]);
		
		// calculate new state
		cState.vsGetX() += (m_avalDerivative[0] + m_avalDerivative[1]*2.0 + m_avalDerivative[2]*2.0 + m_avalDerivative[3])*(vTimeDelta/6.0);
	}
	void IntegrateRK2(INTEGRATE_STATE_t& cState,const VARIABLE_t vTimeDelta)
	{
		size_t szNumberStates = cState.szGetNumberStates();
		
		if(m_valTemp.size() != szNumberStates)
		{
			m_avalDerivative[0].resize(szNumberStates,0.0);
			m_avalDerivative[1].resize(szNumberStates,0.0);
			m_valTemp.resize(szNumberStates,0.0);
		}
		//  % Derivative at left (stage 1) Evaluate at current time and state
		VARIABLE_t vTimeIntegration = 0;
		size_t szStage = 0;
		cState.CalculateXDot(&cState.vsGetX()[0],vTimeIntegration,&m_avalDerivative[szStage][0],FALSE);

	//  % Derivative at 2/3 deltas time (stage 2) Evaluate at time+2/3*dt, x+2/3*dt*v0
		vTimeIntegration = _TWO_THIRDS*vTimeDelta;
		szStage = 1;
		m_valTemp  = cState.vsGetX() + vTimeIntegration*m_avalDerivative[0];
		cState.CalculateXDot(&m_valTemp[0],vTimeIntegration,&m_avalDerivative[szStage][0]);
		// calculate new state
		cState.vsGetX() += (m_avalDerivative[0] + m_avalDerivative[1]*3.0)*(vTimeDelta/4.0);

	}
protected:
	valarray<VARIABLE_t> m_avalDerivative[4];
	valarray<VARIABLE_t> m_valTemp;
};

#endif // !defined(AFX_RUNGEKUTTA4_H__AE389576_293D_427F_B6CC_3B78D4F41D00__INCLUDED_)
