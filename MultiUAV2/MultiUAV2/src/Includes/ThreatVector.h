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
// ThreatVector.h: interface for the CThreats class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_THREATVECTOR_H__DC813EE1_9108_11D3_99EE_00104B70C01B__INCLUDED_)
#define AFX_THREATVECTOR_H__DC813EE1_9108_11D3_99EE_00104B70C01B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <vector>
#include "Threat.h"

using namespace std ;

class CThreatVector  
{
public:
	CThreatVector();
	virtual ~CThreatVector();

public:
	int iGetNumThreats();
	CThreat* pthrGetThreat(int iThreatNum);
	void AddThreat(CThreat *pthtThreat);

	vector<CThreat>* pvtrtGetThreats(){return(&vtrtThreat);};
protected:
	vector<CThreat> vtrtThreat;
	int iNumberThreats;

};

#endif // !defined(AFX_THREATVECTOR_H__DC813EE1_9108_11D3_99EE_00104B70C01B__INCLUDED_)
