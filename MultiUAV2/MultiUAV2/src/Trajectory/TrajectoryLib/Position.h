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
// Position.h: interface for the CPosition class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_POSITION_H__685A57A9_6564_42A2_9CCD_C5814BE13A53__INCLUDED_)
#define AFX_POSITION_H__685A57A9_6564_42A2_9CCD_C5814BE13A53__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "TrajectoryDefinitions.h"

#include <iostream>

class CPosition;
  
#include <vector>
namespace
{
	typedef std::vector<int> V_INT_t;
	typedef V_INT_t::iterator V_INT_IT_t;

	typedef std::vector<double> V_DOUBLE_t;
	typedef V_DOUBLE_t::iterator V_DOUBLE_IT_t;
	typedef V_DOUBLE_t::const_iterator V_DOUBLE_CONST_IT_t;

	typedef std::vector<CPosition> V_POSITION_t;
	typedef V_POSITION_t::iterator V_POSITION_IT_t;
	typedef V_POSITION_t::const_iterator V_POSITION_CONST_IT_t;
}

class CPosition  
{
public:
	CPosition(double dPositionX,double dPositionY,double dPositionZ=n_dAltitudeDefault_ft)
	{
		SetPositionX(dPositionX);
		SetPositionY(dPositionY);
		SetPositionZ(dPositionZ);
	}
	CPosition()
	{
		SetPositionX(0.0);
		SetPositionY(0.0);
		SetPositionZ(0.0);
	}
	virtual ~CPosition(){};

	// copy constructer
	CPosition(const CPosition& rhs)
	{
		SetPositionX(rhs.dGetPositionX());
		SetPositionY(rhs.dGetPositionY());
		SetPositionZ(rhs.dGetPositionZ());
	}
	void operator=(const CPosition& rhs)
	{
		SetPositionX(rhs.dGetPositionX());
		SetPositionY(rhs.dGetPositionY());
		SetPositionZ(rhs.dGetPositionZ());
	}
public:
	double dRelativeAngle2D(const CPosition& posPoint)
	{
		// returns the relative angle between the two
		// NOTE: the point passed in is located at the vertex of the angle

		double dX = dGetPositionX() - posPoint.dGetPositionX(); 
		double dY = dGetPositionY() - posPoint.dGetPositionY(); 
		return(dNormalizeAngleRad(atan2(dY,dX),0.0));
	};
	double dRelativeDistance2D(const CPosition& posPoint )
	{
		using namespace std;

		// returns the distance between this point and another
		double dX = dGetPositionX() - posPoint.dGetPositionX(); 
		double dY = dGetPositionY() - posPoint.dGetPositionY(); 

		return(sqrt((dX*dX) + (dY*dY)));
	};
	double dRelativeDistanceAngle2D(const CPosition& posPoint,double& rdAngleRelative_rad)
	{
		// returns the distance between this point and another
		// also calculates the relative angle between the two
		// NOTE: the point passed in is located at the vertex of the angle

		double dX = dGetPositionX() - posPoint.dGetPositionX(); 
		double dY = dGetPositionY() - posPoint.dGetPositionY(); 
		rdAngleRelative_rad = dNormalizeAngleRad(atan2(dY,dX),0.0);
		return(sqrt((dX*dX) + (dY*dY)));
	};
	CPosition& operator -() 
	{
		m_dPositionX_ft = -m_dPositionX_ft;
		m_dPositionY_ft = -m_dPositionY_ft;
		m_dPositionZ_ft = -m_dPositionZ_ft;
		return(*this);
	};
	CPosition& operator *(double dMultiplier) //two dimensional multiplication
	{
		m_dPositionX_ft *= dMultiplier;
		m_dPositionY_ft *= dMultiplier;
		return(*this);
	};
	void operator *=(double dMultiplier) //two dimensional multiplication
	{
		SetPositionX(dGetPositionX() * dMultiplier);
		SetPositionY(dGetPositionY() * dMultiplier);
	};
	CPosition operator +(CPosition& rhs) 
	{
		m_dPositionX_ft = -m_dPositionX_ft;
		m_dPositionY_ft = -m_dPositionY_ft;
		m_dPositionZ_ft = -m_dPositionZ_ft;
		return(CPosition((dGetPositionX()+rhs.dGetPositionX()),
				(dGetPositionY()+rhs.dGetPositionY()),
				(dGetPositionZ()+rhs.dGetPositionZ())));
	};
	void operator+=(const CPosition& rhs)
	{
		SetPositionX(dGetPositionX() + rhs.dGetPositionX());
		SetPositionY(dGetPositionY() + rhs.dGetPositionY());
		SetPositionZ(dGetPositionZ() + rhs.dGetPositionZ());
	};
	void operator-=(const CPosition& rhs)
	{
		SetPositionX(dGetPositionX() - rhs.dGetPositionX());
		SetPositionY(dGetPositionX() - rhs.dGetPositionY());
		SetPositionZ(dGetPositionX() - rhs.dGetPositionZ());
	};
	double dAbsoluteDistance2D()
	{
		// returns the distance between this point and the orign
		return(pow((pow(dGetPositionX(),2) + pow(dGetPositionY(),2)),0.5));
	};
	void TransformPoint2D(const CPosition& posPoint,const double rdAngleRotation_rad)
	{
		double dCosTheta = cos(rdAngleRotation_rad);
		double dSinTheta = sin(rdAngleRotation_rad);
		double dPositionXNew = dGetPositionX() - posPoint.dGetPositionX();
		double dPositionYNew = dGetPositionY() - posPoint.dGetPositionY();
		SetPositionX(dPositionXNew*dCosTheta + dPositionYNew*dSinTheta);
		SetPositionY(dPositionYNew*dCosTheta - dPositionXNew*dSinTheta);
	}
	void ReTransformPoint2D(const CPosition& posPoint,const double rdAngleRotation_rad)
	{
		double dCosTheta = cos(rdAngleRotation_rad);
		double dSinTheta = sin(rdAngleRotation_rad);

		double dRotationXNew = dGetPositionX()*dCosTheta - dGetPositionY()*dSinTheta;
		double dRotationYNew = dGetPositionX()*dSinTheta + dGetPositionY()*dCosTheta;

		SetPositionX(dRotationXNew + posPoint.dGetPositionX());
		SetPositionY(dRotationYNew + posPoint.dGetPositionY());

//		SetPositionX((dGetPositionX()*dCosTheta) - ((dGetPositionY()*dSinTheta)) + posPoint.dGetPositionX());
//		SetPositionY((dGetPositionY()*dCosTheta) + (dGetPositionX()*dSinTheta) + posPoint.dGetPositionY());
	}
	const CPosition& posGetPosition() const {return(*this);};
	CPosition& posGetPosition() {return(*this);};

	void SetPosition(const CPosition& rposPosition)
		{
			SetPositionX(rposPosition.dGetPositionX());
			SetPositionY(rposPosition.dGetPositionY());
			SetPositionZ(rposPosition.dGetPositionZ());
		};
	void SetPosition(double dPositionX_ft,double dPositionY_ft,double dPositionZ_ft=0.0)
	{
		SetPositionX(dPositionX_ft);
		SetPositionY(dPositionY_ft);
		SetPositionZ(dPositionZ_ft);
	};
	void SetPositionXPlus(double dPositionX_ft){m_dPositionX_ft+=dPositionX_ft;};
	void SetPositionX(double dPositionX_ft){m_dPositionX_ft=dPositionX_ft;};
	double& dGetPositionX(){return(m_dPositionX_ft);};
	const double& dGetPositionX() const {return(m_dPositionX_ft);};
	void SetPositionYPlus(double dPositionY_ft){m_dPositionY_ft+=dPositionY_ft;};
	void SetPositionY(double dPositionY_ft){m_dPositionY_ft=dPositionY_ft;};
	double& dGetPositionY(){return(m_dPositionY_ft);};
	const double& dGetPositionY() const {return(m_dPositionY_ft);};
	void SetPositionZPlus(double dPositionZ_ft){m_dPositionZ_ft+=dPositionZ_ft;};
	void SetPositionZ(double dPositionZ_ft){m_dPositionZ_ft=dPositionZ_ft;};
	const double& dGetPositionZ() const {return(m_dPositionZ_ft);};
protected:
	double m_dPositionX_ft;
	double m_dPositionY_ft;
	double m_dPositionZ_ft;
};

#endif // !defined(AFX_POSITION_H__685A57A9_6564_42A2_9CCD_C5814BE13A53__INCLUDED_)
