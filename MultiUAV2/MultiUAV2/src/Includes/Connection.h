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
//
// Connection.h: interface for the CConnection class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CONNECTION_H__DC813EE0_9108_11D3_99EE_00104B70C01B__INCLUDED_)
#define AFX_CONNECTION_H__DC813EE0_9108_11D3_99EE_00104B70C01B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "GlobalDefines.h"	// globally defined constants

//using namespace std;

class CConnection  
{
public:
	CConnection();
	CConnection(int iConnectToIndex,double dConnectToWeight);
	virtual ~CConnection();

public:
	void operator =(CConnection ctnConnection);
	BOOL operator ==(CConnection ctnConnection);
	BOOL operator ==(int iConnectToIndex);	// check to see if connection exists
	int iGetConnectToIndex(){return(m_iConnectToIndex);};
	void SetConnectToIndex(int ConnectToIndex){m_iConnectToIndex = ConnectToIndex;};
	double dGetConnectToWeight(){return(m_dConnectToWeight);};
	void SetConnectToWeight(double dConnectToWeight){m_dConnectToWeight = dConnectToWeight;};
	double dGetWeightLength(){return(m_dWeightLength);};
	void SetWeightLength(double dWeightLength){m_dWeightLength = dWeightLength;};
	double dGetWeightDetection(){return(m_dWeightDetection);};
	void SetWeightDetection(double dWeightDetection){m_dWeightDetection = dWeightDetection;};
	int iGetThreat1(){return(m_iThreat1);};
	void SetThreat1(int iThreat1){m_iThreat1 = iThreat1;};
	int iGetThreat2(){return(m_iThreat2);};
	void SetThreat2(int iThreat2){m_iThreat2 = iThreat2;};

	BOOL bGetAssociatedWithThreat(int iThreat){return((m_iThreat1==iThreat)||(m_iThreat2==iThreat));};
protected:
	int m_iConnectToIndex;
	double m_dConnectToWeight;
	double m_dWeightLength;
	double m_dWeightDetection;
	int m_iThreat1;
	int m_iThreat2;
};

#endif // !defined(AFX_CONNECTION_H__DC813EE0_9108_11D3_99EE_00104B70C01B__INCLUDED_)
