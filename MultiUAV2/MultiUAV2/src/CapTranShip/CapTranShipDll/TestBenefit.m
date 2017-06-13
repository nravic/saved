function Benefit = TestBenefit(iVehicleID,iTargetID,iTaskID)
%TestBenefit - called by CalculateBenefit.m to act as a test of the algorithms 
%
%  Inputs:
%    iVehicleID - identification number of the vehicle
%    iTargetID - identification number of the target
%    iTaskID - identification number of the task
%
%  Outputs:
%    Benefit - calculated benefit of assigning the given vehivcle to the given
%              target to perform the given task
%

%  AFRL/VACA
%  March 2001 - Created and Debugged - RAS


%%
%%	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION IS RELEASED "AS IS." THE
%%	U.S.GOVERNMENT MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, CONCERNING
%%	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION, INCLUDING, WITHOUT LIMITATION,
%%	ANY WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
%%	WILL THE U.S. GOVERNMENT BE LIABLE FOR ANY DAMAGES, INCLUDING ANY LOST PROFITS,
%%	LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE,
%%	OR INABILITY TO USE, THIS SOFTWARE OR ANY ACCOMPANYING DOCUMENTATION, EVEN IF
%%	INFORMED IN ADVANCE OF THE POSSIBILITY OF SUCH DAMAGES.
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TEST FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin <1,
   iVehicleID = 1;
   iTargetID = 3;
   iTaskID = 3;
end

iNumVehicles = 3;
iNumTargets = 3;
iNumTasks = 3;


iSizeArray = iNumVehicles+(iNumVehicles*iNumTargets*iNumTasks);
persistent RandArray;

%iSetUpFlag = 1;
if((iVehicleID==1)&(iTargetID==0)&(iTaskID==0))
   iSetUpFlag = 1;
else,
   iSetUpFlag = 0;
end;

if (iSetUpFlag),
   RandArray = zeros(iSizeArray,1);
   for iCount = 1:iSizeArray,
      RandArray(iCount) = round(rand*100);
   end;
end;	%if (iSetUpFlag),


iColBenefit = 4;

ContinueToSearch = [
1 0 0 RandArray(1)
2 0 0 RandArray(2)
3 0 0 RandArray(3)
];

BennefitVehicleToTargetTasks01 ={
[
1 1 1 RandArray(4)
1 2 1 RandArray(5)
1 3 1 RandArray(6)
]
[
2 1 1 RandArray(7)
2 2 1 RandArray(8)
2 3 1 RandArray(9)
]

[
3 1 1 RandArray(10)
3 2 1 RandArray(11)
3 3 1 RandArray(12)
]
};
BennefitVehicleToTargetTasks02 = {
[
1 1 2 RandArray(13)
1 2 2 RandArray(14)
1 3 2 RandArray(15)
]
[
2 1 2 RandArray(16)
2 2 2 RandArray(17)
2 3 2 RandArray(18)
]
[
3 1 2 RandArray(19)
3 2 2 RandArray(20)
3 3 2 RandArray(21)
]
};
BennefitVehicleToTargetTasks03 = {
[
1 1 3 RandArray(22)
1 2 3 RandArray(23)
1 3 3 RandArray(24)
]
[
2 1 3 RandArray(25)
2 2 3 RandArray(26)
2 3 3 RandArray(27)
]
[
3 1 3 RandArray(28)
3 2 3 RandArray(29)
3 3 3 RandArray(30)
]
};

BenefitCell = {BennefitVehicleToTargetTasks01;BennefitVehicleToTargetTasks02;BennefitVehicleToTargetTasks03};
               
if ((iVehicleID > iNumVehicles)|(iVehicleID <= 0)|(iTargetID > iNumTargets)|(iTargetID < 0)|(iTaskID > iNumTasks)|(iTaskID < 0)),
	Benefit  = 0;  	%this is an error condition
else,
   if (iTaskID == 0),
      Benefit = ContinueToSearch(iVehicleID,iColBenefit);
   else,
      Benefit = BenefitCell{iTaskID}{iVehicleID}(iTargetID,iColBenefit);
   end;
end;

if (iSetUpFlag),
	% save test file for comparison
	FID = fopen('CTPSave.txt','w+');
	fprintf(FID,'%d %d \r\n',iNumVehicles,iNumTargets);
	fprintf(FID,'\r\n\r\n');
	for iCountVehicle = 1:iNumVehicles,
		for iCount = 1:4
			fprintf(FID,'%d ',ContinueToSearch(iCountVehicle,iCount));
		end;
   	fprintf(FID,'\r\n');
	end;
	fprintf(FID,'\r\n\r\n');
	for iCountTask = 1:iNumVehicles
   	for iCountVehicle = 1:iNumVehicles,
      	for iCountTarget = 1:iNumTargets,
				for iCountCols = 1:4
					fprintf(FID,'%d ',BenefitCell{iCountTask}{iCountVehicle}(iCountTarget,iCountCols));
         	end;
         	fprintf(FID,'\r\n');
			end;
		end;
		fprintf(FID,'\r\n\r\n');
	end;
	fprintf(FID,'-1 \r\n');
	fclose(FID);
end;	%if (iSetUpFlag),





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
