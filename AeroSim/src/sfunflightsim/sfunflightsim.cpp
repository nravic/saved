// sfunflightsim.c
// S-Function interface for Microsoft Flight Simulator
// Marius Niculescu
// 11/16/01

#define S_FUNCTION_NAME  sfunflightsim
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

// Universal data
#include "universal.h"

// FS interface
#include "FSinterface.h"

// FSUIPC library header
#include "FSUIPC_User.h"

// S-function parameters
#define NUM_PARAMS (1)
#define TS_PARAM (ssGetSFcnParam(S,0))

// Macros to access the S-function parameter values
#define SAMPLE_TIME (mxGetPr(TS_PARAM)[0])

// FSUIPC init errors
char *pszErrors[] =
	{	"Okay",
		"Attempt to Open when already Open",
		"Cannot link to FSUIPC or WideClient",
		"Failed to Register common message with Windows",
		"Failed to create Atom for mapping filename",
		"Failed to create a file mapping object",
		"Failed to open a view to the file map",
		"Incorrect version of FSUIPC, or not FSUIPC",
		"Sim is not version requested",
		"Call cannot execute, link not Open",
		"Call cannot execute: no requests accumulated",
		"IPC timed out all retries",
		"IPC sendmessage failed all retries",
		"IPC request contains bad data",
		"Maybe running on WideClient, but FS not running on Server, or wrong FSUIPC",
		"Read or Write request cannot be added, memory for Process is full",
	};

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

    if (!ssSetNumInputPorts(S, 3)) return;

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

	// There is no numerical output from this function
    if (!ssSetNumOutputPorts(S, 0)) return;

	ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetOptions(S, 0);
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
	DWORD dwResult;
	UInt16 SlewFlag = 1;
	UInt16 SlewMode = 3;
	UInt32 Result = 0;
	// Initialize the FSUIPC
	FSUIPC_Close();
	if(FSUIPC_Open(SIM_ANY, &dwResult)) {
		
		// Enable slew mode
		FSUIPC_Write(SLEWFLAG_OFFSET, sizeof(UInt16), &SlewFlag, &Result);

		// Choose slew mode display
		FSUIPC_Write(SLEWMODE_OFFSET, sizeof(UInt16), &SlewMode, &Result);

		// Send to Flight Simulator
		FSUIPC_Process(&Result);
	}
	else {
		ssSetErrorStatus(S,pszErrors[dwResult]);
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
    
	double Position[NPOS];
	double Attitude[NROT];
	double Airspeed;
	double VertSpeed;

	FSPositionType FSPos;
	FSAttitudeType FSAtt;
	SInt32 FSAirsp;
	SInt16 FSVS;

	UInt32 Result = 0;

	Position[LAT] = posvec[0];
	Position[LON] = posvec[1];
	Position[ALT] = posvec[2];
	
	Attitude[ROLL] = attvec[0];
	Attitude[PITCH] = attvec[1];
	Attitude[YAW] = attvec[2];

	Airspeed = velvec[0];
	VertSpeed = velvec[1];

	// Unit conversions
	PositionSimToFS(&FSPos, Position);
	AttitudeSimToFS(&FSAtt, Attitude);
	AirspeedSimToFS(&FSAirsp, Airspeed);
	VertSpeedSimToFS(&FSVS, VertSpeed);

	// Write to FS data structure
	FSUIPC_Write(LAT_OFFSET, sizeof(FSPos.Lat), &FSPos.Lat, &Result);
	FSUIPC_Write(LON_OFFSET, sizeof(FSPos.Lon), &FSPos.Lon, &Result);
	FSUIPC_Write(ALT_OFFSET, sizeof(FSPos.Alt), &FSPos.Alt, &Result);
	FSUIPC_Write(PITCH_OFFSET, sizeof(FSAtt.Pitch), &FSAtt.Pitch, &Result);
	FSUIPC_Write(BANK_OFFSET, sizeof(FSAtt.Bank), &FSAtt.Bank, &Result);
	FSUIPC_Write(HEAD_OFFSET, sizeof(FSAtt.Heading), &FSAtt.Heading, &Result);
	FSUIPC_Write(TAS_OFFSET, sizeof(FSAirsp), &FSAirsp, &Result);
	FSUIPC_Write(IAS_OFFSET, sizeof(FSAirsp), &FSAirsp, &Result);
	FSUIPC_Write(VS_OFFSET, sizeof(FSVS), &FSVS, &Result);

	// Send to Flight Simulator
	FSUIPC_Process(&Result);
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
	FSUIPC_Close();
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
