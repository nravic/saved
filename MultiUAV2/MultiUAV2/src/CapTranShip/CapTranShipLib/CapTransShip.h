/*
//	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION IS RELEASED "AS IS." THE
//	U.S.GOVERNMENT MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, CONCERNING
//	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION, INCLUDING, WITHOUT LIMITATION,
//	ANY WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
//	WILL THE U.S. GOVERNMENT BE LIABLE FOR ANY DAMAGES, INCLUDING ANY LOST PROFITS,
//	LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE,
//	OR INABILITY TO USE, THIS SOFTWARE OR ANY ACCOMPANYING DOCUMENTATION, EVEN IF
//	INFORMED IN ADVANCE OF THE POSSIBILITY OF SUCH DAMAGES.
*/
/****************************************************
 *
 * FILE     : $RCSfile: CapTransShip.h,v $
 * AUTHOR   : hennebry
 * DATE     : $Date: 2004/05/06 13:05:28 $
 * REVISION : $Revision: 2.0.8.3 $
 *
 * MODIFICATION HISTORY:-
 *   $Log: CapTransShip.h,v $
 *   Revision 2.0.8.3  2004/05/06 13:05:28  rasmussj
 *   Merge corrections from stable that happened after merging RAS-02 into STABLE.
 *
 *   Revision 2.0.18.1  2004/05/06 12:47:31  rasmussj
 *   Merged in Development for inital releaase of 2.0
 *
 *   Revision 2.0.20.1  2004/05/06 12:26:49  rasmussj
 *   Merged RAS-02
 *
 *   Revision 2.0.8.2  2004/05/03 20:38:41  rasmussj
 *   Fixed comments, i.e. C->C++
 *
 *   Revision 2.0.8.1  2004/04/30 16:40:10  rasmussj
 *   Added disclaimer to top of all source files. Removed the Vehicle S-Function directory, it was not working.
 *
 *   Revision 2.0  2004/01/22 20:54:51  mitchejw
 *   Initial checkin of v2-pre0
 *
 *   Revision 1.2  2003/10/23 18:37:58  rasmussj
 *   LINUX/Windows version merged into the head.
 *
 *   Revision 1.1.4.1  2003/10/23 16:51:44  rasmussj
 *   Initial LINUX port. Windows compiled and tested also.
 *
 *   Revision 1.2  2003/09/11 16:14:02  mitchejw
 *   linux compile clean up.
 *
 *   Revision 1.1  2003/09/11 16:08:17  mitchejw
 *   Initial revision
 *
 *   Revision 1.1  2003/07/30 15:30:23  rasmussj
 *   Initial Revision
 *
 *   Revision 1.3  2000/12/29 22:13:11  hennebry
 *   much rewriting
 *
 *   Revision 1.2  2000/11/16 23:00:42  hennebry
 *   added stuff to ease interface with java
 *
 *   Revision 1.1  2000/11/02 18:28:38  hennebry
 *   Initial revision
 *
 *
 ****************************************************/

#ifndef CAPTRANSSHIP_H
#define CAPTRANSSHIP_H 1

#include <iostream>
#include <vector>

using std::vector;
using std::istream;
using std::ostream;


class CapTransShip 
{
public:
   // initialization requires number of UCAVs and
   // number of each kind of job
   // UCAVs and targets are numbered from one,
   // i.e., 1..UCAVsNum and 1..targetsNum
   // types are arbitrary, wholly user defined,
   // and not used as indices

   CapTransShip(int un, int tn);
   CapTransShip(istream &fin);

   void print(ostream &fout) const;

   int setJobs(int u, const vector<int> &tas,
                      const vector<int> &tys, const vector<int> &bs );

   int addJob(int u, int ta, int ty, int b);
   int addJob(int u,         int ty, int b) { return addJob(u, 0, ty, b); }

   int
   solve(vector<int> &tas, vector<int> &tys, int &benefit) const;
         // vectors indexed by UCAV

   int getUCAVsNum() const { return UCAVsNum; }
   int getTargetsNum() const { return targetsNum; }

   void getAll(int &un, int &tn,           vector< vector<int> > &tas,
               vector< vector<int> > &tys, vector< vector<int> > &bs ) const {
      un=UCAVsNum; tn=targetsNum; tas=targets; tys=types; bs=benefits;
   }

protected:
   void init(int un, int tn);

protected:
   int UCAVsNum, targetsNum;

   // indexed by UCAV, other
   vector< vector<int> > targets, types, benefits;

private:
   CapTransShip(const CapTransShip &) ;           // no implementation
   void operator =(const CapTransShip &) ;  // no implementation
} ;
// CapTransShip



class CapTransShipPlusSolution : public CapTransShip 
{
public:

   CapTransShipPlusSolution(int un, int tn) : CapTransShip(un, tn) {}
   CapTransShipPlusSolution(istream &fin) : CapTransShip(fin) {}

   int solve() { return CapTransShip::solve(jobsTargets, jobsTypes, benefit); }

   int getJobTarget(int u) const { return jobsTargets[u]; }
   int getType(int u) const { return jobsTypes[u]; }
   int getBenefit() const { return benefit; }

protected:
   vector<int> jobsTargets;
   vector<int> jobsTypes;
   int benefit;
} ;
// CapTransShipPlusSolution

#endif
