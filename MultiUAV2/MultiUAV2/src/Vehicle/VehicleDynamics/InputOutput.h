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
// InputOutput.h: interface for the CInputOutput class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_INPUTOUTPUT_H__80C00253_F120_4168_B826_3387F78A9D11__INCLUDED_)
#define AFX_INPUTOUTPUT_H__80C00253_F120_4168_B826_3387F78A9D11__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <vector>
#include <algorithm>

using namespace std;


template<class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
class CInputOutput  
{
public:

	CInputOutput(size_t szInputs=0,size_t szOutputs=0):
	  m_vDefaultInput(0.0)
	{
		// vpdGetInputs().resize(szInputs,pvdGetDefaultInput());
		ResizeInputs( szInputs );
		vdGetOutputs().resize(szOutputs,0.0);
	}
	virtual ~CInputOutput()
	{
		ClearInputs();
		vdGetOutputs().clear();
	};
	// copy constructor
	CInputOutput(CInputOutput& rhs)
	{
		vpdGetInputs() = rhs.vpdGetInputs();
		vdGetOutputs() = rhs.vdGetOutputs();
	};

public:
	typedef typename CONTAINER_INPUT_t::iterator CONTAINER_INPUT_ITER_t;
	typedef typename CONTAINER_OUTPUT_t::iterator CONTAINER_OUTPUT_ITER_t;
	typedef typename CONTAINER_OUTPUT_t::value_type* POINTER_t;
	typedef vector<string> V_STRING;

public:
	void GetAllLabelsInput(string strPreLabel,string strPostLabel,stringstream& sstrLabels)
	{
		for(V_STRING::iterator itLabel=vstrGetLabelsInput().begin();itLabel!=vstrGetLabelsInput().end();itLabel++)
		{
			sstrLabels << strPreLabel << *itLabel << strPostLabel << endl;
		}
	};
	void GetAllLabelsOutput(string strPreLabel,string strPostLabel,stringstream& sstrLabels)
	{
		for(V_STRING::iterator itLabel=vstrGetLabelsOutput().begin();itLabel!=vstrGetLabelsOutput().end();itLabel++)
		{
			sstrLabels << strPreLabel << *itLabel << strPostLabel << endl;
		}
	};
	void GetAllLabelsState(string strPreLabel,string strPostLabel,stringstream& sstrLabels)
	{
		for(V_STRING::iterator itLabel=vstrGetLabelsState().begin();itLabel!=vstrGetLabelsState().end();itLabel++)
		{
			sstrLabels << strPreLabel << *itLabel << strPostLabel << endl;
		}
	};
public:
	// void ResizeInputs(size_t szSize){vpdGetInputs().resize(szSize,pvdGetDefaultInput());};
	void ResizeInputs(size_t szSize)
	{
		vpdGetInputs().resize(szSize);
		fill( itGetInputsBegin(), itGetInputsEnd(), pvdGetDefaultInput() );
	}

	POINTER_t pvdGetDefaultInput(){return(&m_vDefaultInput);};

	V_STRING& vstrGetLabelsInput(){return(m_vstrLabelsInput);};
	const V_STRING& vstrGetLabelsInput() const {return(m_vstrLabelsInput);};

	V_STRING& vstrGetLabelsOutput(){return(m_vstrLabelsOutput);};
	const V_STRING& vstrGetLabelsOutput() const {return(m_vstrLabelsOutput);};

	V_STRING& vstrGetLabelsState(){return(m_vstrLabelsState);};
	const V_STRING& vstrGetLabelsState() const {return(m_vstrLabelsState);};

	CONTAINER_INPUT_t& vpdGetInputs(){return(m_vpdInputs);};
	const CONTAINER_INPUT_t& vpdGetInputs() const {return(m_vpdInputs);};

	VARIABLE_t& dGetInput(int iIndex){return(*(vpdGetInputs()[iIndex]));};
	const VARIABLE_t& dGetInput(int iIndex) const{return(*(vpdGetInputs()[iIndex]));};

	CONTAINER_OUTPUT_t& vdGetOutputs(){return(m_pvdOutputs);};
	const CONTAINER_OUTPUT_t& vdGetOutputs() const {return(m_pvdOutputs);};
	const CONTAINER_OUTPUT_t* pvdGetOutputs() const {return(&m_pvdOutputs);};

//TODO?????	const CONTAINER_OUTPUT_t::iterator itGetOutput(int iIndex) const {return(&(vdGetOutputs()[iIndex]));};
	CONTAINER_OUTPUT_ITER_t itGetOutput(int iIndex) {return(vdGetOutputs().begin()+iIndex);};

	int iGetNumberInputs(){return(vpdGetInputs().size());};
	int iGetNumberOutputs(){return(vdGetOutputs().size());};

	CONTAINER_OUTPUT_ITER_t itGetOutputsBegin(){return(vdGetOutputs().begin());};
	CONTAINER_OUTPUT_ITER_t itGetOutputsEnd(){return(vdGetOutputs().end());};
	CONTAINER_INPUT_ITER_t itGetInputsBegin(){return(vpdGetInputs().begin());};
	CONTAINER_INPUT_ITER_t itGetInputsEnd(){return(vpdGetInputs().end());};
	void ResetOutputs()
	{
		fill( itGetOutputsBegin(), itGetOutputsEnd(), VARIABLE_t(0) );
	};
	void ClearInputs()
	{
		fill( itGetInputsBegin(), itGetInputsEnd(), static_cast<VARIABLE_t*>(0) );
		vpdGetInputs().clear();
	};
protected:
	CONTAINER_INPUT_t m_vpdInputs;
	CONTAINER_OUTPUT_t m_pvdOutputs;
	VARIABLE_t m_vDefaultInput;
	V_STRING m_vstrLabelsInput;
	V_STRING m_vstrLabelsOutput;
	V_STRING m_vstrLabelsState;
};

#endif // !defined(AFX_INPUTOUTPUT_H__80C00253_F120_4168_B826_3387F78A9D11__INCLUDED_)
