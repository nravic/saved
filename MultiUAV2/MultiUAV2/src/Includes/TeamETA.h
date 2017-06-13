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
// TeamETA.h: interface for the CTeamETA class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_TEAMETA_H__CA87F9E3_7006_11D3_99EE_00104B70C01B__INCLUDED_)
#define AFX_TEAMETA_H__CA87F9E3_7006_11D3_99EE_00104B70C01B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class CTeamETA  
{
public:
	CTeamETA();
	virtual ~CTeamETA();

public:
	double dTeamETA;
	double dTimeStamp;
    CTeamETA &operator=( CTeamETA & );  // Right side is the argument.
};

#endif // !defined(AFX_TEAMETA_H__CA87F9E3_7006_11D3_99EE_00104B70C01B__INCLUDED_)