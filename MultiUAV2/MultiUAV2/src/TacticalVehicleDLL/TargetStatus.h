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
// TargetStatus.h: interface for the CTargetStatus class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_TARGETSTATUS_H__FDE845E3_F042_4779_8FEF_982C70C6AE0B__INCLUDED_)
#define AFX_TARGETSTATUS_H__FDE845E3_F042_4779_8FEF_982C70C6AE0B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class CTargetStatus
{
public:
	CTargetStatus()
	{
		m_dPositionNorth_ft = 0;
		m_dPositionEast_ft = 0;
		m_iID = 0;
		m_bInSensorFootprint = FALSE;
	};
	~CTargetStatus(){};

public:
	int& iGetID(){return(m_iID);};
	const int& iGetID() const {return(m_iID);};

	double& dGetPositionNorth(){return(m_dPositionNorth_ft);};
	const double& dGetPositionNorth() const {return(m_dPositionNorth_ft);};

	double& dGetPositionEast(){return(m_dPositionEast_ft);};
	const double& dGetPositionEast() const {return(m_dPositionEast_ft);};

	double& dGetHeading(){return(m_dHeading_rad);};
	const double& dGetHeading() const {return(m_dHeading_rad);};

	BOOL& bGetInSensorFootprint() {return(m_bInSensorFootprint);};
	const BOOL& bGetInSensorFootprint() const {return(m_bInSensorFootprint);};
protected:
	int m_iID;
	double m_dPositionNorth_ft;
	double m_dPositionEast_ft;
	double m_dHeading_rad;
	BOOL m_bInSensorFootprint;
};


#endif // !defined(AFX_TARGETSTATUS_H__FDE845E3_F042_4779_8FEF_982C70C6AE0B__INCLUDED_)
