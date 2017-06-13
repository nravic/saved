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
// Node.h: interface for the CNode class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_NODE_H__DC813EE0_9108_11D3_99EE_00104B70C01B__INCLUDED_)
#define AFX_NODE_H__DC813EE0_9108_11D3_99EE_00104B70C01B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

//using namespace std;

#include "Threat.h"
#include "ConnectionVector.h"
#include "GlobalDefines.h"	// globally defined constants

#define NODE_UNDEFINED -1
#define DEFAULT_HEURISTIC_COST DBL_MAX/2.0
class CNode  
{
public:
	CNode(BOOL bRequired=FALSE);
	CNode(long int liPositionN,long int liPositionE=0,long int liPositionZ=0,BOOL bRequired=FALSE);
	virtual ~CNode();

public:
	double dDistance(CNode* pndeNode);
	double dDistance(long int liNorth,long int liEast);
	double dDistance(CThreat* pthrtThreat);

	int iFindConnection(int iIndex);
	void operator =(CNode ctnNode);
	void operator =(CNode* ctnNode);
	BOOL operator ==(CNode ctnNode);

	long int liGetPositionN(){return(m_liPositionN);};
	void SetPositionN(long int liPositionN){m_liPositionN = liPositionN;};

	long int liGetPositionE(){return(m_liPositionE);};
	void SetPositionE(long int liPositionE){m_liPositionE = liPositionE;};

	long int liGetPositionZ(){return(m_liPositionZ);};
	void SetPositionZ(long int liPositionZ){m_liPositionZ = liPositionZ;};

	int iGetNodeFrom(){return(m_iNodeFrom);};
	void SetNodeFrom(int iNodeFrom){m_iNodeFrom = iNodeFrom;};

	double dGetF(){return(m_dF);};
	void SetF(double dF){m_dF = dF;};

	double dGetG(){return(m_dG);};
	void SetG(double dG){m_dG = dG;};

	int iGetNumberConnections(){return(cvConnections.iGetNumConnections());};
	CConnection* pctnGetConnection(int iConnectionIndex){return(cvConnections.pctnGetConnection(iConnectionIndex));};

	void AddConnection(int iConnectToIndex,int iThreat1,int iThreat2,double dConnecitonWeight,
									  double dWeightLength,double dWeightDetection)
						{cvConnections.AddConnection(iConnectToIndex,iThreat1,iThreat2,dConnecitonWeight,dWeightLength,dWeightDetection);};

	void SetConnectionWeight(int iConnectToIndex,double dConnecitonWeight=DBL_MAX,
									  double dWeightLength=DBL_MAX,double dWeightDetection=DBL_MAX)
						{cvConnections.SetConnectionWeight(iConnectToIndex,dConnecitonWeight,dWeightLength,dWeightDetection);};

	CConnection  cntnRemoveConnection(int iNodeIndex){return(cvConnections.cntnRemoveConnection(iNodeIndex));};
	int iGetConnectToIndex(int iConnectionIndex){return(cvConnections.iGetConnectToIndex(iConnectionIndex));};
	double dGetConnectToWeight(int iNodeIndex){return(cvConnections.dGetConnectToWeight(iNodeIndex));};
	double dGetWeightLength(int iNodeIndex){return(cvConnections.dGetWeightLength(iNodeIndex));};
	double dGetWeightDetection(int iNodeIndex){return(cvConnections.dGetWeightDetection(iNodeIndex));};

	CConnectionVector cvConnections;

	BOOL bIsValidData(){return(m_bValidData);};
	void SetValidData(BOOL bValidData=TRUE){m_bValidData=bValidData;};

	void SetRequiredTurnPoint(BOOL bRequired=TRUE){m_bRequiredTurnPoint=bRequired;};
	BOOL bGetRequiredTurnPoint(){return(m_bRequiredTurnPoint);};
	void SetRequiredTargetPoint(BOOL bRequired=TRUE){m_bRequiredTargetPoint=bRequired;};
	BOOL bGetRequiredTargetPoint(){return(m_bRequiredTargetPoint);};
	BOOL bGetAssociatedWithThreat(int iThreat){return(cvConnections.bGetAssociatedWithThreat(iThreat));};

	BOOL bGetTypeVoronoi(){return(m_bTypeVoronoi);};
	void SetTypeVoronoi(BOOL bTypeVoronoi=TRUE){m_bTypeVoronoi=bTypeVoronoi;};

	double dGetHeuristicCost(){return(m_dHeuristicCost);};
	void SetHeuristicCost(double dHeuristicCost=0.0){m_dHeuristicCost=dHeuristicCost;};
protected:
	BOOL m_bTypeVoronoi;	// is this a voronoi node? default = TRUE
	BOOL m_bValidData;
	BOOL m_bRequiredTurnPoint;
	BOOL m_bRequiredTargetPoint;
	long int m_liPositionN;		// north position
	long int m_liPositionE;		// east position
	long int m_liPositionZ;		// z position

	int m_iNodeFrom;	// this is the direction of travel to (NODE_UNDEFINED -> not set)
	double m_dF;			// cost to get to this node + heuristic cost to the end.   >= 0 means OPEN	(-1 -> not set)
    double m_dG;			// cost to get to this node .  >= 0 means OPEN || CLOSED	(-1 -> not set)
	double m_dHeuristicCost;	//used by heuristic distance function to calculate cost to go
	
};

#endif // !defined(AFX_NODE_H__DC813EE0_9108_11D3_99EE_00104B70C01B__INCLUDED_)
