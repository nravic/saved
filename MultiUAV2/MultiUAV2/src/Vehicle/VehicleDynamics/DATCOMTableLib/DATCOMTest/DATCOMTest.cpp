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
// DATCOMTest.cpp : Defines the entry point for the console application.
//

#include <cassert>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
using namespace std;

#include <DATCOMTable.h>

#ifndef _WIN32
#include <mallinfo.h>
#endif

static FILE* sdata = stdout; // MATLAB-like data output.
static FILE* sprog = stdout; // progress information.
static FILE* serr  = stderr; // error messages.

namespace
{
# ifndef _WIN32
	const char* default_datfilename = "../../../../../InputFiles/DATCOM.Locaas.dat";
# else
	const char* default_datfilename = "..\\..\\..\\..\\..\\InputFiles\\DATCOM.Locaas.dat";
# endif

	const char* default_outfilename = "DumpTable.txt";
}

int main(int argc, char* argv[])
{
	if( argc < 2 )
	{
		fprintf( serr, "Error:%s - must specify number of test loops!\n", argv[0] );
		exit( EXIT_FAILURE );
	}
	ios_base::sync_with_stdio();

	const int iMaxLoop = atoi( argv[1] );
	const char* datfilename = (argc > 2) ? argv[2] : default_datfilename;
	int stat = 0;

	if( iMaxLoop == 0 )
	{
		fprintf( serr, "What went wrong?  Do you really want zero (0) test loops?!?\n", argv[0] );
		exit( EXIT_FAILURE );
	}

	fprintf(serr, "using input filename:%s\n            (default:%s)\n", 
					datfilename, default_datfilename);
	fprintf(serr, "using output filename %s\n", default_outfilename);
	fprintf(sprog,"iMaxLoop=%d\n",iMaxLoop);

	// new block scope:
	{
		ifstream check_input_file( datfilename );
		if( check_input_file.fail() )
		{
			fprintf(serr, "Error:  Unable to open file %s\n", datfilename);
			exit( EXIT_FAILURE );
		}
	}
	

# ifndef _WIN32
	static meminfo_t mem[2];
	mem[0] = mallinfo();
# endif

	for (int iCountTestLoop=0;iCountTestLoop<iMaxLoop;iCountTestLoop++)
	{
		fprintf(sprog,"iCountTestLoop=%d\n",iCountTestLoop);
		fprintf(sprog,"  creating table...");
		CDATCOMTable* pdatcomTable = new CDATCOMTable();
		CDATCOMTable& datcomTable = *pdatcomTable;
		fprintf(sprog,"done.\n");

		BOOL bSubtractBaseTables = TRUE;
		//BOOL bSubtractBaseTables = FALSE;

		fprintf(sprog,"  reading table...");
		if(!datcomTable.bReadDataFile(datfilename,bSubtractBaseTables))
		{
			fprintf(serr,"Error encountered while reading the file: %s\n", datfilename);
			exit(EXIT_FAILURE);
		}
		fprintf(sprog,"done.\n");

		// the array below corresponds to the for021.xxxxx.dat file
		// double daIndVariables[] = {0.0, 0.4, 0.0, 0.0, 30.0, 0.0, 0.0, 0.0};

		// the array below corresponds to the DATCOM.Locaas.dat file.
		double daIndVariables[] = {0.0, 0.35, 0.0, 0.0, 30.0, 0.0, 0.0};

		int iSizeIndVariables = sizeof(daIndVariables)/sizeof(double);
		int iSizeIndVariablesDATCOM = datcomTable.iGetSizeIndVariables();
		if(iSizeIndVariablesDATCOM!=iSizeIndVariables)
		{
			fprintf(serr,"The independent variables must be in a vector with the length equal to the number of independent variables.");
			return(EXIT_FAILURE);
		}
		// interpolate
		fprintf(sprog,"  interpolating table...");
		datcomTable.Interpolate(daIndVariables,iSizeIndVariables);
		fprintf(sprog,"done.\n");


		// output vector s
		int iSizeSizeDepVariablesDelta = datcomTable.iGetSizeDepVariables();
		int iSizeSizeDepVariablesDerivative = datcomTable.iGetSizeDepVariablesDerivative();
		int iSizeSizeDepVariablesBase = datcomTable.iGetSizeDepVariables();

		vector<double> vdDepVariablesDelta(iSizeSizeDepVariablesDelta,0.0);
		vector<double> vdDepVariablesDerivative(iSizeSizeDepVariablesDerivative,0.0);
		vector<double> vdDepVariablesBase(iSizeSizeDepVariablesBase,0.0);

		datcomTable.GetOutput(&vdDepVariablesDelta[0],&vdDepVariablesDerivative[0],&vdDepVariablesBase[0]);

		fprintf(sdata,"vdDepVariablesDelta = [");
		vector<double>::iterator itData; // odious MSVC++6 for scoping hack
		for(itData=vdDepVariablesDelta.begin();itData!=vdDepVariablesDelta.end();itData++)
		{
			fprintf(sdata,"% 7.4e ",*itData);
		}
		fprintf(sdata,"]\n\n");
		fprintf(sdata,"vdDepVariablesDerivative = [");
		// (as above, so below w.r.t MSVC++6)
		for(itData=vdDepVariablesDerivative.begin();itData!=vdDepVariablesDerivative.end();itData++)
		{
			fprintf(sdata,"% 7.4e ",*itData);
		}
		fprintf(sdata,"]\n\n");
		fprintf(sdata,"vdDepVariablesBase = [");
		// (as above, so below w.r.t MSVC++6)
		for(itData=vdDepVariablesBase.begin();itData!=vdDepVariablesBase.end();itData++)
		{
			fprintf(sdata,"% 7.4e ",*itData);
		}
		fprintf(sdata,"]\n\n");

		//get derivatives
		fprintf(sprog,"  computing derivatives...");
		datcomTable.CalculateDerivatives(daIndVariables,iSizeIndVariables);
		fprintf(sprog,"done.\n");

		// output vector s
		int iColumnsControlDerivatives = datcomTable.iGetColumnsDerivativesIntercepts();
		int iRowsControlIntercepts = datcomTable.iGetRowsDerivativesIntercepts();

		vector<double> vdControlDerivatives((iRowsControlIntercepts*iColumnsControlDerivatives),0.0);
		vector<double> vdControlIntercepts((iRowsControlIntercepts*iColumnsControlDerivatives),0.0);

		fprintf(sprog,"  reading derivatives...");
		datcomTable.GetDerivatives(&vdControlDerivatives[0],&vdControlIntercepts[0]);
		fprintf(sprog,"done.\n");

		fprintf(sdata,"\n\nvdControlDerivatives = [ \n");
		int iTotalCount=0;	
		int iCountRow; // odious MSVC++6 for scoping hack
		for(iCountRow=0;iCountRow<iColumnsControlDerivatives;iCountRow++)
		{
			for(int iCountColumn=0;iCountColumn<iRowsControlIntercepts;iCountColumn++)
			{
				fprintf(sdata,"% 7.4e ",vdControlDerivatives[iTotalCount]);
				iTotalCount++;
			}
			fprintf(sdata,"\n");
		}
		fprintf(sdata," ] \n");

		fprintf(sdata,"\n\nvdControlIntercepts = [ \n");
		iTotalCount=0;
		// (as above, so below w.r.t MSVC++6)
		for(iCountRow=0;iCountRow<iColumnsControlDerivatives;iCountRow++)
		{
			for(int iCountColumn=0;iCountColumn<iRowsControlIntercepts;iCountColumn++)
			{
				fprintf(sdata,"% 7.4e ",vdControlIntercepts[iTotalCount]);
				iTotalCount++;
			}
			fprintf(sdata,"\n");
		}
		fprintf(sdata,"] \n");

		fprintf(sprog,"  dumping table to stringstream...");
		stringstream sstrOutput;
		pdatcomTable->DumpTable(sstrOutput);
		fprintf(sprog,"done.\n");

		fprintf(sprog,"  dumping table to file...");
		ofstream ofstrFile( default_outfilename );
		if(ofstrFile.is_open())
		{
			ofstrFile << sstrOutput.str();
			fprintf(sprog,"done.\n");
		}
		else
		{
			fflush(0x0);
			fprintf(serr,"\nERROR OPENING FILE: `%s'! (attempting cleanup)\n", default_outfilename);
			stat = EXIT_FAILURE; // try to permit cleanup...
		}
		
		fprintf(sprog,"  deleting table...");
		delete pdatcomTable;
		pdatcomTable = 0x0;
		fprintf(sprog,"done.\n");
	}	//for (int iCountTestLoop=0;iCountTestLoop<100;iCountTestLoop++)

# ifndef _WIN32
	mem[1] = mallinfo();
	compare_mallinfo( serr, mem, "\tmemory usage pre/post-loop");
# endif

	return( stat );
}
