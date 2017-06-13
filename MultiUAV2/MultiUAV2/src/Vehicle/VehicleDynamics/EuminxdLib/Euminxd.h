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
// Euminxd.h: interface for the CEuminxd class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_EUMINXD_H__7446C0A6_5C77_48C5_928B_D37D23F4BCED__INCLUDED_)
#define AFX_EUMINXD_H__7446C0A6_5C77_48C5_928B_D37D23F4BCED__INCLUDED_


#pragma warning(disable:4786)

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define ERROR_NONE (0)
#define ERROR_N_GREATER_NMAX (1)
#define ERROR_M_GREATER_MMAX (2)
#define ERROR_NF_GREATER_NFMAX (3)
#define ERROR_UMIN_GREATER_UMAX (4)
#define ERROR_FMIN_GREATER_FMAX (5)
#define ERROR_CONTROLS_CLIPPED (6)
#define WARNING_MAX_ITERATIONS (7)

class CEuminxd  
{
public:
	CEuminxd();
	virtual ~CEuminxd();
public:
	enum enErrors
	{
		errorNone,
		errorNGreaterNMax,
		errorMGreaterMMax,
		errorNFGreaterNFMax,
		errorUMinGreaterUMax,
		errorFMinGreaterFMax,
		errorControlsClipped,
		errorMaxIterationWarning,
		errorTotal
	};
public:
	enErrors Euminxd(int iControlDimensions, int iNumCntrlSurfaces, double *cb, double *ad, double *wa, double *wu, 
			   double *umin, double *umax, double *upref, double *u);
};

#endif // !defined(AFX_EUMINXD_H__7446C0A6_5C77_48C5_928B_D37D23F4BCED__INCLUDED_)
