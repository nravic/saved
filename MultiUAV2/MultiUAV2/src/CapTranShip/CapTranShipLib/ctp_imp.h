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
#ifndef CTP_IMP_H
#define CTP_IMP_H 1

#include "ctp.h"

#define sign(flag) (flag? -1 : 1)

#define Ttail(ARC) ((ref[ARC]?head:tail)[ARC])
#define Thead(ARC) ((ref[ARC]?tail:head)[ARC])

#define Tcost(ARC)  (cost[ARC]*sign(ref[ARC]))

   /* reduced cost */
#define RCost(ARC)  (dual[head[ARC]] - dual[tail[ARC]] + cost[ARC])

#define Scost(JJ,CC) ( sign(ref[JJ])*CC )
     /* Cost(JJ) = Scost(JJ, CC) causes Tcost(JJ)==CC */

#define STcost(JJ) ( Cost(JJ) )
     /* sign(Ref(JJ))*Tcost(JJ) */

#define CostSave(JJ) (costSave[j])

#define Reflect(ARC) { int ntemp; ref[ARC]= !ref[ARC]; cost[ARC]= -cost[ARC]; \
   ntemp=tail[ARC]; tail[ARC]=head[ARC]; head[ARC]=ntemp; }

#endif
