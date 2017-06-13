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
// CommunicationsDLL.cpp
//
//////////////////////////////////////////////////////////////////////


// May 2003 - Created and Debuggggged - RAS


#define S_FUNCTION_NAME CommunicationsDLL
#define S_FUNCTION_LEVEL 2

#include <simstruc.h>

#include <sstream>
using namespace std;

#include <SSDebugDefine.h>
#include <rounding_cast>

namespace	//need persistent string to return an error status to simulink
{
//	static 	stringstream sstrError;

#define SAMPLE_TIME 0.0

#define NAME_S_FUNCTION "CommunicationsDLL"
#define NAME_COMMUNICATION_STRUCTURE "g_CommunicationMemory"
#define NAME_FIELD_MESSAGES "Messages"
#define NAME_FIELD_INBOXES "InBoxes"
#define NAME_FIELD_INBOXES_MESSAGEHEADERS "MessageHeaders"
#define NAME_FIELD_LASTMESSAGEHEADERINDEX "LastMessageHeaderIndex"
#define NAME_FIELD_NUMBERMESSAGES "NumberMessages"
#define NAME_FIELD_MESSAGES_NUMBERENTRIES "NumberEntries"
#define NAME_FIELD_MESSAGES_NUMBER_SENDERS "NumberSenders"
#define NAME_FIELD_MESSAGES_DATA "Data"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

// prototypes
void ResizeOutputs(SimStruct *S,const char* pcMemoryName,stringstream& sstrError);
void GetCommunicationMemory(SimStruct *S,mxArray*& pmxaCommunicationStructure,const char* pcMemoryName,stringstream& sstrError);
void GetInBoxes(SimStruct *S,mxArray* pmxaCommunicationStructure,mxArray*& pmxaInBoxes,stringstream& sstrError);
void GetInBoxesMessageHeaders(SimStruct *S,mxArray* pmxaInBoxes,mxArray*& pmxaMessageHeaders,const int iObjectIndex,stringstream& sstrError);
void GetLastMessageHeaderIndex(SimStruct *S,mxArray* pmxaInBoxes,size_t& szNumberMessageHeaders,const int iObjectIndex,stringstream& sstrError);
void GetMessages(SimStruct *S,mxArray* pmxaCommunicationStructure,mxArray*& pmxaMessages,stringstream& sstrError);
void GetMessage(SimStruct *S,mxArray* pmxaMessages,const size_t& szMessageIndex,mxArray*& pmxaMessage,stringstream& sstrError);
void GetMessageData(SimStruct *S,mxArray* pmxaMessage,mxArray*& pmxaMessageData,stringstream& sstrError);
void GetMessageNumberEntries(SimStruct *S,mxArray* pmxaMessage,size_t& szNumberEntries,stringstream& sstrError);
void GetMessageNumberSenders(SimStruct *S,mxArray* pmxaMessage,size_t& szNumberSenders,stringstream& sstrError);
void GetNumberMessages(SimStruct *S,mxArray* pmxaCommunicationStructure,size_t& szNumberMessages,stringstream& sstrError);



enum enCommunicationInputs 
{	
	inObjectID,
	inNumberInputs 
};

enum enCommunicationParameters 
{	
	paramCommunicationStructureName,
	paramTotalParameters 
};

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

typedef struct SMessageHeader
{
	double dIndexTimeStamp;
	double dIndexTimeActivate;
	double dIndexMessageID;
	double dIndexMessagePointer;
	double dIndexMessageEvaluated;

}	SMessageHeader_t;

typedef struct SCommunications
{
	stringstream m_sstrMemoryStructureName;
}	SCommunications_t;

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
		// Check parameter: communication structure
		if (!mxIsChar(ssGetSFcnParam(S,paramCommunicationStructureName))) 
		{
			stringstream sstrError;
			sstrError << "ERROR:" << NAME_S_FUNCTION 
						<< "Parameter Number #" << paramCommunicationStructureName+1 << " must be the name of the communications structure"
						<< endl << ends;
			ssSetErrorStatus(S,sstrError.str().c_str());
			return;
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
	ssSetNumSFcnParams(S, paramTotalParameters);  /* Number of expected parameters */

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) 
	{
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) 
		{
            return;
        }
    } 
	else 
	{
        return; /* Parameter mismatch will be reported by Simulink */
    }
#endif

    ssSetNumContStates(S, 0);	// number continuous
    ssSetNumDiscStates(S, 0);	// number discrete states

	//INPUT SIZES
	if (!ssSetNumInputPorts(S, 1)) 
		return;
	ssSetInputPortWidth(S,0,inNumberInputs);

	// set direct feedthrough since there are no states (input goes directly to output)
    ssSetInputPortDirectFeedThrough(S, 0, 1);

	//OUTPUT SIZES

	char caTempName[1024];
	if(mxGetString(ssGetSFcnParam(S,paramCommunicationStructureName),caTempName,1024))
	{
		stringstream sstrError;
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< "Parameter Number #" << paramCommunicationStructureName+1 << " did not contain a string."
					<< endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
	stringstream sstrError;
	ResizeOutputs(S,caTempName,sstrError);
	if(!sstrError.str().empty())
	{
		return;
	}


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
    ssSetSampleTime(S, 0, SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Initialize both continuous states to zero.
 */
void mdlInitializeConditions(SimStruct *S)
{
//    real_T *x0 = ssGetRealDiscStates(S);
//    int_T  lp;

//    for (lp=0;lp<2;lp++) { 
//        *x0++=1.0; 
//    }
}

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
	void mdlStart(SimStruct *S)
	{
		SCommunications_t* pCommunications = new SCommunications_t; 
		ssSetUserData(S,(void*)pCommunications);

		char caTempName[1024];
		if(mxGetString(ssGetSFcnParam(S,paramCommunicationStructureName),caTempName,1024))
		{
			stringstream sstrError;
			sstrError << "ERROR:" << NAME_S_FUNCTION 
						<< "Parameter Number #" << paramCommunicationStructureName+1 << " did not contain a string."
						<< endl << ends;
			ssSetErrorStatus(S,sstrError.str().c_str());
		}
		pCommunications->m_sstrMemoryStructureName << caTempName;
	}
#endif /*  MDL_START */


/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = Cx + Du 
 */
void mdlOutputs(SimStruct *S, int_T tid)
{
	SSDEBUG_TIME(ssGetT(S));

	SCommunications_t* pCommunications = static_cast<SCommunications_t*>(ssGetUserData(S));

	InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
	int iObjectIndex = rounding_cast<int>(U(inObjectID)) - 1;
	if(iObjectIndex < 0)
	{
		// this
		return;
	}


	stringstream sstrError;
	// THE g_CommunicationMemory STRUCTURE
	mxArray* pmxaCommunicationStructure;
	GetCommunicationMemory(S,pmxaCommunicationStructure,pCommunications->m_sstrMemoryStructureName.str().c_str(),sstrError);
	if(!sstrError.str().empty()){return;}

	// THE NUMBER OF MESSAGES
	size_t szNumberMessages;
	GetNumberMessages(S,pmxaCommunicationStructure,szNumberMessages,sstrError);
	if(!sstrError.str().empty()){return;}

	//In Boxes
	mxArray* pmxaInBoxes;
	GetInBoxes(S,pmxaCommunicationStructure,pmxaInBoxes,sstrError);
	if(!sstrError.str().empty()){return;}

	//In Boxes.MessageHeaders
	mxArray* pmxaMessageHeaders;
	GetInBoxesMessageHeaders(S,pmxaInBoxes,pmxaMessageHeaders,iObjectIndex,sstrError);
	if(!sstrError.str().empty()){return;}

	size_t szNumberMessageHeaders = 0;
	GetLastMessageHeaderIndex(S,pmxaInBoxes,szNumberMessageHeaders,iObjectIndex,sstrError);
	const int* piDimensions = mxGetDimensions(pmxaMessageHeaders);

	// g_CommunicationMemory.Messages
	mxArray* pmxaMessages;
	GetMessages(S,pmxaCommunicationStructure,pmxaMessages,sstrError);
	if(!sstrError.str().empty()){return;}

//	const size_t& szNumberMessageHeaders = dNumberMessageHeaders;
	SMessageHeader_t* pmessageHeaders = static_cast<SMessageHeader_t*>(static_cast<void*>(mxGetPr(pmxaMessageHeaders)));
	double* pdTest = mxGetPr(pmxaMessageHeaders);
	for(size_t szCountHeaders=0;szCountHeaders<szNumberMessageHeaders;szCountHeaders++)
	{
		if((pmessageHeaders[szCountHeaders].dIndexMessageEvaluated == 0.0) &&
			(pmessageHeaders[szCountHeaders].dIndexTimeActivate < ssGetT(S)))
		{
			size_t szMessageIDIndex = rounding_cast<size_t>(pmessageHeaders[szCountHeaders].dIndexMessageID) - 1;
			size_t szMessageIDTimeStampPortIndex = 2*szMessageIDIndex;
			real_T* prealOutputsTimeStamp = ssGetOutputPortRealSignal(S,szMessageIDTimeStampPortIndex);
			//timestamp
			prealOutputsTimeStamp[0] = pmessageHeaders[szCountHeaders].dIndexTimeStamp;
			real_T* prealOutputs = ssGetOutputPortRealSignal(S,szMessageIDTimeStampPortIndex+1);
			size_t szMessagePointerIndex = rounding_cast<size_t>(pmessageHeaders[szCountHeaders].dIndexMessagePointer) - 1;

			// retrive message data
			mxArray* pmxaMessage = 0;
			GetMessage(S,pmxaMessages,szMessageIDIndex,pmxaMessage,sstrError);
			if(!sstrError.str().empty()){return;}
			mxArray* pmxaMessageData;
			GetMessageData(S,pmxaMessage,pmxaMessageData,sstrError);
			if(!sstrError.str().empty()){return;}

			size_t szNumberEntries = 0;
			GetMessageNumberEntries(S,pmxaMessage,szNumberEntries,sstrError);
			if(!sstrError.str().empty()){return;}

			const int* piDimensions = mxGetDimensions(pmxaMessageData);
			size_t szNumberColumns = piDimensions[1];
			size_t szNumberRows = piDimensions[0];
			if(szNumberEntries != szNumberRows)
			{
				sstrError << "ERROR:" << NAME_S_FUNCTION << ": Number of entries in message definition different that configured number." << endl << ends;
				ssSetErrorStatus(S,sstrError.str().c_str());
				return;
			}
			if(szMessagePointerIndex >= szNumberColumns)
			{
				sstrError << "ERROR:" << NAME_S_FUNCTION << ": Message pointer greater than number of messages." << endl << ends;
				ssSetErrorStatus(S,sstrError.str().c_str());
				return;
			}

			double* pdMessageData = mxGetPr(pmxaMessageData);

			size_t szDataIndex = szMessagePointerIndex*szNumberRows;
			size_t szFromObjectIndex = rounding_cast<size_t>(pdMessageData[szDataIndex]) - 1;
			if(szFromObjectIndex < 0)
			{
				sstrError << "ERROR:" << NAME_S_FUNCTION << ": Message found with from ObjectID < 0 " << endl << ends;
				ssSetErrorStatus(S,sstrError.str().c_str());
				return;
			}

			// put data in output
			size_t szOutputIndex = szFromObjectIndex*(szNumberRows-2);
			szDataIndex ++;		//don't send vehicleID out
			szDataIndex ++;		//don't send timestamp out (here)
			for(size_t szCountRows=2;szCountRows<szNumberRows;szCountRows++,szOutputIndex++,szDataIndex++)
			{
				prealOutputs[szOutputIndex] = pdMessageData[szDataIndex];
			}
			pmessageHeaders[szCountHeaders].dIndexMessageEvaluated = 1;
		}	//if(pmessageHeaders[szCountHeaders].IndexMessageEvaluated != 0.0)
	}	//for(size_t szCountHeaders=0;szCountHeaders<szNumberMessageHeaders;szCountHeaders++)

	SSDEBUG_TIME(ssGetT(S));
}



#define MDL_UPDATE
/* Function: mdlUpdate ======================================================
 * Abstract:
 *      xdot = Ax + Bu
 */
void mdlUpdate(SimStruct *S, int_T tid)
{
}	// void mdlUpdate(SimStruct *S, int_T tid)


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    delete class instance
 */
void mdlTerminate(SimStruct *S)
{
}



void ResizeOutputs(SimStruct *S,const char* pcMemoryName,stringstream& sstrError)
{
	// THE g_CommunicationMemory STRUCTURE
	mxArray* pmxaCommunicationStructure;
	GetCommunicationMemory(S,pmxaCommunicationStructure,pcMemoryName,sstrError);
	if(!sstrError.str().empty()){return;}

	// THE NUMBER OF MESSAGES
	size_t szNumberMessages;
	GetNumberMessages(S,pmxaCommunicationStructure,szNumberMessages,sstrError);
	if(!sstrError.str().empty()){return;}

	// g_CommunicationMemory.Messages
	mxArray* pmxaMessages;
	GetMessages(S,pmxaCommunicationStructure,pmxaMessages,sstrError);
	if(!sstrError.str().empty()){return;}

	if(szNumberMessages != mxGetNumberOfElements(pmxaMessages))
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
			<< ":" << NAME_FIELD_MESSAGES << " does not contain the same number of elements as there are messages. Number cells: " 
					<< mxGetNumberOfElements(pmxaMessages) << " Number Mesages: " << szNumberMessages
					<< endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}

    if (!ssSetNumOutputPorts(S,(szNumberMessages*2)))	//add a port for timestamp for each message
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ":unable to set set the number of output ports to : " << szNumberMessages
					<< endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
	size_t szOutputPortIndex = 0;
	for(size_t szCountMessage=0;szCountMessage<szNumberMessages;szCountMessage++,szOutputPortIndex+=2)
	{
		// g_CommunicationMemory.Messages{iMessageIndex}
		mxArray* pmxaMessage;
		GetMessage(S,pmxaMessages,szCountMessage,pmxaMessage,sstrError);
		if(!sstrError.str().empty()){return;}
		// g_CommunicationMemory.Messages{iMessageIndex}.NumberEntries.
		size_t szNumberEntries;
		GetMessageNumberEntries(S,pmxaMessage,szNumberEntries,sstrError);
		size_t szNumberSenders;
		GetMessageNumberSenders(S,pmxaMessage,szNumberSenders,sstrError);
		if(!sstrError.str().empty()){return;}

		ssSetOutputPortWidth(S,szOutputPortIndex,1);	//timestamp
		ssSetOutputPortWidth(S,szOutputPortIndex+1,(szNumberSenders*(szNumberEntries-2)));	//remove from Object ID and time stamp from the output

	}	//for(size_t szCountMessage=0;szCountMessage<szNumberMessages;szCountMessage++)
}


void GetCommunicationMemory(SimStruct *S,mxArray*& pmxaCommunicationStructure,const char* pcMemoryName,stringstream& sstrError)
{
	// THE g_CommunicationMemory STRUCTURE
#ifdef MATLAB_R12
	pmxaCommunicationStructure = (mxArray *)mexGetArrayPtr(pcMemoryName, "global");
#else	//#ifdef MATLAB_R12
	pmxaCommunicationStructure = (mxArray *)mexGetVariablePtr("global",pcMemoryName);
#endif	//#ifdef MATLAB_R12
	if(pmxaCommunicationStructure ==  NULL)
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ": Unable to find communications structure: " 
					<< pcMemoryName << endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
	if(!mxIsStruct(pmxaCommunicationStructure))
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ":" << pcMemoryName << " is not a structure" 
					<< endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	};
}

void GetInBoxes(SimStruct *S,mxArray* pmxaCommunicationStructure,mxArray*& pmxaInBoxes,stringstream& sstrError)
{
	// g_CommunicationMemory.InBoxes
	pmxaInBoxes = (mxArray *)mxGetField(pmxaCommunicationStructure,0,NAME_FIELD_INBOXES);
	if(pmxaInBoxes ==  NULL)
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ": Unable to find communications structure field: " 
					<< NAME_FIELD_INBOXES << endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
	if(!mxIsStruct(pmxaInBoxes))
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ":" << NAME_FIELD_INBOXES << " is not a structure array" 
					<< endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
}

void GetInBoxesMessageHeaders(SimStruct *S,mxArray* pmxaInBoxes,mxArray*& pmxaMessageHeaders,const int iObjectIndex,stringstream& sstrError)
{
	// g_CommunicationMemory.InBoxes(iObjectIndex).MessageHeaders
	pmxaMessageHeaders = (mxArray *)mxGetField(pmxaInBoxes,iObjectIndex,NAME_FIELD_INBOXES_MESSAGEHEADERS);
	if(pmxaMessageHeaders ==  NULL)
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ": Unable to find inboxes structure field: " 
					<< NAME_FIELD_INBOXES_MESSAGEHEADERS << endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
	if(!mxIsDouble(pmxaMessageHeaders))
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ":" << NAME_FIELD_INBOXES_MESSAGEHEADERS << " is not a double array" 
					<< endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
}

void GetLastMessageHeaderIndex(SimStruct *S,mxArray* pmxaInBoxes,size_t& szNumberMessageHeaders,const int iObjectIndex,stringstream& sstrError)
{
	// g_CommunicationMemory.InBoxes(iObjectIndex).LastMessageHeaderIndex
	mxArray* pmxaLastMessageHeaderIndex = (mxArray *)mxGetField(pmxaInBoxes,iObjectIndex,NAME_FIELD_LASTMESSAGEHEADERINDEX);
	if(pmxaLastMessageHeaderIndex ==  NULL)
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ": Unable to find inboxes structure field: " 
					<< NAME_FIELD_LASTMESSAGEHEADERINDEX << endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
	if(!mxIsDouble(pmxaLastMessageHeaderIndex))
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ":" << NAME_FIELD_LASTMESSAGEHEADERINDEX << " is not a double array" 
					<< endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
	szNumberMessageHeaders = rounding_cast<size_t>(mxGetScalar(pmxaLastMessageHeaderIndex));
}

void GetMessages(SimStruct *S,mxArray* pmxaCommunicationStructure,mxArray*& pmxaMessages,stringstream& sstrError)
{
	// g_CommunicationMemory.Messages
	pmxaMessages = (mxArray *)mxGetField(pmxaCommunicationStructure,0,NAME_FIELD_MESSAGES);
	if(pmxaMessages ==  NULL)
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ": Unable to find communications structure field: " 
					<< NAME_FIELD_MESSAGES << endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
	if(!mxIsCell(pmxaMessages))
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ":" << NAME_FIELD_MESSAGES << " is not a cell array" 
					<< endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
}

void GetMessage(SimStruct *S,mxArray* pmxaMessages,const size_t& szMessageIndex,mxArray*& pmxaMessage,stringstream& sstrError)
{
	// g_CommunicationMemory.Messages{iMessageIndex}
	pmxaMessage = (mxArray *)mxGetCell(pmxaMessages,szMessageIndex);
	if(pmxaMessage ==  NULL)
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ": Unable to access message at index #" 
					<< szMessageIndex << endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
	if(!mxIsStruct(pmxaMessage))
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ": message at index #"<< szMessageIndex << " is not a structure." 
					<< endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	};
}


void GetMessageData(SimStruct *S,mxArray* pmxaMessage,mxArray*& pmxaMessageData,stringstream& sstrError)
{
	// g_CommunicationMemory.Messages{iMessageIndex}.Data.
	pmxaMessageData = (mxArray *)mxGetField(pmxaMessage,0,NAME_FIELD_MESSAGES_DATA);
	if(pmxaMessageData ==  NULL)
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ": Unable to find g_CommunicationMemory.Messages{iMessageIndex}." 
					<< NAME_FIELD_MESSAGES_DATA << endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
	if(!mxIsDouble(pmxaMessageData))
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ":g_CommunicationMemory.Messages{iMessageIndex}.Data is not a double" 
					<< endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	};
}

void GetMessageNumberEntries(SimStruct *S,mxArray* pmxaMessage,size_t& szNumberEntries,stringstream& sstrError)
{
	// g_CommunicationMemory.Messages{iMessageIndex}.NumberEntries.
	mxArray* pmxaMessageNumberEntries = (mxArray *)mxGetField(pmxaMessage,0,NAME_FIELD_MESSAGES_NUMBERENTRIES);
	if(pmxaMessageNumberEntries ==  NULL)
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ": Unable to find g_CommunicationMemory.Messages{iMessageIndex}.NumberEntries field: " 
					<< NAME_FIELD_MESSAGES_NUMBERENTRIES << endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
	if(!mxIsDouble(pmxaMessageNumberEntries))
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ":g_CommunicationMemory.Messages{iMessageIndex}.NumberEntries is not a double" 
					<< endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	};
	szNumberEntries = rounding_cast<size_t>(mxGetScalar(pmxaMessageNumberEntries)) + 2;	//need to add entries for the ID and timestamp
}

void GetMessageNumberSenders(SimStruct *S,mxArray* pmxaMessage,size_t& szNumberSenders,stringstream& sstrError)
{
	// g_CommunicationMemory.Messages{iMessageIndex}.NumberEntries.
	mxArray* pmxaMessageNumberSenders = (mxArray *)mxGetField(pmxaMessage,0,NAME_FIELD_MESSAGES_NUMBER_SENDERS);
	if(pmxaMessageNumberSenders ==  NULL)
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ": Unable to find g_CommunicationMemory.Messages{iMessageIndex}.NumberSenders field: " 
					<< NAME_FIELD_MESSAGES_NUMBER_SENDERS << endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
	if(!mxIsDouble(pmxaMessageNumberSenders))
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ":g_CommunicationMemory.Messages{iMessageIndex}.NumberEntries is not a double" 
					<< endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	};
	szNumberSenders = rounding_cast<size_t>(mxGetScalar(pmxaMessageNumberSenders));
}

void GetNumberMessages(SimStruct *S,mxArray* pmxaCommunicationStructure,size_t& szNumberMessages,stringstream& sstrError)
{
	// THE NUMBER OF MESSAGES
	mxArray* pmxaNumberMessages = (mxArray *)mxGetField(pmxaCommunicationStructure,0,NAME_FIELD_NUMBERMESSAGES);
	if(pmxaNumberMessages ==  NULL)
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ": Unable to find communications structure field: " 
					<< NAME_FIELD_NUMBERMESSAGES << endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	}
	if(!mxIsDouble(pmxaNumberMessages))
	{
		sstrError << "ERROR:" << NAME_S_FUNCTION 
					<< ":" << NAME_FIELD_NUMBERMESSAGES << " is not a double" 
					<< endl << ends;
		ssSetErrorStatus(S,sstrError.str().c_str());
		return;
	};
	szNumberMessages = rounding_cast<size_t>(mxGetScalar(pmxaNumberMessages));
}

} // anonymous namespace


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

