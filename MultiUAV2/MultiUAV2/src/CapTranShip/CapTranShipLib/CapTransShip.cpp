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
 * FILE     : $RCSfile: CapTransShip.cpp,v $
 * AUTHOR   : hennebry
 * DATE     : $Date: 2004/05/06 13:05:28 $
 * REVISION : $Revision: 2.0.8.3 $
 *
 * MODIFICATION HISTORY:-
 *   $Log: CapTransShip.cpp,v $
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
 *   Revision 1.1  2003/09/11 16:02:10  mitchejw
 *   Initial revision
 *
 *   Revision 1.1  2003/07/30 15:30:23  rasmussj
 *   Initial Revision
 *
 *   Revision 1.3  2000/12/29 22:13:40  hennebry
 *   much rewriting
 *
 *   Revision 1.2  2000/11/16 22:59:54  hennebry
 *   added stuff to ease interface with java
 *
 *   Revision 1.1  2000/11/02 18:28:12  hennebry
 *   Initial revision
 *
 *
 ****************************************************/

#include <cassert>

#include "CapTransShip.h"
#include "ctp.h"
#include "badvaluec.h"

using std::endl;

CapTransShip::CapTransShip(int un, int tn) { init(un, tn); }


CapTransShip::CapTransShip(istream &fin)
{
	int un, tan;
	fin >> un >> tan;
	assert(fin);
	init(un, tan);

	int u;
	fin >>u;
	while(1<=u && u<=UCAVsNum && fin) 
	{
	   int ta, ty, b;
	   fin >>ta >>ty >>b;
	   if(0> ta || ta> targetsNum) 
	   {
		  throw BadValueC<int>(ta, "CapTransShip::CapTransShip(istream &)", "target");
	   }
	   addJob(u, ta, ty, b);
	   fin >>u;
	}  // while

	if(-1 != u) 
	{
	   throw BadValueC<int>(u, "CapTransShip::CapTransShip(istream &)", "UCAV or sentinel");
	}
}  // CapTransShip



//================================================================= init

void CapTransShip::init(int un, int tn) 
{
	UCAVsNum=un;
	targetsNum=tn;
	targets.resize(un+1);
	types.resize(un+1);
	benefits.resize(un+1);
}  // init


//==================================================================== print

void CapTransShip::print(ostream &fout) const
{
	fout <<UCAVsNum <<" UCAVs\n"
		 <<targetsNum <<" targets\n"
		 <<"target  type  benefit\n";

	{
		int u;
		for(u=1; u<=UCAVsNum; u++) 
		{
		   fout <<"UCAV " <<u <<endl;
		   int j, jLimit=targets[u].size();
		   for(j=0; j< jLimit; j++) 
		   {
			  fout <<targets[u][j] <<"   " <<types[u][j] <<"   "
										<<benefits[u][j] <<endl;
		   }  // j
		}  // u
	}
}  // print



//=================================================================== setJobs

int CapTransShip::
setJobs(int u, const vector<int> &tas,
                      const vector<int> &tys, const vector<int> &bs)
{
	static const char *fname="CapTransShip::setJobs";
	if(1> u || u> UCAVsNum)
	{
		throw BadValueC<int>(u, fname, "UCAV");
	}
	if(tas.size() != tys.size() || tys.size() != bs.size())
	{
		return 2;
	}

	targets[u].clear();
	typedef vector<int> vector_t;
	typedef vector_t::const_iterator const_iterator;
	vector_t* pvint1 = &targets[u];
	for(const_iterator itTargets=tas.begin();itTargets!=tas.end();itTargets++)
	{
		pvint1->push_back(*itTargets);
	}
	types[u].clear();
	for(const_iterator itTypes=tys.begin();itTypes!=tys.end();itTypes++)
	{
		types[u].push_back(*itTypes);
	}
	benefits[u].clear();
	for(const_iterator itBenefits=bs.begin();itBenefits!=bs.end();itBenefits++)
	{
		benefits[u].push_back(*itBenefits);
	}

	return 0;
}  // setJobs


//=================================================================== addJob

int CapTransShip::addJob(int u, int ta, int ty, int b)
{
	static const char *fname="CapTransShip::addJob(int, int, int, int)";
	if(1> u || u> UCAVsNum) throw BadValueC<int>(u, fname, "UCAV");
	if(0> ta || ta> targetsNum) throw BadValueC<int>(ta, fname, "target");
	targets[u].push_back(ta);
	types[u].push_back(ty);
	benefits[u].push_back(b);
	return 0;
}  // addJob



//================================================================== solve

int CapTransShip::solve(vector<int> &tas, vector<int> &tys, int &benefit) const
{
	// UCAV nodes:    1..UCAVsNum
	// target nodes:  UCAVsNum+1..UCAVsNum+targetsNum
	// terminal node: UCAVsNum+targetsNum+1

	int terminalNode=UCAVsNum+targetsNum+1;
	int arcsNum=targetsNum;
	int flag;

	// count arcs
	{
		int u;
		for(u=1; u<=UCAVsNum; u++) arcsNum+=targets[u].size();
	}

	struct Ctp prob;
	CtpInit(&prob, terminalNode, arcsNum+terminalNode,
			10*(arcsNum+terminalNode), 0, 0, 0 );
	CtpSetNodesNum(&prob, terminalNode);

	// set sources, offsets, add assigment arcs
	vector<int> offsets(UCAVsNum+1);
	CtpSetNode(&prob, terminalNode, -UCAVsNum);

	int offset=1;
	int u;
	for(u=1; u<=UCAVsNum; u++) 
	{
	   flag=CtpSetNode(&prob, u, 1);
	   assert(0==flag); flag=1;

	   // add arcs for UCAV u
	   int j, jLimit=targets[u].size();
	   for(j=0; j< jLimit; j++) 
	   {
		  int head=targets[u][j];
		  if(0==head)
		  {
			  head=terminalNode;
		  }
		  else
		  {
			  head=UCAVsNum+head;
		  }
		  flag=CtpAddArc(&prob, u, head, 2, -benefits[u][j]);
		  assert(0==flag); 
		  flag=1;
	   }  // j

	   offsets[u]=offset;  // index of initial arc from node u
	   offset+=jLimit;
	}

	// add sink arcs
	for(int n=UCAVsNum+1; n< terminalNode; n++)
	{
									   CtpAddArc(&prob, n, terminalNode, 1, 0);
	}

	// solve
	int ctpFlag=CtpPhase1(&prob);
	ctpFlag=CtpSolve(&prob);

	// return solution
	benefit=-prob.obj;
	tas.resize(UCAVsNum+1, -1);
	tys.resize(UCAVsNum+1, -1);

	int *sol=new int[prob.arcsNum+1];
	CtpGetSolution(&prob, sol);
	int a;
	for(a=1, u=1; a<=prob.arcsNum &&
				  (prob.tail[a]<=UCAVsNum || prob.head[a]<=UCAVsNum); a++ ) 
	{
	   if(1==sol[a]) 
	   {
		  int j=a-offsets[u];
		  int t=targets[u][j];
		  tas[u]=t;
		  tys[u]=types[u][j];
		  u++;
	   }
	}  // a

	delete [] sol;

	CtpDestroy(&prob);
	return 0;
}  // solve
