// sfunflightgear.c
// S-Function interface for FlightGear Flight Simulator
// 
// This file provided by Unmanned Dynamics, LLC
// Created:			05/17/02
// Last modified:	07/31/04

#define S_FUNCTION_NAME  sfunflightgear098
#define S_FUNCTION_LEVEL 2

#include <afx.h>
#include <afxsock.h>
#include <time.h>
//#include <winsock2.h>


/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

// Universal data
#include "universal.h"

// Flight Gear data structure 
#include "net_fdm.hxx"

// S-function parameters
#define NUM_PARAMS (3)
#define TS_PARAM (ssGetSFcnParam(S,0))
#define HOSTNAME_PARAM (ssGetSFcnParam(S,1))
#define PORT_PARAM (ssGetSFcnParam(S,2))

// Macros to access the S-function parameter values
#define SAMPLE_TIME (mxGetPr(TS_PARAM)[0])


static void htond (double &x);
static void htonf (float &x);

// The function htond is defined this way due to the way some
// processors and OSes treat floating point values.  Some will raise
// an exception whenever a "bad" floating point value is loaded into a
// floating point register.  Solaris is notorious for this, but then
// so is LynxOS on the PowerPC.  By translating the data in place,
// there is no need to load a FP register with the "corruped" floating
// point value.  By doing the BIG_ENDIAN test, I can optimize the
// routine for big-endian processors so it can be as efficient as
// possible
static void htond (double &x)	
{
    if ( TRUE )	// Add test for little endian here
	{
        int    *Double_Overlay;
        int     Holding_Buffer;
    
        Double_Overlay = (int *) &x;
        Holding_Buffer = Double_Overlay [0];
    
        Double_Overlay [0] = htonl (Double_Overlay [1]);
        Double_Overlay [1] = htonl (Holding_Buffer);
    } 
	else
	{
        return;
    }
}

static void htonf (float &x)	
{
    if ( TRUE )	// Add test for little endian here
	{
        int    *Float_Overlay;
            
        Float_Overlay = (int *) &x;
        Float_Overlay[0] = htonl(Float_Overlay[0]);
    } 
	else
	{
        return;
    }
}


/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    /* See sfuntmpl_doc.c for more details on the macros below */

    ssSetNumSFcnParams(S, NUM_PARAMS);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 9)) return;

	// Position input
    ssSetInputPortWidth(S, 0, 3);
    ssSetInputPortRequiredContiguous(S, 0, true); /*direct input signal access*/
    ssSetInputPortDirectFeedThrough(S, 0, 1);

	// Attitude input
    ssSetInputPortWidth(S, 1, 3);
    ssSetInputPortRequiredContiguous(S, 1, true); /*direct input signal access*/
    ssSetInputPortDirectFeedThrough(S, 1, 1);

	// Velocity input
	ssSetInputPortWidth(S, 2, 2);
    ssSetInputPortRequiredContiguous(S, 2, true); /*direct input signal access*/
    ssSetInputPortDirectFeedThrough(S, 2, 1);

	// Controls input
	ssSetInputPortWidth(S, 3, 7);
    ssSetInputPortRequiredContiguous(S, 3, true); /*direct input signal access*/
    ssSetInputPortDirectFeedThrough(S, 3, 1);

	// Engine input
	ssSetInputPortWidth(S, 4, 3);
    ssSetInputPortRequiredContiguous(S, 4, true); /*direct input signal access*/
    ssSetInputPortDirectFeedThrough(S, 4, 1);

	// AGL
	ssSetInputPortWidth(S, 5, 1);
    ssSetInputPortRequiredContiguous(S, 5, true); /*direct input signal access*/
    ssSetInputPortDirectFeedThrough(S, 5, 1);

	// Velocity NED
	ssSetInputPortWidth(S, 6, 3);
    ssSetInputPortRequiredContiguous(S, 6, true); /*direct input signal access*/
    ssSetInputPortDirectFeedThrough(S, 6, 1);

	// Angular rates
	ssSetInputPortWidth(S, 7, 3);
    ssSetInputPortRequiredContiguous(S, 7, true); /*direct input signal access*/
    ssSetInputPortDirectFeedThrough(S, 7, 1);

	// Accelerations
	ssSetInputPortWidth(S, 8, 3);
    ssSetInputPortRequiredContiguous(S, 8, true); /*direct input signal access*/
    ssSetInputPortDirectFeedThrough(S, 8, 1);

	// There is no numerical output from this function
    if (!ssSetNumOutputPorts(S, 0)) return;

	ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 2);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetOptions(S, 0);

	// Initialize sockets
	AfxSocketInit(NULL);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

}



#undef MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
  /* Function: mdlInitializeConditions ========================================
   * Abstract:
   *    In this function, you should initialize the continuous and discrete
   *    states for your S-function block.  The initial states are placed
   *    in the state vector, ssGetContStates(S) or ssGetRealDiscStates(S).
   *    You can also perform any other initialization activities that your
   *    S-function may require. Note, this routine will be called at the
   *    start of simulation and if it is present in an enabled subsystem
   *    configured to reset states, it will be call when the enabled subsystem
   *    restarts execution to reset the states.
   */
  static void mdlInitializeConditions(SimStruct *S)
  {
  }
#endif /* MDL_INITIALIZE_CONDITIONS */



#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
  static void mdlStart(SimStruct *S)
  {
	struct sockaddr_in sa;
	struct hostent     *hp;
	char HostName[256];
	int buflen;
	SOCKET* pFGSocket;
	unsigned int Port = 5500;
	BOOL FGConnected = FALSE;
	void **PWork = ssGetPWork(S);
	
	// Allocate memory for persistent variables
	PWork[0] = calloc(1, sizeof(SOCKET));
	PWork[1] = calloc(1, sizeof(FGNetFDM));

	// The FGSocket pointer points to one of the persistent variables
	pFGSocket = (SOCKET*)PWork[0];

	// Initialize the persistent variables
	memset(PWork[0], 0, sizeof(SOCKET));
	memset(PWork[1], 0, sizeof(FGNetFDM));
	
	// Read the host name parameter
	buflen = 256;
	mxGetString(HOSTNAME_PARAM, HostName, buflen);

	// Read the port number
	Port = (unsigned int)(mxGetPr(PORT_PARAM)[0]);
	
	// Connect socket
	if((hp= gethostbyname(HostName)) != NULL)
	{
		// Clear address data structure
		memset(&sa,0,sizeof(sa));

		// Copy the address data from the host name lookup
		memcpy((char *)&sa.sin_addr,hp->h_addr,hp->h_length);     /* set address */
		
		// Set the address family (should be AF_INET)
		sa.sin_family= hp->h_addrtype;

		// Set the port number
		sa.sin_port= htons((u_short)Port);

		// Create a datagram socket
		*pFGSocket = socket(hp->h_addrtype,SOCK_DGRAM,0);

		if(*pFGSocket >= 0)
		{
			// Connect the socket, should always succeed for UDP
			if(connect(*pFGSocket,(struct sockaddr *)&sa, sizeof(sa)) < 0)
			{
				closesocket(*pFGSocket);	// Uh-oh, problem
			}// If failed to connect socket
			else
			{
				// Set the socket to non-blocking mode
				u_long arg = 1;
				if (ioctlsocket(*pFGSocket, FIONBIO, &arg ) == 0)
					FGConnected = TRUE;
				else
					closesocket(*pFGSocket);
			}// If socket connected
		}// If created a socket
	}// If got FG computer address

	// Exit if not connected
	if(!FGConnected)
	{
		ssSetErrorStatus(S,"Could not connect to host !");
		return;
	}

  }
#endif /*  MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    const real_T *posvec = (const real_T*) ssGetInputPortSignal(S,0);
	const real_T *attvec = (const real_T*) ssGetInputPortSignal(S,1);
	const real_T *velvec = (const real_T*) ssGetInputPortSignal(S,2);
	const real_T *con = (const real_T*) ssGetInputPortSignal(S,3);
	const real_T *engine = (const real_T*) ssGetInputPortSignal(S,4);
	const real_T *agl = (const real_T*) ssGetInputPortSignal(S,5);
	const real_T *VelNED = (const real_T*) ssGetInputPortSignal(S,6);
	const real_T *Rates = (const real_T*) ssGetInputPortSignal(S,7);
	const real_T *Acc = (const real_T*) ssGetInputPortSignal(S,8);
	void **PWork = ssGetPWork(S);
	SOCKET* pFGSocket = (SOCKET*)PWork[0];
	FGNetFDM* pFGNet = (FGNetFDM*)PWork[1];

	pFGNet->version = FG_NET_FDM_VERSION;

	// Position
	pFGNet->latitude = posvec[0];
	pFGNet->longitude = posvec[1];
	pFGNet->altitude = posvec[2];
	pFGNet->agl = (float)agl[0];

	// Attitude
	pFGNet->phi = (float)attvec[0];
	pFGNet->theta = (float)attvec[1];
	pFGNet->psi = (float)attvec[2];

	// Airspeed and vertical speed
	pFGNet->vcas = (float)velvec[0];
	pFGNet->climb_rate = (float)velvec[1];
	pFGNet->v_north = (float)VelNED[0];
	pFGNet->v_east = (float)VelNED[1];
	pFGNet->v_down = (float)VelNED[2];

	// Angular rates
	pFGNet->phidot = (float)Rates[0];
	pFGNet->thetadot = (float)Rates[1];
	pFGNet->psidot = (float)Rates[2];

	// Accelerations
	pFGNet->A_X_pilot = (float)Acc[0];
	pFGNet->A_Y_pilot = (float)Acc[1];
	pFGNet->A_Z_pilot = (float)Acc[2];

	// Engines
	pFGNet->num_engines = 1;
	if(engine[0] > 0)
		pFGNet->eng_state[0] = 2;
	else
		pFGNet->eng_state[0] = 0;
	pFGNet->rpm[0] = (float)engine[1];
	pFGNet->fuel_flow[0] = (float)engine[2];
	pFGNet->egt[0] = 0.0f;
	pFGNet->oil_temp[0] = 0.0f;
	pFGNet->oil_px[0] = 0.0f;
	// Fuel tanks
	pFGNet->num_tanks = 1;
	pFGNet->fuel_quantity[0] = 1.0f;
	// Landing gear
	pFGNet->num_wheels = 0;

	// environment
    pFGNet->cur_time = time(NULL);	// system time
    pFGNet->warp = 0;				// don't know what this does!
    pFGNet->visibility = 50000.0f;	// meters

	// Controls
	pFGNet->elevator = (float)con[1];
	pFGNet->elevator_trim_tab = 0.0f;
	pFGNet->left_flap = (float)con[0];
	pFGNet->right_flap = (float)con[0];
	pFGNet->left_aileron = -(float)con[2];
	pFGNet->right_aileron = (float)con[2];
	pFGNet->rudder = -(float)con[3];
	pFGNet->nose_wheel = -(float)con[3];
	pFGNet->speedbrake = 0.0f;
	pFGNet->spoilers = 0.0f;

	// Convert the net buffer to network format
    pFGNet->version = htonl(pFGNet->version);
    htond(pFGNet->longitude);
    htond(pFGNet->latitude);
    htond(pFGNet->altitude);
    htonf(pFGNet->agl);
    htonf(pFGNet->phi);
    htonf(pFGNet->theta);
    htonf(pFGNet->psi);
	htonf(pFGNet->alpha);
	htonf(pFGNet->beta);
	htonf(pFGNet->phidot);
	htonf(pFGNet->thetadot);
	htonf(pFGNet->psidot);
    htonf(pFGNet->vcas);
    htonf(pFGNet->climb_rate);
	htonf(pFGNet->v_north);
	htonf(pFGNet->v_east);
	htonf(pFGNet->v_down);
	htonf(pFGNet->v_wind_body_north);
	htonf(pFGNet->v_wind_body_east);
	htonf(pFGNet->v_wind_body_down);
	htonf(pFGNet->A_X_pilot);
	htonf(pFGNet->A_Y_pilot);
	htonf(pFGNet->A_Z_pilot);
	htonf(pFGNet->stall_warning);
	htonf(pFGNet->slip_deg);
	pFGNet->num_engines = htonl(pFGNet->num_engines);
	pFGNet->eng_state[0] = htonl(pFGNet->eng_state[0]);
	htonf(pFGNet->rpm[0]);
	htonf(pFGNet->fuel_flow[0]);
	htonf(pFGNet->egt[0]);
	htonf(pFGNet->oil_temp[0]);
	htonf(pFGNet->oil_px[0]);
	pFGNet->num_tanks = htonl(pFGNet->num_tanks);
	htonf(pFGNet->fuel_quantity[0]);
	pFGNet->num_wheels = htonl(pFGNet->num_wheels);
    pFGNet->cur_time = htonl( pFGNet->cur_time );
    pFGNet->warp = htonl( pFGNet->warp );
    htonf(pFGNet->visibility);
	htonf(pFGNet->elevator);
	htonf(pFGNet->elevator_trim_tab);
	htonf(pFGNet->left_flap);
	htonf(pFGNet->right_flap);
	htonf(pFGNet->left_aileron);
	htonf(pFGNet->right_aileron);
	htonf(pFGNet->rudder);
	htonf(pFGNet->nose_wheel);
	htonf(pFGNet->speedbrake);
	htonf(pFGNet->spoilers);

	// Send to FlightGear
	send(*pFGSocket, (const char*)pFGNet, sizeof(FGNetFDM), 0);
}



#undef MDL_UPDATE  /* Change to #undef to remove function */
#if defined(MDL_UPDATE)
  /* Function: mdlUpdate ======================================================
   * Abstract:
   *    This function is called once for every major integration time step.
   *    Discrete states are typically updated here, but this function is useful
   *    for performing any tasks that should only take place once per
   *    integration step.
   */
  static void mdlUpdate(SimStruct *S, int_T tid)
  {
  }
#endif /* MDL_UPDATE */



#undef MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
  /* Function: mdlDerivatives =================================================
   * Abstract:
   *    In this function, you compute the S-function block's derivatives.
   *    The derivatives are placed in the derivative vector, ssGetdX(S).
   */
  static void mdlDerivatives(SimStruct *S)
  {
  }
#endif /* MDL_DERIVATIVES */



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlStart, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
	void **PWork = ssGetPWork(S);
	SOCKET* pFGSocket = (SOCKET*)PWork[0];
	
	// Close the socket connection
	closesocket(*pFGSocket);

	// Free persistent variables
	free(PWork[0]);
	free(PWork[1]);
}


/*======================================================*
 * See sfuntmpl_doc.c for the optional S-function methods *
 *======================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
