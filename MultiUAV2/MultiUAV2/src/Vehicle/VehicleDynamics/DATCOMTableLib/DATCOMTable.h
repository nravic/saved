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
// DATCOMTable.h: interface for the CDATCOMTable class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_DATCOMTABLE_H__137E6944_7268_4831_B911_2961BC82D23C__INCLUDED_)
#define AFX_DATCOMTABLE_H__137E6944_7268_4831_B911_2961BC82D23C__INCLUDED_


#pragma warning(disable:4786)


#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

//#include "Interpolate.h"
#include "DeltaTable.h"


typedef map<double,CDeltaTable*> MAP_DOUBLE_DELTATABLE;
typedef MAP_DOUBLE_DELTATABLE::iterator MAP_DOUBLE_DELTATABLE_IT;

typedef CTableMap<DOUBLE_VALARRAY*,DOUBLE_VALARRAY,MAP_DOUBLE_DELTATABLE,CDeltaTable> MACH_TABLE_MAP;

class CDATCOMTable  
{
public:
	CDATCOMTable();
	virtual ~CDATCOMTable();


public:
	BOOL bReadDataFile(const char *pcDataFileName,BOOL bSubtractBaseTables=TRUE);

	int iGetSizeIndVariables(){return(m_iSizeIndVariableVector);};
	void Interpolate(double* pdIndVariables,int iSizeIndVariables);
	void Interpolate(VDOUBLE& vdIndVariables);
	void Interpolate(	DOUBLE_VALARRAY& valdIndVariables,
						DOUBLE_VALARRAY& valdDepVariablesDelta,
						DOUBLE_VALARRAY& valdDepVariablesDerivative,
						DOUBLE_VALARRAY& valdDepVariablesBase);

	int iGetSizeDepVariables(){return(mapmachdataTables.iGetSizeDepVariables());};
	int iGetSizeDepVariablesDerivative(){return(m_valOutputDerivative.size());};
	void GetOutput(double* pdDepVariablesDelta,double* pdDepVariablesDerivative,double* pdDepVariablesBase);
	void GetOutput(VDOUBLE& vdDepVariablesDelta,VDOUBLE& vdDepVariablesDerivative,VDOUBLE& vdDepVariablesBase);

	void CalculateDerivatives(	DOUBLE_VALARRAY& valdIndVariables,
								V_DOUBLE_VALARRAY& vdvalDerivatives,
								V_DOUBLE_VALARRAY& vdvalIntercepts);
	void CalculateDerivatives(double* pdIndVariables,int iSizeIndVariables);
	int iGetSizeDerivativesIntercepts(){return(iGetColumnsDerivativesIntercepts()*iGetRowsDerivativesIntercepts());};
	int iGetColumnsDerivativesIntercepts(){return(m_vdvalControlDerivatives.begin()->size());};
	int iGetRowsDerivativesIntercepts(){return(m_vdvalControlDerivatives.size());};
	void GetDerivatives(double* pdControlDerivatives,double* pdControlIntercepts);

	void DumpTable(stringstream& sstrOutput)
	{
		mapmachdataTables.DumpTable(sstrOutput,"*************\nMach");
	};

	void DumpTableToFileNamed( const char* fname )
	{
		stringstream oss;
		DumpTable(oss);

		ofstream ofs( fname );
		assert( ofs.is_open() );

		ofs << oss.str();

		return;
	}
	
protected:

	BOOL bReadDataFile(ifstream& fstrFile,BOOL bSubtractBaseTables=TRUE);

	MACH_TABLE_MAP mapmachdataTables;

	DOUBLE_VALARRAY m_valOutputDelta;
	DOUBLE_VALARRAY m_valOutputDerivative;
	DOUBLE_VALARRAY m_valOutputBase;

	V_DOUBLE_VALARRAY m_vdvalControlDerivatives;
	V_DOUBLE_VALARRAY m_vdvalControlIntercepts;

	int m_iSizeIndVariableVector;
};

#endif // !defined(AFX_DATCOMTABLE_H__137E6944_7268_4831_B911_2961BC82D23C__INCLUDED_)
