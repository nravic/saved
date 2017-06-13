/****************************************************
 *
 * FILE     : $RCSfile: ctpdriver.c,v $
 * AUTHOR   : hennebry
 * DATE     : $Date: 2004/01/22 20:54:51 $
 * REVISION : $Revision: 2.0 $
 *
 * MODIFICATION HISTORY:-
 *   $Log: ctpdriver.c,v $
 *   Revision 2.0  2004/01/22 20:54:51  mitchejw
 *   Initial checkin of v2-pre0
 *
 *   Revision 1.2  2003/10/23 18:37:57  rasmussj
 *   LINUX/Windows version merged into the head.
 *
 *   Revision 1.1.4.1  2003/10/23 16:51:45  rasmussj
 *   Initial LINUX port. Windows compiled and tested also.
 *
 *   Revision 1.1  2003/09/18 15:45:15  mitchejw
 *   Initial revision
 *
 *   Revision 1.1  2003/07/30 15:30:22  rasmussj
 *   Initial Revision
 *
 *
 ****************************************************/

#include "ctp.h"

#include <stdio.h>


int main(int argsNum, char *args[])
{
int retval;
struct Ctp prob;
retval=CtpReadProb(&prob, args[1]);
if(retval) {
   fprintf(stderr, "CtpReadProb returned %d\n", retval);
   return retval;
}
retval=CtpPhase1(&prob);
if(retval) {
   fprintf(stderr, "CtpPhase1 returned %d\n", retval);
   return retval;
}
retval=CtpSolve(&prob);
if(retval) {
   fprintf(stderr, "CtpPhase1 returned %d\n", retval);
   return retval;
}

CtpPrintSol(&prob, stdout, "");

return 0;
}  /* main */
