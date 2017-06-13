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
// DrawingObjs.h: interface for the CDrawingObjs class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_DRAWINGOBJS_H__3CBCC126_3444_11D3_99EE_00104B70C01B__INCLUDED_)
#define AFX_DRAWINGOBJS_H__3CBCC126_3444_11D3_99EE_00104B70C01B__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000


#include <vector>
#include <fstream>
#include <sstream>
using namespace std;
//#include <afx.h>

#include "Coords.h"	// Added by ClassView
#include "Color.h"

class CPointAVDS  
{
public:
	CPointAVDS(){dXpos=0.0;dYpos=0.0;dZpos=0.0;};
	CPointAVDS(double dXposIn,double dYposIn,double dZposIn=0.0){dXpos=dXposIn;dYpos=dYposIn;dZpos=dZposIn;};
	virtual ~CPointAVDS(){};

public:
	void operator=(CPointAVDS* pcolorRHS){this->dXpos=pcolorRHS->dXpos;this->dYpos=pcolorRHS->dYpos;this->dZpos=pcolorRHS->dZpos;};

	double dXpos;
	double dYpos;
	double dZpos;
};

typedef std::vector<CPointAVDS> VPOINT;
typedef std::vector<CColor> VCOLOR;


class CDrawingObjs  
{
public:
	CColorVector colorvColors; 

	static CPointAVDS pointZero;	// used for default
	void Rectangle(double dLength,double dWidth,CPointAVDS *ppntCenter=&pointZero);
	void RectangularSolid(double dLength,double dWidth,double dHeight,CPointAVDS *ppntCenter=&pointZero);
	void SaveFace(VPOINT* pvpntPoints,CPointAVDS *ppntCenter=&pointZero,strstream* pcstrLabel=NULL);
	void SaveTriangle(CPointAVDS* ppntOne,CPointAVDS* ppntTwo,CPointAVDS* ppntThree);
	void SaveFence(VPOINT* pvpntBottomCircle,VPOINT* pvpntTopCircle,BOOL bHoles=FALSE);
	void FindCircle(VPOINT* pvpntCircle,CPointAVDS* ppntCenter,double dRadius,int iNumberSegments);
	void m_Fence(double, double, double, double,double, double, double, double );
	void m_Fence(CCoords Coords,BOOL bHoles=FALSE,int iNumberSides=0);

	void m_WriteLine(char* strLine);
	void m_HemiSphere(double dRadiusSphere,
						double dXOffset = 0.0,
						double dYOffset = 0.0,
						double dZOffset = 0.0,
						BOOL bHoles = FALSE);
	ofstream ofsOutFile;
	void m_Circle(CCoords Coords,int iNumberSides=32);
	CDrawingObjs(strstream strFilename);
	virtual ~CDrawingObjs();

};

#endif // !defined(AFX_DRAWINGOBJS_H__3CBCC126_3444_11D3_99EE_00104B70C01B__INCLUDED_)
