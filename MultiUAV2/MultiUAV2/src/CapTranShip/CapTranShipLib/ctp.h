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
 * FILE     : $RCSfile: ctp.h,v $
 * AUTHOR   : hennebry
 * DATE     : $Date: 2004/05/06 13:05:29 $
 * REVISION : $Revision: 2.0.8.3 $
 *
 * MODIFICATION HISTORY:-
 *   $Log: ctp.h,v $
 *   Revision 2.0.8.3  2004/05/06 13:05:29  rasmussj
 *   Merge corrections from stable that happened after merging RAS-02 into STABLE.
 *
 *   Revision 2.0.18.1  2004/05/06 12:47:32  rasmussj
 *   Merged in Development for inital releaase of 2.0
 *
 *   Revision 2.0.20.1  2004/05/06 12:26:50  rasmussj
 *   Merged RAS-02
 *
 *   Revision 2.0.8.2  2004/05/03 20:38:42  rasmussj
 *   Fixed comments, i.e. C->C++
 *
 *   Revision 2.0.8.1  2004/04/30 16:40:11  rasmussj
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
 *   Revision 1.1  2003/09/18 15:47:48  mitchejw
 *   Initial revision
 *
 *   Revision 1.1  2003/07/30 15:30:24  rasmussj
 *   Initial Revision
 *
 *   Revision 1.1  2000/11/02 18:27:23  hennebry
 *   Initial revision
 *
 *
 ****************************************************/

#ifndef CTP_H
#define CTP_H 1

#include <stdio.h>

#if defined(__cplusplus) /* C++ */
extern "C" {
#endif

struct Ctp {
   int      nodesNum,
            nodesNumMax,
            arcsNum,
            arcsNumMax,
            root,
            itersNum,
            itersNumMax;

   int verbosity;
   int arcEnter;
   int checkPoint;
   int checkPointInc;

   int supSum,   /* should be zero */
       obj,
       phase;  /* 0=no basis,  1=phase 1,  2=phase 2 */

   /* most indexed from 1 */
   int *tail,  /* as possibly reflected */
       *head,  /* as possibly reflected */
       *cost,  /* as possibly negated */
       *costSave,  /* not negated */
       *kap,   /* capacity */
       *ref,   /* reflected */
       *sup,   /* supply */
       *barc,  /* basis arc from node to parent */
       *flow,
       *flowComp,
       *dual,
       *parent,
       *nextPre,  /* next in preorder */
       *depth;    /* [0..nodesNum]  depth[root] = 1 */
} ;
/* Ctp */


int CtpInit(struct Ctp *toCtp,
            unsigned nodesNumMax, unsigned arcsNumMax, unsigned itersNumMax,
            int cp, int cpi, int ver );

int CtpAlloc(struct Ctp *toCtp);
int CtpArgs(struct Ctp *toCtp, int argsNum, char **args);
void CtpDestroy(struct Ctp *prob);

int CtpSetNodesNum(struct Ctp *toCtp, unsigned nn);
int CtpSetNode(struct Ctp *toCtp, int n, int s);
int CtpAddArc(struct Ctp *toCtp, unsigned t, unsigned h, int k, int c);
int CtpGetNode(struct Ctp *toCtp, int n, int *s);
int CtpGetArc(struct Ctp *toCtp, int arc, int *t, int *h, int *k, int *c);
int CtpGetSolution(struct Ctp *toCtp, int *sol);

int CtpPhase1(struct Ctp *toCtp);
int CtpPhase12(struct Ctp *toCtp, int flag);  /* called by CtpPhase1 */
int CtpSolve(struct Ctp *toCtp);

void
CtpFindEntrant(struct Ctp *toCtp, int *vet, int *veh, int *vea, int *vrcost);

int CtpMakeBasic(struct Ctp *toCtp, int t, int h, int a, int rc);
void CtpPrice(struct Ctp *toCtp);
int CtpOk(struct Ctp *toCtp);
int CtpReadProb(struct Ctp *toCtp,  const char *fname);
int CtpReadNetGen(struct Ctp *toCtp, const char *fname);
int CtpPrintSol(struct Ctp *toCtp, FILE *fout, const char *label);
int CtpDump(struct Ctp *toCtp, FILE *fout);
int CtpPrintSol(struct Ctp *toCtp, FILE *fout, const char *msg);
int CtpPrintNodes(struct Ctp *toCtp, FILE *fout, const char *msg);
int CtpPrintArcs(struct Ctp *toCtp, FILE *fout, const char *msg);
int CtpPrintProb(struct Ctp *toCtp, FILE *fout, const char *msg);
int CtpLindo(struct Ctp *toCtp, FILE *fout);
int CtpCheckPoint(struct Ctp *toCtp, char *prefix, int i, char **fname);
int CtpRestart(struct Ctp *toCtp, const char *fname);
int Unphase1(struct Ctp *toCtp);
int CtpErrVal(void);

#if defined(__cplusplus) /* C++ */
}
#endif

#endif
