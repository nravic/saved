// sfunjoy.cpp
// S-Function implementing a Windows joystick interface
// Marius Niculescu
// 11/19/01

#define S_FUNCTION_NAME  sfunjoy
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

#include "windows.h"

// Multimedia header
#include "mmsystem.h"

// S-function parameters
#define NUM_PARAMS (2)
#define TS_PARAM (ssGetSFcnParam(S,0))
#define JOY_PARAM (ssGetSFcnParam(S,1))

// Macros to access the S-function parameter values
#define SAMPLE_TIME (mxGetPr(TS_PARAM)[0])
#define JOYSTICK_ID (mxGetPr(JOY_PARAM)[0])


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

	// No inputs from Simulink
    if (!ssSetNumInputPorts(S, 0)) return;

	// Output position, button states and POV
    if (!ssSetNumOutputPorts(S, 3)) return;

	// Position
    ssSetOutputPortWidth(S, 0, 6);

	// Button states
	ssSetOutputPortWidth(S, 1, 32);

	// POV hat switch
	ssSetOutputPortWidth(S, 2, 1);

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
	  JOYINFOEX JoyInfoStruct;
	  MMRESULT JoyResult;

	  // Read joystick
	  if(JOYSTICK_ID == 2)
		  JoyResult = joyGetPosEx(JOYSTICKID2, &JoyInfoStruct);
	  else
		  JoyResult = joyGetPosEx(JOYSTICKID1, &JoyInfoStruct);

	  if(JoyResult!=JOYERR_NOERROR) {
		// Output appropriate error message
		switch(JoyResult) {

			case MMSYSERR_NODRIVER:
				ssSetErrorStatus(S, "Joystick not installed.");
				return;
			break;

			case MMSYSERR_INVALPARAM:
				ssSetErrorStatus(S, "Invalid parameter passed.");
				return;
			break;

			case MMSYSERR_BADDEVICEID:
				ssSetErrorStatus(S, "Joystick identifier is invalid.");
				return;
			break;

			case JOYERR_UNPLUGGED:
				ssSetErrorStatus(S, "Joystick is not plugged in.");
				return;
			break;
		}
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
    real_T       *joypos = (real_T*)ssGetOutputPortSignal(S,0);
	real_T		 *joybflags = (real_T*)ssGetOutputPortSignal(S,1);
	real_T		 *joypov = (real_T*)ssGetOutputPortSignal(S,2);
	
	JOYINFOEX JoyInfoStruct;
	MMRESULT JoyResult;
	DWORD i;

	// Return all joystick data
	JoyInfoStruct.dwFlags = JOY_RETURNALL;

	// Read joystick
	  if(JOYSTICK_ID == 2)
		  JoyResult = joyGetPosEx(JOYSTICKID2, &JoyInfoStruct);
	  else
		  JoyResult = joyGetPosEx(JOYSTICKID1, &JoyInfoStruct);

	// Save data if there are no errors
	if(JoyResult==JOYERR_NOERROR) {
		// Save position data
		joypos[0] = (real_T)JoyInfoStruct.dwXpos;
		joypos[1] = (real_T)JoyInfoStruct.dwYpos;
		joypos[2] = (real_T)JoyInfoStruct.dwZpos;
		joypos[3] = (real_T)JoyInfoStruct.dwRpos;
		joypos[4] = (real_T)JoyInfoStruct.dwUpos;
		joypos[5] = (real_T)JoyInfoStruct.dwVpos;

		// Save button flags
		for(i=0;i<32;i++) {
			if((JoyInfoStruct.dwButtons>>i) & 0x0000000000000000000000000000001)
				joybflags[i] = 1;
			else
				joybflags[i] = 0;
		}

		// Save POV hat position
		joypov[0] = (real_T)JoyInfoStruct.dwPOV;
	}
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
