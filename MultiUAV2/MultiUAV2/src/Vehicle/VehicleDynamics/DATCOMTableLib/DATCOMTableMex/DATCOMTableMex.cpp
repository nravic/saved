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


#include <mex.h>
#include <vector>
using std::vector;

#include <rounding_cast>

#include <DATCOMTable.h>
static vector<CDATCOMTable*> vpdatcomTables;

#define FUNCTION_SYNTAX "\n\
[TableSetID] = DATCOMTableMex(1,filename,bSubtractBaseTables); %read file\n\
[DepDeltaIncrements Derivatives DepBaseIncrements] = DATCOMTableMex(2,TableSetID,IndVariables); %interpolate\n\
[Derivatives Intercepts] = DATCOMTableMex(3,TableSetID,IndVariables); %calculate derivatives\n\
DATCOMTableMex(4); %clear\n\
Where:\n\
\t action = 1 to read the file\n\
\t action = 2 to call interpolation function\n\
\t action = 3 to calculate the derivatives\n\
\t action = 4 to clear all tables from memory"

enum enActions {enReadFile=1,enInterpolate,enCalculateDerivatives,enClearAllTables};

extern "C"
{
	void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray* prhs[]);
}

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray* prhs[])
{

	if(nrhs<1)
	{
		mexErrMsgTxt("An input is required.\n The syntax for this function is:" FUNCTION_SYNTAX);
	}
	if( !mxIsNumeric(prhs[0]) || !mxIsDouble(prhs[0]) ||
		mxIsEmpty(prhs[0]) || mxIsComplex(prhs[0]) ||
		mxGetN(prhs[0])*mxGetM(prhs[0])!=1 ) 
	{
		mexErrMsgTxt("action must be a scalar equal to 1 or 2.");
	}
	int iAction = rounding_cast<int>(mxGetScalar(prhs[0]));

	switch(iAction)
	{
	case enReadFile:
		{
			if((nrhs!=2)&&(nrhs!=3))
			{
				mexErrMsgTxt("Reading the file requires an action and a file name. \nThe syntax for this function is:" FUNCTION_SYNTAX);
			}
			if(nlhs!=1) 
			{
				mexErrMsgTxt("Reading the file requires no outputs. \nThe syntax for this function is:" FUNCTION_SYNTAX);
			}
			if( !mxIsChar(prhs[1]) || mxIsEmpty(prhs[1]) ) 
			{
				mexErrMsgTxt("The file name must be a string. \nThe syntax for this function is:" FUNCTION_SYNTAX);
			}
			char caFileName[MAX_LENGTH_LINE];
			const char* pcaFileName = (const char*)&caFileName;

			mxGetString(prhs[1],caFileName,MAX_LENGTH_LINE);

			vpdatcomTables.push_back(new CDATCOMTable());

			BOOL bSubtractBaseTables = TRUE;
			if(nrhs==3)
			{
				bSubtractBaseTables = rounding_cast<BOOL>(mxGetScalar(prhs[2]));
			}

			if(!vpdatcomTables.back()->bReadDataFile(pcaFileName,bSubtractBaseTables))
			{
				char caTemp[MAX_LENGTH_LINE];
				sprintf(caTemp,"Error encountered while reading the file:%s\n",pcaFileName);
				mexErrMsgTxt(caTemp);
			}

			plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);
			double* pdOutputVector = mxGetPr(plhs[0]);

			*pdOutputVector = vpdatcomTables.size();
		}
		break;

	case enInterpolate:
		{
			if(nrhs!=3)
			{
				mexErrMsgTxt("Interpolating the table requires an action, a table ID and values for the independent variables. \nThe syntax for this function is:" FUNCTION_SYNTAX);
			}
			if(nlhs!=3) 
			{
				mexErrMsgTxt("Interpolating the table requires 3 output vectors one each for the Dependent Delta Increments, Derivatives and Dependent Base Increments, . \nThe syntax for this function is:" FUNCTION_SYNTAX);
			}
			if( !mxIsNumeric(prhs[1]) || !mxIsDouble(prhs[1]) ||
				mxIsEmpty(prhs[1]) || mxIsComplex(prhs[1]) ||
				mxGetN(prhs[1])*mxGetM(prhs[1])!=1 ) 
			{
				mexErrMsgTxt("Table ID must be a scalar.\nThe syntax for this function is:" FUNCTION_SYNTAX);
			}
			int iTableSetIDIndex = rounding_cast<int>(mxGetScalar(prhs[1]))-1;
			if((iTableSetIDIndex>=vpdatcomTables.size())||(iTableSetIDIndex<0))
			{
				mexErrMsgTxt("The given table ID is out of range, i.e. it is either less than zero or larger than the number of tables-1.");
			}
			// input vectors
			int iSizeIndVariables = vpdatcomTables[iTableSetIDIndex]->iGetSizeIndVariables();
			if(((mxGetN(prhs[2])!=iSizeIndVariables)&&(mxGetM(prhs[2])!=iSizeIndVariables))||
				((mxGetN(prhs[2])!=1)&&(mxGetM(prhs[2])!=1)))
			{
				char cTemp[1026];
				sprintf((char *)&cTemp,"The independent variable input must be in a vector with the length equal to the number of independent variables.\n Number Independent Variables in table=%d\n Number independent variables passed in = %d",iSizeIndVariables,mxGetN(prhs[2]));
				mexErrMsgTxt((char *)&cTemp);
			}
			double* pdIndVariables = mxGetPr(prhs[2]);

			vpdatcomTables[iTableSetIDIndex]->Interpolate(pdIndVariables,iSizeIndVariables);

			// output vector s
			int iSizeSizeDepVariablesDelta = vpdatcomTables[iTableSetIDIndex]->iGetSizeDepVariables();
			int iSizeSizeDepVariablesDerivative = vpdatcomTables[iTableSetIDIndex]->iGetSizeDepVariablesDerivative();
			int iSizeSizeDepVariablesBase = vpdatcomTables[iTableSetIDIndex]->iGetSizeDepVariables();

			plhs[0] = mxCreateDoubleMatrix(1,iSizeSizeDepVariablesDelta, mxREAL);
			double* pdDepVariablesDelta = mxGetPr(plhs[0]);
			plhs[1] = mxCreateDoubleMatrix(1,iSizeSizeDepVariablesDerivative, mxREAL);
			double* pdDepVariablesDerivative = mxGetPr(plhs[1]);
			plhs[2] = mxCreateDoubleMatrix(1,iSizeSizeDepVariablesBase, mxREAL);
			double* pdDepVariablesBase = mxGetPr(plhs[2]);

			vpdatcomTables[iTableSetIDIndex]->GetOutput(pdDepVariablesDelta,pdDepVariablesDerivative,pdDepVariablesBase);
		}
		break;

	case enCalculateDerivatives:
		{
			if(nrhs!=3)
			{
				mexErrMsgTxt("Calculating derivatives requires an action, a table ID and values for the independent variables. \nThe syntax for this function is:" FUNCTION_SYNTAX);
			}
			if(nlhs!=2) 
			{
				mexErrMsgTxt("Calculating derivatives requires 2 output matricies one the derivatives and one for the intercepts, . \nThe syntax for this function is:" FUNCTION_SYNTAX);
			}
			if( !mxIsNumeric(prhs[1]) || !mxIsDouble(prhs[1]) ||
				mxIsEmpty(prhs[1]) || mxIsComplex(prhs[1]) ||
				mxGetN(prhs[1])*mxGetM(prhs[1])!=1 ) 
			{
				mexErrMsgTxt("Table ID must be a scalar.\nThe syntax for this function is:" FUNCTION_SYNTAX);
			}
			int iTableSetIDIndex = rounding_cast<int>(mxGetScalar(prhs[1]))-1;
			if((iTableSetIDIndex>=vpdatcomTables.size())||(iTableSetIDIndex<0))
			{
				mexErrMsgTxt("The given table ID is out of range, i.e. it is either less than zero or larger than the number of tables-1.");
			}
			// input vectors
			int iSizeIndVariables = vpdatcomTables[iTableSetIDIndex]->iGetSizeIndVariables();
			if(((mxGetN(prhs[2])!=iSizeIndVariables)&&(mxGetM(prhs[2])!=iSizeIndVariables))||
				((mxGetN(prhs[2])!=1)&&(mxGetM(prhs[2])!=1)))
			{
				mexErrMsgTxt("The independent variables must be in a vector with the length equal to the number of independent variables.");
			}
			double* pdIndVariables = mxGetPr(prhs[2]);
			vpdatcomTables[iTableSetIDIndex]->CalculateDerivatives(pdIndVariables,iSizeIndVariables);

			// output vector s
			int iColumnsControlDerivatives = vpdatcomTables[iTableSetIDIndex]->iGetColumnsDerivativesIntercepts();
			int iRowsControlIntercepts = vpdatcomTables[iTableSetIDIndex]->iGetRowsDerivativesIntercepts();

			plhs[0] = mxCreateDoubleMatrix(iRowsControlIntercepts,iColumnsControlDerivatives, mxREAL);
			double* pdControlDerivatives = mxGetPr(plhs[0]);
			plhs[1] = mxCreateDoubleMatrix(iRowsControlIntercepts,iColumnsControlDerivatives, mxREAL);
			double* pdControlIntercepts = mxGetPr(plhs[1]);

			vpdatcomTables[iTableSetIDIndex]->GetDerivatives(pdControlDerivatives,pdControlIntercepts);

		}
		break;

	case enClearAllTables:
		{
			if(nrhs!=1)
			{
				mexErrMsgTxt("Clearing tables from memory only requires the action input parameter. \nThe syntax for this function is:" FUNCTION_SYNTAX);
			}
			if(nlhs!=0) 
			{
				mexErrMsgTxt("Clearing tables from memory no outputs. \nThe syntax for this function is:" FUNCTION_SYNTAX);
			}
			for(std::vector<CDATCOMTable*>::iterator itTable=vpdatcomTables.begin();itTable!=vpdatcomTables.end();itTable++)
			{
				delete *itTable;
			}
			vpdatcomTables.clear();
		}
		break;

	default:
		mexErrMsgTxt("Unknown table ID number.\nThe syntax for this function is:" FUNCTION_SYNTAX);
		break;
	}


}
