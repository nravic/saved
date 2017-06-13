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
//////////////////////////////////////////////////////////////////////////////

/*  File    : CapTranShipDll.cpp
 *  Abstract:
 */

#define S_FUNCTION_NAME CapTranShipDll
#define S_FUNCTION_LEVEL 2

//#include <afxwin.h>         // MFC core and standard components

#include <simstruc.h>

#include <CapTransShip.h>
#include <SSDebugDefine.h>
#include <BoundBenefit.h>

#include "CapTranShipDll.h"


#define SAMPLE_TIME 0.0


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////   PARAMETER DEFINITIONS      //////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
#define NPARAMS 3

#define MAX_VEHICLES_IDX 0
#define PARAM_MAX_VEHICLES(S) ssGetSFcnParam(S,MAX_VEHICLES_IDX)
 
#define MAX_TARGETS_IDX 1
#define PARAM_MAX_TARGETS(S) ssGetSFcnParam(S,MAX_TARGETS_IDX)
 
 
#define MAX_TASKS_IDX 2
#define PARAM_MAX_TASKS(S) ssGetSFcnParam(S,MAX_TASKS_IDX)
 


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////   INPUT/OUTPUT DEFINITIONS   //////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
/*

INPUTS:
	- Number of vehicles, targets and tasks, i.e  8 vehicles, 10 targets, 2 tasks => 3 elements
	- Bennefit of continuing to search for each vehicle, i.e 8 vehicles => 8 elements
	- Bennefit of assigning each vehicle to target/task type, i.e 8 vehicles * 10 targets * 2 task types => 160 elements

																		178 total elements

OUTPUTS
	-Vector for each vehicle to target assignment, i.e. 8 vehicles = 8 elements
	-Vector for each vehicle to task type assignment, i.e. 8 vehicles = 8 elements
	-Bennefit Metric = 1 element
																	17 total elements

NOTE: the actual number and definitions of the inputs/outputs used will depend on the values for the 
      number of vehicles, targets and tasks.

*/
#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */
#define NUMBER_OUTPUT_ENTRIES (2)	//target and task type assigned

enum eunmDimensionInputs {enInputDimVehicles,enInputDimTargets,enInputDimTasks,enInputDimTotal};

#define START_CONTINUE_TO_SEARCH (enInputDimTotal)

// MATLAB can handle C++ mangle
// extern "C"
// {
// 	void mdlStart(SimStruct *S);
// 	void mdlInitializeSizes(SimStruct *S);
// 	void mdlInitializeSampleTimes(SimStruct *S);
// 	void mdlInitializeConditions(SimStruct *S);
// 	void mdlOutputs(SimStruct *S, int_T tid);
// 	void mdlUpdate(SimStruct *S, int_T tid);
// 	void mdlTerminate(SimStruct *S);
// 	void mdlCheckParameters(SimStruct *S);
// }


namespace
{
	
/*====================*
 * S-function methods *
 *====================*/

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
	/* Function: mdlCheckParameters =============================================
	 * Abstract:
	 *    Validate our parameters to verify they are okay.
	*/
	void mdlCheckParameters(SimStruct *S)
	{
      /* Check 1st parameter: maximum number of vehicles */
      {
          if (!mxIsDouble(PARAM_MAX_VEHICLES(S)) || mxGetNumberOfElements(PARAM_MAX_VEHICLES(S)) != 1) 
		  {
              ssSetErrorStatus(S,"1st parameter to the CapTransShip S-function must be the "
                               "maximum number of vehicles available in the simulation");
              return;
          }
      }
 
      /* Check 2nd parameter: maximum number of targets */
      {
          if (!mxIsDouble(PARAM_MAX_TARGETS(S)) || mxGetNumberOfElements(PARAM_MAX_TARGETS(S)) != 1) 
		  {
              ssSetErrorStatus(S,"2nd parameter to the CapTransShip S-function must be the "
                               "maximum number of targets available in the simulation");
              return;
          }
      }
      /* Check 3rd parameter: maximum number of tasks */
      {
          if (!mxIsDouble(PARAM_MAX_TASKS(S)) || mxGetNumberOfElements(PARAM_MAX_TASKS(S)) != 1) 
		  {
              ssSetErrorStatus(S,"3rd parameter to the CapTransShip S-function must be the "
                               "maximum number of tasks defined in the simulation.");
              return;
          }
      }
	}
#endif /* MDL_CHECK_PARAMETERS */



/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */

	ssSetNumContStates(S, 0);	// number continuous
    ssSetNumDiscStates(S, 0);	// number discrete states

    if (!ssSetNumInputPorts(S, 1)) 
	{
		return;
	}

	int iNumberVehicles = rounding_cast<int>(*mxGetPr(PARAM_MAX_VEHICLES(S)));
	int iNumberTargets = rounding_cast<int>(*mxGetPr(PARAM_MAX_TARGETS(S)));
	int iNumberTasks = rounding_cast<int>(*mxGetPr(PARAM_MAX_TASKS(S)));

	int iNumberInputs = enInputDimTotal + iNumberVehicles + iNumberVehicles*iNumberTargets*iNumberTasks;
    ssSetInputPortWidth(S, 0, iNumberInputs);
	ssSetInputPortDirectFeedThrough(S,0,1);

    if (!ssSetNumOutputPorts(S, 1))
	{
		return;
	}
	int iNumberOutputs = (iNumberVehicles*NUMBER_OUTPUT_ENTRIES) + 1;
    ssSetOutputPortWidth(S, 0, iNumberOutputs); // add one for the bennefit value of the assignmet

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl.doc */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S,0,INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}



#undef MDL_INITIALIZE_CONDITIONS

#undef MDL_START  /* Change to #undef to remove function */


/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = Cx + Du 
 */
void mdlOutputs(SimStruct *S, int_T tid)
{
	SSDEBUG_TIME(ssGetT(S));

	real_T* prealOutputs = ssGetOutputPortRealSignal(S,0);
	if(prealOutputs == NULL)
	{
		ssSetErrorStatus(S,"Error obtaining the output pointer.");
		return;
	}
	InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);

	if(uPtrs == NULL)
	{
		ssSetErrorStatus(S,"Error obtaining the input pointer.");
		return;
	}
	int iNumberVehicles = rounding_cast<int>(U(enInputDimVehicles));
	int iNumberTargets = rounding_cast<int>(U(enInputDimTargets));
	int iNumberTasks = rounding_cast<int>(U(enInputDimTasks));

	if((iNumberVehicles > *mxGetPr(PARAM_MAX_VEHICLES(S)))||(iNumberVehicles <= 0))
	{
		char caErrorMessage[256];
		sprintf(caErrorMessage,"CapTranShipDLL: Number of inputs passed into block (%d) either less than \
or equal zero, or greater than maximum number vehicles specified in parameter 1 (%d)",iNumberVehicles,*mxGetPr(PARAM_MAX_VEHICLES(S)));
		ssSetErrorStatus(S,caErrorMessage);
		return;
	}
	if((iNumberTargets > *mxGetPr(PARAM_MAX_TARGETS(S)))||(iNumberTargets <= 0))
	{
		char caErrorMessage[256];
		sprintf(caErrorMessage,"CapTranShipDLL: Number of inputs passed into block (%d) either less than \
or equal zero, or greater than maximum number targets specified in parameter 2 (%d)",iNumberTargets,*mxGetPr(PARAM_MAX_TARGETS(S)));
		ssSetErrorStatus(S,caErrorMessage);
		return;
	}
	if((iNumberTasks > *mxGetPr(PARAM_MAX_TASKS(S)))||(iNumberTasks <= 0))
	{
		char caErrorMessage[256];
		sprintf(caErrorMessage,"CapTranShipDLL: Number of inputs passed into block (%d) either less than \
or equal zero, or greater than maximum number tasks specified in parameter 3 (%d)",iNumberTasks,*mxGetPr(PARAM_MAX_TASKS(S)));
		ssSetErrorStatus(S,caErrorMessage);
		return;
	}


	VVEHICLETASKS vtasksInputs;	// input storage

	int iContinueToSearchIndex = START_CONTINUE_TO_SEARCH;
	int iTaskBennefitStart = iContinueToSearchIndex + iNumberVehicles;
	int iTaskBennefitOffset = iNumberVehicles*iNumberTargets;

	for(int iCountVehicles = 0,iCountType = 0,iCountBenefit = iTaskBennefitStart;
								iCountVehicles < iNumberVehicles;iCountVehicles++,iContinueToSearchIndex++)
	{
		CVehicleTasks vehctasksTemp;
		vehctasksTemp.iVehicleID = iCountVehicles;

		// bennefit of continuing to search assignment
		vehctasksTemp.viTaskTarget.push_back(0);
		vehctasksTemp.viTaskType.push_back(0);
		int iBoundedBenefit = ibound_benefit( U(iContinueToSearchIndex) );
		vehctasksTemp.viTaskBenefit.push_back( iBoundedBenefit );

		// bennefit of this vehicle assignmet to this target with this task
		for(int iCountTargets = 1;iCountTargets <= iNumberTargets;iCountTargets++,iCountType++,iCountBenefit++)
		{
			for(int iCountTask = 0;iCountTask < iNumberTasks;iCountTask++)
			{
				vehctasksTemp.viTaskTarget.push_back(iCountTargets);
				int iTaskBenefitIndex = iCountBenefit + iCountTask*iTaskBennefitOffset;
				int iBoundedBenefit = ibound_benefit( U(iTaskBenefitIndex) );
				vehctasksTemp.viTaskBenefit.push_back( iBoundedBenefit );
				vehctasksTemp.viTaskType.push_back(iCountTask+1);	// define tasks to start at 1
			}	//for(int iCountTask = 0;iCountTask <= iNumberTasks;iNumberTasks++)
		}	//for(int iNumVehicles = 0;iNumVehicles < iNumberVehicles;iNumVehicles++)

		vtasksInputs.push_back(vehctasksTemp);
	}	//for(int iNumVehicles = 0;iNumVehicles < iNumberTargets;iNumVehicles++)

	// instantiate the capcitated transhipment function
	CapTransShip pctpCapTransShip(iNumberVehicles,iNumberTargets);

	for(VVEHICLETASKS::iterator itTasks=vtasksInputs.begin();itTasks!=vtasksInputs.end();itTasks++)
	{
		pctpCapTransShip.setJobs(itTasks->iVehicleID+1,itTasks->viTaskTarget,
														itTasks->viTaskType,itTasks->viTaskBenefit);
	}

	vector<int> viAssignedTargets;	// output storage
	vector<int> viAssignedTaskTypes;	// output storage
	int iAssignmentBenefit;	// output storage

	int iFlag = pctpCapTransShip.solve(viAssignedTargets,viAssignedTaskTypes,iAssignmentBenefit);
	if(iFlag) 
	{
		char caErrorMessage[256];
		sprintf(caErrorMessage,"A call to the CapTransShip S-function returned error #%d",iFlag);
		ssSetErrorStatus(S,caErrorMessage);
		return;
	}

	int iTargetOffset = 0;
	int iTaskOffset = iNumberVehicles;
	for(VInt::iterator itTargets=viAssignedTargets.begin()+1, itTaskTypes=viAssignedTaskTypes.begin()+1;
															itTargets!=viAssignedTargets.end();itTargets++,itTaskTypes++,iTargetOffset++,iTaskOffset++)
	{
		prealOutputs[iTargetOffset] = *itTargets;
		prealOutputs[iTaskOffset] = *itTaskTypes;
	}
	int iBennefitOffset = iNumberVehicles*NUMBER_OUTPUT_ENTRIES;
	prealOutputs[iBennefitOffset] = iAssignmentBenefit;

	SSDEBUG_TIME(ssGetT(S));
}



#define MDL_UPDATE
/* Function: mdlUpdate ======================================================
 * Abstract:
 *      xdot = Ax + Bu
 */
void mdlUpdate(SimStruct *S, int_T tid)
{
	InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);


}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
void mdlTerminate(SimStruct *S)
{
}
 
} // anonymous namespace

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
