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
// Color.h: interface for the CColor class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_COLOR_H__E679B8A4_86D1_11D3_99EE_00104B70C01B__INCLUDED_)
#define AFX_COLOR_H__E679B8A4_86D1_11D3_99EE_00104B70C01B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <sstream>
#include <vector>
using namespace std;
//#include <afxwin.h>         // MFC core and standard components

namespace
{
	static const strstream anon_sstrError("ERROR",0);
	static const strstream anon_sstrColorBlack("Black",0);
}


class CColor  
{
public:
//	CColor(CString cstrName = "Black",float fRed=0.0,float fGreen=0.0,float fBlue=0.0,float fTransparent=0.0);
	CColor(strstream cstrName=anon_sstrColorBlack,float fRed=0.0,float fGreen=0.0,float fBlue=0.0,float fTransparent=0.0);
	virtual ~CColor();

public:
	strstream m_cstrName;
	float m_fRed;		//Red intensity 0.0 to 1.0
	float m_fGreen;	//Green intensity 0.0 to 1.0
	float m_fBlue;	//Blue intensity 0.0 to 1.0
	float m_fTransparent; //0.0 opaque to 1.0 clear

	CColor operator*(double dMultiplier);
	void operator=(CColor* pcolorRHS);

};

typedef std::vector<CColor> VCOLOR;

enum enTargetColors {entcGray,entcYelow,entcGreen,entcMagenta,entcRed,entcWhite,entcNumberColors};
class CColorVector  
{
public:
	CColorVector(); 
	virtual ~CColorVector();


public:
	int iTargetColors[entcNumberColors];
	CColor* pcolorGetGray(){return(&m_vcolorColors.back());};
	int iGetSizeColors(){return(m_vcolorColors.size());};
	strstream& cstrGetColorName(int iIndex){return((iIndex<iGetSizeColors())?(m_vcolorColors[iIndex].m_cstrName):(anon_sstrError));};
	float fGetColorRed(int iIndex){return((iIndex<iGetSizeColors())?(m_vcolorColors[iIndex].m_fRed):(0.0));};
	float fGetColorGreen(int iIndex){return((iIndex<iGetSizeColors())?(m_vcolorColors[iIndex].m_fGreen):(0.0));};
	float fGetColorBlue(int iIndex){return((iIndex<iGetSizeColors())?(m_vcolorColors[iIndex].m_fBlue):(0.0));};
	float fGetColorTransparent(int iIndex){return((iIndex<iGetSizeColors())?(m_vcolorColors[iIndex].m_fTransparent):(0.0));};
	CColor* pcolorGetColor(int iIndex){return((iIndex<iGetSizeColors())?(&(m_vcolorColors.at(iIndex))):(&(m_vcolorColors.at(0))));};
	

protected:
	VCOLOR m_vcolorColors; 

};




#endif // !defined(AFX_COLOR_H__E679B8A4_86D1_11D3_99EE_00104B70C01B__INCLUDED_)
