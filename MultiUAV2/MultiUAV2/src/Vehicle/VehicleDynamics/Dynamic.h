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
// Dynamic.h: interface for the CDynamic class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_DYNAMIC_H__4A288E2A_FE3E_420C_92D6_5EA45A3FCBBF__INCLUDED_)
#define AFX_DYNAMIC_H__4A288E2A_FE3E_420C_92D6_5EA45A3FCBBF__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <sstream>
using namespace std;

#include <GlobalDefines.h>

#include "InputOutput.h"

template<class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
class CDynamic   :
	public CInputOutput<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>
{
public:
	CDynamic()
	{
		szGetStartIndexX() = 0;
		szGetXSize() = 0;
		szGetStartIndexOutputs() = 0;
	};
	virtual ~CDynamic(){};
	CDynamic(CDynamic& rhs)
	{
		szGetXSize() = rhs.szGetXSize();
		szGetStartIndexX() = rhs.szGetStartIndexX();
		szGetStartIndexOutputs() = rhs.szGetStartIndexOutputs();
	};

public:
	virtual void CalculateXdot(VARIABLE_t* avState, const VARIABLE_t vDeltaTime, VARIABLE_t* avStateDot,BOOL bUpdateOutputs=TRUE){};
	virtual void UpdateOutputs(VARIABLE_t* avState, const VARIABLE_t& vDeltaTime,BOOL bIntermediateStep=FALSE){};
	virtual BOOL bInitialize(stringstream& sstrErrorMessage){return(TRUE);};
	virtual void DefaultState(VARIABLE_t* avState){};

	size_t& szGetXSize(){return(m_szSizeX);};
	const size_t& szGetXSize() const {return(m_szSizeX);};

	size_t& szGetStartIndexX(){return(m_szIndexStartX);};
	const size_t& szGetStartIndexX() const {return(m_szIndexStartX);};
	const size_t vGetXIndex(size_t szIndex) const {return(szIndex+szGetStartIndexX());};

	size_t& szGetStartIndexOutputs(){return(m_szStartIndexOutputs);};
	const size_t& szGetStartIndexOutputs() const {return(m_szStartIndexOutputs);};
	const size_t vGetOutputIndex(size_t szIndex) const {return(szIndex+szGetStartIndexOutputs());};


protected:
	size_t m_szStartIndexOutputs;
	size_t m_szIndexStartX;
	size_t m_szSizeX;
};

#endif // !defined(AFX_DYNAMIC_H__4A288E2A_FE3E_420C_92D6_5EA45A3FCBBF__INCLUDED_)
