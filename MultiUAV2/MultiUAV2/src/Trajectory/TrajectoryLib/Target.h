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
// Target.h: interface for the CTarget class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_TARGET_H__617C2944_C2FA_4CFE_B293_E616F4395C71__INCLUDED_)
#define AFX_TARGET_H__617C2944_C2FA_4CFE_B293_E616F4395C71__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "TrajectoryDefinitions.h"
#include "BaseObject.h"

class CTarget;

#include <vector>
namespace
{
	typedef std::vector<CTarget> V_TARGET_t;
	typedef V_TARGET_t::iterator V_TARGET_IT_t;
	typedef V_TARGET_t::const_iterator V_TARGET_CONST_IT_t;
}

class CTarget : public CBaseObject
{
public:
	CTarget(int iID,double dPositionX_ft,double dPositionY_ft,double dPsi_rad,int iTasktypeRequired, double dTimePrerequsite_ft=0.0)
	{
		SetID(iID);
		SetHeading(dPsi_rad);
		SetPosition(dPositionX_ft,dPositionY_ft);
		n_enTaskType_t tasktypeRequired = (n_enTaskType_t)iTasktypeRequired;
		SetTaskRequired(tasktypeRequired);
		SetTimePrerequisite(dTimePrerequsite_ft);
	};

	CTarget(int iID,double dPositionX_ft,double dPositionY_ft,double dPsi_rad,n_enTaskType_t tasktypeRequired=taskClassify, double dTimePrerequsite_ft=0.0)
	{
		SetID(iID);
		SetHeading(dPsi_rad);
		SetPosition(dPositionX_ft,dPositionY_ft);
		SetTaskRequired(tasktypeRequired);
		SetTimePrerequisite(dTimePrerequsite_ft);
	};

	virtual ~CTarget(){};

	// copy constructer
	CTarget(const CTarget& rhs)
		:	CBaseObject(rhs)
	{
		SetTaskRequired(rhs.typeGetTaskRequired());
		SetTimePrerequisite(rhs.dGetTimePrerequisite());
		SetHeadingsTo(rhs.rvdGetHeadingsTo());
	};

	void operator=(const CTarget& rhs)
	{
		CBaseObject::operator=(rhs);
		SetTaskRequired(rhs.typeGetTaskRequired());
		SetTimePrerequisite(rhs.dGetTimePrerequisite());
		SetHeadingsTo(rhs.rvdGetHeadingsTo());
	};

public:
	const double& dGetTimePrerequisite() const {return(m_dTimePrerequisite_ft);};
	void SetTimePrerequisite(double dTimePrerequisite_ft){m_dTimePrerequisite_ft=dTimePrerequisite_ft;};

	const n_enTaskType_t typeGetTaskRequired() const {return(m_tasktypeRequired);};
	void SetTaskRequired(const n_enTaskType_t& tasktypeRequired){m_tasktypeRequired = tasktypeRequired;};

	const int iGetNumberHeadings() const {return(m_vdClassifyHeadingsTo.size());};

	V_DOUBLE_t& rvdGetHeadingsTo() {return(m_vdClassifyHeadingsTo);};
	const V_DOUBLE_t& rvdGetHeadingsTo() const {return(m_vdClassifyHeadingsTo);};
	void SetHeadingsTo(const V_DOUBLE_t& vdClassifyHeadingsTo){m_vdClassifyHeadingsTo = vdClassifyHeadingsTo;};

	void AddHeadingTo(double dHeadingTo)
	{
		if(dHeadingTo < (DBL_MAX/2.0))	//DBL_MAX indicates a non-value 
		{
			rvdGetHeadingsTo().push_back(dHeadingTo);
		}
	}
protected:
	n_enTaskType_t m_tasktypeRequired;
	V_DOUBLE_t m_vdClassifyHeadingsTo;

	double m_dTimePrerequisite_ft;
};

#endif // !defined(AFX_TARGET_H__617C2944_C2FA_4CFE_B293_E616F4395C71__INCLUDED_)
