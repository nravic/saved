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
// DATCOMTable.cpp: implementation of the CDATCOMTable class.
//
//////////////////////////////////////////////////////////////////////


#pragma warning(disable:4786)

#include <cassert>
#include <sstream>	//stringstream
using namespace std;

#include <float.h>	//DBL_MAX

#include "DATCOMTable.h"


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CDATCOMTable::CDATCOMTable()
	: m_iSizeIndVariableVector(-1)
{}

CDATCOMTable::~CDATCOMTable()
{
}


BOOL CDATCOMTable::bReadDataFile(const char *pcDataFileName,BOOL bSubtractBaseTables)
{
	BOOL bReturn = FALSE;
	ifstream fstrFile(pcDataFileName);
//	fstrFile.open("Datacom.dat",(ios::in|ios::nocreate));
	if(fstrFile.is_open())
	{
		bReturn = bReadDataFile(fstrFile,bSubtractBaseTables);
	}
	return(bReturn);
}

BOOL CDATCOMTable::bReadDataFile(ifstream& fstrFile,BOOL bSubtractBaseTables)
{
	char caTemp[MAX_LENGTH_LINE];
	BOOL bReturn = FALSE;
	
	//VARIABLES: MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4
	fstrFile.getline(caTemp,MAX_LENGTH_LINE);	//read/discard line
//	fstrFile.getline(caTemp,MAX_LENGTH_LINE);	//read/discard line
	//           ROWS, TOTAL COLUMNS, COLUMNS OF DERIVATIVES
	fstrFile.getline(caTemp,MAX_LENGTH_LINE);	//read/discard line
	//DATA:      ALPHA,CN,CM,CA,CY,CLN,CLL,CNQ,CMQ,CAQ,CYR,CLNR,CLLR,CYP,CLNP,CLLP
	fstrFile.getline(caTemp,MAX_LENGTH_LINE,'\n');	//read/discard line

	VDOUBLE vIndVariableValues;

	while(fstrFile.peek() != EOF)
	{
		// remove any extra spaces and lines from the data file
		char cPeek = fstrFile.peek();
		while((cPeek==' ')||(cPeek=='\t')||(cPeek=='\n')||(cPeek=='\r')||(cPeek=='\v')||(cPeek=='\f'))	
		{
			fstrFile.ignore();
			cPeek = fstrFile.peek();
		}
		fstrFile.getline(caTemp,MAX_LENGTH_LINE,'\n');
		istringstream istrInputLine(caTemp);

		m_iSizeIndVariableVector = 1;	// start at one to account for alpha
		int iCountIndVariables = enindvarMach;	// this is an index, so it is one less than the size required for mach
		vIndVariableValues.resize(0,0.0);
		vIndVariableValues.resize(iCountIndVariables,0.0);
		while(istrInputLine.peek() != EOF)
		{
			double dTemp;
			istrInputLine >> dTemp;
			iCountIndVariables++;
			m_iSizeIndVariableVector++;
			vIndVariableValues.push_back(dTemp);
//			fstrFile.eatwhite();
		}

		mapmachdataTables.SetDeltaIndex(enindvarMach);
		if(mapmachdataTables.m_maptableData.find(vIndVariableValues[enindvarMach]) == mapmachdataTables.m_maptableData.end())
		{
			mapmachdataTables.m_maptableData[vIndVariableValues[enindvarMach]]= new CDeltaTable;
		}
		bReturn = mapmachdataTables.m_maptableData[vIndVariableValues[enindvarMach]]->bReadDataFile(&fstrFile,&vIndVariableValues);


		// remove any extra spaces and lines from the data file
		cPeek = fstrFile.peek();
		while((cPeek==' ')||(cPeek=='\t')||(cPeek=='\n')||(cPeek=='\r')||(cPeek=='\v')||(cPeek=='\f'))	
		{
			fstrFile.ignore();
			cPeek = fstrFile.peek();
		}
	}		//while(fstrFile.peek() != EOF)
	fstrFile.close();

	if(bSubtractBaseTables)
	{
		// subtract base table from all other tables
		for(MAP_DOUBLE_DELTATABLE_IT itTable=mapmachdataTables.m_maptableData.begin();itTable!=mapmachdataTables.m_maptableData.end();itTable++)
		{
			itTable->second->SubtractBaseTables();
		}
	}

  // size the output based on what was read from the file
	assert( mapmachdataTables.iGetSizeDepVariables() > 0 );
	assert( mapmachdataTables.iGetSizeExtraVariables() > 0 );
	m_valOutputBase.resize( mapmachdataTables.iGetSizeDepVariables() );
	m_valOutputDelta.resize( mapmachdataTables.iGetSizeDepVariables() );
	m_valOutputDerivative.resize( mapmachdataTables.iGetSizeExtraVariables() );

# ifdef JWM_DEBUG
	const char* debug_fname = "debug_datcom_table.txt";
	DumpTableToFileNamed( debug_fname );
# endif	

	return(bReturn);
}


void CDATCOMTable::Interpolate(double* pdIndVariables,int iSizeIndVariables) 
{

	DOUBLE_VALARRAY valIndVariables(iSizeIndVariables);

	for(int iCountInputs=0;iCountInputs<iSizeIndVariables;iCountInputs++)
	{
		valIndVariables[iCountInputs] = pdIndVariables[iCountInputs];
	}
	InterpolateT(FALSE,valIndVariables,&mapmachdataTables,&m_valOutputDelta,&m_valOutputDerivative,&m_valOutputBase);
}

void CDATCOMTable::Interpolate(VDOUBLE& vdIndVariables) 
{

	DOUBLE_VALARRAY valIndVariables(vdIndVariables.size());

	int iCountInputs=0;
	for(VDOUBLE_IT itIndVariable=vdIndVariables.begin();itIndVariable!=vdIndVariables.end();itIndVariable++,iCountInputs++)
	{
		valIndVariables[iCountInputs] = *itIndVariable;
	}
	InterpolateT(FALSE,valIndVariables,&mapmachdataTables,&m_valOutputDelta,&m_valOutputDerivative,&m_valOutputBase);
}


void CDATCOMTable::Interpolate(	DOUBLE_VALARRAY& valdIndVariables,
								DOUBLE_VALARRAY& valdDepVariablesDelta,
								DOUBLE_VALARRAY& valdDepVariablesDerivative,
								DOUBLE_VALARRAY& valdDepVariablesBase) 
{
	InterpolateT(FALSE,valdIndVariables,&mapmachdataTables,&valdDepVariablesDelta,&valdDepVariablesDerivative,&valdDepVariablesBase);
}


void CDATCOMTable::GetOutput(double *pdDepVariablesDelta, double *pdDepVariablesDerivative, double *pdDepVariablesBase)
{
	int iCountOutputs; // for scope hack for vile MSVC++ 6
	for(iCountOutputs=0;iCountOutputs<m_valOutputDelta.size();iCountOutputs++)
	{
		pdDepVariablesDelta[iCountOutputs] = m_valOutputDelta[iCountOutputs];
	}
	for(iCountOutputs=0;iCountOutputs<m_valOutputDerivative.size();iCountOutputs++)
	{
		pdDepVariablesDerivative[iCountOutputs] = m_valOutputDerivative[iCountOutputs];
	}
	for(iCountOutputs=0;iCountOutputs<m_valOutputBase.size();iCountOutputs++)
	{
		pdDepVariablesBase[iCountOutputs] = m_valOutputBase[iCountOutputs];
	}
}

void CDATCOMTable::GetOutput(VDOUBLE& vdDepVariablesDelta,VDOUBLE& vdDepVariablesDerivative,VDOUBLE& vdDepVariablesBase)
{
	int iCountOutputs; // for scope hack for odious MSVC++ 6
	for(iCountOutputs=0;iCountOutputs<m_valOutputDelta.size();iCountOutputs++)
	{
		vdDepVariablesDelta.push_back(m_valOutputDelta[iCountOutputs]);
	}
	for(iCountOutputs=0;iCountOutputs<m_valOutputDerivative.size();iCountOutputs++)
	{
		vdDepVariablesDerivative.push_back(m_valOutputDerivative[iCountOutputs]);
	}
	for(iCountOutputs=0;iCountOutputs<m_valOutputBase.size();iCountOutputs++)
	{
		vdDepVariablesBase.push_back(m_valOutputBase[iCountOutputs]);
	}
}

void CDATCOMTable::CalculateDerivatives(double *pdIndVariables, int iSizeIndVariables)
{
	m_vdvalControlDerivatives.clear();
	m_vdvalControlIntercepts.clear();

	DOUBLE_VALARRAY valIndVariables(iSizeIndVariables);

	for(int iCountInputs=0;iCountInputs<iSizeIndVariables;iCountInputs++)
	{
		valIndVariables[iCountInputs] = pdIndVariables[iCountInputs];
	}

	int iNumberDepVariables = iGetSizeDepVariables();

	for(int iCountDeltas=enindvarFirstDelta;iCountDeltas<iSizeIndVariables;iCountDeltas++)
	{
		//ASSUME:: each delta has the same number of tables for every flight condition
		double dDeltaUpper = 0.0;
		double dDeltaLower = 0.0;
		mapmachdataTables.FindDeltaEndPoints(iCountDeltas,pdIndVariables[iCountDeltas],dDeltaUpper,dDeltaLower);

		DOUBLE_VALARRAY vaDerivativesTemp(DBL_MAX,iNumberDepVariables);
		DOUBLE_VALARRAY vaInterceptsTemp(DBL_MAX,iNumberDepVariables);

		if(dDeltaUpper != dDeltaLower)
		{
			DOUBLE_VALARRAY vaDeltaTemp(0.0,valIndVariables.size());
			vaDeltaTemp[enindvarAlpha] = valIndVariables[enindvarAlpha];
			vaDeltaTemp[enindvarMach] = valIndVariables[enindvarMach];

			vaDeltaTemp[iCountDeltas] = dDeltaLower;
			DOUBLE_VALARRAY vaTempDeltaOutLower(0.0,iGetSizeDepVariables());
			InterpolateT(FALSE,vaDeltaTemp,&mapmachdataTables,&vaTempDeltaOutLower);

			vaDeltaTemp[iCountDeltas] = dDeltaUpper;
			DOUBLE_VALARRAY vaTempDeltaOutUpper(0.0,iGetSizeDepVariables());
			InterpolateT(FALSE,vaDeltaTemp,&mapmachdataTables,&vaTempDeltaOutUpper);

			double dDenominator = dDeltaUpper - dDeltaLower;
			vaDerivativesTemp = (vaTempDeltaOutUpper - vaTempDeltaOutLower)/dDenominator;

			vaInterceptsTemp = -(vaDerivativesTemp*dDeltaLower) + vaTempDeltaOutLower;
		}
		else
		{
			//ERROR:: can't calculate deriative fill ouput with DBL_MAX
		}
		m_vdvalControlDerivatives.push_back(vaDerivativesTemp);
		m_vdvalControlIntercepts.push_back(vaInterceptsTemp);
	}
}



void CDATCOMTable::CalculateDerivatives(	DOUBLE_VALARRAY& valdIndVariables,
											V_DOUBLE_VALARRAY& vdvalDerivatives,
											V_DOUBLE_VALARRAY& vdvalIntercepts)
{
	int iNumberDepVariables = iGetSizeDepVariables();

	for(int iCountDeltas=enindvarFirstDelta;iCountDeltas<valdIndVariables.size();iCountDeltas++)
	{
		//ASSUME:: each delta has the same number of tables for every flight condition
		double dDeltaUpper = 0.0;
		double dDeltaLower = 0.0;
		mapmachdataTables.FindDeltaEndPoints(iCountDeltas,valdIndVariables[iCountDeltas],dDeltaUpper,dDeltaLower);

		DOUBLE_VALARRAY vaInterceptsTemp(DBL_MAX,iNumberDepVariables);

		if(dDeltaUpper != dDeltaLower)
		{
			DOUBLE_VALARRAY vaDeltaTemp(0.0,valdIndVariables.size());
			vaDeltaTemp[enindvarAlpha] = valdIndVariables[enindvarAlpha];
			vaDeltaTemp[enindvarMach] = valdIndVariables[enindvarMach];

			vaDeltaTemp[iCountDeltas] = dDeltaLower;
			DOUBLE_VALARRAY vaTempDeltaOutLower(0.0,iGetSizeDepVariables());
			InterpolateT(FALSE,vaDeltaTemp,&mapmachdataTables,&vaTempDeltaOutLower);

			vaDeltaTemp[iCountDeltas] = dDeltaUpper;
			DOUBLE_VALARRAY vaTempDeltaOutUpper(0.0,iGetSizeDepVariables());
			InterpolateT(FALSE,vaDeltaTemp,&mapmachdataTables,&vaTempDeltaOutUpper);

			double dDenominator = dDeltaUpper - dDeltaLower;
			vdvalDerivatives[iCountDeltas] = (vaTempDeltaOutUpper - vaTempDeltaOutLower)/dDenominator;

			vdvalIntercepts[iCountDeltas] = -(vdvalDerivatives[iCountDeltas]*dDeltaLower) + vaTempDeltaOutLower;
		}
		else
		{
			//ERROR:: can't calculate deriative fill ouput with DBL_MAX
		}
	}
}


void CDATCOMTable::GetDerivatives(double* pdControlDerivatives,double* pdControlIntercepts)
{
	int iColumnOffsetAmount = iGetRowsDerivativesIntercepts()-1;
	int iCountRows =0;
	for(V_DOUBLE_VALARRAY_IT itRowsDerivatives=m_vdvalControlDerivatives.begin(),
							itRowsIntercepts=m_vdvalControlIntercepts.begin();
							itRowsDerivatives!=m_vdvalControlDerivatives.end();
							itRowsDerivatives++,itRowsIntercepts++,iCountRows++)
	{
		for(int iColumnOffset=iCountRows, iCountColumn=0; iCountColumn<itRowsDerivatives->size();iCountColumn++,iColumnOffset+=iColumnOffsetAmount)
		{
			int iColumnIndex = iColumnOffset + iCountColumn;
			pdControlDerivatives[iColumnIndex] = (*itRowsDerivatives)[iCountColumn];
			pdControlIntercepts[iColumnIndex] =  (*itRowsIntercepts)[iCountColumn];
		}
	}
}
