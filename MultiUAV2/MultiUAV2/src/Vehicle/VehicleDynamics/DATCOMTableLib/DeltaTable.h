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
// DeltaTable.h: interface for the CDeltaTable class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_DELTATABLE_H__137E6944_7268_4831_B911_2961BC82D23C__INCLUDED_)
#define AFX_DELTATABLE_H__137E6944_7268_4831_B911_2961BC82D23C__INCLUDED_


#pragma warning(disable:4786)


#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000


#include "DataTable.h"

#include <map>
#include <vector>

using namespace std;

typedef vector<CDataTable> VDATATABLE;
typedef VDATATABLE::iterator VDATATABLE_IT;
typedef map<double,CDataTable*> MAP_DOUBLE_DATATABLE;
typedef MAP_DOUBLE_DATATABLE::iterator MAP_DOUBLE_DATATABLE_IT;

//typedef vector<CDeltaTableMap*> VP_DELTA_TABLE_MAP;
typedef CTableMap<double,DOUBLE_VALARRAY,MAP_DOUBLE_DATATABLE,CDataTable> DELTA_TABLE_MAP;
typedef vector<DELTA_TABLE_MAP*> VP_DELTA_TABLE_MAP;
typedef VP_DELTA_TABLE_MAP::iterator VP_DELTA_TABLE_MAP_IT;



class CDeltaTable  
{
public:
	CDeltaTable();
	virtual ~CDeltaTable();

public:
	void SubtractBaseTables();
	BOOL bReadDataFile(ifstream* pfstrFile,VDOUBLE* pvdIndVariableValues);
	void Interpolate(
					  DOUBLE_VALARRAY& valIndVariables,
					  DOUBLE_VALARRAY* pvalOutputRowDelta,
					  DOUBLE_VALARRAY* pvalOutputRowDerivative=NULL,
					  DOUBLE_VALARRAY* pvalOutputRowBase=NULL
					);

	int iGetSizeDepVariables(){return(m_vpmapDeltaTable[0]->iGetSizeDepVariables());};
	int iGetSizeExtraVariables(){return(m_vpmapDeltaTable[0]->iGetSizeExtraVariables());};
	int iGetSizeIndVariables(){return(m_vpmapDeltaTable.size()+1);};	// add one for the included independent variable

	void FindDeltaEndPoints(int iIndVariableIndex,double dDeltaValue,double& rdDeltaUpper,double& rdDeltaLower);

	void DumpTable(stringstream& sstrOutput)
	{
		int iDeltaIndex = 0;
		for(VP_DELTA_TABLE_MAP_IT itTable=m_vpmapDeltaTable.begin();itTable!=m_vpmapDeltaTable.end();itTable++,iDeltaIndex++)
		{
			stringstream sstrLabel;
			sstrLabel << "Delta#" << iDeltaIndex << ":";
			(*itTable)->DumpTable(sstrOutput,sstrLabel.str());
		}
	};
protected:

	VP_DELTA_TABLE_MAP m_vpmapDeltaTable;	// one map of data tables for each delta type (including one for the base)
};

#endif // !defined(AFX_DELTATABLE_H__137E6944_7268_4831_B911_2961BC82D23C__INCLUDED_)
