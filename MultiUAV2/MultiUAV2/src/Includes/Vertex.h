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
// Vertex.h: interface for the CVertex class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VERTEX_H__9FAC2E02_8D14_11D3_99EE_00104B70C01B__INCLUDED_)
#define AFX_VERTEX_H__9FAC2E02_8D14_11D3_99EE_00104B70C01B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "GlobalDefines.h"

class CVertex  
{
public:
	CVertex();
	CVertex(double dX,double dY=0.0,double dZ=0.0):m_dX(dX),m_dY(dY),m_dZ(dZ),m_bEndPoint(FALSE){};
	virtual ~CVertex();

public:
	BOOL operator ==(CVertex vtxVertex);
	void operator =(CVertex vtxVertex);
	double dGetDistance(CVertex vtxPoint);
	double dGetX(){return(m_dX);};
	double dGetY(){return(m_dY);};
	double dGetZ(){return(m_dZ);};
	void SetX(double dX){m_dX=dX;};
	void SetY(double dY){m_dY=dY;};
	void SetZ(double dZ){m_dZ=dZ;};
	BOOL bGetEndPoint(){return(m_bEndPoint);};
	void SetEndPoint(BOOL bEndPoint=TRUE){m_bEndPoint=bEndPoint;};
protected:
	BOOL m_bEndPoint;
	double m_dX;
	double m_dY;
	double m_dZ;

};

#endif // !defined(AFX_VERTEX_H__9FAC2E02_8D14_11D3_99EE_00104B70C01B__INCLUDED_)
