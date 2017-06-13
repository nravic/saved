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

/*  File    : CapTranShipMex.cpp
 *  Abstract:
 */

#include <iostream>
#include <fstream>
#include <iomanip>
using namespace std;

#include "mex.h"
#include "CapTransShip.h"
#include "CapTranShipMex.h"

#include <BoundBenefit.h>

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

#define FUNCTION_SYNTAX "\n\
[TargetAssigned,TaskAssigned,TotalBennifit] = CapTranShipMex(Bennifits,NumberVehicles,NumberTargets,NumberTasks);\n\
\n\
Where:\n\
    Bennifits is a nxm bennifits matrix:\n\
				n=NumberVehicles*NumberTargets*NumberTasks + NumberVehicles\n\
				m=1 (Bennifit)\n\
\n\
"

enum eunmInputs {enInputBennifits,enInputNumVehicles,enInputNumTargets,enInputNumTasks,enInputNumTotal};
enum eunmOutputs {enOutputAssignedTarget,enOutputAssignedTask,enTotalBennifit,enOutputNumTotal};


extern "C"
{
	void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray* prhs[]);
}

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray* prhs[])
{

	if(nrhs!=enInputNumTotal)
	{
		mexErrMsgTxt("4 inputs are required.\n The syntax for this function is:" FUNCTION_SYNTAX);
	}
	if(nlhs!=enOutputNumTotal) 
	{
		mexErrMsgTxt("3 outputs are required.\nThe syntax for this function is:" FUNCTION_SYNTAX);
	}

	// number of vehicles
	if( !mxIsNumeric(prhs[enInputNumVehicles]) || !mxIsDouble(prhs[enInputNumVehicles]) ||
		mxIsEmpty(prhs[enInputNumVehicles]) || mxIsComplex(prhs[enInputNumVehicles]) ||
		mxGetN(prhs[enInputNumVehicles])*mxGetM(prhs[enInputNumVehicles])!=1 ) 
	{
		mexErrMsgTxt("NumberVehicles must be a scalar.\nThe syntax for this function is:" FUNCTION_SYNTAX);
	}
	int iNumberVehicles = rounding_cast<int>(mxGetScalar(prhs[enInputNumVehicles]));

	// number of targets
	if( !mxIsNumeric(prhs[enInputNumTargets]) || !mxIsDouble(prhs[enInputNumTargets]) ||
		mxIsEmpty(prhs[enInputNumTargets]) || mxIsComplex(prhs[enInputNumTargets]) ||
		mxGetN(prhs[enInputNumTargets])*mxGetM(prhs[enInputNumTargets])!=1 ) 
	{
		mexErrMsgTxt("NumberTargets must be a scalar.\nThe syntax for this function is:" FUNCTION_SYNTAX);
	}
	int iNumberTargets = rounding_cast<int>(mxGetScalar(prhs[enInputNumTargets]));

	// number of tasks
	if( !mxIsNumeric(prhs[enInputNumTasks]) || !mxIsDouble(prhs[enInputNumTasks]) ||
		mxIsEmpty(prhs[enInputNumTasks]) || mxIsComplex(prhs[enInputNumTasks]) ||
		(mxGetN(prhs[enInputNumTasks])*mxGetM(prhs[enInputNumTasks])!=1) ) 
	{
		mexErrMsgTxt("NumberTasks must be a scalar.\nThe syntax for this function is:" FUNCTION_SYNTAX);
	}
	int iNumberTasks = rounding_cast<int>(mxGetScalar(prhs[enInputNumTasks]));

	if( !mxIsNumeric(prhs[enInputNumTasks]) || !mxIsDouble(prhs[enInputNumTasks]) ||
		mxIsEmpty(prhs[enInputNumTasks]) || mxIsComplex(prhs[enInputNumTasks]))
	{
		mexErrMsgTxt("Bennifits matrix incorrect.\nThe syntax for this function is:" FUNCTION_SYNTAX);
	}
	// bennifit matrix
	int iNumberRowsCalc = (iNumberVehicles*iNumberTargets*iNumberTasks + iNumberVehicles);
	int iNumberColumnsCalc = 1;
	int iNumberRows = mxGetM(prhs[enInputBennifits]);
	int iNumberColumns = mxGetN(prhs[enInputBennifits]);
	if((iNumberRows!=iNumberRowsCalc) || (iNumberColumns!=iNumberColumnsCalc))
	{
		char caErrorMessage[1024];
		sprintf(caErrorMessage,"Bennifits matrix incorrect dimensions (%dX%d) should be (%dX%d)\n\n"FUNCTION_SYNTAX,
											iNumberRows,iNumberColumns,iNumberRowsCalc,iNumberColumnsCalc);
		mexErrMsgTxt(caErrorMessage);
	}

	double* pdBennifitsInput = mxGetPr(prhs[enInputBennifits]);
	plhs[enOutputAssignedTarget] = mxCreateDoubleMatrix(iNumberVehicles,1, mxREAL);
	double* pdAssignedTarget = mxGetPr(plhs[enOutputAssignedTarget]);
	plhs[enOutputAssignedTask] = mxCreateDoubleMatrix(iNumberVehicles,1, mxREAL);
	double* pdAssignedTask = mxGetPr(plhs[enOutputAssignedTask]);
	plhs[enTotalBennifit] = mxCreateDoubleMatrix(1,1, mxREAL);
	double* pdTotalBennifit = mxGetPr(plhs[enTotalBennifit]);



	VVEHICLETASKS vtasksInputs;	// input storage

	int iContinueToSearchIndex = 0;
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
		int iBoundedBenefit = ibound_benefit( pdBennifitsInput[iContinueToSearchIndex] );
		vehctasksTemp.viTaskBenefit.push_back( iBoundedBenefit );

		// bennefit of this vehicle assignmet to this target with this task
		for(int iCountTargets = 1;iCountTargets <= iNumberTargets;iCountTargets++,iCountType++,iCountBenefit++)
		{
			for(int iCountTask = 0;iCountTask < iNumberTasks;iCountTask++)
			{
				vehctasksTemp.viTaskTarget.push_back(iCountTargets);
				int iTaskBenefitIndex = iCountBenefit + iCountTask*iTaskBennefitOffset;
				int iBoundedBenefit = ibound_benefit( pdBennifitsInput[iTaskBenefitIndex] );
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
		char caErrorMessage[1024];
		sprintf(caErrorMessage,"A call to the CapTransShip S-function returned error #%d",iFlag);
		mexErrMsgTxt(caErrorMessage);
	}

	int iOffset = 0;
	for(VInt::iterator itTargets=viAssignedTargets.begin()+1, itTaskTypes=viAssignedTaskTypes.begin()+1;
															itTargets!=viAssignedTargets.end();itTargets++,itTaskTypes++,iOffset++)
	{
		pdAssignedTarget[iOffset] = *itTargets;
		pdAssignedTask[iOffset] = *itTaskTypes;
	}
	*pdTotalBennifit = iAssignmentBenefit;

}


