// TestEuminxd.cpp : Defines the entry point for the console application.
//

#include "Euminxd.h"
#include <iostream>
using namespace std;

int main(int argc, char* argv[])
{
	CEuminxd euxdSolve;

#ifndef AUSTINTEST
	int iAxisDimension = 3;
	int iNumberOutputs = 3;
	int nf = 3;
	double dInputCommands[3] = {1.0, 0.5, 0.75};
	double dCB[9] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 2.0, 3.0, -1.0};
	double wa[3] = {1.0, 1.0, 1.0};
	double wu[3] = {0.00001, 0.00001, 0.00001};
	double vUmin[3] = {-1.0, -1.0, -1.0};
	double vUmax[3] = {1.0, 1.0, 1.0};
	double upref[3] = {0.0, 0.0, 0.0};
	double f1[9] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
	double fmin[3] = {0.0, 0.0, 0.0};
	double fmax[3] = {0.0, 0.0, 0.0};
	double matActuatorPosition[3] = {0.0, 0.0, 0.0};
	double ec = 0.01;
int iCountCols; // for scope hack for rancid MSVC++6
for(iCountCols=0;iCountCols<iNumberOutputs;iCountCols++)
{
	cout << "matActuatorPosition = " << matActuatorPosition[iCountCols] << endl;
}
#else
	int iAxisDimension = 1;
	int iNumberOutputs = 1;
	int nf = 1;
	double dInputCommands[1] = {1.0};
	double dCB[1] = {0.5};
	double wa[1] = {1.0};
	double wu[1] = {0.00001};
	double vUmin[1] = {-1.0};
	double vUmax[1] = {1.354};
	double upref[1] = {0.0};
	double f1[1] = {0.0};
	double fmin[1] = {0.0};
	double fmax[1] = {0.0};
	double matActuatorPosition[1] = {0.0};
	double ec = 0.01;
	cout << "matActuatorPosition = " << matActuatorPosition[0] << endl;
#endif //AUSTINTEST

	
	if(euxdSolve.Euminxd(iAxisDimension, iNumberOutputs, dCB, dInputCommands, wa, wu, vUmin, vUmax, upref, matActuatorPosition))
//	if(euxdSolve.Euminxd(iAxisDimension, iNumberOutputs, dCB, dInputCommands, wa, wu, vUmin, vUmax, upref, nf, f1, fmin, fmax, matActuatorPosition, ec))
		{
			//TODO - need to return an error message
		}


cout << "iAxisDimension = " << iAxisDimension << endl;
cout << "iNumberOutputs = " << iNumberOutputs << endl;
//cout << "nf = " << nf << endl;

#ifndef AUSTINTEST
for(iCountCols=0;iCountCols<iNumberOutputs;iCountCols++)
{
	cout << "dInputCommands = " << dInputCommands[iCountCols] << endl;
}
for(iCountCols=0;iCountCols<1;iCountCols++)
{
	cout << "dCB = " << dCB[iCountCols] <<"\t";
	cout << "dCB = " << dCB[iCountCols+1] <<"\t";
	cout << "dCB = " << dCB[iCountCols+2] << endl;
	cout << "dCB = " << dCB[iCountCols+3] <<"\t";
	cout << "dCB = " << dCB[iCountCols+4] <<"\t";
	cout << "dCB = " << dCB[iCountCols+5] << endl;
	cout << "dCB = " << dCB[iCountCols+6] <<"\t";
	cout << "dCB = " << dCB[iCountCols+7] <<"\t";
	cout << "dCB = " << dCB[iCountCols+8] << endl;

}
for(iCountCols=0;iCountCols<iNumberOutputs;iCountCols++)
{
	cout << "vUmin = " << vUmin[iCountCols] <<"\t";
}
cout << "\n";
for(iCountCols=0;iCountCols<iNumberOutputs;iCountCols++)
{
	cout << "vUmax = " << vUmax[iCountCols] <<"\t";
}
cout << "\n";
//	cout << "wa = " << wa[iCountCols] << endl;
//	cout << "wu = " << wu[iCountCols] << endl;
//	cout << "vUmin = " << vUmin[iCountCols] << endl;
//	cout << "vUmax = " << vUmax[iCountCols] << endl;
//	cout << "upref = " << upref[iCountCols] << endl;
//	cout << "f1 = " << f1[iCountCols] << endl;
//	cout << "f1 = " << f1[iCountCols+iNumberOutputs] << endl;
//	cout << "f1 = " << f1[iCountCols+iNumberOutputs+iNumberOutputs] << endl;
//	cout << "fmin = " << fmin[iCountCols] << endl;
//	cout << "fmax = " << fmax[iCountCols] << endl;

for(iCountCols=0;iCountCols<iNumberOutputs;iCountCols++)
{
	cout << "matActuatorPosition = " << matActuatorPosition[iCountCols] << endl;
}
#else
	cout << "dInputCommands = " << dInputCommands[0] << endl;
	cout << "dCB = " << dCB[0] << endl;
	cout << "vUmin = " << vUmin[0] << endl;
	cout << "vUmax = " << vUmax[0] << endl;
	cout << "matActuatorPosition = " << matActuatorPosition[0] << endl;
#endif //AUSTINTEST

cout << "ec = " << ec << endl;

	return 0;
}
