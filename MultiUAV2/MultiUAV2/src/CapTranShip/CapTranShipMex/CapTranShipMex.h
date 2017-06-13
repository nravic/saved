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
//////////////////////////////////////////////////////////////////////////////

// CapTranShipDll.h: interface for the CapTranShipDll class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CAPTRANSHIPMEX_H__6988E92A_2645_467A_9865_5F8DD5E32A4E__INCLUDED_)
#define AFX_CAPTRANSHIPMEX_H__6988E92A_2645_467A_9865_5F8DD5E32A4E__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <vector>
using namespace std;

class CVehicleTasks  
{
public:
	// inputs to the assignment algorithm
	int iVehicleID;
	vector<int> viTaskTarget;
	vector<int> viTaskType;
	vector<int> viTaskBenefit; 

};

typedef vector<CVehicleTasks> VVEHICLETASKS;
typedef vector<int> VInt;

#endif // !defined(AFX_CAPTRANSHIPMEX_H__6988E92A_2645_467A_9865_5F8DD5E32A4E__INCLUDED_)
