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
// TurnFillet.h: interface for the CTurnFillet class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_TURNFILLET_H__80027780_AE48_11D3_99EE_00104B70C01B__INCLUDED_)
#define AFX_TURNFILLET_H__80027780_AE48_11D3_99EE_00104B70C01B__INCLUDED_

#include "Vertex.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "GlobalDefines.h"	// globally defined constants

#include <vector>
using namespace std;

class CTurnFillet  
{
public:
	CTurnFillet();
	virtual ~CTurnFillet();



public:
	void operator =(CTurnFillet tfilFillet);
	CVertex vtxGetTangentBC(){return(m_vtxTangentBC);};
	CVertex vtxGetTangentBA(){return(m_vtxTangentBA);};
	double dGetFiletLength(){return(m_dArcLength);};
//TODO: check default value for dMinWaypointDist
	BOOL bCalculateTurn(CVertex vtxPointA,CVertex vtxPointB,CVertex vtxPointC,double dRadius,double dMinWaypointDist = 2000.0);

	
	//take three points and a turn radius
	// calculate the equation of the circle and the tangent points to the two lines

	CVertex m_vtxCenter;	// center of circle
	CVertex m_vtxTangentBA;	// tangent point to circle on the line segment BA
	CVertex m_vtxTangentBC;	// tangent point to circle on the line segment BC
	double m_dMinX;	// minimum x value along the arc
	double m_dMaxX;	// maximum x value along the arc
	double m_dMinY;	// minimum y value along the arc
	double m_dMaxY;	// maximum y value along the arc
	double m_dRadius;
	double m_dRadiusSquared;
	double m_dArcLength;

	int iGetNumWayPoints(){return(m_iNumWayPoints);};

	vector<CVertex> vtxaWayPoints;
	int m_iNumWayPoints;

protected:
	BOOL m_bFilletBCGood;
	BOOL m_bFilletABGood;
};

#endif // !defined(AFX_TURNFILLET_H__80027780_AE48_11D3_99EE_00104B70C01B__INCLUDED_)
