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
// NodeVector.h: interface for the CNodes class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_NODEVECTOR_H__DC813EE1_9108_11D3_99EE_00104B70C01B__INCLUDED_)
#define AFX_NODEVECTOR_H__DC813EE1_9108_11D3_99EE_00104B70C01B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "GlobalDefines.h"	// globally defined constants

#include <vector>
#include <math.h>
#include <fstream>
#include "Node.h"
using namespace std;

typedef vector<int> PATHvi ;	// this is one path which is made up of the indicies to the node that make up the path
typedef vector<PATHvi> PATH_VECTORvvi ;	// this is an array of paths

class CNodeVector  
{
public:
	CNodeVector();
	virtual ~CNodeVector();

public:
	void ClearAllHeuristicCosts();
	CConnection cntnRemoveConnection(int iNodeIndex1,int iNodeIndex2);

	void operator =(CNodeVector vndeNodes);

	double dDistanceToEdge(CNode* pndePosition,CNode* pndeOne,CNode* pndeTwo);
	void ClearVector();
	BOOL bIsOnSegment(CNode* ndeEndA,CNode* ndeEndB,CNode* ndePoint);
	int iInsertEnd(const class CNode& ndeInsert);
	void InsertBegin(const class CNode& ndeInsert);
	void FindIntersection(CNode* pndeTemp,int iIndexA,int iIndexB,int iIndexC,int iIndexD);
	void RemoveNode(int iNodeIndex);
#ifndef STEVETEST
	void PrintPlotWeights(std::ofstream* ofsWriteNodes);
#endif	//#ifdef STEVETEST

	int iGetAbsoluteDistance(int iIndex1, int iIndex2);
	int iWhichNodeIndex(CNode* pnodeNode);
	CNode* pnGetNode(int iNodeIndex){return((iNodeIndex<m_iNumberNodes)?(&m_vndeNodes[iNodeIndex]):(NULL));};
	int AddNode(CNode *pnodeNode);
	void SetConnectionWeights(int iNodeIndex1,int iNodeIndex2,double dConnecitonWeight=DBL_MAX,
									  double dWeightLength=DBL_MAX,
									  double dWeightDetection=DBL_MAX);
	void AddConnections(int iNodeIndex1,int iNodeIndex2,int iThreat1=-1,int iThreat2=-1,
							double dConnecitonWeight=DBL_MAX,
							double dWeightLength=DBL_MAX,
							double dWeightDetection=DBL_MAX);
	BOOL bValidIndex(int iIndex){return (iIndex<m_iNumberNodes);};
	double dGetConnectToWeight(int iIndex1, int iIndex2);
	double dGetWeightLength(int iIndex1, int iIndex2);
	double dGetWeightDetection(int iIndex1, int iIndex2);

	int iGetNumNodes(){return(m_vndeNodes.size());};
	vector<CNode>* pvndeGetNodes(){return(&m_vndeNodes);};
protected:
	vector<CNode> m_vndeNodes;
	int m_iNumberNodes;

};

#endif // !defined(AFX_NODEVECTOR_H__DC813EE1_9108_11D3_99EE_00104B70C01B__INCLUDED_)
