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
// Euminxd.cpp: implementation of the CEuminxd class.
//
//////////////////////////////////////////////////////////////////////


#pragma warning(disable:4786)


#define nmax 4
#define mmax 10
#define epsx 1e-6

#include "Euminxd.h"
#include <cmath>

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CEuminxd::CEuminxd()
{

}

CEuminxd::~CEuminxd()
{

}


CEuminxd::enErrors CEuminxd::Euminxd(int iControlDimensions, int iNumCntrlSurfaces, double *cb, double *ad, double *wa, double *wu, 
			   double *umin, double *umax, double *upref, double *u)
{
// C call
//int euminx (int iControlDimensions, int iNumCntrlSurfaces, double *cb, double *ad, double *wa,
//  double *wu, double *umin, double *umax, double *upref, double *u)

double ubase[mmax],axp[nmax][mmax],axn[nmax][mmax],hxp[mmax],hxn[mmax];
double ax[nmax][(2*nmax)+(2*mmax)],bx[nmax],cx[(2*nmax)+(2*mmax)],hx[(2*nmax)+(2*mmax)],x[(2*nmax)+(2*mmax)];
double binv[nmax][nmax],bidb[nmax],xb[nmax],dbd[nmax],dj[nmax+(2*mmax)],tma[nmax+1][nmax];
double tmam,tman,tmae,aer,djm,ddm,dd,dde,aux;
int npos,nneg,npn,nb,nd,nx,found,done,count=0;
int i,j,k,idi,ibi,js=0,ids=0,iter,iterm,nva,nvan,icas=0,is=0,ibs;
int lpos[mmax],lneg[mmax],id[nmax+(2*mmax)],ib[nmax],ipn[(2*nmax)+(2*mmax)];
int ica[nmax+1],iva[nmax+1],itma[nmax+1], idsax, ibsax;
enErrors iError = errorNone;
// Check dimensions
if (iControlDimensions>nmax) {
  //printf("Error: number of rows of CB exceeds maximum in euminx");
  //return;
iError = errorNGreaterNMax;}
if (iNumCntrlSurfaces>mmax) {
  //printf("Error: number of columns of CB exceeds maximum in euminx");
  //return;
iError = errorMGreaterMMax;}
// Split controls into positive and negative ranges with respect 
// to the preferred controls
npos=0;nneg=0;
for (i=0;i<iNumCntrlSurfaces;i++) { 
  ubase[i]=upref[i];
  if (umax[i]>upref[i]) {
    lpos[npos]=i;hxp[npos]=umax[i]-upref[i];
    //for (j=0;j<iControlDimensions;j++) {axp[j][npos]=cb[j+i*(iControlDimensions)];}
	for (j=0;j<iControlDimensions;j++) {axp[j][npos]=cb[j*(iNumCntrlSurfaces)+i];}
    if (umin[i]>upref[i]) {
	  ubase[i]=umin[i];hxp[npos]=umax[i]-umin[i];}
    npos=npos+1;}
  if (umin[i]<upref[i]) {
    lneg[nneg]=i;hxn[nneg]=-umin[i]+upref[i];
    //for (j=0;j<iControlDimensions;j++) {axn[j][nneg]=-cb[j+i*(iControlDimensions)];}
	for (j=0;j<iControlDimensions;j++) {axn[j][nneg]=-cb[j*(iNumCntrlSurfaces)+i];}
    if (umax[i]<upref[i]) {
	  ubase[i]=umax[i];hxn[nneg]=umax[i]-umin[i];}
    nneg=nneg+1;}}
npn=npos+nneg;
// Set-up simplex problem
nb=iControlDimensions;nd=npn+nb;nx=nb+nd;
for (i=0;i<nd;i++){id[i]=i;}
for (i=0;i<nb;i++){ib[i]=nd+i;}
for (i=0;i<nb;i++) { 
  for (j=0;j<npos;j++){ax[i][j]=axp[i][j];}
  for (j=0;j<nneg;j++){ax[i][j+npos]=axn[i][j];}
  bx[i]=ad[i];
  for (j=0;j<iNumCntrlSurfaces;j++)
  {
	//bx[i]=bx[i]-cb[i+j*(iControlDimensions)]*ubase[j];
	  bx[i]=bx[i]-cb[count]*ubase[j];
	  count=count+1;
  }
  if (bx[i]<0.) {
    bx[i]=-bx[i];for (j=0;j<npn;j++){ax[i][j]=-ax[i][j];}}}
for (i=0;i<nb;i++) {
  for (j=0;j<nb;j++){ax[i][npn+j]=0.;ax[i][nd+j]=0.;}
  ax[i][npn+i]=-1.;ax[i][nd+i]=1.;}
for (i=0;i<nx;i++) {ipn[i]=1;}
aer=0.;for (i=0;i<nb;i++) {aer=aer+bx[i];}
for (i=0;i<npos;i++){hx[i]=hxp[i];cx[i]=wu[lpos[i]];
}
for (i=0;i<nneg;i++){hx[i+npos]=hxn[i];cx[i+npos]=wu[lneg[i]];}

for (i=0;i<iControlDimensions;i++){cx[npn+i]=wa[i];cx[npn+iControlDimensions+i]=wa[i];
}
for (i=npn;i<nx;i++){hx[i]=aer;}
// Simplex algorithm - Initialization
for (i=0;i<nb;i++) {
  for (j=0;j<nb;j++) {binv[i][j]=0.;}
  binv[i][i]=1.;xb[i]=bx[i];}
done=0;iter=0;iterm=1;for (i=1;i<=nb;i++){iterm=iterm*(nb+nd+1-i);}
for (i=1;i<=nb;i++){iterm=iterm/(nb+1-i);}
// Start iterations
while (!done) {
// Compute the gradient of the cost with respect to the non-basic 
// variables and find the variable that gives the highest gradient
djm=0.;
for (i=0;i<nd;i++) {idi=id[i];
	
dj[i]=cx[idi];

  for (j=0;j<nb;j++) {
	for (k=0;k<nb;k++) {
	  dj[i]=dj[i]-cx[ib[j]]*binv[j][k]*ax[k][idi];}}
  if (dj[i]<djm) {djm=dj[i];js=i;}}
// Determine which variable reaches its limit first:
// the non-basic variable or one of the basic variables
// If several variables reach their limit at the same time,
// store the information needed for the anticycling procedure
nva=0;
if (djm<- epsx ) {
  ids=id[js];
  ddm=hx[ids];nva=1;ica[0]=1;
  for (i=0;i<nb;i++){dbd[i]=0.;
    for (j=0;j<nb;j++){dbd[i]=dbd[i]+binv[i][j]*ax[j][ids];}}
  for (i=0;i<nb;i++){
	if (dbd[i]>epsx) {dd=xb[i]/dbd[i];dde=dd-ddm;
	  if (dde<-epsx) {nva=1;ica[0]=2;iva[0]=i;ddm=dd;}
      if (fabs(dde)<epsx) {ica[nva]=2;iva[nva]=i;nva=nva+1;}}
    if (dbd[i]<-epsx) {dd=(xb[i]-hx[ib[i]])/dbd[i];dde=dd-ddm;
	  if (dde<-epsx){nva=1;ica[0]=3;iva[0]=i;ddm=dd;}
      if (fabs(dde)<epsx){ica[nva]=3;iva[nva]=i;nva=nva+1;}}}}
else {done=1;} 
// Anticycling procedure using the perturbation approach
if (nva==1) {icas=ica[0];is=iva[0];}
if (nva>1) {is=0;
  if(ica[0]==1) {for (j=0;j<nb;j++){tma[0][j]=0.;is=1;}} 
  for (i=is;i<nva;i++){
	for (j=0;j<nb;j++){
			tma[i][j]=binv[iva[i]][j]/dbd[iva[i]];}}
  found=0;for (i=0;i<nva;i++){itma[i]=i;}
  for (j=0;j<nb;j++){ 
    if (found==0) {
      tmam=tma[itma[0]][j];nvan=1;
      for (i=1;i<nva;i++){ 
        tman=tma[itma[i]][j];tmae=tman-tmam;
		if (tmae<-epsx) {nvan=1;itma[0]=itma[i];tmam=tman;}
        if (fabs(tmae)<epsx) {
	      itma[nvan]=itma[i];nvan=nvan+1;}}
	  nva=nvan;if (nva==1){found=1;}}}
  if (found==0) { 
    //printf("Warning: variable not found in anticycling procedure \n");
  }
  icas=ica[itma[0]];is=iva[itma[0]];}
// Swap the non-basic variable with the appropriate variable
if (done==0) { switch (icas) {
  case 1 : // the non-basic variable reaches its upper limit

	if (ids < 10)
	{idsax = ids;}
	else
	{idsax = ids+1;}
    for (i=0;i<nb;i++) {
	  bx[i]=bx[i]-hx[ids]*ax[i][ids];ax[i][ids]=-ax[i][ids];}
	ipn[ids]=-ipn[ids];cx[ids]=-cx[ids];
  break;
  case 2: // a basic variable reaches its lower limit
    ibs=ib[is];id[js]=ibs;ib[is]=ids;
    for (i=0;i<nb;i++) {bidb[i]=0.;
      for (j=0;j<nb;j++) {
		bidb[i]=bidb[i]+binv[i][j]*(ax[j][ids]-ax[j][ibs]);}}
	for (j=0;j<nb;j++) {
        aux=binv[is][j]/(1.+bidb[is]);
	    for (i=0;i<nb;i++) {binv[i][j]=binv[i][j]-bidb[i]*aux;}}
  break;
  case 3: // a basic variable reaches its upper limit
    ibs=ib[is];id[js]=ibs;ib[is]=ids;
	if (ibs < 10)
	{ibsax = ibs;}
	else
	{ibsax = ibs+1;}
	if (ids < 10)
	{idsax = ids;}
	else
	{idsax = ids+1;}
    for (i=0;i<nb;i++) {
      bx[i]=bx[i]-hx[ibs]*ax[i][ibs];ax[i][ibs]=-ax[i][ibs];}
    ipn[ibs]=-ipn[ibs];cx[ibs]=-cx[ibs];
    for (i=0;i<nb;i++) {bidb[i]=0.;
      for (j=0;j<nb;j++) {
		  bidb[i]=bidb[i]+binv[i][j]*(ax[j][ids]+ax[j][ibs]);}}
    for (j=0;j<nb;j++) {aux=binv[is][j]/(1.+bidb[is]);
      for (i=0;i<nb;i++) {binv[i][j]=binv[i][j]-bidb[i]*aux;}}
  break;
}}
// Compute the new basic variables
for (i=0;i<nb;i++) {xb[i]=0.;
  for (j=0;j<nb;j++) {xb[i]=xb[i]+binv[i][j]*bx[j];}}
// Continue, unless solution found or max. # of iterations reached
iter=iter+1;if (iter>=iterm) {
  //printf("Warning: maximum number of iterations reached in euminx \n");
  done=1;}
} // End iterations when done 
// Obtain the solution x from the results
for (i=0;i<nx;i++) {x[i]=0.;}
for (i=0;i<nb;i++) {ibi=ib[i];
  if (ipn[ibi]<0) {x[ibi]=hx[ibi]-xb[i];}
  else {x[ibi]=xb[i];}}
for (i=0;i<nd;i++) {idi=id[i];
  if (ipn[idi]<0) {x[idi]=hx[idi];}}
// Obtain the control input from the solution x
for (i=0;i<iNumCntrlSurfaces;i++){u[i]=ubase[i];}
for (i=0;i<npos;i++){u[lpos[i]]=u[lpos[i]]+x[i];}
for (i=0;i<nneg;i++){u[lneg[i]]=u[lneg[i]]-x[i+npos];}

return iError;
//
}
