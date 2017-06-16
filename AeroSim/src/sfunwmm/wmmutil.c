//----------------------------------------------------------------------//
//		This file provided by Unmanned Dynamics, LLC		//
//		Ph: 541-308-0894, Email: info@u-dynamics.com		//
//----------------------------------------------------------------------//
// Name:		wmmutil.c
// Description:		WMM-96 world geomagnetic model functions
// Created:		11/15/2001
// Last modified:	11/15/2001
//----------------------------------------------------------------------//

// Standard headers
#include <math.h>
#include <stdio.h>
#include <string.h>

// Own header
#include "wmmutil.h"

// Project headers
#include "Types.h"
#include "universal.h"


// Global constants
const UInt32 maxord = 12;
const double a = 6378.137;
const double b = 6356.7523142;
const double re = 6371.2;
const double rTd = 0.017453292;

// Global variables
double epoch;
double c[13][13], cd[13][13], sp[13], cp[13], dp[13][13], tc[13][13], k[13][13], fn[13], fm[13], pp[13], snorm[169];
double *p = snorm;
double a2, b2, c2, a4, b4, c4;

// Function definitions

// Initialize the geomagnetic model
int InitGeomag(char *WMMFileName)
{
	UInt8 c_str[81], c_new[5], model[20];
	UInt32 i,icomp,n,m,j,D1,D2;
	FILE *wmmdat;
	double snorm[169], gnm, hnm, dgnm, dhnm, flnmj;
	
	// Open WMM coefficients file
	wmmdat = fopen(WMMFileName,"r");

	// If the file was opened successfully
	if(wmmdat)
	{
		// INITIALIZE CONSTANTS
		sp[0] = 0.0;
		cp[0] = *p = pp[0] = 1.0;
		dp[0][0] = 0.0;
		a2 = a*a;
		b2 = b*b;
		c2 = a2-b2;
		a4 = a2*a2;
		b4 = b2*b2;
		c4 = a4-b4;
    
		// READ WORLD MAGNETIC MODEL SPHERICAL HARMONIC COEFFICIENTS
		c[0][0] = 0.0;
		cd[0][0] = 0.0;
		fgets(c_str, 80, wmmdat);
		sscanf(c_str,"%lf%s",&epoch,model);

		icomp = 1;
		while(icomp!=0) {
			// Read line from file
			fgets(c_str, 80, wmmdat);

			// CHECK FOR LAST LINE IN FILE
			for (i=0; i<4 && (c_str[i] != '\0'); i++) {
				c_new[i] = c_str[i];
				c_new[i+1] = '\0';
			}
			icomp = strcmp("9999", c_new);
	
			// If not end of file
			if(icomp!=0) {
				// END OF FILE NOT ENCOUNTERED, GET VALUES
				sscanf(c_str,"%d%d%lf%lf%lf%lf",&n,&m,&gnm,&hnm,&dgnm,&dhnm);
				if (m <= n) {
					c[m][n] = gnm;
					cd[m][n] = dgnm;
					if (m != 0) {
						c[n][m-1] = hnm;
						cd[n][m-1] = dhnm;
					}
				}
			}
		}

		// CONVERT SCHMIDT NORMALIZED GAUSS COEFFICIENTS TO UNNORMALIZED
		snorm[0] = 1.0;
		for(n=1; n<=maxord; n++) {
			snorm[n] = snorm[n-1]*(double)(2*n-1)/(double)n;
			j = 2;
			for(m=0,D1=1,D2=(n-m+D1)/D1; D2>0; D2--,m+=D1) {
				k[m][n] = (double)(((n-1)*(n-1))-(m*m))/(double)((2*n-1)*(2*n-3));
				if(m>0) {
					flnmj = (double)((n-m+1)*j)/(double)(n+m);
					snorm[n+m*13] = snorm[n+(m-1)*13]*sqrt(flnmj);
					j = 1;
					c[n][m-1] = snorm[n+m*13]*c[n][m-1];
					cd[n][m-1] = snorm[n+m*13]*cd[n][m-1];
				}
				c[m][n] = snorm[n+m*13]*c[m][n];
				cd[m][n] = snorm[n+m*13]*cd[m][n];
			}
			fn[n] = (double)(n+1);
			fm[n] = (double)n;
		}
		k[1][1] = 0.0;

   		// Close WMM coefficients file
		fclose(wmmdat);

		return 1;
	}
	// If the file could not be opened
	return 0;
}

// Run the geomagnetic model
void RunGeomag(double *Mag, double *Pos, double Time)
{
	double dt, rlon, rlat, glat, glon, srlon, srlat, crlon, crlat, srlat2, crlat2, alt;
	double q, q1, q2, ct, st, r, r2, d, ca, sa;
	UInt32 m, n, D3, D4;
	double aor, ar, br, bt, bp, bpp, par, temp1, temp2, parp;
	double bx, by, bz, bh, dec, dip, ti, gv;
	
	dt = Time - epoch;
    
    rlon = Pos[LON];
    rlat = Pos[LAT];
	glon = rlon*RAD_TO_DEG;
	glat = rlat*RAD_TO_DEG;
    srlon = sin(rlon);
    srlat = sin(rlat);
    crlon = cos(rlon);
    crlat = cos(rlat);
    srlat2 = srlat*srlat;
    crlat2 = crlat*crlat;
	alt = Pos[ALT]/1000.0;

    sp[1] = srlon;
    cp[1] = crlon;
	
	/* CONVERT FROM GEODETIC COORDS. TO SPHERICAL COORDS. */
    q = sqrt(a2-c2*srlat2);
	q1 = alt*q;
	q2 = ((q1+a2)/(q1+b2))*((q1+a2)/(q1+b2));
	ct = srlat/sqrt(q2*crlat2+srlat2);
	st = sqrt(1.0-(ct*ct));
	r2 = (alt*alt)+2.0*q1+(a4-c4*srlat2)/(q*q);
	r = sqrt(r2);
	d = sqrt(a2*crlat2+b2*srlat2);
	ca = (alt+d)/r;
	sa = c2*crlat*srlat/(r*d);
    
    for (m=2; m<=maxord; m++) {
		sp[m] = sp[1]*cp[m-1]+cp[1]*sp[m-1];
		cp[m] = cp[1]*cp[m-1]-sp[1]*sp[m-1];
	}
    
    aor = re/r;
    ar = aor*aor;
    br = bt = bp = bpp = 0.0;
    for(n=1; n<=maxord; n++) {
		ar = ar*aor;
		for (m=0,D3=1,D4=(n+m+D3)/D3; D4>0; D4--,m+=D3) 
		{
			// COMPUTE UNNORMALIZED ASSOCIATED LEGENDRE POLYNOMIALS
			// AND DERIVATIVES VIA RECURSION RELATIONS
			if(n == m) {
				p[n+m*13] = st*p[n-1+(m-1)*13];
				dp[m][n] = st*dp[m-1][n-1]+ct*p[n-1+(m-1)*13];
			}
			else if(n == 1 && m == 0) {
				p[n+m*13] = ct*p[n-1+m*13];
				dp[m][n] = ct*dp[m][n-1]-st*p[n-1+m*13];
			}
			else if(n > 1 && n != m) {
				if(m > n-2) p[n-2+m*13] = 0.0;
				if(m > n-2) dp[m][n-2] = 0.0;
				p[n+m*13] = ct*p[n-1+m*13]-k[m][n]*p[n-2+m*13];
				dp[m][n] = ct*dp[m][n-1] - st*p[n-1+m*13]-k[m][n]*dp[m][n-2];
			}
			
			// TIME ADJUST THE GAUSS COEFFICIENTS
			tc[m][n] = c[m][n]+dt*cd[m][n];
			if(m != 0) tc[n][m-1] = c[n][m-1]+dt*cd[n][m-1];
						
			// ACCUMULATE TERMS OF THE SPHERICAL HARMONIC EXPANSIONS
			par = ar*p[n+m*13];
			if(m == 0) {
				temp1 = tc[m][n]*cp[m];
				temp2 = tc[m][n]*sp[m];
			}
			else {
				temp1 = tc[m][n]*cp[m]+tc[n][m-1]*sp[m];
				temp2 = tc[m][n]*sp[m]-tc[n][m-1]*cp[m];
			}
			bt = bt-ar*temp1*dp[m][n];
			bp += (fm[m]*temp2*par);
			br += (fn[n]*temp1*par);

		    // SPECIAL CASE:  NORTH/SOUTH GEOGRAPHIC POLES
			if(st == 0.0 && m == 1) {
				if(n == 1) pp[n] = pp[n-1];
				else pp[n] = ct*pp[n-1]-k[m][n]*pp[n-2];
				parp = ar*pp[n];
				bpp += (fm[m]*temp2*parp);
			}
		}
	}
    if(st == 0.0) bp = bpp;
    else bp /= st;

    // ROTATE MAGNETIC VECTOR COMPONENTS FROM SPHERICAL TO
    // GEODETIC COORDINATES
    bx = -bt*ca-br*sa;
    by = bp;
    bz = bt*sa-br*ca;

    // COMPUTE DECLINATION (DEC), INCLINATION (DIP) AND
    // TOTAL INTENSITY (TI)
    bh = sqrt((bx*bx)+(by*by));
    ti = sqrt((bh*bh)+(bz*bz));
    dec = atan2(by,bx)*RAD_TO_DEG;
    dip = atan2(bz,bh)*RAD_TO_DEG;

    // COMPUTE MAGNETIC GRID VARIATION IF THE CURRENT
    // GEODETIC POSITION IS IN THE ARCTIC OR ANTARCTIC
    // (I.E. GLAT > +55 DEGREES OR GLAT < -55 DEGREES)
    // OTHERWISE, SET MAGNETIC GRID VARIATION TO -999.0
    gv = -999.0;
    if(fabs(glat) >= 55.) {
		if(glat > 0.0 && glon >= 0.0) gv = dec-glon;
		if(glat > 0.0 && glon < 0.0) gv = dec+fabs(glon);
		if(glat < 0.0 && glon >= 0.0) gv = dec+glon;
		if(glat < 0.0 && glon < 0.0) gv = dec-fabs(glon);
		if(gv > +180.0) gv -= 360.0;
		if(gv < -180.0) gv += 360.0;
    }
    
	// COMPUTE X, Y, Z COMPONENTS OF THE MAGNETIC FIELD
    Mag[NORTH]=ti*(cos((dec*rTd))*cos((dip*rTd)));
    Mag[EAST]=ti*(cos((dip*rTd))*sin((dec*rTd)));
    Mag[DOWN]=ti*(sin((dip*rTd)));
}


	 