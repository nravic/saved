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
// RasMatrix.h: interface for the CRasMatrix class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_RASMATRIX_H__BDFC62FD_5254_46DF_8B5E_8D45317C1F5C__INCLUDED_)
#define AFX_RASMATRIX_H__BDFC62FD_5254_46DF_8B5E_8D45317C1F5C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <cassert>

#include <valarray>
using namespace std;
#include <iostream>

#include <GlobalDefines.h>

template<class VARIABLE_t>
class CRasMatrix  
{
public:		//CONSTRUCTORS/DESTRUCTORS
	CRasMatrix(size_t szRows=1,size_t szColumns=1,VARIABLE_t vDefaultValue=0.0)
		:m_szRows(szRows),m_szColumns(szColumns),m_valvData(vDefaultValue,szRows*szColumns)	{};
	CRasMatrix(size_t szRows,size_t szColumns,VARIABLE_t* pvDefaultValues)
		:m_szRows(szRows),m_szColumns(szColumns),m_valvData(pvDefaultValues,szRows*szColumns)	{};
	virtual ~CRasMatrix(){};
	//copy constructor
	CRasMatrix(CRasMatrix& rhs)
	{
		Resize(rhs.sGetszRows(),rhs.sGetszColumns());
		sGetvalvData() = rhs.sGetvalvData();
		sGetszRows() = rhs.sGetszRows();
		sGetszColumns() = rhs.sGetszColumns();
	};

public:		//ENUMS AND TYPEDEFS
	typedef valarray<VARIABLE_t> VAL_VARIABLE_t;

public:		//ACCESSORS	(storage at end of class)
	size_t& sGetszRows(){ return(m_szRows); }
	const size_t& sGetszRows() const { return(m_szRows); }

	size_t& sGetszColumns(){ return(m_szColumns); }
	const size_t& sGetszColumns() const { return(m_szColumns); }

	VAL_VARIABLE_t& sGetvalvData(){ return(m_valvData); }
	const VAL_VARIABLE_t& sGetvalvData() const { return(m_valvData); }

public:		//OPERATOR OVERRIDES
	CRasMatrix& operator=(CRasMatrix& rhs)
	{
		Resize(rhs.sGetszRows(),rhs.sGetszColumns());
		sGetvalvData() = rhs.sGetvalvData();
		sGetszRows() = rhs.sGetszRows();
		sGetszColumns() = rhs.sGetszColumns();

		return(*this);
	};
	VARIABLE_t& operator()(size_t szRow,size_t szColumn)
	{
		//TODO:: check for sizes???
		assert(szRow<sGetszRows());
		assert(szColumn<sGetszColumns());
		size_t szDataIndex = (szRow*sGetszColumns()) + szColumn;	//row major
		return(sGetvalvData()[szDataIndex]);
	};
	const VARIABLE_t operator()(size_t szRow,size_t szColumn) const
	{
		//TODO:: check for sizes???
		assert(szRow<sGetszRows());
		assert(szColumn<sGetszColumns());
		size_t szDataIndex = (szRow*sGetszColumns()) + szColumn;	//row major
		return(sGetvalvData()[szDataIndex]);
	};
public:		//FUNCTIONS
	void Product(const CRasMatrix& rmMatrixLeft,const CRasMatrix& rmMatrixRight)	
	{
		assert(rmMatrixLeft.sGetszColumns()==rmMatrixRight.sGetszRows());
		if((sGetszRows()!=rmMatrixLeft.sGetszRows())|
			(sGetszColumns()!=rmMatrixRight.sGetszColumns()))
		{
			Resize(rmMatrixLeft.sGetszRows(),rmMatrixRight.sGetszColumns());
		}

		for(size_t szCountColumns=0;szCountColumns<sGetszColumns();szCountColumns++)
		{
			for(size_t szCountRows=0;szCountRows<sGetszRows();szCountRows++)
			{
				VARIABLE_t vSumTemp = 0.0;
				for(size_t szCountElement=0;szCountElement<rmMatrixLeft.sGetszColumns();szCountElement++)
				{
					VARIABLE_t vTemp1 = rmMatrixLeft(szCountRows,szCountElement);
					VARIABLE_t vTemp2 = rmMatrixRight(szCountElement,szCountColumns);
					vSumTemp += vTemp1 * vTemp2;
				}
				operator()(szCountRows,szCountColumns) = vSumTemp;
			}
		}
	};
	void Sum(const CRasMatrix& rmMatrixLeft,const CRasMatrix& rmMatrixRight)	
	{
		assert(rmMatrixLeft.sGetszColumns()==rmMatrixRight.sGetszColumns());
		assert(rmMatrixLeft.sGetszRows()==rmMatrixRight.sGetszRows());
		if((sGetszRows()!=rmMatrixLeft.sGetszRows())|
			(sGetszColumns()!=rmMatrixLeft.sGetszColumns()))
		{
			Resize(rmMatrixLeft.sGetszRows(),rmMatrixLeft.sGetszColumns());
		}
		sGetvalvData() = rmMatrixLeft.sGetvalvData() + rmMatrixRight.sGetvalvData();
	};
	void DivideByScalar(const CRasMatrix& rmMatrix,const VARIABLE_t& vScalar)	
	{
		if((sGetszRows()!=rmMatrix.sGetszRows())|
			(sGetszColumns()!=rmMatrix.sGetszColumns()))
		{
			Resize(rmMatrix.sGetszRows(),rmMatrix.sGetszColumns());
		}
		sGetvalvData() = rmMatrix.sGetvalvData() / vScalar;
	};
	void Transpose(CRasMatrix& rmMatrix)	
	{
		CRasMatrix* prmTemp = 0;
		BOOL bLocalAllocation = FALSE;
		if(&rmMatrix != this)
		{
			prmTemp = &rmMatrix;
			Resize(rmMatrix.sGetszColumns(),rmMatrix.sGetszRows());
		}
		else
		{
			bLocalAllocation = TRUE;
			prmTemp = new CRasMatrix();
			*prmTemp = rmMatrix;
		}
		for(size_t szCountColumns=0;szCountColumns<sGetszColumns();szCountColumns++)
		{
			for(size_t szCountRows=0;szCountRows<sGetszRows();szCountRows++)
			{
				operator()(szCountRows,szCountColumns) = (*prmTemp)(szCountColumns,szCountRows);
			}
		}
		if(bLocalAllocation)
		{
			delete prmTemp;
			prmTemp = 0;
		}
	};

	void Resize(size_t szRows,size_t szColumns,VARIABLE_t vDefaultValue=0.0)
	{
		sGetvalvData().resize((szRows*szColumns),vDefaultValue);
		sGetszRows() = szRows;
		sGetszColumns() = szColumns;
	};

	VARIABLE_t vGetSumRow(size_t szRow)
	{
		//TODO:: check for sizes???
		assert(szRow<sGetszRows());
		size_t szDataIndex = szRow*sGetszColumns();	//row major
		VARIABLE_t vReturnValue = 0.0;
		for(size_t szCountColumns=szDataIndex;szCountColumns<sGetszColumns();szCountColumns++,szDataIndex++)
		{
			vReturnValue += sGetvalvData()[szDataIndex];
		}
		return(vReturnValue);
	};

	VARIABLE_t vGetSumColumn(size_t szColumn)
	{
		//TODO:: check for sizes???
		assert(szColumn<sGetszColumns());
		size_t szDataIndex = szColumn;
		VARIABLE_t vReturnValue = 0.0;
		for(size_t szCountRows=0;szCountRows<sGetszRows();szCountRows++,szDataIndex+=sGetszColumns())
		{
			vReturnValue += sGetvalvData()[szDataIndex];
		}
		return(vReturnValue);
	};

	void InvertMatrix3X3(const CRasMatrix & mInput)
	{
		CRasMatrix mdAdjoint(3,3);
		size_t szRow1 = 1;	size_t szRow2 = 2;	size_t szCol1 = 1;	size_t szCol2 = 2;
		mdAdjoint(0,0) = (mInput(szRow1,szCol1)*mInput(szRow2,szCol2) - mInput(szRow2,szCol1)*mInput(szRow1,szCol2));
		szRow1 = 1;	szRow2 = 2;	szCol1 = 0;	szCol2 = 2;
		mdAdjoint(0,1) = -(mInput(szRow1,szCol1)*mInput(szRow2,szCol2) - mInput(szRow2,szCol1)*mInput(szRow1,szCol2));
		szRow1 = 1;	szRow2 = 2;	szCol1 = 0;	szCol2 = 1;
		mdAdjoint(0,2) = (mInput(szRow1,szCol1)*mInput(szRow2,szCol2) - mInput(szRow2,szCol1)*mInput(szRow1,szCol2));

		szRow1 = 0;	szRow2 = 2;	szCol1 = 1;	szCol2 = 2;
		mdAdjoint(1,0) = -(mInput(szRow1,szCol1)*mInput(szRow2,szCol2) - mInput(szRow2,szCol1)*mInput(szRow1,szCol2));
		szRow1 = 0;	szRow2 = 2;	szCol1 = 0;	szCol2 = 2;
		mdAdjoint(1,1) = (mInput(szRow1,szCol1)*mInput(szRow2,szCol2) - mInput(szRow2,szCol1)*mInput(szRow1,szCol2));
		szRow1 = 0;	szRow2 = 2;	szCol1 = 0;	szCol2 = 1;
		mdAdjoint(1,2) = -(mInput(szRow1,szCol1)*mInput(szRow2,szCol2) - mInput(szRow2,szCol1)*mInput(szRow1,szCol2));

		szRow1 = 0;	szRow2 = 1;	szCol1 = 1;	szCol2 = 2;
		mdAdjoint(2,0) = (mInput(szRow1,szCol1)*mInput(szRow2,szCol2) - mInput(szRow2,szCol1)*mInput(szRow1,szCol2));
		szRow1 = 0;	szRow2 = 1;	szCol1 = 0;	szCol2 = 2;
		mdAdjoint(2,1) = -(mInput(szRow1,szCol1)*mInput(szRow2,szCol2) - mInput(szRow2,szCol1)*mInput(szRow1,szCol2));
		szRow1 = 0;	szRow2 = 1;	szCol1 = 0;	szCol2 = 1;
		mdAdjoint(2,2) = (mInput(szRow1,szCol1)*mInput(szRow2,szCol2) - mInput(szRow2,szCol1)*mInput(szRow1,szCol2));

		VARIABLE_t dDeterminant = (mInput(0,0)*mdAdjoint(0,0)) + (mInput(0,1)*mdAdjoint(0,1)) + (mInput(0,2)*mdAdjoint(0,2));

		DivideByScalar(mdAdjoint,dDeterminant);
	};

protected:
	size_t m_szRows;
	size_t m_szColumns;
	VAL_VARIABLE_t m_valvData;
};

template<class VARIABLE_t>
ostream &operator << (ostream &os,const CRasMatrix<VARIABLE_t>& matRhs) 
{
        size_t szRows = matRhs.sGetszRows();
        size_t szColumns = matRhs.sGetszColumns();
 //       os << '[' << szRows << ',' << szColumns << "][";
        os << '[' ;
        if (szRows > 0) 
		{
            os << ' ' ;
            if (szColumns > 0)
                os << matRhs(0,0);
            for (size_t j = 1; j < szColumns; ++ j)
			{
                os << ',' << matRhs(0,j);
			}
			if(szRows > 1)
			{
				os << ';';
			}
        }
        for (size_t i = 1; i < szRows; ++ i) 
		{
            os << " " ;
            if (szColumns > 0)
			{
                os << matRhs(i,0);
			}
            for(size_t j = 1; j < szColumns; ++ j)
			{
                os << ',' << matRhs(i,j);
			}
			if(i != szRows-1)
			{
				os << ';';
			}
        }
        os << ']';
        return os;
    }
#endif // !defined(AFX_RASMATRIX_H__BDFC62FD_5254_46DF_8B5E_8D45317C1F5C__INCLUDED_)
