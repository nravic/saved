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
// DataTable.cpp: implementation of the CDataTable class.
//
//////////////////////////////////////////////////////////////////////

#pragma warning(disable:4786)

#include <cassert>
#include <float.h>	//DBL_MAX
#include <iostream>	//cerr
#include <ostream>	//endl

#include <rounding_cast>

using namespace std;

#include "DataTable.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
CDataMapTable::CDataMapTable()
{
	m_iIndVariableIndex = enindvarAlpha;
}

CDataMapTable::CDataMapTable(const CDataMapTable& rhs)	// copy constructor
{
	mappvalData.clear();
	MAP_DOUBLE_VALARRAY::const_iterator itRHS;
	for(itRHS=rhs.mappvalData.begin();itRHS!=rhs.mappvalData.end();itRHS++)
	{
		CDataMapTable datamapTemp;
		mappvalData[itRHS->first] = new DOUBLE_VALARRAY;
		*(mappvalData[itRHS->first]) = *(itRHS->second);
	}
}


CDataMapTable::~CDataMapTable()
{
	MAP_DOUBLE_VALARRAY::const_iterator itMap;
	for(itMap=mappvalData.begin();itMap!=mappvalData.end();itMap++)
	{
		if(mappvalData[itMap->first])
		{
			delete mappvalData[itMap->first];
		}
	}
	mappvalData.clear();
}

//////////////////////////////////////////////////////////////////////
// member functions
//////////////////////////////////////////////////////////////////////

void CDataMapTable::operator -=(const CDataMapTable& rhs)
{
	MAP_DOUBLE_VALARRAY::iterator itThis;
	MAP_DOUBLE_VALARRAY::const_iterator itRHS;
	for(itThis=mappvalData.begin(),itRHS=rhs.mappvalData.begin();
				((itThis!=mappvalData.end())&&(itRHS!=rhs.mappvalData.end()));itThis++,itRHS++)
	{
		*(itThis->second) -= *(itRHS->second);
	}
}


void CDataMapTable::operator = (const CDataMapTable& rhs)
{
	mappvalData.clear();
	MAP_DOUBLE_VALARRAY::const_iterator itRHS;
	for(itRHS=rhs.mappvalData.begin();itRHS!=rhs.mappvalData.end();itRHS++)
	{
		CDataMapTable datamapTemp;
		mappvalData[itRHS->first] = new DOUBLE_VALARRAY;
		*(mappvalData[itRHS->first]) = *(itRHS->second);
	}
}

void CDataMapTable::GetIndVariableLimits(
											BOOL bAddZeroPoint,
											DOUBLE_VALARRAY& vaindepVariable,double& indepVariable,
											double* pdIndValueUpper,double* pdIndValueLower,
											DOUBLE_VALARRAY* DepValueUpperDelta,DOUBLE_VALARRAY* DepValueLowerDelta,
											DOUBLE_VALARRAY* DepValueUpperDerivative,DOUBLE_VALARRAY* DepValueLowerDerivative,// THESE SHOULD BE NULL
											DOUBLE_VALARRAY* DepValueUpperBase,DOUBLE_VALARRAY* DepValueLowerBase	//THESE SHOULD BE NULL (DEFINED TO BE COMPATABLE WITH THE TEMPLATE
										)
{

	assert( DepValueUpperDerivative == 0x0  &&  DepValueLowerDerivative == 0x0 );
	assert( DepValueUpperBase == 0x0  &&  DepValueLowerBase == 0x0 );
	assert( DepValueUpperDelta != 0x0 );
	assert( DepValueLowerDelta != 0x0 );

	indepVariable = vaindepVariable[m_iIndVariableIndex];
	std::pair<MAP_DOUBLE_VALARRAY_IT,MAP_DOUBLE_VALARRAY_IT> pairitRange;
	pairitRange = mappvalData.equal_range(indepVariable);

	if((&*pairitRange.first)->first != indepVariable)
	{
		if(pairitRange.first != mappvalData.begin())
		{
			pairitRange.first--;
		}
		else
		{
			pairitRange.first = mappvalData.end();
		}
	}
	else
	{
		pairitRange.second = pairitRange.first;
	}

	if((pairitRange.first!=mappvalData.end())&&(pairitRange.second!=mappvalData.end()))
	{
		if((&*pairitRange.first)->first != (&*pairitRange.second)->first)
		{
			*(pdIndValueLower) = (&*pairitRange.first)->first;
			*(pdIndValueUpper) = (&*pairitRange.second)->first;
			resize_assign_array( *((&*pairitRange.first)->second),  *(DepValueLowerDelta) );
			resize_assign_array( *((&*pairitRange.second)->second), *(DepValueUpperDelta) );
		}
		else
		{
			*(pdIndValueLower) = (&*pairitRange.first)->first;
			*(pdIndValueUpper) = (&*pairitRange.second)->first;
			resize_assign_array( *((&*pairitRange.second)->second), *(DepValueUpperDelta) );
		}
	}
	else if(pairitRange.first!=mappvalData.end())
	{
		// only lower is valid
		*(pdIndValueLower) = (&*pairitRange.first)->first;
		*(pdIndValueUpper) = BOUND_INVALID;
		resize_assign_array( *((&*pairitRange.first)->second), *(DepValueLowerDelta) );
	}
	else if(pairitRange.second!=mappvalData.end())
	{
		// only upper is valid
		*(pdIndValueLower) = BOUND_INVALID;
		*(pdIndValueUpper) = (&*pairitRange.second)->first;
		resize_assign_array( *((&*pairitRange.second)->second), *(DepValueUpperDelta) );
	}
	else
	{
		// neither valid
		*(pdIndValueLower) = BOUND_INVALID;
		*(pdIndValueUpper) = BOUND_INVALID;
	}
}



//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
CDataTable::CDataTable()
{
	m_bValidData = FALSE;
}

CDataTable::CDataTable(const CDataTable& rhs)	// copy constructor
{
	m_datamapDepVariableData = rhs.m_datamapDepVariableData;
	m_datamapExtraData = rhs.m_datamapExtraData;
}


CDataTable::~CDataTable()
{
}

//////////////////////////////////////////////////////////////////////
// member functions
//////////////////////////////////////////////////////////////////////

void CDataTable::operator= (const CDataTable& rhs)
{
	m_datamapDepVariableData = rhs.m_datamapDepVariableData;
	m_datamapExtraData = rhs.m_datamapExtraData;
	m_bValidData = rhs.m_bValidData;
}

void CDataTable::operator-= (const CDataTable& rhs)
{
	m_datamapDepVariableData -= rhs.m_datamapDepVariableData;
}

void CDataTable::Interpolate(
								DOUBLE_VALARRAY& valIndVariables,
								DOUBLE_VALARRAY* pvalOutputRowDelta,
								DOUBLE_VALARRAY* pvalOutputRowDerivative, // may be 0x0
								DOUBLE_VALARRAY* pvalOutputRowBase        // may be 0x0
							)
{
	assert( pvalOutputRowDelta != 0x0 );
	assert( valIndVariables.size()     > 0 );

	if((m_bValidData)&&(pvalOutputRowDelta!=NULL)&&(pvalOutputRowDerivative!=NULL))
	{
		InterpolateT(FALSE,valIndVariables,&m_datamapDepVariableData,pvalOutputRowDelta);
		InterpolateT(FALSE,valIndVariables,&m_datamapExtraData,pvalOutputRowDerivative);
	}
	else if((m_bValidData)&&(pvalOutputRowDelta!=NULL))
	{
		InterpolateT(FALSE,valIndVariables,&m_datamapDepVariableData,pvalOutputRowDelta);
	}
	else
	{
		//TODO:: ERROR: no outputs defined
	}
}

BOOL CDataTable::bReadTable(ifstream *pfstrFile)
{
	char caTemp[MAX_LENGTH_LINE];

	double dNumberRows = 0.0;
	double dNumberColumns = 0.0;
	double dNumberExtraData = 0.0;
	
	// read table dimensions
	(*pfstrFile) >> dNumberRows >> dNumberColumns >> dNumberExtraData; 
	(*pfstrFile).getline(caTemp,MAX_LENGTH_LINE);

	int iNumberRows = rounding_cast<int>(dNumberRows);
	int iNumberColumns = rounding_cast<int>(dNumberColumns);
	int iNumberExtraData = rounding_cast<int>(dNumberExtraData);

	const int NUMBER_INCLUDED_IND_VARIABLE = 1;
	int iNumberDependentData = iNumberColumns - NUMBER_INCLUDED_IND_VARIABLE - iNumberExtraData;

	// check for errors
	if((iNumberRows<=0)||
		(iNumberColumns<=1)||
		(iNumberDependentData < 0))
	{
		cerr << "ERROR:: error encountered while reading table dimensions from the file." << endl;
		return(FALSE);
	}
	
	for(int iCountRows=0;iCountRows<iNumberRows;iCountRows++)
	{
		double dIndVariable;
		(*pfstrFile) >> dIndVariable;

		m_datamapDepVariableData.mappvalData[dIndVariable] = new DOUBLE_VALARRAY(0.0,iNumberDependentData);
		int iCountColumns; // for scope hack for odious MSVC++6
		for(iCountColumns=0;iCountColumns<iNumberDependentData;iCountColumns++)
		{
			double dDepVariable;
			(*pfstrFile) >> dDepVariable;
			(m_datamapDepVariableData.mappvalData[dIndVariable])->operator[](iCountColumns) = dDepVariable;
		}
		if(iNumberExtraData > 0)
		{
			m_datamapExtraData.mappvalData[dIndVariable] = new DOUBLE_VALARRAY(0.0,iNumberExtraData);
			// (see for scope hack for contemptable MSVC++6 above)
			for(iCountColumns=0;iCountColumns<iNumberExtraData;iCountColumns++)
			{
				double dExtraData;
				(*pfstrFile) >> dExtraData;
				(m_datamapExtraData.mappvalData[dIndVariable])->operator[](iCountColumns) = dExtraData;
			}
		}
	}
	m_bValidData = TRUE;
	return(TRUE);
}

