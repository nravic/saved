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
// Interpolate.h: interface for the CInterpolate class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_INTERPOLATE_H__137E6944_7268_4831_B911_2961BC82D23C__INCLUDED_)
#define AFX_INTERPOLATE_H__137E6944_7268_4831_B911_2961BC82D23C__INCLUDED_


#pragma warning(disable:4786)


#include <GlobalDefines.h>

#include <cassert>
#include <fstream>	//ifstream

#ifdef JWM_DEBUG
# include <iostream>
#endif

using namespace std;

#include <resize_assign>


#define MAX_LENGTH_LINE 1024

#define BOUND_INVALID (DBL_MAX)

enum enBaseDataType 
{
	basedataNone,
	basedataBase,
	basedataExtra
};
enum enIndependentVariables 
{	
	enindvarAlpha,
	enindvarMach,
	enindvarAltitude,
	enindvarFirstDelta = enindvarAltitude,
	enindvarBeta
};	// order of independent variable in the input array

#include <valarray>
typedef valarray<double> DOUBLE_VALARRAY;

#include <vector>
typedef vector<double> VDOUBLE;
typedef VDOUBLE::iterator VDOUBLE_IT;

typedef vector<DOUBLE_VALARRAY> V_DOUBLE_VALARRAY;
typedef V_DOUBLE_VALARRAY::iterator V_DOUBLE_VALARRAY_IT;

//////////////////////////////////////////////////////////////////////
// DEFINITION OF INTERPOLATION TEMPLATE
//////////////////////////////////////////////////////////////////////

template<class DEPENDENT_VARIABLE_TABLE,class DEPENDENT_VARIABLE> 
void InterpolateT(
					BOOL bAddZeroPoint,
					DOUBLE_VALARRAY& vaindepVariable,
					DEPENDENT_VARIABLE_TABLE* pdependentVariableTable,
					DEPENDENT_VARIABLE* pdepvarOutputDelta,
					DEPENDENT_VARIABLE* pdepvarOutputDerivative=NULL,
					DEPENDENT_VARIABLE* pdepvarOutputBase=NULL
					)
{

	// the following algorithm can be very confusing, so read carefully...
	if( pdepvarOutputDelta      == 0x0 &&
			pdepvarOutputDerivative == 0x0 &&
			pdepvarOutputBase       == 0x0    )
	{
		// move 'nothing to do' higher in the chain; see below.
		return;
	}

	double indepVariable = 0.0;
	double indepValueUpper = 0.0;
	double indepValueLower = 0.0;

	// This next decl block should really include the correct size for all
	// the array like performers, however it is not so, and the 
	// resize_assign_{array,scalar}() family takes care of this.
	// Nevertheless, better to give the size so folks know the lineage.  A
	// few notes are included on this below:
  //   0. see iGetSizeDepVariables(); need to allocate space, maybe static?
  //   1. (digging) const size_t k=pdependentVariableTable->mappvalData.begin()->second->size();
  //   2. (quick-n-dirty) const size_t k = pdepvarOutputDelta->size();
	DEPENDENT_VARIABLE depvarValueUpperDelta, depvarValueLowerDelta;
	DEPENDENT_VARIABLE depvarValueUpperDerivative, depvarValueLowerDerivative;
	DEPENDENT_VARIABLE depvarValueUpperBase, depvarValueLowerBase;



	if((pdepvarOutputDelta!=NULL)&&(pdependentVariableTable == NULL))
	{
		assert( pdepvarOutputDelta->size() > 0 );
		*pdepvarOutputDelta = 0.0;
	}
	if((pdepvarOutputDelta!=NULL)&&(pdepvarOutputDerivative!=NULL)&&(pdepvarOutputBase!=NULL))
	{
		pdependentVariableTable->GetIndVariableLimits(
														bAddZeroPoint,
														vaindepVariable,indepVariable,
														&indepValueUpper,&indepValueLower,
														&depvarValueUpperDelta,&depvarValueLowerDelta,
														&depvarValueUpperDerivative,&depvarValueLowerDerivative,
														&depvarValueUpperBase,&depvarValueLowerBase
														);
	}
	else if((pdepvarOutputDelta!=NULL)&&(pdepvarOutputDerivative!=NULL))
	{
		pdependentVariableTable->GetIndVariableLimits(
														bAddZeroPoint,
														vaindepVariable,indepVariable,
														&indepValueUpper,&indepValueLower,
														&depvarValueUpperDelta,&depvarValueLowerDelta,
														&depvarValueUpperDerivative,&depvarValueLowerDerivative
														);
	}
	else if((pdepvarOutputDelta!=NULL))
	{
		pdependentVariableTable->GetIndVariableLimits(
														bAddZeroPoint,
														vaindepVariable,indepVariable,
														&indepValueUpper,&indepValueLower,
														&depvarValueUpperDelta,&depvarValueLowerDelta
														);
	}
	else
	{
		bool error__no_output_vector_defined = true;
		assert( error__no_output_vector_defined == false );

		//TODO:: error encountered no output vector defined
		return;
	}

	if(((indepValueUpper!=indepValueLower)&&((indepValueUpper==BOUND_INVALID)||(indepValueLower==BOUND_INVALID)))||((indepValueUpper==indepValueLower)&&(indepValueUpper!=BOUND_INVALID)))	//only a single limit
	{
		if(indepValueUpper != BOUND_INVALID)
		{
			if(pdepvarOutputDerivative!=NULL)
			{
				resize_assign_array( depvarValueUpperDerivative, *pdepvarOutputDerivative );
			}
			if(pdepvarOutputBase!=NULL)
			{
				resize_assign_array( depvarValueUpperBase, *pdepvarOutputBase );
			}
			if(pdepvarOutputDelta!=NULL)
			{
				resize_assign_array( depvarValueUpperDelta, *pdepvarOutputDelta );
			}
		}
		else
		{
			if(pdepvarOutputDelta!=NULL)
			{
				resize_assign_array( depvarValueLowerDelta, *pdepvarOutputDelta );
			}
			if(pdepvarOutputDerivative!=NULL)
			{
				resize_assign_array( depvarValueLowerDerivative, *pdepvarOutputDerivative );
			}
			if(pdepvarOutputBase!=NULL)
			{
				resize_assign_array( depvarValueLowerBase, *pdepvarOutputBase );
			}
		}
		// handle the zero crossing:: this assumes that vales for zero deflection are zero
		if(indepValueLower == BOUND_INVALID)
		{
			if(indepValueUpper>(double)0.0)
			{
				double indepIndVariableTemp = (indepVariable<0)?(0.0):(indepVariable);	// do not extrapolate past zero
				double indepPercentInterpolate = indepIndVariableTemp/indepValueUpper;
				if(pdepvarOutputDelta!=NULL)
				{
					assert( pdepvarOutputDelta->size() > 0 );
					(*pdepvarOutputDelta) *= indepPercentInterpolate;
				}
				if(pdepvarOutputDerivative!=NULL)
				{
					assert( pdepvarOutputDerivative->size() > 0 );
					(*pdepvarOutputDerivative) *= indepPercentInterpolate;
				}
				if(pdepvarOutputBase!=NULL)
				{
					assert( pdepvarOutputBase->size() > 0 );
					(*pdepvarOutputBase) *= indepPercentInterpolate;
				}
			}
		}
		else if(indepValueUpper == BOUND_INVALID)
		{
			if(indepValueLower<(double)0.0)
			{
				double indepIndVariableTemp = (indepVariable>0)?(0.0):(indepVariable);	// do not extrapolate past zero
				double indepPercentInterpolate = (indepIndVariableTemp-indepValueLower)/(-indepValueLower);
				if(pdepvarOutputDelta!=NULL)
				{
					assert( pdepvarOutputDelta->size() > 0 );
					(*pdepvarOutputDelta) *= ((double)1.0 - indepPercentInterpolate);
				}
				if(pdepvarOutputDerivative!=NULL)
				{
					assert( pdepvarOutputDerivative->size() > 0 );
					(*pdepvarOutputDerivative) *= ((double)1.0 - indepPercentInterpolate);
				}
				if(pdepvarOutputBase!=NULL)
				{
					assert( pdepvarOutputBase->size() > 0 );
					(*pdepvarOutputBase) *= ((double)1.0 - indepPercentInterpolate);
				}
			}
		}
		else
		{
#   ifdef JWM_DEBUG
			bool error_encountered_while_calculating_table_indicies_nobounds = true;
			assert( error_encountered_while_calculating_table_indicies_nobounds == false );
#   endif

			//either greater that the maximum entry or less that the minimum entry or upper==lower.
		}
	}
	else if ((indepValueUpper!=BOUND_INVALID)&&(indepValueLower!=BOUND_INVALID))	
	{
		double indepPercentInterpolate = (indepVariable - indepValueLower)/(indepValueUpper - indepValueLower);
		if(pdepvarOutputDelta!=NULL)
		{
			resize_assign_array( ((depvarValueUpperDelta) - (depvarValueLowerDelta))*indepPercentInterpolate + depvarValueLowerDelta, 
													 *pdepvarOutputDelta );
		}
		if(pdepvarOutputDerivative!=NULL)
		{
			resize_assign_array( ((depvarValueUpperDerivative) - (depvarValueLowerDerivative))*indepPercentInterpolate + depvarValueLowerDerivative,
													 *pdepvarOutputDerivative );
		}
		if(pdepvarOutputBase!=NULL)
		{
			resize_assign_array( ((depvarValueUpperBase) - (depvarValueLowerBase))*indepPercentInterpolate + depvarValueLowerBase,
													 *pdepvarOutputBase );
		}
	}
	else
	{
#  ifdef JWM_DEBUG
		bool error_encountered_while_calculating_table_indicies = true;
		assert( error_encountered_while_calculating_table_indicies == false );
#  endif

		//TODO:: error encountered while calculating indicies
		(*pdepvarOutputDelta) = DEPENDENT_VARIABLE(0.0,pdepvarOutputDelta->size());

		return;
	}
}





//////////////////////////////////////////////////////////////////////
// DEFINITION OF TABLE MAP TEMPLATE
//////////////////////////////////////////////////////////////////////
template<class INDEPENDENT_VARIABLE,class DEPENDENT_VARIABLE,class MAP_TABLE,class TABLE_DATA> 
class CTableMap
{
public:
	typedef typename MAP_TABLE::iterator MAP_TABLE_IT_t;
	typedef typename MAP_TABLE::const_iterator MAP_TABLE_CIT_t;

	CTableMap(int iIndVariableIndex=-1);
	CTableMap(const CTableMap& rhs);
	~CTableMap();
public:
	void GetIndVariableLimits(
								BOOL bAddZeroPoint,
								DOUBLE_VALARRAY& vaindepVariable, double& indepVariable,
								double* pdIndValueUpper,double* pdIndValueLower,
								DEPENDENT_VARIABLE* DepValueUpperDelta,DEPENDENT_VARIABLE* DepValueLowerDelta,
								DEPENDENT_VARIABLE* DepValueUpperDerivative=NULL,DEPENDENT_VARIABLE* DepValueLowerDerivative=NULL,
								DEPENDENT_VARIABLE* DepValueUpperBase=NULL,DEPENDENT_VARIABLE* DepValueLowerBase=NULL
							);
	MAP_TABLE m_maptableData;

	BOOL bReadDataFile(ifstream* pifstrFile,VDOUBLE* pvdIndVariableValues)
	{
		BOOL ret = m_maptableData.bReadDataFile(pifstrFile,pvdIndVariableValues);

		assert( m_maptableData.size() > 0 );

#   ifdef JWM_DEBUG
		cerr << "m_maptableData.size() == " << m_maptableData.size() << endl;
		exit(0);
#   endif

		return(ret);
	}

	int iGetDeltaIndex(){return(m_iIndVariableIndex);};
	void SetDeltaIndex(int iIndVariableIndex){m_iIndVariableIndex=iIndVariableIndex;};

	int iGetSizeDepVariables(){return((!m_maptableData.empty())?(m_maptableData.begin()->second->iGetSizeDepVariables()):(-1));};
	int iGetSizeExtraVariables(){return((!m_maptableData.empty())?(m_maptableData.begin()->second->iGetSizeExtraVariables()):(-1));};

	int iGetSizeIndVariables(){return((!m_maptableData.empty())?(m_maptableData.begin()->second->iGetSizeIndVariables()):(-1));};

	void FindDeltaEndPoints(int iIndVariableIndex,double dDeltaValue,double& rdDeltaUpper,double& rdDeltaLower);

	void DumpTable(stringstream& sstrOutput,string strLabel)
	{
		for(MAP_TABLE_IT_t itTable=m_maptableData.begin();itTable!=m_maptableData.end();itTable++)
		{
			sstrOutput << strLabel << ":" << itTable->first << ":\n";	//print out the independent variable for these tables
			itTable->second->DumpTable(sstrOutput);
			sstrOutput << endl;
		}
		sstrOutput << endl;	//add an extra line return at the end of the tables
	};

protected:
	int m_iIndVariableIndex;	// index into the independent variable array for this delta, should be set when data is read
};


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
template<class INDEPENDENT_VARIABLE,class DEPENDENT_VARIABLE,class MAP_TABLE,class TABLE_DATA> 
CTableMap<INDEPENDENT_VARIABLE,DEPENDENT_VARIABLE,MAP_TABLE,TABLE_DATA>::CTableMap(int iIndVariableIndex)
{
	m_iIndVariableIndex = iIndVariableIndex;
}

template<class INDEPENDENT_VARIABLE,class DEPENDENT_VARIABLE,class MAP_TABLE,class TABLE_DATA> 
CTableMap<INDEPENDENT_VARIABLE,DEPENDENT_VARIABLE,MAP_TABLE,TABLE_DATA>::CTableMap(const CTableMap& rhs)	// copy constructor
{
	MAP_TABLE_CIT_t itRHS;
	for(itRHS=rhs.m_maptableData.begin();itRHS!=rhs.m_maptableData.end();itRHS++)
	{
		CTableMap datamapTemp;
		m_maptableData[itRHS->first] = new TABLE_DATA;
		*(m_maptableData[itRHS->first]) = *(itRHS->second);
	}
}


template<class INDEPENDENT_VARIABLE,class DEPENDENT_VARIABLE,class MAP_TABLE,class TABLE_DATA> 
CTableMap<INDEPENDENT_VARIABLE,DEPENDENT_VARIABLE,MAP_TABLE,TABLE_DATA>::~CTableMap()
{
	MAP_TABLE_CIT_t itMap;
	for(itMap=m_maptableData.begin();itMap!=m_maptableData.end();itMap++)
	{
		if(m_maptableData[itMap->first])
		{
			delete m_maptableData[itMap->first];
		}
	}
	m_maptableData.clear();
}

//////////////////////////////////////////////////////////////////////
// member functions
//////////////////////////////////////////////////////////////////////

template<class INDEPENDENT_VARIABLE,class DEPENDENT_VARIABLE,class MAP_TABLE,class TABLE_DATA> 
void CTableMap<INDEPENDENT_VARIABLE,DEPENDENT_VARIABLE,MAP_TABLE,TABLE_DATA>::
			GetIndVariableLimits(
									BOOL bAddZeroPoint,
									DOUBLE_VALARRAY& vaindepVariable, double& indepVariable,
									double* pdIndValueUpper,double* pdIndValueLower,
									DEPENDENT_VARIABLE* DepValueUpperDelta,DEPENDENT_VARIABLE* DepValueLowerDelta,
									DEPENDENT_VARIABLE* DepValueUpperDerivative,DEPENDENT_VARIABLE* DepValueLowerDerivative,
									DEPENDENT_VARIABLE* DepValueUpperBase,DEPENDENT_VARIABLE* DepValueLowerBase
								)
{
	double dIndValue = indepVariable = (m_iIndVariableIndex < 0)?(0.0):(vaindepVariable[m_iIndVariableIndex]);
	std::pair<MAP_TABLE_IT_t, MAP_TABLE_IT_t> pairitRange;
	pairitRange = m_maptableData.equal_range(dIndValue);
	if((&*pairitRange.first)->first != dIndValue)
	{
		if(pairitRange.first != m_maptableData.begin())
		{
			pairitRange.first--;
		}
		else
		{
			pairitRange.first = m_maptableData.end();
		}
	}
	else
	{
		pairitRange.second = pairitRange.first;
	}

	if((pairitRange.first!=m_maptableData.end())&&(pairitRange.second!=m_maptableData.end()))
	{
		if((&*pairitRange.first)->first != (&*pairitRange.second)->first)
		{
			*(pdIndValueLower) = (&*pairitRange.first)->first;
			*(pdIndValueUpper) = (&*pairitRange.second)->first;
			(&*pairitRange.second)->second->Interpolate(vaindepVariable,DepValueUpperDelta,DepValueUpperDerivative,DepValueUpperBase);
			(&*pairitRange.first)->second->Interpolate(vaindepVariable,DepValueLowerDelta,DepValueLowerDerivative,DepValueLowerBase);
		}
		else
		{
			*(pdIndValueLower) = (&*pairitRange.first)->first;
			*(pdIndValueUpper) = (&*pairitRange.second)->first;
			(&*pairitRange.second)->second->Interpolate(vaindepVariable,DepValueUpperDelta,DepValueUpperDerivative,DepValueUpperBase);
			DepValueLowerBase = DepValueUpperBase;
			DepValueLowerDelta = DepValueUpperDelta;
			DepValueLowerDerivative = DepValueUpperDerivative;
		}
	}
	else if( (&*pairitRange.first) != (&*m_maptableData.end()) )
	{
		// only lower is valid
		*(pdIndValueLower) = (&*pairitRange.first)->first;
		*(pdIndValueUpper) = BOUND_INVALID;
		(&*pairitRange.first)->second->Interpolate(vaindepVariable,DepValueLowerDelta,DepValueLowerDerivative,DepValueLowerBase);
	}
	else if( (&*pairitRange.second) != (&*m_maptableData.end()) )
	{
		// only upper is valid
		*(pdIndValueLower) = BOUND_INVALID;
		*(pdIndValueUpper) = (&*pairitRange.second)->first;
		(&*pairitRange.second)->second->Interpolate(vaindepVariable,DepValueUpperDelta,DepValueUpperDerivative,DepValueUpperBase);
	}
	else
	{
		// neither valid
		*(pdIndValueLower) = BOUND_INVALID;
		*(pdIndValueUpper) = BOUND_INVALID;
	}

	if(bAddZeroPoint)
	{
		// first need to determine what (vector) size is needed...
		const size_t DVT_SZ = 6;
		const DEPENDENT_VARIABLE* _dvtbl[] = { DepValueUpperDelta, DepValueLowerDelta,
																					 DepValueUpperDerivative, DepValueLowerDerivative,
																					 DepValueUpperBase, DepValueLowerBase };

		// look in the table for a non-null input...
		const DEPENDENT_VARIABLE** ptbl_end = &_dvtbl[0] - 1;
		const DEPENDENT_VARIABLE** ptbl = &_dvtbl[DVT_SZ-1];
		while( *ptbl-- == 0x0 && ptbl != ptbl_end ) {}

		assert( ptbl != ptbl_end  );
		assert( *ptbl != 0x0 );
		
		size_t sz = (*ptbl)->size();  // now we presume we know the size.
			
		if
		(	((*(pdIndValueLower)<0.0)&&(*(pdIndValueUpper)>0.0))&&
			((*(pdIndValueLower) != BOUND_INVALID)&&(*(pdIndValueUpper) != BOUND_INVALID))
		)
		{
			if(*(pdIndValueLower) == BOUND_INVALID)
			{
				*(pdIndValueLower) = 0.0;
				if(DepValueLowerDelta != NULL)
				{
					resize_assign_scalar( 0.0, sz, *DepValueLowerDelta );
				}
				if(DepValueLowerDerivative != NULL)
				{
					resize_assign_scalar( 0.0, sz, *DepValueLowerDerivative );
				}
				if(DepValueLowerBase != NULL)
				{
					resize_assign_scalar( 0.0, sz, *DepValueLowerBase );
				}
			}
			else if(*(pdIndValueUpper) == BOUND_INVALID)
			{
				*(pdIndValueUpper) = 0.0;
				if(DepValueUpperDelta != NULL)
				{
					resize_assign_scalar( 0.0, sz, *DepValueUpperDelta );
				}
				if(DepValueUpperDerivative != NULL)
				{
					resize_assign_scalar( 0.0, sz, *DepValueUpperDerivative );
				}
				if(DepValueUpperBase != NULL)
				{
					resize_assign_scalar( 0.0, sz, *DepValueUpperBase );
				}
			}
			else if(dIndValue >= 0.0)
			{
				*(pdIndValueLower) = 0.0;
				if(DepValueLowerDelta != NULL)
				{
					resize_assign_scalar( 0.0, sz, *DepValueLowerDelta );
				}
				if(DepValueLowerDerivative != NULL)
				{
					resize_assign_scalar( 0.0, sz, *DepValueLowerDerivative );
				}
				if(DepValueLowerBase != NULL)
				{
					resize_assign_scalar( 0.0, sz, *DepValueLowerBase );
				}
			}
			else
			{
				*(pdIndValueUpper) = 0.0;
				if(DepValueUpperDelta != NULL)
				{
					resize_assign_scalar( 0.0, sz, *DepValueUpperDelta );
				}
				if(DepValueUpperDerivative != NULL)
				{
					resize_assign_scalar( 0.0, sz, *DepValueUpperDerivative );
				}
				if(DepValueUpperBase != NULL)
				{
					resize_assign_scalar( 0.0, sz, *DepValueUpperBase );
				}
			}
		}
	}
}


template<class INDEPENDENT_VARIABLE,class DEPENDENT_VARIABLE,class MAP_TABLE,class TABLE_DATA> 
void CTableMap<INDEPENDENT_VARIABLE,DEPENDENT_VARIABLE,MAP_TABLE,TABLE_DATA>::FindDeltaEndPoints(int iIndVariableIndex,double dDeltaValue,
																							double& rdDeltaUpper,double& rdDeltaLower)
{
	m_maptableData.begin()->second->FindDeltaEndPoints(iIndVariableIndex,dDeltaValue,rdDeltaUpper,rdDeltaLower);
}


#endif // !defined(AFX_INTERPOLATE_H__137E6944_7268_4831_B911_2961BC82D23C__INCLUDED_)
