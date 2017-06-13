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
// BaseObject.h: interface for the CBaseObject class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_BASEOBJECT_H__F3B5500F_0216_47FC_ABF5_E229C9660AD2__INCLUDED_)
#define AFX_BASEOBJECT_H__F3B5500F_0216_47FC_ABF5_E229C9660AD2__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Position.h"
#include <string>
#include <fstream>
using std::ofstream;

class CBaseObject : public CPosition  
{
public:
	CBaseObject(){};
	virtual ~CBaseObject(){};

	CBaseObject(const CBaseObject& rhs)
		: CPosition(rhs)
	{
		SetID(rhs.iGetID());
		SetHeading(rhs.dGetHeading());
	};
	void operator=(const CBaseObject& rhs)
	{
		CPosition::operator =(rhs);
		SetID(rhs.iGetID());
		SetHeading(rhs.dGetHeading());
	};
public:
	const int iGetID() const {return(m_iID);};
	void SetID(int iID){m_iID=iID;};

	const double dGetHeading() const {return(m_dPsi_rad);};
	void SetHeading(const double dPsi_rad){m_dPsi_rad=dPsi_rad;};


#define CIRCLE_SIZE (3.0)
#define MATLAB_COLOR_OBJECT_POSITION "[0.1,0.5,0.1]"

	void SaveMatlabPlotStringPosition(ofstream& ofStream)
	{
		ofStream << "rectangle('Position',["
				<< dGetPositionX() - CIRCLE_SIZE/2.0 << ","
				<< dGetPositionY() - CIRCLE_SIZE/2.0 << ","
				<< CIRCLE_SIZE << "," << CIRCLE_SIZE << "],'Curvature',[1,1],"
				<< "'FaceColor',"MATLAB_COLOR_OBJECT_POSITION",'EdgeColor',[0.1,0.1,0.1]);\n"
				<< "text(" << dGetPositionX() << "," << dGetPositionY() << ",'ID #" << iGetID() << "','FontSize',18,'HorizontalAlignment','right','VerticalAlignment','bottom','Color',"MATLAB_COLOR_OBJECT_POSITION");\n";
	};
protected:
	int m_iID;
	double m_dPsi_rad;


};

#endif // !defined(AFX_BASEOBJECT_H__F3B5500F_0216_47FC_ABF5_E229C9660AD2__INCLUDED_)
