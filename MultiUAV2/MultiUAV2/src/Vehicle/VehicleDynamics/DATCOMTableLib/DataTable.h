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
// DataTable.h: interface for the CDataTable class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_DATATABLE_H__F3545F93_829E_4C75_8355_632CF8AE75F0__INCLUDED_)
#define AFX_DATATABLE_H__F3545F93_829E_4C75_8355_632CF8AE75F0__INCLUDED_


#pragma warning(disable:4786)

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Interpolate.h"

#include <sstream>
#include <map>
#include <functional>

using namespace std;


typedef map<double,DOUBLE_VALARRAY*,less<double> > MAP_DOUBLE_VALARRAY;
//typedef map<double,DOUBLE_VALARRAY*,less_equal<double> > MAP_DOUBLE_VALARRAY;
typedef MAP_DOUBLE_VALARRAY::iterator MAP_DOUBLE_VALARRAY_IT;

class CDataMapTable
{
public:
	CDataMapTable();
	CDataMapTable(const CDataMapTable& rhs);
	~CDataMapTable();
public:
	typedef std::map<double,DOUBLE_VALARRAY*> MAP_DPVALARRAY_t;
	typedef MAP_DPVALARRAY_t::iterator MAP_DPVALARRAY_IT_t;
public:
	void GetIndVariableLimits(
								BOOL bAddZeroPoint,
								DOUBLE_VALARRAY& vaindepVariable,double& indepVariable,
								double* pdIndValueUpper,double* pdIndValueLower,
								DOUBLE_VALARRAY* DepValueUpperDelta,DOUBLE_VALARRAY* DepValueLowerDelta,
								DOUBLE_VALARRAY* DepValueUpperDerivative=NULL,DOUBLE_VALARRAY* DepValueLowerDerivative=NULL,
								DOUBLE_VALARRAY* DepValueUpperBase=NULL,DOUBLE_VALARRAY* DepValueLowerBase=NULL
							);
	int UpperIndex(double dIndepVariable);
	int LowerIndex(double dIndepVariable);

	DOUBLE_VALARRAY* operator[](int iIndex);
	void operator -=(const CDataMapTable& rhs);
	void operator = (const CDataMapTable& rhs);

	MAP_DPVALARRAY_t mappvalData;

	int iGetSizeVariables(){return((mappvalData.empty())?(-1):(static_cast<int>(mappvalData.begin()->second->size())));};

	void DumpTable(stringstream& sstrOutput)
	{
		for(MAP_DPVALARRAY_IT_t itRow=mappvalData.begin();itRow!=mappvalData.end();itRow++)
		{
			sstrOutput << itRow->first << ":\t";	//print out the independent variable for this row
			for(int iCountElement=0;iCountElement<itRow->second->size();iCountElement++)
			{
				sstrOutput << itRow->second->operator[](iCountElement) << "\t";
			}
			sstrOutput << endl;
		}
			sstrOutput << endl;	//add an extra line return at the end of the table
	};

protected:
	int m_iIndVariableIndex;	// index into the independent variable array for this delta, should be set when data is read

};

typedef CDataMapTable DATA_TABLE_MAP;


class CDataTable  
{
public:
	CDataTable();
	CDataTable(const CDataTable& rhs);	// copy constructor
	virtual ~CDataTable();
public:
	BOOL bReadTable(ifstream* pfstrFIle);
	void Interpolate(
						DOUBLE_VALARRAY& valIndVariables,
						DOUBLE_VALARRAY* pvalOutputRowDelta,
						DOUBLE_VALARRAY* pvalOutputRowDerivative=NULL,
						DOUBLE_VALARRAY* pvalOutputRowBase=NULL
					);

	void operator =(const CDataTable& rhs);
	void operator -=(const CDataTable& rhs);

	int iGetSizeDepVariables(){return(m_datamapDepVariableData.iGetSizeVariables());};
	int iGetSizeExtraVariables(){return(m_datamapExtraData.iGetSizeVariables());};

	void DumpTable(stringstream& sstrOutput)
	{
		sstrOutput << "VariableData:" << endl;
		m_datamapDepVariableData.DumpTable(sstrOutput);
		sstrOutput << "ExtraData:" << endl;
		m_datamapExtraData.DumpTable(sstrOutput);
	};
protected:
	DATA_TABLE_MAP m_datamapDepVariableData;
	DATA_TABLE_MAP m_datamapExtraData;
	BOOL m_bValidData;
};

#endif // !defined(AFX_DATATABLE_H__F3545F93_829E_4C75_8355_632CF8AE75F0__INCLUDED_)
