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
//
// TrajectoryMex.cpp
//
//////////////////////////////////////////////////////////////////////


// November 2002 - constucted - RAS

#include <mex.h>

#include <rounding_cast>

#include "Trajectory.h"	// needed to create an instance of target class

#define PROGRAM_NAME "TrajectoryMex"

#define MINIMUM_DISTANCE_USAGE "\
usage: TrajectoryMex - used to calculate a trajectory between a vehicle and a target. \n\
The vehicle requires last assigned position, heading and last task completion time. \n\
The target requires position, task required, and task prerequsite time. \n\n\
\t[Waypoints,TotalDistance,FinalHeading] = TrajectoryMex(VehicleState,TargetState,TargetHeadings,LengthenPath) \n\
\t- calculates the waypoints for a minimum distance trajectory from the vehicle to the target. \n\
\tIf LengthenPath=1 then the trajectory is lengthened, if necessary, to meet the task time \n\
\tprerequisite of the target.\n\
\t\tVehicleState is a 8x1 vector with the following entries:\n\
\t\t\t[iID; dPositionX_ft; dPositionY_ft; dPsi_rad; dCommandSensorStandOff_ft; dCommandTurnRadius_ft; \n\
\t\t\tVehicleType (1-Munition, 2-UAV); dTotalDistanceTraveled_ft]\n\
\t\tTargetState is a 6x1 vector with the following entries:\n\
\t\t\t[iID; dPositionX_ft; dPositionY_ft; dPsi_rad; tasktypeRequired; dTimePrerequisite_ft]\n\n\
 "

// extern "C"
// {
// 	void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]);
// }

namespace
{
	CTrajectory* pTrajectory = NULL;
}

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{

	/* Check for proper number of arguments */

	if(pTrajectory!=NULL)
	{
	  delete pTrajectory;
	  pTrajectory = NULL;
	}
	pTrajectory = new CTrajectory();
	if (nrhs != 4) 
	{
		mexErrMsgTxt(PROGRAM_NAME": MinimunDistance requires four input arguments:\n vehicle state, target state, desired headings to the target, \nand whether or not to lenghten the path (1 or 0)\n\n"MINIMUM_DISTANCE_USAGE);
	}      
	if (nlhs != 3) 
	{
		mexErrMsgTxt(PROGRAM_NAME": MinimunDistance requires three output arguments: assigned waypoints,total distance, and final heading.\n\n"MINIMUM_DISTANCE_USAGE);
	}      

	if(pTrajectory==NULL)
	{
		mexErrMsgTxt("Could not allocate new instance of CTrajectory.");
	}

	int iParameter = 0;
	if( !mxIsNumeric(prhs[iParameter]) || !mxIsDouble(prhs[iParameter]) ||
		mxIsEmpty(prhs[iParameter]) || mxIsComplex(prhs[iParameter]) ||
		(mxGetM(prhs[iParameter])!=9) || (mxGetN(prhs[iParameter])!=1) ) 
	{
		mexErrMsgTxt("Vehicle State must be a 9X1 vector: \n\tiID\n\tdPositionX_ft\n\tdPositionY_ft\n\tdPositionZ_ft\n\tdPsi_rad\n\tdCommandSensorStandOff_ft\n\tdCommandTurnRadius_ft\n\tVehicleType (1-Munition, 2-UAV)\n\tdTotalDistanceTraveled_ft");
	}
	double* pdVehicleState = mxGetPr(prhs[iParameter]);
	n_enVehicleType_t vehicleType = (pdVehicleState[6]==1)?(envehicleMunition):(envehicleUAV);
	CVehicle vehicleState(rounding_cast<int>(pdVehicleState[0]),pdVehicleState[1],pdVehicleState[2],pdVehicleState[3],pdVehicleState[4],pdVehicleState[5],pdVehicleState[6],vehicleType,pdVehicleState[8]);

	iParameter = 1;
	if( !mxIsNumeric(prhs[iParameter]) || !mxIsDouble(prhs[iParameter]) ||
		mxIsEmpty(prhs[iParameter]) || mxIsComplex(prhs[iParameter]) ||
		(mxGetM(prhs[iParameter])!=6) || (mxGetN(prhs[iParameter])!=1) ) 
	{
		mexErrMsgTxt("Target State must be a 6X1 vector: \n\tiID\n\tdPositionX_ft\n\tdPositionY_ft\n\tdPsi_rad\n\ttasktypeRequired\n\tdTimePrerequisite_ft");
	}
	double* pdTargetState = mxGetPr(prhs[iParameter]);
	CTarget targetState(rounding_cast<int>(pdTargetState[0]),pdTargetState[1],pdTargetState[2],pdTargetState[3],rounding_cast<int>(pdTargetState[4]),pdTargetState[5]);

	iParameter = 2;
	int itemp = mxGetM(prhs[iParameter]);
	int itemp1 = mxGetN(prhs[iParameter]);
	if( !mxIsNumeric(prhs[iParameter]) || !mxIsDouble(prhs[iParameter]) ||
		mxIsEmpty(prhs[iParameter]) || mxIsComplex(prhs[iParameter]) ||
		(mxGetM(prhs[iParameter])==0) || (mxGetN(prhs[iParameter])!=1) ) 
	{
		mexErrMsgTxt("Target headings must be a vector");
	}
	double* pdTargetHeadings = mxGetPr(prhs[iParameter]);
	for(int iCountHeadings=0;iCountHeadings<mxGetM(prhs[iParameter]);iCountHeadings++)
	{
		targetState.AddHeadingTo(pdTargetHeadings[iCountHeadings]);
	}

	iParameter = 3;
	if( !mxIsNumeric(prhs[iParameter]) || !mxIsDouble(prhs[iParameter]) ||
		mxIsEmpty(prhs[iParameter]) || mxIsComplex(prhs[iParameter]) ||
		mxGetM(prhs[iParameter])*mxGetN(prhs[iParameter])!=1 ) 
	{
		mexErrMsgTxt("Choice whether or not to lengthen paths must be 1 or 0.");
	}
	int iLengthenPath = rounding_cast<int>(mxGetScalar(prhs[iParameter]));
	if((iLengthenPath!=0)&&(iLengthenPath!=1))
	{
		mexErrMsgTxt("Choice whether or not to lengthen paths must be 1 or 0.");
	}

	double dDistanceTotal = pTrajectory->dMinimumDistance(vehicleState,targetState,iLengthenPath,pathTurnStraightTurn);

	V_WAYPOINT_t& vWaypoints = vehicleState.vwayGetWaypoints();
	int iNumberWaypoints = vWaypoints.size();

	plhs[0] = mxCreateDoubleMatrix(iNumberWaypoints,wayNumberEntries, mxREAL);
	/*  create a C pointer to the output matrix */
	double* prealOutputs = mxGetPr(plhs[0]);
	int iIndex = 0;
	for(V_WAYPOINT_IT_t itWaypoint=vWaypoints.begin();itWaypoint!=vWaypoints.end();itWaypoint++,iIndex++)
	{
		prealOutputs[iIndex] = itWaypoint->dGetPositionX();
		prealOutputs[iIndex+iNumberWaypoints*1] = itWaypoint->dGetPositionY();
		prealOutputs[iIndex+iNumberWaypoints*2] = itWaypoint->dGetPositionZ();
		prealOutputs[iIndex+iNumberWaypoints*3] = itWaypoint->dGetMachCommand();
		prealOutputs[iIndex+iNumberWaypoints*4] = itWaypoint->bGetMachCommandFlag();
		prealOutputs[iIndex+iNumberWaypoints*5] = itWaypoint->dGetSegmentLength();
		prealOutputs[iIndex+iNumberWaypoints*6] = itWaypoint->circleGetTurn().dGetPositionX();
		prealOutputs[iIndex+iNumberWaypoints*7] = itWaypoint->circleGetTurn().dGetPositionY();
		prealOutputs[iIndex+iNumberWaypoints*8] = itWaypoint->circleGetTurn().turnGetTurnDirection();
		prealOutputs[iIndex+iNumberWaypoints*9] = itWaypoint->typeGetWaypoint();
		prealOutputs[iIndex+iNumberWaypoints*10] = itWaypoint->iGetTargetHandle();
		prealOutputs[iIndex+iNumberWaypoints*11] = itWaypoint->bGetResetVehiclePosition();

	}
	plhs[1] = mxCreateDoubleMatrix(1,1, mxREAL);
	double* prealOutputs2 = mxGetPr(plhs[1]);
	prealOutputs2[0] = dDistanceTotal;
	plhs[2] = mxCreateDoubleMatrix(1,1, mxREAL);
	double* prealOutputs3 = mxGetPr(plhs[2]);
	prealOutputs3[0] = vehicleState.dGetHeadingFinal();

	if(pTrajectory!=NULL)
	{
		delete pTrajectory;
		pTrajectory = NULL;
	}
  return;
}
