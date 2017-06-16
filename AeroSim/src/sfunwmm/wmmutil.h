//----------------------------------------------------------------------//
//		This file provided by Unmanned Dynamics, LLC		//
//		Ph: 541-308-0894, Email: info@u-dynamics.com		//
//----------------------------------------------------------------------//
// Name:		wmmutil.h
// Description:		WMM-96 world geomagnetic model functions
// Created:		11/15/2001
// Last modified:	11/15/2001
//----------------------------------------------------------------------//

// Function prototypes

// Initialize the geomagnetic model
int InitGeomag(char *WMMFileName);

// Run the geomagnetic model
void RunGeomag(double *Mag, double *Pos, double Time);