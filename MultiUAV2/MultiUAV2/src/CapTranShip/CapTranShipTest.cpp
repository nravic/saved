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
/****************************************************
 *
 * FILE     : $RCSfile: CapTranShipTest.cpp,v $
 * AUTHOR   : hennebry
 * DATE     : $Date: 2004/05/06 13:05:30 $
 * REVISION : $Revision: 2.0.8.2 $
 *
 * MODIFICATION HISTORY:-
 *   $Log: CapTranShipTest.cpp,v $
 *   Revision 2.0.8.2  2004/05/06 13:05:30  rasmussj
 *   Merge corrections from stable that happened after merging RAS-02 into STABLE.
 *
 *   Revision 2.0.18.1  2004/05/06 12:47:33  rasmussj
 *   Merged in Development for inital releaase of 2.0
 *
 *   Revision 2.0.20.1  2004/05/06 12:26:51  rasmussj
 *   Merged RAS-02
 *
 *   Revision 2.0.8.1  2004/04/30 16:40:12  rasmussj
 *   Added disclaimer to top of all source files. Removed the Vehicle S-Function directory, it was not working.
 *
 *   Revision 2.0  2004/01/22 20:54:51  mitchejw
 *   Initial checkin of v2-pre0
 *
 *   Revision 1.2  2003/10/23 18:37:57  rasmussj
 *   LINUX/Windows version merged into the head.
 *
 *   Revision 1.1.4.1  2003/10/23 16:51:45  rasmussj
 *   Initial LINUX port. Windows compiled and tested also.
 *
 *   Revision 1.2  2003/09/11 17:31:56  mitchejw
 *   linux compile clean up.
 *
 *   Revision 1.1  2003/07/30 15:30:22  rasmussj
 *   Initial Revision
 *
 *   Revision 1.2  2000/12/29 22:14:46  hennebry
 *   much rewriting
 *
 *   Revision 1.1  2000/11/02 18:29:04  hennebry
 *   Initial revision
 *
 *
 ****************************************************/


#include <iostream>
#include <fstream>
#include <iomanip>
using namespace std;

#include "CapTransShip.h"


int main(int argsNum, char **args)
{
if(argsNum!=2) {
   cerr <<args[0] <<" should have one argument, not " <<argsNum-1 <<endl;
	 cerr << "\tHint: did you specify the input file, e.g. CTPSave.txt?" << endl;
   return -1;
}

ifstream fin(args[argsNum-1]);
if(!fin) {
   cerr <<"Cannot open file " <<args[argsNum-1] <<" for input\n";
   return -2;
}

CapTransShip grasshopper(fin);

grasshopper.print(cout);
vector<int> targets, types;
int benefit;
int flag=grasshopper.solve(targets, types, benefit);
if(flag) {
   cerr <<"solve returned " <<flag <<endl;
   return -3;
}

int UCAVsNum=grasshopper.getUCAVsNum();
cout <<"\nbenefit=" <<benefit <<endl;
cout <<"UCAV  target type\n";
{
int u;
for(u=1; u<=UCAVsNum; u++) {
   cout <<setw(4) <<u
        <<"  " <<setw(4) <<targets[u]
        <<"  " <<setw(6) <<types[u] <<endl;
}  // u
}

return 0;
}  // main
