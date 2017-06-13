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
 * FILE     : $RCSfile: ctp.c,v $
 * AUTHOR   : hennebry
 * DATE     : $Date: 2004/05/06 13:05:29 $
 * REVISION : $Revision: 2.0.8.3 $
 *
 * MODIFICATION HISTORY:-
 *   $Log: ctp.c,v $
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
 *   Revision 1.3  2003/09/11 17:26:21  mitchejw
 *   0. removed some comment tokens in preprocessor directives
 *   1. add (FILE*) cast to fdopen() call 'cuz it complained, even though
 *      the proto say it returns FILE* and not int.  *shrugs*
 *
 *   Revision 1.2  2003/09/11 16:14:02  mitchejw
 *   linux compile clean up.
 *
 *   Revision 1.1  2003/09/11 16:09:16  mitchejw
 *   Initial revision
 *
 *   Revision 1.1  2003/07/30 15:30:24  rasmussj
 *   Initial Revision
 *
 *   Revision 1.3  2001/01/29 20:06:45  hennebry
 *   bug fix  CtpReadProb now set checkPoint and checkPointInc to zero.
 *
 *   Revision 1.2  2000/12/29 22:09:11  hennebry
 *   bug fix
 *   basic artificial arcs at zero are now handled correctly
 *   comment change
 *   newline added to printed output
 *
 *   Revision 1.1  2000/11/02 18:27:01  hennebry
 *   Initial revision
 *
 *
 ****************************************************/

#include <stdlib.h>

#include "ctp_imp.h"


int CtpInit(struct Ctp *toCtp,
            unsigned nodesNumMax, unsigned arcsNumMax, unsigned itersNumMax,
            int cp, int cpi, int ver )
{
toCtp->nodesNum=0;
toCtp->nodesNumMax=nodesNumMax;
toCtp->arcsNum=0;
toCtp->arcsNumMax=arcsNumMax;
toCtp->root=0;
toCtp->itersNumMax=itersNumMax;
toCtp->itersNum=0;
toCtp->supSum=0;
toCtp->obj=0;
toCtp->phase=0;

toCtp->checkPoint=cp;
toCtp->checkPointInc=cpi;
toCtp->verbosity=ver;
toCtp->arcEnter=0;

return CtpAlloc(toCtp);
}  /* CtpInit */


/*=============================================================== CtpAlloc */

int CtpAlloc(struct Ctp *toCtp)
{
int nodesNumMax1=toCtp->nodesNumMax+1;
int arcsNumMax1=toCtp->arcsNumMax+1;
toCtp->tail=(int*)malloc(sizeof(int)*arcsNumMax1);
toCtp->head=(int*)malloc(sizeof(int)*arcsNumMax1);
toCtp->cost=(int*)malloc(sizeof(int)*arcsNumMax1);
toCtp->costSave=(int*)malloc(sizeof(int)*arcsNumMax1);
toCtp->kap=(int*)malloc(sizeof(int)*arcsNumMax1);
toCtp->ref=(int*)malloc(sizeof(int)*arcsNumMax1);

toCtp->sup=(int*)malloc(sizeof(int)*nodesNumMax1);
toCtp->barc=(int*)malloc(sizeof(int)*nodesNumMax1);

toCtp->flow=(int*)malloc(sizeof(int)*arcsNumMax1);
toCtp->flowComp=(int*)malloc(sizeof(int)*arcsNumMax1);

toCtp->dual=(int*)malloc(sizeof(int)*nodesNumMax1);
toCtp->parent=(int*)malloc(sizeof(int)*nodesNumMax1);
toCtp->nextPre=(int*)malloc(sizeof(int)*nodesNumMax1);
toCtp->depth=(int*)malloc(sizeof(int)*nodesNumMax1);

return 0;
}  /* CtpAlloc */


/*============================================================= CtpDestroy */

void CtpDestroy(struct Ctp *toCtp)
{
if(toCtp->tail) { free(toCtp->tail); toCtp->tail=0; }
if(toCtp->head) { free(toCtp->head); toCtp->head=0; }
if(toCtp->cost) { free(toCtp->cost); toCtp->cost=0; }
if(toCtp->costSave) { free(toCtp->costSave); toCtp->costSave=0; }
if(toCtp->kap) { free(toCtp->kap); toCtp->kap=0; }
if(toCtp->ref) { free(toCtp->ref); toCtp->ref=0; }
if(toCtp->sup) { free(toCtp->sup); toCtp->sup=0; }
if(toCtp->barc) { free(toCtp->barc); toCtp->barc=0; }
if(toCtp->flow) { free(toCtp->flow); toCtp->flow=0; }
if(toCtp->flowComp) { free(toCtp->flowComp); toCtp->flowComp=0; }
if(toCtp->dual) { free(toCtp->dual); toCtp->dual=0; }
if(toCtp->parent) { free(toCtp->parent); toCtp->parent=0; }
if(toCtp->nextPre) { free(toCtp->nextPre); toCtp->nextPre=0; }
if(toCtp->depth) { free(toCtp->depth); toCtp->depth=0; }
toCtp->nodesNum=0;
toCtp->nodesNumMax=0;
toCtp->arcsNum=0;
toCtp->arcsNumMax=0;
toCtp->phase=0;
}  /* CtpDestroy */


/*========================================================= CtpSetNodesNum */

int CtpSetNodesNum(struct Ctp *toCtp, unsigned nn)
{
if(nn< 2) return 1;
if(nn> toCtp->nodesNumMax) return 2;
if(toCtp->phase> 0) return 3;
if(toCtp->arcsNum> 0) return 4;
toCtp->nodesNum=nn;
{
unsigned n;
for(n=0; n<=nn; n++) toCtp->sup[n]=0;
}
return 0;
}  /* CtpSetNodesNum */


/*========================================================= CtpSetNode */

int CtpSetNode(struct Ctp *toCtp, int n, int s)
{
if(toCtp->phase> 0) return -2;
if(1> n || n> toCtp->nodesNum) return -1;
toCtp->supSum+=s-toCtp->sup[n];
toCtp->sup[n]=s;
return 0;
}  /* CtpSetNode */



/*============================================================== CtpAddArc */

int CtpAddArc(struct Ctp *toCtp, unsigned t, unsigned h, int k, int c)
{
int arcsNum=toCtp->arcsNum;

if(toCtp->nodesNum< t || t< 1 || toCtp->nodesNum< h || h< 1) return 1;
if(k< 0) return 2;
if(arcsNum>=toCtp->arcsNumMax) return 3;
if(toCtp->phase> 0) return 4;
arcsNum= ++(toCtp->arcsNum);
toCtp->tail[arcsNum]=t;
toCtp->head[arcsNum]=h;
toCtp->kap[arcsNum]=k;
toCtp->cost[arcsNum]=c;
toCtp->ref[arcsNum]=0;
return 0;
}  /* CtpAddArc */



/*================================================================CtpArgs */

int CtpArgs(struct Ctp *toCtp, int argsNum, char **args)
{
int a=0;
while(a< argsNum) {
   if(   0==strcmp(args[a], "-itersNumMax") ||
         0==strcmp(args[a], "-inm") ) {
      char *stopper;
      unsigned long inm=strtoul(args[a+1], &stopper, 0);
      if(*stopper> ' ') {
         fprintf(stderr, "%s does not represent "
                 "an unsigned integer\n", args[a+1] );
         return -1;
      }
      toCtp->itersNumMax=(int)inm;
      a+=2;
   } else if(0==strcmp(args[a], "-verbosity") ||
             0==strcmp(args[a], "-v") ) {
      char *stopper;
      int v=strtol(args[a+1], &stopper, 0);
      if(*stopper> ' ') {
         fprintf(stderr, "%s does not represent an integer\n", args[a+1]);
         return -2;
      }
      toCtp->verbosity=v;
      a+=2;
   } else if(0==strcmp(args[a], "-checkPoint") ||
             0==strcmp(args[a], "-cp") ) {
      char *stopper;
      int cp=strtol(args[a+1], &stopper, 0);
      if(*stopper> ' ') {
         fprintf(stderr, "%s does not represent an integer\n",
                 args[a+1] );
         return -2;
      }
      toCtp->checkPoint=cp;
      a+=2;
   } else if(0==strcmp(args[a], "-checkPointInc") ||
             0==strcmp(args[a], "-cpi") ) {
      char *stopper;
      int cpi=strtol(args[a+1], &stopper, 0);
      if(*stopper> ' ') {
         fprintf(stderr, "%s does not represent an integer\n",
                 args[a+1] );
         return -2;
      }
      toCtp->checkPointInc=cpi;
      a+=2;
   } else {
      fprintf(stderr, "%s is not a valid argument\n", args[a]);
      return -2;
   }
}  /* a */

return 0;
}  /* CtpArgs */


/*=============================================================CtpGetNode */

int CtpGetNode(struct Ctp *toCtp, int n, int *s)
{
*s=toCtp->sup[n];
return 0;
}  /* CtpGetNode */


/*===============================================================CtpGetArc */

int CtpGetArc(struct Ctp *toCtp, int arc, int *t, int *h, int *k, int *c)
{
int *tail=toCtp->tail;
int *head=toCtp->head;
int *ref=toCtp->ref;
int *cost=toCtp->cost;

*t=Ttail(arc);
*h=Thead(arc);
*k=toCtp->kap[arc];
*c=Tcost(arc);

return 0;
}  /* CtpGetArc */



/*===========================================================CtpGetSolution */

int CtpGetSolution(struct Ctp *toCtp, int *sol)
{
int *tail=toCtp->tail;
int *head=toCtp->head;
int *ref=toCtp->ref;
int *barc=toCtp->barc;
int *flow=toCtp->flow;
int *flowComp=toCtp->flowComp;
int *kap=toCtp->kap;
int arcsNum=toCtp->arcsNum;

if(toCtp->phase<=0) return -1;
{
int a;
for(a=1; a<=arcsNum; a++) {
   int t=tail[a], h=head[a];
   if(barc[t]==a) {
      if(ref[a]) sol[a]=flowComp[t];
      else sol[a]=flow[t];
   } else if(barc[h]==a) {
      if(ref[a]) sol[a]=flowComp[h];
      else sol[a]=flow[h];
   } else {
      /* non-basic */
      if(ref[a]) sol[a]=kap[a];
      else sol[a]=0;
   }
}  /* a */
}

return 0;
}  /* CtpGetSolution */


static char nnm[]="nodesNumMax",
            nn[]= "nodesNum",
            anm[]="arcsNumMax",
            an[]= "arcsNum",
            inm[]="itersNumMax",
            su[]="supplies";

/*============================================================CtpReadProb */

int CtpReadProb(struct Ctp *toCtp,  const char *fname)
{
/*
   nodesNumMax <nodesNumMax>
   nodesNum <nodesNum>
   arcsNumMax <arcsNumMax>
   arcsNum <arcsNum>
   itersNumMax <itersNumMax>
   supplies
   <supply>...
   tail head cap cost
   <tail head cap cost>...
   end
*/
int nodesNumMax, nodesNum;
int arcsNumMax,  arcsNum;
int itersNumMax;
int *sup, *tail, *head, *kap, *cost;
FILE *fin;
char buf[31];
int sval;
if(!fname || *fname<=' ' || *fname=='-' && !fname[1]) fin=stdin;
else fin=fopen(fname, "r");
if(!fin) {
   fprintf(stderr, "Cannot open input file %s\n", fname);
   return __LINE__;
}

strcpy(buf, "empty");
sval=fscanf(fin, "%30s", buf);
if(sval != 1) return __LINE__;
if(strcmp(buf, nnm)) {
   fprintf(stderr, "error: buf=%s\n", buf);
   return __LINE__;
}
sval=fscanf(fin, "%d", &nodesNumMax);
if(sval!=1) return __LINE__;

sval=fscanf(fin, " %30s", buf);
if(sval != 1) return __LINE__;
if(strcmp(buf, nn)) return __LINE__;
sval=fscanf(fin, "%d", &nodesNum);
if(sval!=1) return __LINE__;

sval=fscanf(fin, " %30s", buf);
if(sval != 1) return __LINE__;
if(strcmp(buf, anm)) return __LINE__;
sval=fscanf(fin, "%d", &arcsNumMax);
if(sval!=1) return __LINE__;

sval=fscanf(fin, " %30s", buf);
if(sval != 1) return __LINE__;
if(strcmp(buf, an)) return __LINE__;
sval=fscanf(fin, "%d", &arcsNum);
if(sval!=1) return __LINE__;

toCtp->nodesNumMax=nodesNumMax;
toCtp->arcsNumMax=arcsNumMax;
CtpAlloc(toCtp);
toCtp->nodesNum=nodesNum;
toCtp->arcsNum=arcsNum;
toCtp->phase=0;
sup=toCtp->sup;
tail=toCtp->tail;
head=toCtp->head;
kap=toCtp->kap;
cost=toCtp->cost;

sval=fscanf(fin, " %30s", buf);
if(sval != 1) return __LINE__;
if(strcmp(buf, inm)) return __LINE__;
sval=fscanf(fin, "%d", &itersNumMax);
if(sval!=1) return __LINE__;
toCtp->itersNumMax=itersNumMax;
toCtp->itersNum=0;

sval=fscanf(fin, " %30s", buf);
if(sval != 1) return __LINE__;
if(strcmp(buf, su)) return __LINE__;
{
char *stopper=0;
int supSum=0;
int supn;
int n;
for(n=1; n<=nodesNum; n++) {
   sval=fscanf(fin, " %30s", buf);
   if(sval != 1) return __LINE__;
   supn=strtol(buf, &stopper, 0);
   if(stopper==buf) {
      fprintf(stderr, "string %s does not represent a valid value"
              " of sup[%d]\n",  buf, n);
      return __LINE__;
   }
   supSum+=supn;
   sup[n]=supn;
}  /* n */
toCtp->supSum=supSum;
}


sval=fscanf(fin, " %30s", buf);
if(sval != 1) return __LINE__;
if(strcmp(buf, "tail")) return __LINE__;
sval=fscanf(fin, " %30s", buf);
if(sval != 1) return __LINE__;
if(strcmp(buf, "head")) return __LINE__;
sval=fscanf(fin, " %30s", buf);
if(sval != 1) return __LINE__;
if(strcmp(buf, "cap")) return __LINE__;
sval=fscanf(fin, " %30s", buf);
if(sval != 1) return __LINE__;
if(strcmp(buf, "cost")) return __LINE__;


{
char *stopper=0;
int t, h, ca, co;
int sval;
int a;
for(a=1; a<=arcsNum; a++) {
   sval=fscanf(fin, " %30s", buf);
   if(sval != 1) return __LINE__;
   t=strtol(buf, &stopper, 0);
   if(stopper==buf) {
      fprintf(stderr, "string %s is not in integer format "
              "for tail[%d]\n",  buf, a );
      return __LINE__;
   }
   if(1> t || t> nodesNum) {
      fprintf(stderr, "tail %d for arc %d is out of range 1..%d\n",
              t, a, nodesNum );
   }
   tail[a]=t;

   sval=fscanf(fin, " %30s", buf);
   if(sval != 1) return __LINE__;
   h=strtol(buf, &stopper, 0);
   if(stopper==buf) {
      fprintf(stderr, "string %s is not in integer format "
              "for head[%d]\n",  buf, a );
      return __LINE__;
   }
   if(1> h || h> nodesNum) {
      fprintf(stderr, "head %d for arc %d is out of range 1..%d\n",
              h, a, nodesNum );
      return __LINE__;
   }
   head[a]=h;

   sval=fscanf(fin, " %30s", buf);
   if(sval != 1) return __LINE__;
   ca=strtol(buf, &stopper, 0);
   if(stopper==buf) {
      fprintf(stderr, "string %s is not in integer format "
              "for cap[%d]\n",  buf, a );
      return __LINE__;
   }
   if(ca< 0) {
      fprintf(stderr, "error: capacity %d for arc %d is negative.\n", ca, a );
      return __LINE__;
   }
   kap[a]=ca;

   sval=fscanf(fin, " %30s", buf);
   if(sval != 1) return __LINE__;
   co=strtol(buf, &stopper, 0);
   if(stopper==buf) {
      fprintf(stderr, "string %s is not in integer format "
              "for cost[%d]\n",  buf, a );
      return __LINE__;
   }
   cost[a]=co;

}  /* a */

}

sval=fscanf(fin, " %30s", buf);
if(sval != 1) return __LINE__;
if(strcmp(buf, "end")) {
   fprintf(stderr, "error: no end line\n");
   return __LINE__;
}

toCtp->checkPoint=toCtp->checkPointInc=0;  /* no checkpoints */

return 0;

}  /* CtpReadProb */



/*===========================================================CtpReadNetGen */

int CtpReadNetGen(struct Ctp *toCtp, const char *fname)
{
/* NETGEN format:
BEGIN
NETGEN PROBLEM     999                nodesNum NODES AND     arcsNum ARCS
USER:   99999999       suppliesNum       demandsNum        9      999   999999
DATA:          9          9          9        999          9       9999
SUPPLY
           nodeNum          supply
...
ARCS
           tail  head        cost capacity
...
DEMAND
        nodeNum     demand
...
END

arcsNum is often wrong
To connect the graph, netgen will often add additional
arcs to connect a graph

*/

int nodesNum, arcsNumMin;
int suppliesNum, demandsNum;
int sc, retval;
int supSum=0;
int *tail, *head, *cost, *ref, *sup, *kap;
FILE *fin=fopen(fname, "r");
int n;
char str[30], nodesStr[30];
toCtp->phase=toCtp->nodesNum=-1;
if(!fin) {
   if(toCtp->verbosity>=1) {
      fprintf(stderr, "cannot open file %s for input.\n", fname);
   }
   return -120;
}

{
/* get nodesNum */
while(!feof(fin)) {
   fscanf(fin, "%20s", str);
   if(strcmp(str, "NODES")) {
      strcpy(nodesStr, str);
   } else break;
}  /* fin */

if(feof(fin)) return -1;
nodesNum=atoi(nodesStr);
if(nodesNum< 2) return -2;
}

if(nodesNum< 2 || feof(fin)) return -3;
toCtp->nodesNum=nodesNum;


{
/* get arcsNumMin */
while(!feof(fin)) {
   fscanf(fin, "%20s", str);
   if(strcmp(str, "ARCS")) {
      strcpy(nodesStr, str);
   } else break;
}  /* fin */

if(feof(fin)) return -1;
arcsNumMin=atoi(nodesStr);
if(arcsNumMin< 1) return -2;
}

if(arcsNumMin< 1 || feof(fin)) return -6;

retval=CtpInit(toCtp, nodesNum, arcsNumMin+2*nodesNum,
               10*(arcsNumMin+nodesNum), 0, 0, 0 );
if(retval) return -7;
tail=toCtp->tail;
head=toCtp->head;
cost=toCtp->cost;
sup=toCtp->sup;
kap=toCtp->kap;
ref=toCtp->ref;
toCtp->nodesNum=nodesNum;
toCtp->verbosity=1;
{
int j;
for(j=1; j<=nodesNum; j++) sup[j]=0;
}

/* find number of supplies and demands */
{
while(!feof(fin)) {
   int n=-9;
   fscanf(fin, "%*[^U]USER:%n", &n);
   if(n>=0) break;
}  /* fin */
}

if(feof(fin)) {
   return -100;
}

n=-9;
fscanf(fin, "%*d%d%d%n", &suppliesNum, &demandsNum, &n);
if(n< 0) {
   return -101;
}

if(suppliesNum< 0 || demandsNum< 0 || suppliesNum+demandsNum> nodesNum) {
   return -102;
}


/* get positive supply values */
do {
   n=-9;
   fscanf(fin, "%*[^S]SUPPLY %n", &n);
} while(!feof(fin) && n< 0);

if(feof(fin)) return -8;


{
int j;
for(j=1; j<=suppliesNum; j++) {
   int nodeNum, supply;
   int sc=fscanf(fin, "%d %d", &nodeNum, &supply);
   if(sc != 2) {
      if(toCtp->verbosity>=1) {
         fprintf(stderr, "sc=%d  nodesNum=%d  supply=%d\n",
                 sc, nodesNum, supply );
      }
      return -9;
   }
   if(1> nodeNum || nodeNum> nodesNum || supply< 0) {
      return -10;
   }
   if(sup[nodeNum] != 0) {
      return -11;
   }
   supSum+=supply;
   sup[nodeNum]=supply;
}  /* j */
}


/* get arcs */
{
int arcsNum=0;
int arcsNumMax=arcsNumMin+nodesNum;
{
int n=-666;
fscanf(fin, " ARCS %n", &n);
if(n< 0) {
   return -12;
}
}

while(1) {
   int t, h, c, k;
   sc=fscanf(fin, "%d%d%d%d", &t, &h, &c, &k);
   if(sc==4) {
      if(1> t || t> nodesNum || 1> h || h> nodesNum) {
         return -15;
      }
      if(k< 0) {
         return -16;
      }
      arcsNum++;
      if(arcsNum> arcsNumMax) {
         return -123;
      }
      tail[arcsNum]=t; head[arcsNum]=h;
      cost[arcsNum]=c; kap[arcsNum]=k;
      ref[arcsNum]=0;
   } else if(sc==0) break;
   else {
      return -13;
   }
}  /* while */

toCtp->arcsNum=arcsNum;
}

/* get negative supply values */
{
int n=-9;
fscanf(fin, "%9s%n", str, &n);
if(n< 0) {
   return -121;
}
if(strcmp(str, "DEMAND")) {
   return -122;
}
}

if(feof(fin)) return -8;

{
int j;
for(j=1; j<=demandsNum; j++) {
   int nodeNum, demand;
   int sc=fscanf(fin, "%d %d", &nodeNum, &demand);
   if(sc != 2) {
      if(toCtp->verbosity>=1) {
         fprintf(stderr,
            "j=%d  sc=%d  nodeNum=%d  demand=%d\n",
            j, sc, nodeNum, demand );
      }
      return -110;
   }
   if(1> nodeNum || nodeNum> nodesNum || demand< 0) {
      return -10;
   }
   if(sup[nodeNum] != 0) {
      return -11;
   }
   supSum-=demand;
   sup[nodeNum]=-demand;
}  /* j */
}

toCtp->supSum=supSum;

if(supSum != 0) {
   return -12;
}
toCtp->phase=0;
toCtp->arcEnter=0;
return 0;
}  /* CtpReadNetGen */



static char yn[2][5] = { "NO  ", "YES " } ;


/*================================================================CtpDump */
 
int CtpDump(struct Ctp *toCtp, FILE *fout)
{
int nodesNum=toCtp->nodesNum;
int arcsNum=toCtp->arcsNum;
int itersNum=toCtp->itersNum;
int obj=toCtp->obj;


int *cost=toCtp->cost;
int *ref=toCtp->ref;
int *barc=toCtp->barc;
int *flow=toCtp->flow;
int *flowComp=toCtp->flowComp;
int *dual=toCtp->dual;
int *parent=toCtp->parent;
int *nextPre=toCtp->nextPre;
int *depth=toCtp->depth;

int j, jLimit=arcsNum;

if(!fout) return 0;

if(nodesNum> jLimit) jLimit=nodesNum;
fprintf(fout, "\nDUMP HERE. OBJ=%d   COUNT=%d\n", obj, itersNum);
fprintf(fout, "INDEX REF COST FLOW FLOWCOMP DUAL PAR BARC NPRE DEPTH INDEX\n");

for(j=1; j<=jLimit; j++) {
   if(j<=arcsNum) fprintf(fout, "%5d %4.4s%4d", j, yn[ref[j]], cost[j]);
   else fprintf(fout, "%14s", "");
   if(j<=nodesNum) {
      fprintf(fout, " %4d %6d %6d %3d %4d %4d %5d %5d", flow[j], flowComp[j],
         dual[j], parent[j], barc[j], nextPre[j], depth[j], j);
   }
   fprintf(fout, "\n");
}  /* j */
return 0;
}  /* CtpDump */
 

/*============================================================ CtpPrintSol */

int CtpPrintSol(struct Ctp *toCtp, FILE *fout, const char *msg)
{
int arcsNum=toCtp->arcsNum;
int itersNum=toCtp->itersNum;
int obj=toCtp->obj;
int phase=toCtp->phase;




int *tail=toCtp->tail;
int *head=toCtp->head;
int *kap=toCtp->kap;
int *ref=toCtp->ref;
int *barc=toCtp->barc;
int *flow=toCtp->flow;
int *flowComp=toCtp->flowComp;

int h, t;
int  a;
int f;
char *bnb;

fprintf(fout, "%s printsol:\n", msg);
if(!phase) {
   fprintf(fout, "printsol: no solution to print\n");
   return -1;
}
fprintf(fout, 
 "           OBJ=%d   COUNT=%d\n%7s ARC %8s FLOW\n",
          obj, itersNum, "", "" );
for(a=1 ; a<=arcsNum ; a++) {
   t=(ref[a] ? head : tail)[a]; h=(ref[a] ? tail : head)[a];
   fprintf(fout, "%8d-->%-8d", t, h);
   if(ref[a]) {
      if(barc[h]==a) {    
         f=flowComp[h];
         bnb=" BASIC   ";
      } else {            
         f=kap[a];
         bnb=" NONBASIC";
      }
   } else {
      if(barc[t]==a) {    
         f=flow[t];
         bnb=" BASIC   ";
      } else {            
         f=0;
         bnb=" NONBASIC";
      }
   }
   fprintf(fout, "%5d%s\n", f, bnb);
}   

fprintf(fout, "printsol done\n");
return 0;
}  /* CtpPrintSol */


/*============================================================CtpPrintNodes */

int CtpPrintNodes(struct Ctp *toCtp, FILE *fout, const char *msg)
{
int nodesNum=toCtp->nodesNum;
int supSum=toCtp->supSum;

int *sup=toCtp->sup;

int n;

fprintf(fout, "\n%s printnodes: %d nodesNum\n", msg, nodesNum);

fprintf(fout, "%12.12s   %11.11s\n", "node",  "supply");
for(n=1; n<=nodesNum; n++) {
   fprintf(fout, "%8d   %11d\n", n, sup[n]);
}
fprintf(fout, "Total supply is %d\nprintnodes done\n", supSum);
return 0;
}  /* CtpPrintNodes */


/*============================================================CtpPrintArcs */

int CtpPrintArcs(struct Ctp *toCtp, FILE *fout, const char *msg)
{
int arcsNum=toCtp->arcsNum;

int *tail=toCtp->tail;
int *head=toCtp->head;
int *cost=toCtp->cost;
int *ref=toCtp->ref;
int *kap=toCtp->kap;

int a;

fprintf(fout, "\n%s printarcs: %d arcsNum\n", msg, arcsNum);

fprintf(fout, "%8.8s-->%-12.12s   %10.10s   %11.11s\n",
        "tail",    "head",  "capacity", "cost");
for(a=1; a<=arcsNum; a++) {
   fprintf(fout, "%8d-->%-8d   %10u   %11d\n",
           (ref[a] ? head : tail)[a],
           (ref[a] ? tail : head)[a], kap[a], Tcost(a) );
}

fprintf(fout, "printarcs done\n");
return 0;
}  /* CtpPrintArcs */


/*=============================================================CtpPrintProb */

int CtpPrintProb(struct Ctp *toCtp, FILE *fout, const char *msg)
{
fprintf(fout, "%s printprob: \n", msg);
CtpPrintNodes(toCtp, fout, "printprob: ");
CtpPrintArcs(toCtp, fout, "printprob: ");
fprintf(fout, "printprob done\n");
return 0;
}  /* CtpPrintProb */


/*================================================================CtpPhase1 */

int CtpPhase1(struct Ctp *toCtp)
{
int oldarcs, a;
int flag;

int nodesNum=toCtp->nodesNum;
int arcsNum=toCtp->arcsNum;
int arcsNumMax=toCtp->arcsNumMax;
int root=toCtp->root;
int supSum=toCtp->supSum;
int obj=toCtp->obj;
int phase=toCtp->phase;

int *tail=toCtp->tail;
int *head=toCtp->head;
int *cost=toCtp->cost;
int *costSave=toCtp->costSave;
int *kap=toCtp->kap;
int *ref=toCtp->ref;
int *sup=toCtp->sup;
int *barc=toCtp->barc;
int *flow=toCtp->flow;
int *flowComp=toCtp->flowComp;
int *dual=toCtp->dual;
int *parent=toCtp->parent;
int *nextPre=toCtp->nextPre;
int *depth=toCtp->depth;

switch (phase) {
case 2:
   if(toCtp->verbosity>=1) {
      fprintf(stderr, "There already is a basis:\n");
      CtpPrintSol(toCtp, stderr, "CtpPhase1: ");
   }
   return 1;
case 1: goto f1;
case 0: break;
default : {
   if(toCtp->verbosity>=1) {
      fprintf(stderr, "phase=%d  error in ctp code\n", phase);
   }
   return -1;
}}  

if(supSum != 0) {
   if(toCtp->verbosity>=1) fprintf(stderr, "Total supply = %d != 0\n", supSum);
   return -1;
}
if(nodesNum<2) {
   if(toCtp->verbosity>=1) fprintf(stderr, "No arcs; no variable; no basis\n");
   return -1;
}
if(arcsNumMax<arcsNum+nodesNum-1) {
   if(toCtp->verbosity>=1) {
      fprintf(stderr, "Need at least %d more arcs\n",
              arcsNum+nodesNum-1-arcsNumMax );
   }
   return -1;
}

toCtp->root=root=1;
toCtp->obj=obj=0;
for(a=1; a <=arcsNum; a++) { costSave[a]=Tcost(a), cost[a]=0, ref[a]=0; }
oldarcs=arcsNum;
toCtp->arcsNum=arcsNum+=nodesNum-1;
{
int n;
for(n=2, a=oldarcs+1; n<=nodesNum; n++, a++) {
   parent[n]=root;
   depth[n]=2;
   nextPre[n]=n+1;
   barc[n]=a;
   if(sup[n] > 0) {  
      ref[a]=0;
      tail[a]=n;
      head[a]=root;
      cost[a]=Scost(a, n);
      obj += n*sup[n];
      dual[n]=n;
      kap[a]=sup[n];
      flow[n]=sup[n];
      flowComp[n]=0;
   } else {          
      ref[a]=1;
      tail[a]=n;
      head[a]=root;
      cost[a]= Scost(a, n);
      obj -= n*sup[n];
      dual[n]= -n;
      kap[a]= -sup[n];
      flow[n]=0;
      flowComp[n]= -sup[n];
   }   
}  /* n */
}

toCtp->obj=obj;

depth[root]=1;
depth[0]=0;
parent[root]=0;
barc[root]=0;
flow[root]=flowComp[root]=0;
nextPre[root]=2;
nextPre[nodesNum]=0;
dual[root]=0;
toCtp->phase=phase=1;

f1:
flag=CtpSolve(toCtp);
return CtpPhase12(toCtp, flag);
}  /* CtpPhase1 */


/*==============================================================CtpPhase12 */

int CtpPhase12(struct Ctp *toCtp, int flag)
{
int obj=toCtp->obj;
int arcsNum=toCtp->arcsNum;
int nodesNum=toCtp->nodesNum;
int root=toCtp->root;
int *tail=toCtp->tail;
int *head=toCtp->head;
int *dual=toCtp->dual;
int *barc=toCtp->barc;
int *nextPre=toCtp->nextPre;
int *parent=toCtp->parent;
int *depth=toCtp->depth;
int *flow=toCtp->flow;
int *flowComp=toCtp->flowComp;
int *costSave=toCtp->costSave;
int *cost=toCtp->cost;
int *ref=toCtp->ref;
int *kap=toCtp->kap;


if(obj != 0) {
   switch (flag) {
   case 1:  if(toCtp->verbosity>=1) {
               fprintf(stderr, "CtpPhase1: feasibility not resolved\n");
            }
            return -1;
   case 0:  if(toCtp->verbosity>=1) {
               fprintf(stderr, "CtpPhase1: problem infeasible,");
               fprintf(stderr, " optimal phase 1 basis retained\n"); 
            }
            return 1;
   case -1: if(toCtp->verbosity>=1) {
               fprintf(stderr, "CtpPhase1: CtpSolve returned -1\n");
            }
            return -1;
   default: if(toCtp->verbosity>=1) {
                fprintf(stderr,
                   "CtpPhase1: CtpSolve returned %d: error in ctp code\n",
                   flag );
            }
            return -2;
   }  /* flag */
}  /* obj */


{
int lastRealArc=arcsNum-nodesNum+1;
int baNum=0;  /* num basic artificials */
int n;
for(n=1; n<=nodesNum; n++) if(barc[n]> lastRealArc) {
   baNum++;
   flow[n]=flowComp[n]=0; /* get ready to zero its capacity */
}  /* n */

if(baNum> 0) {
   {
   /* set artificial capacities to zero */
   /* artificials may be saturated at zero */
   int a;
   for(a=lastRealArc+1; a<=arcsNum; a++) kap[a]=0;
   }

   {
   /* pivot artificials out of the basis */
   int a, failures;
   for(a=1, failures=0; baNum> 0 && failures< lastRealArc; a=a%lastRealArc+1) {
      if(dual[head[a]] != dual[tail[a]]) {
         CtpMakeBasic(toCtp, Ttail(a), Thead(a), a, 0);
         failures=0;
      } else failures++;
   }  /* a, baNum, failures */
   }
}  /* baNum */
}
 
toCtp->arcsNum=arcsNum -= nodesNum-1;

{
/* get rid of basic artificial arcs, if any
   might disconnect the network */
int alpha=root, beta, gamma, r;
do {
   r=nextPre[alpha];
   if(r==0) break;
   if(barc[r] > arcsNum) {
      flow[r]=flowComp[r]=0;
      parent[r]=0;
      barc[r]=0;
      beta=r;
      do {
         gamma=nextPre[beta];
         depth[beta]--;
         if(depth[gamma]< 3) break;
         beta=gamma;
      }  while(1);

      nextPre[alpha]=gamma;
      nextPre[beta]=root;
      root=r;
      if(gamma==0) break;
   }   

   alpha=nextPre[alpha];
}  while(1);
}

{ int a ; for(a=1; a<=arcsNum; a++) cost[a]=Scost(a, costSave[a]); }
CtpPrice(toCtp);
toCtp->phase=2;
return 0;
}  /* CtpPhase12 */



/*=================================================================CtpPrice */

void CtpPrice(struct Ctp *toCtp)
{
/* initializes dual variables & obj */
int nodesNum=toCtp->nodesNum;
int arcsNum=toCtp->arcsNum;
int root=toCtp->root;
int obj=toCtp->obj;

int *cost=toCtp->cost;
int *kap=toCtp->kap;
int *ref=toCtp->ref;
int *barc=toCtp->barc;
int *flow=toCtp->flow;
int *dual=toCtp->dual;
int *parent=toCtp->parent;
int *nextPre=toCtp->nextPre;

int n, j;
int  a;
obj=0;
for(a=1; a<=arcsNum; a++) {
   if(ref[a]) obj += kap[a]*Tcost(a);
}
    
dual[root]=0;
n=root;
for(j=2; j<=nodesNum; j++) {
   n=nextPre[n];
   a=barc[n];
   if(a==0) dual[n]=0;
   else {
      dual[n]=dual[parent[n]]+( cost[a] );
      obj +=flow[n]*( cost[a] );
   }
}  

toCtp->obj=obj;
}  /* CtpPrice */
    

/*==========================================================CtpFindEntrant */

void
CtpFindEntrant(struct Ctp *toCtp, int *vet, int *veh, int *vea, int *vrcost)
{
/* find an improving arc */
/* the returned endpoints are the real unreflected endpoints */
int      rc;

int arcsNum=toCtp->arcsNum;
int arcEnter=toCtp->arcEnter;

int *tail=toCtp->tail;
int *head=toCtp->head;
int *cost=toCtp->cost;
int *kap=toCtp->kap;
int *ref=toCtp->ref;
int *dual=toCtp->dual;

/* first available */
{
int j;
for(j=1; j<=arcsNum; j++) {
   arcEnter=arcEnter%arcsNum+1;
   rc=RCost(arcEnter);
   if(rc < 0 && kap[arcEnter]> 0) {
      (*veh)=(ref[arcEnter] ? tail : head)[arcEnter];
      (*vet)=(ref[arcEnter] ? head : tail)[arcEnter];
      (*vea)=arcEnter; (*vrcost)=rc;
      toCtp->arcEnter=arcEnter;
      return;
   }
}  /* j */
}
       
(*veh)=0; (*vet)=0; (*vea)=0; (*vrcost)=1;  
}  /* CtpFindEntrant */


/*=============================================================CtpMakeBasic */
       
int CtpMakeBasic(struct Ctp *toCtp,
                 int entertail, int enterhead, int enterarc, int rcost )
{
/* int entertail, enterhead;   the real, unreflected endpoints
   int  enterarc;
   int rcost;
   performs a pivot which allows the specified arc to enter the basis
   if the current basis is feasible the blocking arc is selected to
   produce the smallest possible new flow
   if the current basis is not feasible the blocking arc is selected to
   produce the smallest possible non-negative new flow
   this is done by ignoring already violated limits
 */

int root=toCtp->root;
int obj=toCtp->obj;

int *tail=toCtp->tail;
int *head=toCtp->head;
int *cost=toCtp->cost;
int *kap=toCtp->kap;
int *ref=toCtp->ref;
int *barc=toCtp->barc;
int *flow=toCtp->flow;
int *flowComp=toCtp->flowComp;
int *dual=toCtp->dual;
int *parent=toCtp->parent;
int *nextPre=toCtp->nextPre;
int *depth=toCtp->depth;



int lo, mid, hi,               /* nodes usually on pivot stem */
         flowtail, flowhead,        /* effective tail and head of enterarc */
         blockchild,                /* 0 or deeper node of blocking arc     */
         t, h,
         depthlimit,          /* temporary stops search for beta, gamma */
         startadd, startsub,  /* deepest parts of backpaths not in pivot stem */
         join,                /* deepest common part of backpaths */
         alpha1,              /* NextPre(alpha) */
         alpha,               /* predecesor(mid) = last(LSubtree(hi)) */
         beta,                /* last(subtree(mid))  */
         gamma;               /* Nextpre(beta)  */

int  newarc, oldarc;      /* temporaries help to update Barc(pivot stem) */
int newFlow, newFlowcomp,   /* temporaries help to update flows */
         oldFlow, oldFlowcomp,   /* ditto */
         dflow,               /* change in flow in entering arc */
         dpflow;              /* change in flows in pivot stem   */
int ddual;               /* change in duals */
int ddepth,                   /* differences in depth */
    tailblocker;             /* =1 if blocking arc is on backpath(flowtail)
                                =0 if blocking arc is on backpath(flowhead) */

/* the pivot stem is the set of nodes along the path from a node of the
   entering arc (deepest) to the blocking child (shallowest)

   if mid=Parent(lo) and lo & mid are on the pivot stem :
      LSubtree(mid) = { n in subtree(mid) : n precedes lo in preorder }
                      which always contains mid
   RForest(mid)  = subtree(mid) - subtree(lo) - LSubtree(mid)
                   which may be empty
   if mid is on the pivot stem, but has no child on the pivot stem :
      mid in { entertail, enterhead }
      LSubtree(mid) = { mid }
      RForest(mid)  = subtree(mid) - { mid }
 */

/* get correct direction */
if(ref[enterarc]) {
   flowtail=enterhead;
   flowhead=entertail;
} else {
   flowtail=entertail;
   flowhead=enterhead;
}

 
/* find blocking arc */
t=flowtail; h=flowhead;
dflow=kap[enterarc];  /* first consider entering arc */
ddepth=depth[h] -(int)0 -depth[t];
blockchild=0;  /* none such so far */

/* search nodes deeper than flowhead */
for( ; ddepth<0; ddepth++,t=parent[t]) {
   if(flow[t]<dflow && flow[t]>=0) {          /* ignores violated limits */
      dflow=flow[t];
      blockchild=t;
      tailblocker=1;
   }
}  /* t */

/* search nodes deeper than flowtail */
for( ; ddepth>0; ddepth--,h=parent[h]) {
   if(flowComp[h]<dflow && flowComp[h]>=0) {  /* ignores violated limits */
      dflow=flowComp[h];
      blockchild=h;
      tailblocker=0;
   } 
}  /* h */

/* Depth(t)==Depth(h) */
for( ; t != h; t=parent[t], h=parent[h]) {
   if(flow[t]<dflow && t != root && flow[t]>=0) { /* ignores violated limits */
      dflow=flow[t];
      blockchild=t;
      tailblocker=1;
   } 
   if(flowComp[h]<dflow && h != root &&
                                flowComp[h]>=0) { /* ignores violated limits */
      dflow=flowComp[h];
      blockchild=h;
      tailblocker=0;
   } 
}  /* t, h */
   
/* t=h */
join=t;
toCtp->obj=obj+=rcost*dflow;

/* set up for updating flows not on pivot stem */
if(blockchild==0) {
   startadd=flowhead;
   startsub=flowtail;
} else if(tailblocker) {   
   startadd=flowhead;
   startsub=parent[blockchild];
   dpflow= -dflow;
} else {                   
   startadd=parent[blockchild];
   startsub=flowtail;
   dpflow= dflow;
   if(depth[blockchild] != 1) {
      Reflect(barc[blockchild])
   }
}

/* decrease all flows from flowtail to join except pivot stem */
for(t=startsub; t !=join; t=parent[t]) {
   flow[t]-= dflow;
   flowComp[t]+= dflow;
}

/* increase all flows from flowhead to join except pivot stem */
for(h=startadd; h !=join; h=parent[h]) {
   flow[h]+= dflow;
   flowComp[h]-= dflow;
}

if(blockchild==0) { /* no pivot stem */
   Reflect(enterarc);
   return 0;
}

/* set up for updating pivot stem and its subtrees */

if(tailblocker) {
   Reflect(enterarc)    /* will be undone */
   lo=flowhead;     /* will become parent of flowtail */
   mid=flowtail;    /* will become child  of flowhead */
   newFlow=dflow;
   newFlowcomp=kap[enterarc]-newFlow;
} else {
   lo=flowtail;     /* will become parent of flowhead */
   mid=flowhead;    /* will become child  of flowtail */
   newFlowcomp=dflow;
   newFlow=kap[enterarc]-newFlowcomp;
}
hi=parent[mid];
oldFlow=flow[mid];
oldFlowcomp=flowComp[mid];

depthlimit=depth[mid];
ddepth=depth[lo]+(int)1-depth[mid];
ddual=dual[lo]-( cost[enterarc] )-dual[mid];
depth[mid]+=ddepth;
dual[mid]+=ddual;

alpha=mid;  /* =last(LSubtree(mid)) */
gamma=nextPre[mid];
oldarc=barc[mid];
newarc=enterarc;

/* update pivot stem and its subtrees */

do {  /* once per node on pivot stem */

   hi=parent[mid];

   /* update dual & depth of RForest(mid) */
   /* alpha=last(LSubtree(mid)) */
   for(beta=alpha; depth[gamma]> depthlimit; beta=gamma, gamma=nextPre[beta]) {
      dual[gamma]+=ddual;
      depth[gamma]+=ddepth;
   }
   depthlimit-- ;
   /* beta=last(subtree(mid)),  gamma=Nextpre(beta) */

   parent[mid]=lo;

   Reflect(newarc)
   barc[mid]=newarc;
   flow[mid]=newFlow;
   flowComp[mid]=newFlowcomp;

   if(mid==blockchild) { /* find alpha */
      alpha=hi;
      if(alpha==0) alpha1=root;
      else alpha1=nextPre[alpha];
      do {
         if(alpha1==mid) break;
         alpha=alpha1;
         alpha1=nextPre[alpha];
      } while(1);
      /* Nextpre(alpha)=mid */
   } else {              /* find alpha and arc temporaries; and */
      /* update depth and dual of LSubtree(hi) */
      newarc=oldarc;
      newFlowcomp=oldFlow+dpflow;
      newFlow=oldFlowcomp-dpflow;
      oldarc=barc[hi];
      oldFlow=flow[hi];
      oldFlowcomp=flowComp[hi];

      ddepth+=2;
      ddual=dual[mid]-( cost[newarc] )-dual[hi];

      alpha=hi; 
      do {
         alpha1=nextPre[alpha];
         depth[alpha]+=ddepth;
         dual[alpha]+=ddual;
         if(alpha1==mid) break;
         alpha=alpha1;
      } while(1);
      /* Nextpre(alpha)=mid */
   }
   /* Nextpre(alpha)=mid */
      
   nextPre[alpha]=gamma;       /* & nilling Nextpre(beta)
                                  disconnects mid from hi ***/
   nextPre[beta]=nextPre[lo]; /* to make mid first child of lo */
   nextPre[lo]=mid;           /* to make mid first child of lo */

   lo=mid; mid=hi;
   /* alpha=last(LSubtree(mid)) */
} while(lo != blockchild);

return 0;
}  /* CtpMakeBasic */


/*================================================================== CtpOk */

int CtpOk(struct Ctp *toCtp)
{
int nodesNum=toCtp->nodesNum;
int arcsNum=toCtp->arcsNum;
int obj=toCtp->obj;

int *tail=toCtp->tail;
int *head=toCtp->head;
int *cost=toCtp->cost;
int *kap=toCtp->kap;
int *ref=toCtp->ref;
int *sup=toCtp->sup;
int *barc=toCtp->barc;
int *flow=toCtp->flow;
int *flowComp=toCtp->flowComp;
int *dual=toCtp->dual;
int *parent=toCtp->parent;
int *nextPre=toCtp->nextPre;
int *depth=toCtp->depth;

int n, n1, p, c;
int f;
int a;
int cost2;
int *sup2;

sup2=(int*)malloc((nodesNum+1)*sizeof(sup[1]));
if(sup2 != 0) {
   for(n=1; n<=nodesNum; n++) sup2[n]=flow[n];
   for(n=1; n<=nodesNum; n++) {
      if(1<=parent[n] && parent[n]<=nodesNum) {
         sup2[parent[n]]-=flow[n];
      } else if(depth[n]!=1 || parent[n] !=0) {
         if(toCtp->verbosity>=1) {
            fprintf(stderr, "depth[%d]=%d parent[%d]=%d\n"
                    "Error in ctp code\n", n, depth[n], n, parent[n] );
         }
         return -__LINE__;
      }
   }  /* n */
   for(a=1; a<=arcsNum; a++) {
      sup2[(ref[a] ? head : tail)[a]]+=kap[a]*ref[a];
      sup2[(ref[a] ? tail : head)[a]]-=kap[a]*ref[a];
   }  /* a */
}   

cost2=0;
for(a=1; a<=arcsNum; a++) {
   if(ref[a]) {
      c=(ref[a] ? tail : head)[a];
      p=(ref[a] ? head : tail)[a];
      cost2+=kap[a]*Tcost(a);
   } else { c=(ref[a] ? head : tail)[a]; p=(ref[a] ? tail : head)[a]; }

   if(barc[p]==a) {
      if(toCtp->verbosity>=1) {
         fprintf(stderr, "Reflection error involving arc %u and node %u\n",
                                             a,       p );
         fprintf(stderr, "Error in ctp code\n");
      }
      free(sup2); return -1;
   }
   if(barc[c]==a) cost2+=( cost[a] )*flow[c];
}

for(n=1; n<=nodesNum; n++) {
   if(((depth[n]==1) + (parent[n]==0) + (barc[n]==0)) % 3) {
      if(toCtp->verbosity>=1) {
         fprintf(stderr, "Conflicting root status from Barc, "
                 "Depth and Parent(%u)\nError in ctp code\n", n);
      }
      free(sup2); return -1;
   }
   if(depth[n] !=1 && flow[n]+flowComp[n] != kap[barc[n]]) {
      if(toCtp->verbosity>=1) {
         fprintf(stderr, "Flow(%u)+Flowcomp(%u) != Kap(%u)\n", n, n, barc[n]);
         fprintf(stderr, "Error in ctp code\n");
      }
      free(sup2); return -1;
   }
   if(depth[n] != 1 && dual[n] != dual[parent[n]]+( cost[barc[n]] )) {
      if(toCtp->verbosity>=1) {
         fprintf(stderr, "Bad dual(%u), dual(%u), or barc(%u)=%u\n",
                 n, parent[n], n, barc[n]);
         fprintf(stderr, "Error in ctp code\n");
      }
      free(sup2); return -1;
}  }


for(n=1; n<=nodesNum; n++) {
   if(barc[n]>arcsNum) {
      if(toCtp->verbosity>=1) {
         fprintf(stderr, "%u=wrong basic arc for node %u", barc[n], n);
         fprintf(stderr, "Error in ctp code\n");
      }
      free(sup2); return -1;
   }
   p=parent[n]; n1=nextPre[n];
   if(depth[n] != 1 && depth[n] != 1+depth[p]) {
      if(toCtp->verbosity>=1) {
         fprintf(stderr, "Wrong depth for %u or %u\n", n, p);
         fprintf(stderr, "Error in ctp code\n");
      }
      free(sup2); return -1;
   }
   if(depth[n] != 1 && parent[nextPre[p]] != p) {
      if(toCtp->verbosity>=1) {
         fprintf(stderr, "Parent %u followed by %u instead of child\n",
                 p, nextPre[p] );
         fprintf(stderr, "Error in ctp code\n");
      }
      free(sup2); return -1;
   }
   n1=p;
   if(depth[n] != 1) do {
      n1=nextPre[n1];
      if(n1==n) break;
      if(depth[n1]<=depth[p]) {
         if(toCtp->verbosity>=1) {
            fprintf(stderr, "child %u not preceded by parent %u\n", n1, p);
            fprintf(stderr, "Error in ctp code\n");
         }
         free(sup2); return -1;
      }
   }  while(1);

   if(sup2[n] != sup[n]) {
      if(toCtp->verbosity>=1) {
         fprintf(stderr, "supply from node %u is %d not %d\n", n, f, sup[n]);
         fprintf(stderr, "Error in ctp code\n");
      }
      free(sup2); return -1;
   }
}   

if(cost2 != obj) {
   if(toCtp->verbosity>=1) {
      fprintf(stderr, "Objective is %d not %d\n", cost2, obj);
      fprintf(stderr, "Error in ctp code\n");
   }
   free(sup2); return -1;
}

free(sup2);
return 0;
}  /* CtpOk */


/*================================================================CtpSolve */

int CtpSolve(struct Ctp *toCtp)
{
int itersNum=toCtp->itersNum;
int itersNumMax=toCtp->itersNumMax;
int phase=toCtp->phase;

int t, h;
int a;
int rcost;
int bpt, retval;
int i=0;

if(! phase) {
   if(toCtp->verbosity>=1) fprintf(stderr, "There is no basis\n");
   return -1;
}
if(toCtp->verbosity>=2) {
   fprintf(stderr, "%d pivots allowed\n", itersNumMax);
   fprintf(stderr, "Checkpoints are after pivot %d and each %d thereafter\n",
           toCtp->checkPoint, toCtp->checkPointInc );
}
   
toCtp->itersNum=itersNum=0;
bpt=toCtp->checkPoint;;
do {
   CtpFindEntrant(toCtp, &t, &h, &a, &rcost);
   if(t==0) { 
      if(toCtp->verbosity>=2) fprintf(stderr, "CtpSolve: solution optimal\n");
      retval=0;
      break;
    }
   if(itersNum >=itersNumMax) { 
      toCtp->itersNum=itersNum;
      if(toCtp->verbosity>=1) {
         fprintf(stderr, "solve: solution may not be optimal\n");
         CtpPrintSol(toCtp, stderr, "CtpSolve ");
      }
      CtpCheckPoint(toCtp, "ctp", i, 0);
      i=1-i;
      retval=1;
      break;
   }
   CtpMakeBasic(toCtp, t, h, a, rcost);
   itersNum++;
   if(itersNum==bpt && bpt> 0) {
      toCtp->itersNum=itersNum;
      CtpCheckPoint(toCtp, "ctp", i, 0);
      i=1-i;
      bpt+=toCtp->checkPointInc;
      if(toCtp->verbosity>=1) CtpPrintSol(toCtp, stderr, "CtpSolve: ");
   }
}  while(1);

toCtp->itersNum=itersNum;
toCtp->checkPoint=bpt;
if(toCtp->verbosity>=2) {
   fprintf(stderr, "obj=%d\n", toCtp->obj);
   fprintf(stderr, "CtpSolve done after %d pivots\n", itersNum);
}
CtpOk(toCtp);
return retval;
}  /* CtpSolve */


/*=================================================================Unphase1 */

int Unphase1(struct Ctp *toCtp)
{
int *ref=toCtp->ref;
int *tail=toCtp->tail;
int *head=toCtp->head;
int *cost=toCtp->cost;
int *costSave=toCtp->costSave;
int a;
if(toCtp->phase != 1) return 1;
toCtp->arcsNum-=(toCtp->nodesNum-1);
for(a=toCtp->arcsNum; a>=1; a--) {
   if(ref[a]) {
      int tmp=tail[a]; tail[a]=head[a]; head[a]=tmp;
      ref[a]=0;
   }
   cost[a]=costSave[a];
}  /* a */

toCtp->phase=0;
return 0;
}  /* Unphase1 */


/*=================================================================CtpLindo */

int CtpLindo(struct Ctp *toCtp, FILE *fout)
{
int nodesNum=toCtp->nodesNum;
int arcsNum=toCtp->arcsNum;

int *tail=toCtp->tail;
int *head=toCtp->head;
int *cost=toCtp->cost;
int *kap=toCtp->kap;
int *ref=toCtp->ref;
int *sup=toCtp->sup;

int col;
int n;
int  a;
char *plus;

fprintf(fout, "MIN\n");
for(a=1,col=0,plus=""; a<=arcsNum; a++, plus="+") {
   col+=fprintf(fout, " %s %dT%dH%d", Tcost(a)< 0 ? "-" : plus, 
               abs(cost[a]),
               (ref[a] ? head : tail)[a],  (ref[a] ? tail : head)[a]);
   if(col>40) putchar('\n'), col=0;
}
fprintf(fout, "\nSUBJECT TO\n");

for(n=1; n<=nodesNum; n++) {
   for(a=1,col=0,plus=" "; a<=arcsNum; a++) {
      if((ref[a] ? head : tail)[a]==n) {
         col+=fprintf(fout, " %sT%dH%d", plus, n, (ref[a] ? tail : head)[a]);
         plus="+";
      }
      if((ref[a] ? tail : head)[a]==n) {
         col+=fprintf(fout, " -T%dH%d", (ref[a] ? head : tail)[a], n);
         plus="+";
      }
      if(col>40) putchar('\n'), col=0;
   }   
   fprintf(fout, " = %d\n", sup[n]);
}  /* n */

for(a=1,col=0; a<=arcsNum; a++) {
   col+=fprintf(fout, "  T%dH%d <= %u",
               (ref[a] ? head : tail)[a],
               (ref[a] ? tail : head)[a], kap[a]);
   if(col>40) putchar('\n'), col=0;
}  /* a */
fprintf(fout, "\nLEAVE\n");
return 0;
}  /* CtpLindo */


/*===============================================================CtpErrVal */

int CtpErrVal(void)
{
printf("Errval\n");
fprintf(stderr, "Errval\n");
fflush(0);
abort();
return -666;
}  /* CtpErrVal */



static void printUnchk(int v)
{
if(v>=1) fprintf(stderr, "Cannot finish breakpoint file.\n");
}  /* printfailed */


static const char magic[5]="cTp1";


/*===========================================================CtpCheckPoint */

int CtpCheckPoint(struct Ctp *toCtp, char *prefix, int i, char **fname)
{
int nodesNum=toCtp->nodesNum;
int arcsNum=toCtp->arcsNum;
char *template=(char*)malloc(8+strlen(prefix));
FILE *fout=0;
int des;
int writtenNum=-9;

sprintf(template, "%s%dXXXXXX", prefix, i%10);
#ifdef WIN32
des=fopen(template,"w+");
if(des==NULL) {
#else	
des=mkstemp(template);
if(des==-1) {
#endif	
   if(toCtp->verbosity>=1) {
      fprintf(stderr, "Cannot open file with template %s\n", template);
   }
   free(template);
   if(fname) *fname=0;
   return 1;
}

if(toCtp->verbosity>=2) {
   fprintf(stderr, "CheckPoint file is %s\n", template);
}
if(fname) *fname=template;
else free(template);

fout=(FILE*)fdopen(des, "w");
writtenNum=fwrite(magic, 1, 4, fout);
if(writtenNum!=4) {
   printUnchk(toCtp->verbosity);
   return __LINE__;
}

writtenNum=fwrite(
   &toCtp->nodesNum, sizeof(int), &toCtp->phase-&toCtp->nodesNum+1, fout );
if(writtenNum!=(&toCtp->phase-&toCtp->nodesNum+1)) {
   printUnchk(toCtp->verbosity);
   return __LINE__;
}

writtenNum=fwrite(toCtp->tail+1, sizeof(int), arcsNum, fout);
if(writtenNum!=arcsNum) { printUnchk(toCtp->verbosity); return __LINE__; }
writtenNum=fwrite(toCtp->head+1, sizeof(int), arcsNum, fout);
if(writtenNum!=arcsNum) { printUnchk(toCtp->verbosity); return __LINE__; }
writtenNum=fwrite(toCtp->cost+1, sizeof(int), arcsNum, fout);
if(writtenNum!=arcsNum) { printUnchk(toCtp->verbosity); return __LINE__; }
writtenNum=fwrite(toCtp->costSave+1, sizeof(int), arcsNum, fout);
if(writtenNum!=arcsNum) { printUnchk(toCtp->verbosity); return __LINE__; }
writtenNum=fwrite(toCtp->kap+1, sizeof(int), arcsNum, fout);
if(writtenNum!=arcsNum) { printUnchk(toCtp->verbosity); return __LINE__; }
writtenNum=fwrite(toCtp->ref+1, sizeof(int), arcsNum, fout);
if(writtenNum!=arcsNum) { printUnchk(toCtp->verbosity); return __LINE__; }


writtenNum=fwrite(toCtp->sup+1, sizeof(int), nodesNum, fout);
if(writtenNum!=nodesNum) { printUnchk(toCtp->verbosity); return __LINE__; }
writtenNum=fwrite(toCtp->barc+1, sizeof(int), nodesNum, fout);
if(writtenNum!=nodesNum) { printUnchk(toCtp->verbosity); return __LINE__; }

writtenNum=fwrite(toCtp->flow+1, sizeof(int), nodesNum, fout);
if(writtenNum!=nodesNum) { printUnchk(toCtp->verbosity); return __LINE__; }
writtenNum=fwrite(toCtp->flowComp+1, sizeof(int), nodesNum, fout);
if(writtenNum!=nodesNum) { printUnchk(toCtp->verbosity); return __LINE__; }

writtenNum=fwrite(toCtp->dual+1, sizeof(int), nodesNum, fout);
if(writtenNum!=nodesNum) { printUnchk(toCtp->verbosity); return __LINE__; }
writtenNum=fwrite(toCtp->parent+1, sizeof(int), nodesNum, fout);
if(writtenNum!=nodesNum) { printUnchk(toCtp->verbosity); return __LINE__; }
writtenNum=fwrite(toCtp->nextPre+1, sizeof(int), nodesNum, fout);
if(writtenNum!=nodesNum) { printUnchk(toCtp->verbosity); return __LINE__; }
writtenNum=fwrite(toCtp->depth, sizeof(int), nodesNum+1, fout);
if(writtenNum!=nodesNum+1) { printUnchk(toCtp->verbosity); return __LINE__; }
fclose(fout);
return 0;
}  /* CtpCheckPoint */


static void printUnres(int v)
{
if(v>=1) fprintf(stderr, "Cannot finish reading restart file.\n");
}  /* printUnres */


/*============================================================ CtpRestart */

int CtpRestart(struct Ctp *toCtp, const char *fname)
{
char mbuf[5];
int nodesNum, arcsNum;
int readNum;
FILE *fin=fopen(fname, "r");

if(!fin) { fprintf(stderr, "Cannot open input file %s\n", fname); return 1; }

mbuf[4]=0;
readNum=fread(mbuf, 1, 4, fin);
if(readNum != 4) {
   fprintf(stderr, "Cannot read magic number from file %s\n", fname);
   return 2;
}
if(strcmp(mbuf, magic)) {
   fprintf(stderr, "Magic number %s should have been %s\n", mbuf, magic);
   return 3;
}

readNum=fread(
   &toCtp->nodesNum, sizeof(int), &toCtp->phase-&toCtp->nodesNum+1, fin );
if(readNum!=(&toCtp->phase-&toCtp->nodesNum+1)) {
   printUnres(toCtp->verbosity); return __LINE__;
}

if(CtpAlloc(toCtp)) return 4;

nodesNum=toCtp->nodesNum;
arcsNum=toCtp->arcsNum;


readNum=fread(toCtp->tail+1, sizeof(int), arcsNum, fin);
if(readNum!=arcsNum) { printUnres(toCtp->verbosity); return __LINE__; }
readNum=fread(toCtp->head+1, sizeof(int), arcsNum, fin);
if(readNum!=arcsNum) { printUnres(toCtp->verbosity); return __LINE__; }
readNum=fread(toCtp->cost+1, sizeof(int), arcsNum, fin);
if(readNum!=arcsNum) { printUnres(toCtp->verbosity); return __LINE__; }
readNum=fread(toCtp->costSave+1, sizeof(int), arcsNum, fin);
if(readNum!=arcsNum) { printUnres(toCtp->verbosity); return __LINE__; }
readNum=fread(toCtp->kap+1, sizeof(int), arcsNum, fin);
if(readNum!=arcsNum) { printUnres(toCtp->verbosity); return __LINE__; }
readNum=fread(toCtp->ref+1, sizeof(int), arcsNum, fin);
if(readNum!=arcsNum) { printUnres(toCtp->verbosity); return __LINE__; }


readNum=fread(toCtp->sup+1, sizeof(int), nodesNum, fin);
if(readNum!=nodesNum) { printUnres(toCtp->verbosity); return __LINE__; }
readNum=fread(toCtp->barc+1, sizeof(int), nodesNum, fin);
if(readNum!=nodesNum) { printUnres(toCtp->verbosity); return __LINE__; }

readNum=fread(toCtp->flow+1, sizeof(int), nodesNum, fin);
if(readNum!=nodesNum) { printUnres(toCtp->verbosity); return __LINE__; }
readNum=fread(toCtp->flowComp+1, sizeof(int), nodesNum, fin);
if(readNum!=nodesNum) { printUnres(toCtp->verbosity); return __LINE__; }

readNum=fread(toCtp->dual+1, sizeof(int), nodesNum, fin);
if(readNum!=nodesNum) { printUnres(toCtp->verbosity); return __LINE__; }
readNum=fread(toCtp->parent+1, sizeof(int), nodesNum, fin);
if(readNum!=nodesNum) { printUnres(toCtp->verbosity); return __LINE__; }
readNum=fread(toCtp->nextPre+1, sizeof(int), nodesNum, fin);
if(readNum!=nodesNum) { printUnres(toCtp->verbosity); return __LINE__; }
readNum=fread(toCtp->depth, sizeof(int), nodesNum+1, fin);
if(readNum!=nodesNum+1) { printUnres(toCtp->verbosity); return __LINE__; }
return 0;
}  /* CtpRestart */
