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
// VehicleDynamicsMex.cpp
//
//////////////////////////////////////////////////////////////////////


// August 2002 - constucted - RAS

#include <sstream>
using namespace std;

#include <mex.h>

#include <VehicleSimulation.h>
#include <rounding_cast>

#if defined( _WIN32 )
const size_t max_path_len = _MAX_PATH;
# else
const size_t max_path_len = PATH_MAX;
#endif

#define PROGRAM_NAME "VehicleDynamicsMex"

#define FUNCTION_USAGE "\
USAGE: [output] = VehicleDynamicsMex(Action, ...options)\n\
   - INITIALIZE:  Action=1\n\
       [InstanceIDOut] = VehicleDynamicsMex(1,InstanceID,InitialState);\n\
          InstanceID (optional) - the ID number of the simulation instance to initialize/reinitialize.\n\
          InitialState (optional) - the intial state of the simulation.\n\
          Command Type(optional)  - \n\
			0 - Alt, Psi, Beta, Vel command system. (default)\n\
			1 - P, Q, R, Throttle command system.\n\
          Control Allocation Method(optional)  - \n\
			0 - Pseudo inverse. (default)\n\
			1 - Linear Program.\n\
          DataFile (optional) - the name of the data file. Defaults to 'DATCOM.dat'\n\
          ParameterFile (optional) - the name of the parameter file. Defaults to 'Parameter.dat'\n\
   - UPDATE:  Action=2\n\
       [OutputMatrix] = VehicleDynamicsMex(2,InstanceID,InputMatrix);\n\
          InstanceID - the ID number of the simulation instance to update.\n\
          InputMatrix - inputs to the simulation with each row of the matrix representing one time step.\n\
          OutputMatrix  - outputs from the simulation with each row of the matrix representing one time step.\n\
   - CLEAR INSTANCE:  Action=3\n\
		VehicleDynamicsMex(3,InstanceID);\n\
          InstanceID (optional) - the ID number of the simulation instance to clear.\n\
          NOTE: if an instance is not given then this function will clear all instances.\n\
\n\
	Note use [] for optional parameters that are not used.\n\
"

enum Actions 
{
	actionsInitialize=1,
	actionsUpdate,
	actionsClear,
	actionsPrintOutputs,
	actionsTotal
};

extern "C"
{
	void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]);
}

namespace
{
	typedef CVehicleSimulation<VAL_DOUBLE_t,V_PDOUBLE_t,V_DOUBLE_t,double> CVEHICLESIMULATION_t;
	typedef CDynamicInversion<VAL_DOUBLE_t,V_PDOUBLE_t,V_DOUBLE_t,double> CDYNAMIC_INVERSION_t;
//	typedef CDynamicInversion<STATE_t,CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t> CDYNAMIC_INVERSION_t;
	typedef vector<CVEHICLESIMULATION_t*> V_PCVEHICLESIMULATION_t;
	typedef V_PCVEHICLESIMULATION_t::iterator V_PCVEHICLESIMULATION_IT_t;
	static V_PCVEHICLESIMULATION_t vsimVehicles;
}


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{

	/* Check for proper number of arguments */

	if (nrhs < 1) 
	{
		mexErrMsgTxt(FUNCTION_USAGE);
	}
	if( !mxIsNumeric(prhs[0]) || !mxIsDouble(prhs[0]) ||
		mxIsEmpty(prhs[0]) || mxIsComplex(prhs[0]) ||
		mxGetM(prhs[0])*mxGetN(prhs[0])!=1 ) 
	{
		mexErrMsgTxt("Action must be a scalar.");
	}
	int iAction = rounding_cast<int>(mxGetScalar(prhs[0]));

	switch(iAction)
	{
	case actionsPrintOutputs:
		{
			// VehicleDynamicsMex(PrintOutputs,InstanceID)
			if (nrhs != 2) 
			{
				mexErrMsgTxt(PROGRAM_NAME": PrintOutputs requires two input arguments: PrintOutputs=4, InstanceID");
			}
			if (nlhs != 0) 
			{
				mexErrMsgTxt(PROGRAM_NAME": PrintOutputs requires one output argument for the state matrix.");
			}      

			int iInstanceID = rounding_cast<int>(mxGetScalar(prhs[1]));
			if(iInstanceID < vsimVehicles.size())
			{
				if(vsimVehicles[iInstanceID]==NULL)
				{
					mexErrMsgTxt("Initialization must be called before calling PrintOutputs.");
				}
			}
			else
			{
				mexErrMsgTxt(PROGRAM_NAME": InstanceID greater than number of instances");
			}
			CVEHICLESIMULATION_t* pvehicleSimulation = vsimVehicles[iInstanceID];
			stringstream sstrLabels;
			pvehicleSimulation->GetOutputLabels(""," = IndexOutput;IndexOutput = IndexOutput + 1;",sstrLabels);
			mexPrintf(sstrLabels.str().c_str());
			break;
		}
	case actionsClear:
		{
			if (nrhs < 2) 
			{
				mexPrintf("%s",PROGRAM_NAME": Clearing all simulation instances.");
				for(V_PCVEHICLESIMULATION_IT_t itVehicle=vsimVehicles.begin();itVehicle!=vsimVehicles.end();itVehicle++)
				{
					// iterators are no longer pointers?
					if((*itVehicle)!=NULL)
					{
					  delete &(*itVehicle);
					  (*itVehicle) = NULL;
					}
				}
				vsimVehicles.clear();
			}
			else
			{
				int iInstanceID = rounding_cast<int>(mxGetScalar(prhs[1]));
				if(iInstanceID < vsimVehicles.size())
				{
					stringstream cstrTemp;
					cstrTemp << PROGRAM_NAME": Deleting instance #" << iInstanceID << endl << ends;
					mexPrintf("%s",cstrTemp.str().c_str());
					// iterators are not pointers? (no, they are not...delete corrected below)
					if(vsimVehicles[iInstanceID]!=NULL)
					{
					  delete &*vsimVehicles[iInstanceID];
					  (vsimVehicles[iInstanceID]) = NULL;
					}
				}
				else
				{
					mexErrMsgTxt(PROGRAM_NAME": InstanceID greater than number of instances");
				}
			}
			break;
		}
	case actionsInitialize:
		{
			// Check for proper number of arguments 
			// VehicleDynamicsMex(Initialize,InstanceID,InitialState,CommandType,ControlAllocationMethod,DataFileName,ParameterFileName,SubtractBaseTables)
			enum enInitializeOptions
			{
				initInitialize,
				initInstanceID,
				initInitialState,
				initCommandType,
				initControlAllocationMethod,
				initDataFileName,
				initParameterFileName,
				initSubtractBaseTables,
				initTotal
			};
			if (nlhs != 1) 
			{
				mexErrMsgTxt(PROGRAM_NAME": Initialization requires one output argument to return the InstanceID.");
			}      
			if (nrhs != initTotal) 
			{
				stringstream sstrErrorMessage;
				sstrErrorMessage << PROGRAM_NAME
					<< ": Initialization requires " << initTotal 
					<< "input arguments: Initialize=1, InstanceID(option), Initial State Vector(option),"
					<< "Command Type(option), Control Allocation Method(option), Data File Name(option), "
					<< "Parameter File Name(option), SubtractBaseTables (option).";
				mexErrMsgTxt(sstrErrorMessage.str().c_str());
			}


			//  parameter file name
			string strParameterFile = "Parameters.dat";
			if(!mxIsEmpty(prhs[initParameterFileName]))
			{
				if(!mxIsNumeric(prhs[initParameterFileName]))
				{
					char caTemp[max_path_len];
					if (mxGetString(prhs[initParameterFileName],static_cast<char*>(&caTemp[0]),max_path_len))
					{
						stringstream sstrErrorMessage;
						sstrErrorMessage << "Parameter File Name is invalid.";
						mexErrMsgTxt(sstrErrorMessage.str().c_str());
					}
					strParameterFile = caTemp;
				}
				else
				{
					stringstream sstrErrorMessage;
					sstrErrorMessage << "Parameter File Name is invalid.";
					mexErrMsgTxt(sstrErrorMessage.str().c_str());
				}
			}

			//  data file name
			string strDataFile = "DATCOM.dat";
			if(!mxIsEmpty(prhs[initDataFileName]))
			{
				if(!mxIsNumeric(prhs[initDataFileName]))
				{
					char caTemp[max_path_len];
					if (mxGetString(prhs[initDataFileName],static_cast<char*>(&caTemp[0]),max_path_len))
					{
						stringstream sstrErrorMessage;
						sstrErrorMessage << "Data File Name is invalid.";
						mexErrMsgTxt(sstrErrorMessage.str().c_str());
					}
					strDataFile = caTemp;
				}
				else
				{
					stringstream sstrErrorMessage;
					sstrErrorMessage << "Data File Name is invalid.";
					mexErrMsgTxt(sstrErrorMessage.str().c_str());
				}
			}

			//  SubtractBaseTables
			BOOL bSubtractBaseTables = TRUE;
			if(!mxIsEmpty(prhs[initSubtractBaseTables]))
			{
				if(mxIsNumeric(prhs[initSubtractBaseTables]))
				{
					bSubtractBaseTables = rounding_cast<BOOL>(mxGetScalar(prhs[initSubtractBaseTables]));
					bSubtractBaseTables = (bSubtractBaseTables!=0)?(1):(0);
				}
				else
				{
					stringstream sstrErrorMessage;
					sstrErrorMessage << "SubtractBaseTables is invalid. It must be a 1 or a 0.";
					mexErrMsgTxt(sstrErrorMessage.str().c_str());
				}
			}

			// instance ID
			CVEHICLESIMULATION_t* pvehicleSimulation;
			int iInstanceID = vsimVehicles.size() + 1;
			if(!mxIsEmpty(prhs[initInstanceID]))
			{
				if(mxIsNumeric(prhs[initInstanceID]) && mxIsDouble(prhs[initInstanceID]) && 
						(mxGetM(prhs[initInstanceID])==1) && (mxGetN(prhs[initInstanceID])==1))
				{
					iInstanceID = rounding_cast<int>(mxGetScalar(prhs[initInstanceID]));
				}
				else
				{
					stringstream sstrErrorMessage;
					sstrErrorMessage << PROGRAM_NAME
						<< ": Error encountered during Initialization: problem with InstanceID";
					mexErrMsgTxt(sstrErrorMessage.str().c_str());
				}
			}
			if(iInstanceID >= vsimVehicles.size())
			{
				stringstream sstrErrorMessage;
				vsimVehicles.push_back(new CVEHICLESIMULATION_t(sstrErrorMessage,bSubtractBaseTables,strParameterFile,strDataFile));
				if(!sstrErrorMessage.str().empty())
				{
					mexErrMsgTxt(sstrErrorMessage.str().c_str());
				}
				iInstanceID = vsimVehicles.size() - 1;
				pvehicleSimulation = vsimVehicles[iInstanceID];
				stringstream cstrTemp;
				cstrTemp << PROGRAM_NAME": Adding new instance, #" << iInstanceID << endl << ends;
				mexPrintf("%s",cstrTemp.str().c_str());
			}
			else
			{
				if(vsimVehicles[iInstanceID]!=NULL)
				{
					// remember, iterators are not pointers...
				  delete &*vsimVehicles[iInstanceID];
				}
				stringstream sstrErrorMessage;
				vsimVehicles[iInstanceID] = new CVEHICLESIMULATION_t(sstrErrorMessage,bSubtractBaseTables,strParameterFile,strDataFile);
				if(!sstrErrorMessage.str().empty())
				{
					mexErrMsgTxt(sstrErrorMessage.str().c_str());
				}
				pvehicleSimulation = vsimVehicles[iInstanceID];

				stringstream cstrTemp;
				cstrTemp << PROGRAM_NAME": Resetting instance, #" << iInstanceID << endl << ends;
				mexPrintf("%s",cstrTemp.str().c_str());
			}

			// initialize states
			VAL_DOUBLE_t vdInitialState;
			if(!mxIsEmpty(prhs[initInitialState]))
			{
				if( !mxIsNumeric(prhs[initInitialState]) || !mxIsDouble(prhs[initInitialState]) ||
					mxIsEmpty(prhs[initInitialState]) || mxIsComplex(prhs[initInitialState]) ||
					mxGetM(prhs[initInitialState])!=pvehicleSimulation->iGetNumberStates() || 
																mxGetN(prhs[initInitialState])!=1 ) 
				{
					stringstream cstrTemp;
					cstrTemp << "Initial state parameter must be a " << pvehicleSimulation->iGetNumberStates() << " by 1 vector." << endl;
					mexErrMsgTxt(cstrTemp.str().c_str());
				}

				double* pdParameterState = NULL;
				pdParameterState = mxGetPr(prhs[initInitialState]);
				vdInitialState.resize(pvehicleSimulation->iGetNumberStates(),0.0);
				for(int iCountStates=0;iCountStates<pvehicleSimulation->iGetNumberStates();iCountStates++)
				{
					vdInitialState[iCountStates] = pdParameterState[iCountStates];
				}
			}	

			//  command type
			CVEHICLESIMULATION_t::enFCStype cmdtype = CVEHICLESIMULATION_t::fcsAltPsiBetaVel;
			if(!mxIsEmpty(prhs[initCommandType]))
			{
				int iCmdType = CVEHICLESIMULATION_t::fcsTotal;
				if(mxIsNumeric(prhs[initCommandType]) && mxIsDouble(prhs[initCommandType]) && 
						(mxGetM(prhs[initCommandType])==1) && (mxGetN(prhs[initCommandType])==1))
				{
					iCmdType = rounding_cast<int>(mxGetScalar(prhs[initCommandType]));
					if (iCmdType>=CVEHICLESIMULATION_t::fcsTotal)
					{
						stringstream sstrErrorMessage;
						sstrErrorMessage << "Command type is invalid, received: "
							<< iCmdType << ",/tnumber of types: "
							<< CVEHICLESIMULATION_t::fcsTotal << ends;
						mexErrMsgTxt(sstrErrorMessage.str().c_str());
					}
					cmdtype = static_cast<CVEHICLESIMULATION_t::enFCStype>(iCmdType);
				}
				else
				{
					stringstream sstrErrorMessage;
					sstrErrorMessage << "Command type is invalid, received: "
						<< iCmdType << ",/tnumber of types: "
						<< CVEHICLESIMULATION_t::fcsTotal << ends;
					mexErrMsgTxt(sstrErrorMessage.str().c_str());
				}
			}

			
			//  cntrl alloc method
			CDYNAMIC_INVERSION_t::enControlAllocation ctlallcmeth = CDYNAMIC_INVERSION_t::ctlallcPsuedoInverse;
			if(!mxIsEmpty(prhs[initControlAllocationMethod]))
			{
				int iCtlAllcMeth = CDYNAMIC_INVERSION_t::ctlallcTotal;
				if(mxIsNumeric(prhs[initControlAllocationMethod]) && mxIsDouble(prhs[initControlAllocationMethod]) && 
						(mxGetM(prhs[initControlAllocationMethod])==1) && (mxGetN(prhs[initControlAllocationMethod])==1))
				{
					iCtlAllcMeth = rounding_cast<int>(mxGetScalar(prhs[initControlAllocationMethod]));
					if (iCtlAllcMeth>=CDYNAMIC_INVERSION_t::ctlallcTotal)
					{
						stringstream sstrErrorMessage;
						sstrErrorMessage << "Control allocation method is invalid, received: "
							<< iCtlAllcMeth << ",/tnumber of methods: "
							<< CDYNAMIC_INVERSION_t::ctlallcTotal << ends;
						mexErrMsgTxt(sstrErrorMessage.str().c_str());
					}
					ctlallcmeth = static_cast<CDYNAMIC_INVERSION_t::enControlAllocation>(iCtlAllcMeth);
				}
				else
				{
						stringstream sstrErrorMessage;
						sstrErrorMessage << "Control allocation method is invalid, received: "
							<< iCtlAllcMeth << ",/tnumber of methods: "
							<< CDYNAMIC_INVERSION_t::ctlallcTotal << ends;
						mexErrMsgTxt(sstrErrorMessage.str().c_str());
				}
			}

			stringstream sstrErrorMessage;
			if(!pvehicleSimulation->bReinitialize(vdInitialState,cmdtype,ctlallcmeth,sstrErrorMessage))
			{
				sstrErrorMessage << ends;
				mexErrMsgTxt(sstrErrorMessage.str().c_str());
			}

			plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);
			/*  create a C pointer to a copy of the output matrix */
			double* prealOutputs = mxGetPr(plhs[0]);
			prealOutputs[0] = iInstanceID;
		}
		break;

	case actionsUpdate:
		{
			// VehicleDynamicsMex(UpdateX,ElapsedTime,Input)
			if (nrhs < 1) 
			{
				mexErrMsgTxt(PROGRAM_NAME": Update requires three input arguments: Update=2, InstanceID and Input matrix");
			}
			if (nlhs != 1) 
			{
				mexErrMsgTxt(PROGRAM_NAME": Update requires one output argument for the state matrix.");
			}      

			int iInstanceID = rounding_cast<int>(mxGetScalar(prhs[1]));
			if(iInstanceID < vsimVehicles.size())
			{
				if(vsimVehicles[iInstanceID]==NULL)
				{
					mexErrMsgTxt("Initialization must be called before calling Update.");
				}
			}
			else
			{
				mexErrMsgTxt(PROGRAM_NAME": InstanceID greater than number of instances");
			}
			CVEHICLESIMULATION_t* pvehicleSimulation = vsimVehicles[iInstanceID];;

			int iArgument = 2;
			BOOL bIsNumeric = mxIsNumeric(prhs[iArgument]);
			BOOL bIsDouble = mxIsDouble(prhs[iArgument]);
			BOOL bIsEmpty = mxIsEmpty(prhs[iArgument]);
			BOOL bIsComplex = mxIsComplex(prhs[iArgument]);
			size_t szNumberRows = mxGetM(prhs[iArgument]);
			size_t szNumberColumns = mxGetN(prhs[iArgument]);

			if(!bIsNumeric || !bIsDouble ||	bIsEmpty || bIsComplex ||
				szNumberColumns!=(pvehicleSimulation->iGetNumberInputs()+1)) 
			{
				stringstream cstrTemp;
				cstrTemp << "Inputs parameter must be an n by " << pvehicleSimulation->iGetNumberInputs() << " vector. (Input dimensions were " << szNumberRows << " by "<< szNumberColumns << ")" << endl;
				mexErrMsgTxt(cstrTemp.str().c_str());
			}
			double* pdParameterInputs;
			pdParameterInputs = mxGetPr(prhs[iArgument]);

			size_t szNumberOutputs = pvehicleSimulation->iGetNumberOutputs();
			plhs[0] = mxCreateDoubleMatrix(szNumberRows,szNumberOutputs, mxREAL);
			/*  create a C pointer to a copy of the output matrix */
			double* prealOutputs = mxGetPr(plhs[0]);
			for(size_t szCountRows=0;szCountRows<szNumberRows;szCountRows++)
			{
				double dElapsedTimeSec = pdParameterInputs[szCountRows];
				V_DOUBLE_t vdInputs(pvehicleSimulation->iGetNumberInputs(),0.0);
				for(int iCountInputs=0;iCountInputs<pvehicleSimulation->iGetNumberInputs();iCountInputs++)
				{
					vdInputs[iCountInputs] = pdParameterInputs[szNumberRows*(iCountInputs+1)+szCountRows];	//the +1 accounts for time being the first column in the input matrix
				}

				V_DOUBLE_t vdOutputs(pvehicleSimulation->iGetNumberOutputs(),0.0);
				stringstream sstrErrorMessage;
				if(!pvehicleSimulation->bUpdate(vdInputs,dElapsedTimeSec,vdOutputs,sstrErrorMessage))
				{
					mexPrintf("%s",sstrErrorMessage.str().c_str());
					break;
				}
				V_DOUBLE_t::iterator itOutput = vdOutputs.begin();
				for(int iCountOutputs=0;iCountOutputs<pvehicleSimulation->iGetNumberOutputs();iCountOutputs++,itOutput++)
				{
					prealOutputs[(szNumberRows*iCountOutputs)+szCountRows] = *itOutput;
				}
			}	//for(size_t szCountRows=0;szCountRows<;szCountRows++))
		}
		break;
	default:
	  // error message "Action not recognized"
		break;
  }
  return;
}
