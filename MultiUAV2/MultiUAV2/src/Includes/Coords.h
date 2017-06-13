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
// Coords.h: interface for the CCoords class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_COORDS_H__3CBCC127_3444_11D3_99EE_00104B70C01B__INCLUDED_)
#define AFX_COORDS_H__3CBCC127_3444_11D3_99EE_00104B70C01B__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

//#include <afxwin.h>         // MFC core and standard components
#include <sstream>
using namespace std;


#define LATITUDE_DEFAULT 37.5781285


class CCoords  
{
public:
	CCoords();
	virtual ~CCoords();

	double dRadius[2];
	double dXpos[2];
	double dYpos[2];
	double dZpos[2];
	double dLatitude;
};

class CRectangle  
{
public:
//	CRectangle(strstream cstrLabel="No Label",double dLength=0.0,double dWidth=0.0,double dHeight=0.0);
	CRectangle(strstream cstrLabel,double dLength=0.0,double dWidth=0.0,double dHeight=0.0);
	virtual ~CRectangle();

	strstream m_cstrLabel;
	double m_dLength;
	double m_dWidth;
	double m_dHeight;
};

#endif // !defined(AFX_COORDS_H__3CBCC127_3444_11D3_99EE_00104B70C01B__INCLUDED_)
