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
// Circle.h: interface for the CCircle class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CIRCLE_H__FDEC0548_7BE2_4C0E_81B0_4B10300842F9__INCLUDED_)
#define AFX_CIRCLE_H__FDEC0548_7BE2_4C0E_81B0_4B10300842F9__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "TrajectoryDefinitions.h"
#include "Position.h"

class CCircle;

#include <vector>
namespace
{
	typedef std::vector<CCircle> V_CIRCLE_t;
	typedef V_CIRCLE_t::iterator V_CIRCLE_IT_t;
	typedef V_CIRCLE_t::const_iterator V_CIRCLE_CONST_IT_t;
}

class CCircle : public CPosition
{
public:
	// default constructor
	CCircle()
	{
		SetPosition(0.0,0.0);
		SetRadius(0.0);
		SetTurnDirection(turnNone);
	};
	CCircle(double dCenterX_ft,double dCenterY_ft,double dRadius_ft,enTurnDirection_t turnDirection)
	{
		SetPosition(dCenterX_ft,dCenterY_ft);
		SetRadius(dRadius_ft);
		SetTurnDirection(turnDirection);
	};
	CCircle(const CPosition& posCenter,double dRadius_ft,enTurnDirection_t turnDirection)
	{
		SetPosition(posCenter);
		SetRadius(dRadius_ft);
		SetTurnDirection(turnDirection);
	};
	// default destructor
	virtual ~CCircle(){};
	// copy constructer
	CCircle(const CCircle& rhs)
	{
		SetRadius(rhs.dGetRadius());
		SetTurnDirection(rhs.turnGetTurnDirection());
		SetPosition(rhs.posGetPosition());
	};
public:
	const double& dGetRadius() const {return(m_dRadius_ft);};
	double& dGetRadius(){return(m_dRadius_ft);};
	void SetRadius(double dRadius_ft){m_dRadius_ft=iRound(dRadius_ft);};

	const enTurnDirection_t& turnGetTurnDirection() const {return(m_turnDirection);};
	void SetTurnDirection(enTurnDirection_t turnDirection){m_turnDirection=turnDirection;};

	double dGetAngle(CPosition& posPoint){posPoint.dRelativeAngle2D(*this);};
	double dGetRelativeAngle(CPosition& posPoint1,CPosition& posPoint2)
	{
		// returns relative angle from point1 to point2 using the cirle center as the vertex
		double dAngle1 = posPoint1.dRelativeAngle2D(*this);
		double dAngle2 = posPoint2.dRelativeAngle2D(*this);
		if(turnGetTurnDirection() == turnClockwise)
		{
			if(dAngle1 <= dAngle2)
			{
				return((_2PI - dAngle2) + dAngle1);
			}
			else
			{
				return(dAngle2 - dAngle1);
			}
		}
		else
		{
			if(dAngle1 <= dAngle2)
			{
				return(dAngle2 - dAngle1);
			}
			else
			{
				return((_2PI - dAngle1) + dAngle2);
			}
		}
	};

	void GetNewHeadingAngleAndPosition(double& dFinalHeadingAngle,CPosition& posFinal,double dRotationAngleFinal_rad)
	{
		// returns a new position and heading of a vehicle on the turn 
		// based on the circle and the final angle (dRotationAngleFinal_rad)
		//
		// the function returns the new heading angle in the reference "dFinalHeadingAngle"
		// and the new position is returned in the "posFinal" reference
		dFinalHeadingAngle = dNormalizeAngleRad(dRotationAngleFinal_rad + _PI_O_2);
		posFinal.SetPositionX(dGetRadius()*cos(dRotationAngleFinal_rad));
		posFinal.SetPositionY(dGetRadius()*sin(dRotationAngleFinal_rad));
	}
	void GetOppositeTurnCircle(double& dFinalHeadingAngle,CCircle& circleOpposite)
	{
		// returns the turn circle that is tangent to this one at the given angle
		circleOpposite.SetPositionX(2.0*dGetRadius()*cos(dFinalHeadingAngle));
		circleOpposite.SetPositionY(2.0*dGetRadius()*sin(dFinalHeadingAngle));
		circleOpposite.SetRadius(dGetRadius());
		circleOpposite.SetTurnDirection((turnGetTurnDirection()==turnClockwise)?(turnCounterclockwise):(turnClockwise));
	}
protected:
	//CPosition inherited;
	double m_dRadius_ft;
	enTurnDirection_t m_turnDirection;
};


#endif // !defined(AFX_CIRCLE_H__FDEC0548_7BE2_4C0E_81B0_4B10300842F9__INCLUDED_)
