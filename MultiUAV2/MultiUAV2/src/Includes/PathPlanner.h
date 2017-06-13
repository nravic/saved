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
// PathPlanner.h: interface for the CPathPlanner class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_PATHPLANNER_H__D3FBD980_BDE3_11D3_99EE_00104B70C01B__INCLUDED_)
#define AFX_PATHPLANNER_H__D3FBD980_BDE3_11D3_99EE_00104B70C01B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <cfloat>	// DBL_MAX

#include "GlobalDefines.h"	// globally defined constants
#include "EnvironmentSim.h"
#include "db_class.h"
#include "input_class.h"	//siminput (pXin)

typedef std::vector<waystruct> WAYPOINTS;

class CSensitivity
{	
public:
	CSensitivity()
	{
		m_dPathLength = DBL_MAX;	// set to an obviously invalid number
		m_dPathCost = DBL_MAX;	// set to an obviously invalid number
		m_bGoodPath = FALSE;
	};
	

	vector<CTurnFillet> m_vtfilletTurnNodes;
	WAYPOINTS m_wptsPlannedPath;
	WAYPOINTS m_wptsDetailedPath;
	double m_dPathLength;
	double m_dPathCost;
	BOOL m_bGoodPath;

	void operator =(CSensitivity sensIn)
	{
		m_vtfilletTurnNodes = sensIn.m_vtfilletTurnNodes;
		m_wptsPlannedPath = sensIn.m_wptsPlannedPath;
		m_wptsDetailedPath = sensIn.m_wptsDetailedPath;
		m_dPathLength = sensIn.m_dPathLength;
		m_dPathCost = sensIn.m_dPathCost;
		m_bGoodPath = sensIn.m_bGoodPath;
	};
};

typedef std::vector<CSensitivity> VSENSITIVITY;

class CPathPlanner  
{
public:
	CPathPlanner();
	virtual ~CPathPlanner();

public:
	// environment simulation models
	void SetpEnvSim(CEnvironmentSim* penvSim){m_penvSim=penvSim;};
	CEnvironmentSim* m_penvSim;

	void PlotMainScript();
	void PlotPathScript();
	void PlotThreatsTargets(trtlist* pSensedThreats,double dMinimumAttackParameterFeet=0.0);
	void SetWayPointSeparation(double dWayPointSeparation){m_dWayPointSeparation=dWayPointSeparation;};
	void SetTurnRadius(double dTurnRadius){m_dTurnRadius=dTurnRadius;};
	int iGetNumThreatsPlanned(){return(m_iNumThreatsPlanned);};

	WAYPOINTS* pwptsGetPlannedPath(trtlist* pSensedThreats,waystruct wayCurrPosition,
									waystruct wayTargetPosition,
									 double dAttackHeadingDeg,
									 double dMinimumAttackParameterFeet,
									database_man* pDBManager,
									 double dNorthPosition,
									 double dEastPosition,
									 double dHeadingDeg,
									BOOL bOutputPlotData = FALSE,
									int iPlotID = 1);

	double dDistanceToGo(waystruct* pwptsCurrentPosition);
	double dCostToGo(waystruct* pwptsCurrentPosition);

protected:
	void PlotCATAData(int iPlotID,CSensitivity* psenSensitivity,
								waystruct* pwayCurrPosition,VSENSITIVITY* pvsenSensitivity,
								double dMinimumAttackParameterFeet = 10000.0,trtlist* pSensedThreats=NULL);
	void PlotVoronoiNodes(int iPlotID,CNodeVector* pndsVoronoiNodes,BOOL bPlotNumbers=TRUE);
	double dDistance(waystruct wayPoint1,waystruct wayPoint2);
	void FindClosestEdge(vector<int>* pviEdgeNodes,CNode* pndePositionAC,Voronoi* pvrniVoronoi);
	BOOL FlyToVector(CNodeVector* pndsTurnNodes,
						CNode* pndePositionAC,double dHeading,
						CNode* pndeEdgePointFrom,CNode* pndeEdgePointTo);
	int m_iMaxNumPaths;
	static BOOL m_bSavePlotRendezvous;
	static BOOL m_bFirstPlot;
	static BOOL m_bClearPlots;	// used to clear the plot directory at the beginning of each run
	WAYPOINTS::iterator itwayGetNextDetailedPoint(waystruct* pwptCurrentPosition);
	vector<int> viFindVoronoiCell(CNode* pndeNode,CNodeVector* pndsNodes,CThreatVector* pvthrThreatVector);
	void GetSmallerSegments(vector<CNode>* pvndePathNodes,waystruct* pwptWaypoint1,waystruct* pwptWaypoint2,double dSegmentLength);
	BOOL bFindFlyablePath(vector<int>* pviPath,CNodeVector* pndsNodes,
										CNode* pndePositionAC,double dHeadingDeg,
										CNode* pndeFromNode,vector<CTurnFillet>* patrnfTest);
	double dCalculatePathLength(waystruct* pwptCurrentPositon,waystruct* pwptTargetPositon,WAYPOINTS* pwptsPlannedPath);
	double dCalculatePathCost(waystruct* pwptCurrentPositon,WAYPOINTS* pwptsPlannedPath,CThreatVector* pvthrThreatVector);	// calculate the cost of each segment on the path
	void CalculateCosts(CNodeVector* pndsNodes,CThreatVector* pvthrThreatVector);	// calculate the weights on all of the connections
	double dCalculateCostOne(CNode* pndNode1,CNode* pndNode2,CThreatVector* pvthrThreatVector); //calculates the weight for one connection

	BOOL bAddTurnFillets(vector<int>* pviPath,CNodeVector* pndsNodes,vector<CTurnFillet>* patrnfTest);
	WAYPOINTS m_wptsPlannedPath;
	waystruct m_wptTargetPositon;
	CThreatVector* m_pvthrThreatVector;

	double m_dWayPointSeparation;
	double m_dTurnRadius;

	sim_input* m_pXin;
	int m_iNumTimesPlanned;	// (for plotting) this is the number of times that the path planner has been called
	int m_iNumThreatsPlanned;	// this is the number of threats included in the last path plan

	VSENSITIVITY m_vsenSensitivity;
	CSensitivity m_sensPlannedPath;
};

#endif // !defined(AFX_PATHPLANNER_H__D3FBD980_BDE3_11D3_99EE_00104B70C01B__INCLUDED_)
