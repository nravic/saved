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
// DeltaTable.cpp: implementation of the CDeltaTable class.
//
//////////////////////////////////////////////////////////////////////


#pragma warning(disable:4786)

#include <float.h>	//DBL_MAX
#include "DeltaTable.h"




//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CDeltaTable::CDeltaTable()
{
}

CDeltaTable::~CDeltaTable()
{
	for(VP_DELTA_TABLE_MAP_IT itDeltaMap=m_vpmapDeltaTable.begin();itDeltaMap!=m_vpmapDeltaTable.end();itDeltaMap++)
	{
		if(*itDeltaMap!=0)
		{
			delete *itDeltaMap;
		}
	}
	m_vpmapDeltaTable.clear();
}


BOOL CDeltaTable::bReadDataFile(ifstream* pfstrFile,VDOUBLE* pvdIndVariableValues)
{
	BOOL bReturn = FALSE;

	// check the independent variable values to see which table to construct
	int iDeltaIndex = -1;
	double dDeltaValue = 0;
	int iCountDeltaIndex = 0;
	for(VDOUBLE_IT itIndVar=pvdIndVariableValues->begin()+enindvarFirstDelta;
											itIndVar!=pvdIndVariableValues->end();itIndVar++,iCountDeltaIndex++)
	{
		if((*itIndVar)!=0.0)
		{
			if(iDeltaIndex >= 0)
			{
				CDataTable datatableTemp;
				datatableTemp.bReadTable(pfstrFile);	//read table and throw it away
				//TODO:: error only one delta value allowed per table
				return(FALSE);
			}
			dDeltaValue = (*itIndVar);
			iDeltaIndex = iCountDeltaIndex;	// keep track of delta index to use
		}
	}

//	int iSizeRequired = ((iDeltaIndex<0)?(0):(iDeltaIndex + 1)) + 1;	//check to see if this is a base table, add one for index and one for base
	int iSizeRequired = ((iDeltaIndex<0)?(0):(iDeltaIndex + 1)) + 1;	//check to see if this is a base table, add one for index and one for base

	int iResizeAmount = iSizeRequired - m_vpmapDeltaTable.size();
	for(int iCountResize=0;iCountResize<iResizeAmount;iCountResize++)
	{
		m_vpmapDeltaTable.push_back(new DELTA_TABLE_MAP);
	}
	if(iDeltaIndex>=0)
	{
		m_vpmapDeltaTable[iSizeRequired-1]->SetDeltaIndex(enindvarFirstDelta+iDeltaIndex);
	}

	MAP_DOUBLE_DATATABLE* maptablevalData = &(m_vpmapDeltaTable[iSizeRequired-1]->m_maptableData);
	if(maptablevalData->find(dDeltaValue) == maptablevalData->end())
	{
		(*maptablevalData)[dDeltaValue] = new CDataTable;
		bReturn = (*maptablevalData)[dDeltaValue]->bReadTable(pfstrFile);
	}
	else
	{
		CDataTable datatableTemp;
		datatableTemp.bReadTable(pfstrFile);	//read table and throw it away
		//TODO:: repeated delta value encountered while reading data or base table entered twice
		return(FALSE);
	}
	return(bReturn);
}


void CDeltaTable::Interpolate(
							  DOUBLE_VALARRAY& valIndVariables,
							  DOUBLE_VALARRAY* pvalOutputRowDelta,
							  DOUBLE_VALARRAY* pvalOutputRowDerivative,
							  DOUBLE_VALARRAY* pvalOutputRowBase
							  )
{

	if((pvalOutputRowDelta==NULL))
	{
		return;
	}

	int iDeltaIndex = 1;	// base table is 0
	assert(iGetSizeDepVariables()>=0);
	pvalOutputRowDelta->resize(iGetSizeDepVariables());
	*pvalOutputRowDelta = 0.0;

	for(int iCountIndVariable=enindvarFirstDelta;iCountIndVariable<valIndVariables.size();iCountIndVariable++,iDeltaIndex++)
	{
		if((valIndVariables[iCountIndVariable]!=0)&&(iDeltaIndex < m_vpmapDeltaTable.size()))
		{
			DOUBLE_VALARRAY valaTempDelta(0.0,iGetSizeDepVariables());
			InterpolateT(TRUE,valIndVariables,m_vpmapDeltaTable[iDeltaIndex],&valaTempDelta);

			assert( pvalOutputRowDelta != 0x0 );
			assert( pvalOutputRowDelta->size() == valaTempDelta.size() );
			(*pvalOutputRowDelta) += valaTempDelta;
		}
	}
	InterpolateT(FALSE,valIndVariables,m_vpmapDeltaTable[0],pvalOutputRowBase,pvalOutputRowDerivative);

	return;
}


void CDeltaTable::SubtractBaseTables()
{
	// subtract base table from all other tables
	// assume the first table is the base table
	MAP_DOUBLE_DATATABLE_IT itDeltaTableBase=(*(&*m_vpmapDeltaTable.begin()))->m_maptableData.begin();
	for(VP_DELTA_TABLE_MAP_IT itDeltaMap=m_vpmapDeltaTable.begin()+1;itDeltaMap!=m_vpmapDeltaTable.end();itDeltaMap++)
	{
		for( MAP_DOUBLE_DATATABLE_IT itDeltaTable=(*itDeltaMap)->m_maptableData.begin();
				 itDeltaTable!=(*itDeltaMap)->m_maptableData.end();itDeltaTable++)
		{
			*((*itDeltaTable).second) -= *((*itDeltaTableBase).second);
		}
	}

	return;
}

void CDeltaTable::FindDeltaEndPoints(int iIndVariableIndex,double dDeltaValue,double& rdDeltaUpper,double& rdDeltaLower)
{
	int iDeltaIndex = iIndVariableIndex - enindvarFirstDelta + 1;
	if(iDeltaIndex >= m_vpmapDeltaTable.size())
	{
		// not enough delta tables defined to evaluate derivative for this delta
		rdDeltaLower = 0.0;
		rdDeltaUpper = 0.0;
		return;
	}
	MAP_DOUBLE_DATATABLE* pmapDataTables = &(m_vpmapDeltaTable[iDeltaIndex]->m_maptableData);

	if(pmapDataTables->size()==1)
	{
		// the second point is assumed to be zero
		double dTemp = (*(pmapDataTables->begin())).first;
		if(dTemp > 0)
		{
			rdDeltaUpper = dTemp;
			rdDeltaLower = 0.0;
		}
		else
		{
			rdDeltaUpper = 0.0;
			rdDeltaLower = dTemp;
		}
	}
	else if(pmapDataTables->size() < 1)
	{
		// this is an error condition, there are no points in this map
		rdDeltaUpper = rdDeltaLower = 0;
	}
	else
	{
		// need the pair of deltas surronding this delta or the line segment that it is attached to
		// ASSUME:: zero is a point of interest

		std::pair<MAP_DOUBLE_DATATABLE_IT, MAP_DOUBLE_DATATABLE_IT> pairitRange;
		pairitRange = pmapDataTables->equal_range(dDeltaValue);

		MAP_DOUBLE_DATATABLE_IT itSecondPlusOne = pairitRange.second;
		itSecondPlusOne++;

		if((pairitRange.first)->first != dDeltaValue)
		{
			if(pairitRange.first != pmapDataTables->begin())
			{
				pairitRange.first--;
			}
			else
			{
				pairitRange.first = pmapDataTables->end();
			}
		}
		else if((pairitRange.second != pmapDataTables->end())&& (pairitRange.first!=pairitRange.second))
		{
		}
		else if((pairitRange.second != pmapDataTables->end())&& (itSecondPlusOne!=pmapDataTables->end()))
		{
			pairitRange.second++;
		}
		else if((pairitRange.first!=pmapDataTables->begin()))
		{
			if(pairitRange.second == pmapDataTables->end())
			{
				MAP_DOUBLE_DATATABLE_IT itTemp = pairitRange.first;
				pairitRange.second = itTemp;
			}
			pairitRange.first--;
		}
		else
		{
			pairitRange.second = pairitRange.first;
		}
		rdDeltaLower = (pairitRange.first==pmapDataTables->end())?(0.0):((pairitRange.first)->first);
		rdDeltaUpper = (pairitRange.second==pmapDataTables->end())?(0.0):((pairitRange.second)->first);
		double dTempLower = (pairitRange.first)->first;
		double dTempUpper = (pairitRange.second)->first;
		if((dTempUpper != dTempLower)&&((dTempUpper>=0)&&(dTempLower>=0)||((dTempUpper<=0)&&(dTempLower<=0))))
		{
			if(dTempUpper > dTempLower)
			{
				rdDeltaUpper = dTempUpper;
				rdDeltaLower = dTempLower;
			}
			else
			{
				rdDeltaUpper = dTempLower;
				rdDeltaLower = dTempUpper;
			}
		}
		else if(dTempUpper == dTempLower)
		{
			if(dTempUpper>0)
			{
				rdDeltaUpper = dTempUpper;
				rdDeltaLower = 0.0;
			}
			else
			{
				rdDeltaUpper = 0.0;
				rdDeltaLower = dTempUpper;
			}
		}
		else if((dTempUpper>0.0)&&(dTempLower<0.0))
		{
			if(dDeltaValue < 0.0)
			{
				rdDeltaUpper = 0.0;
				rdDeltaLower = dTempLower;
			}
			else
		{
			rdDeltaUpper = dTempUpper;
			rdDeltaLower = 0.0;
			}
		}
		else if((dTempUpper<0)&&(dTempLower>0))
		{
			rdDeltaUpper = dTempLower;
			rdDeltaLower = 0.0;
		}
		else
		{
			// this is for cases that I missed, it should be an error
			rdDeltaLower = dTempLower;
			rdDeltaUpper = dTempUpper;
		}
	}
}
