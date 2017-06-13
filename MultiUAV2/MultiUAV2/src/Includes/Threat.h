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
// Threat.h: interface for the CThreat class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_THREAT_H__DC813EE0_9108_11D3_99EE_00104B70C01B__INCLUDED_)
#define AFX_THREAT_H__DC813EE0_9108_11D3_99EE_00104B70C01B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class CThreat  
{
public:
	CThreat();
	virtual ~CThreat();

public:
	void operator =(CThreat trtThreat);
	double dGetKillProb(double dPositionN,double dPositionE,double dPositionZ);
	double dGetKillProb(double dPositionN,double dPositionE);

	double dGetPositionN(){return(m_dPositionN);};
	double dGetPositionE(){return(m_dPositionE);};
	double dGetPositionZ(){return(m_dPositionZ);};

	double m_dPositionN;		// north position
	double m_dPositionE;		// east position
	double m_dPositionZ;		// z position
	double m_dMaxRange;			// maximum range
	double m_dMaxKillProb;		// Probability of kill at zero range
	double m_dMinKillProb;		// Probability of kill at max range

	int iGetThreatID(){return(m_iThreatID);};
	void SetThreatID(int iThreatID){m_iThreatID=iThreatID;};
protected:
	double m_dDeltaKillProb;	// difference between max and min probability of kill
	int m_iThreatID;
};

#endif // !defined(AFX_THREAT_H__DC813EE0_9108_11D3_99EE_00104B70C01B__INCLUDED_)
