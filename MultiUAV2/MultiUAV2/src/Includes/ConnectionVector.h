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
// ConnectionVector.h: interface for the CConnections class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CONNECTIONVECTOR_H__DC813EE1_9108_11D3_99EE_00104B70C01B__INCLUDED_)
#define AFX_CONNECTIONVECTOR_H__DC813EE1_9108_11D3_99EE_00104B70C01B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <float.h>	//DBL_MAX
#include <vector>
#include "Connection.h"

using namespace std ;

class CConnectionVector  
{
public:
	CConnectionVector();
	virtual ~CConnectionVector();

public:
	CConnection cntnRemoveConnection(int iNodeIndex);
	BOOL bGetAssociatedWithThreat(int iThreat);
	int iFindConnectionIndex(int iNodeIndex);
	int iGetNumConnections(){return(vctnConnection.size());};
//	int iGetNumConnections(){return(m_iNumberConnections);};
	CConnection* pctnGetConnection(int iConnectionIndex);
	void SetConnectionWeight(int iConnectToIndex,double dConnecitonWeight=DBL_MAX,
									  double dWeightLength=DBL_MAX,
									  double dWeightDetection=DBL_MAX);
	void AddConnection(int iConnectToIndex,int iThreat1,int iThreat2,
									double dConnecitonWeight=DBL_MAX,
									double dWeightLength=DBL_MAX,
									double dWeightDetection=DBL_MAX);
	int iGetConnectToIndex(int iConnectionIndex){
								return((iConnectionIndex<vctnConnection.size())?
									vctnConnection[iConnectionIndex].iGetConnectToIndex():-1);};
	double dGetConnectToWeight(int iConnectionIndex);
	double dGetWeightLength(int iConnectionIndex);
	double dGetWeightDetection(int iConnectionIndex);

	vector<CConnection> vctnConnection;

protected:
//	int m_iNumberConnections;

};

#endif // !defined(AFX_CONNECTIONVECTOR_H__DC813EE1_9108_11D3_99EE_00104B70C01B__INCLUDED_)
