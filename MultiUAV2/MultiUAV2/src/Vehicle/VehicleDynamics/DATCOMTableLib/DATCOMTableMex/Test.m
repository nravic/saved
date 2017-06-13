function Test
%Test - This script function contains various tests of the DATCOMTableMex function.


%  AFRL/VACA
%  January 2002 - RAS

clear all;

tdir = ['..',filesep '..',filesep '..',filesep '..',filesep '..',filesep];

addpath([tdir, 'm-file']);
addpath( GetLibDir(tdir) );


% cases available in check_case()
cases = { 'CheckMemory', 'CheckLocaas', 'CheckGlobalhawk', ...
					'Type1', 'Type2', 'Type3', 'Type4', 'Type5' };

for k = 1:length(cases)
	select_test_case( tdir, cases{k} );
end

return;


%=====================================================================
function select_test_case( tdir, TestType )
	
idir = [tdir, 'InputFiles', filesep];
datcom_local  = 'for021.020111a.dat';
datcom_locaas = [ idir, 'DATCOM.locaas.dat' ];
datcom_gblhwk = [ idir, 'DATCOM.globalhawk.dat' ];

if( ~exist(datcom_local, 'file') )
	warn(['input file ', datcom_local, ' does not exist.']);
end
if( ~exist(datcom_locaas, 'file') )
	warn(['input file ', datcom_locaas, ' does not exist.']);
end
if( ~exist(datcom_gblhwk, 'file') )
	warn(['input file ', datcom_gblhwk, ' does not exist.']);
end

% clear out old stuff
disp('Clearing tables...');
DATCOMTableMex(4);	
disp('done.');

disp(['Selecting Test: ', TestType]);

switch(TestType),
	
case 'CheckMemory',
	for Count=1:100,
		% read tables from file
		TableID = DATCOMTableMex(1,datcom_local);
		MACH = 0.4; ALPHADEG = 0.0; ALTITUDE = 0; SIDESLIP = 0; DEL1 = 0.0; DEL2 = 0; DEL3 = 0; DEL4 = 0;
		Delta1 = [30];
		for (DEL1=Delta1),
			IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
			[DepDeltaIncrements DerivativesStability DepBaseIncrements] = DATCOMTableMex(2,TableID,IndVariables);
			[Derivatives Intercepts] = DATCOMTableMex(3,TableID,IndVariables);
		end;
		% clear out old stuff
		DATCOMTableMex(4);	%clear tables
	end;
	load handel;
	sound(y,Fs);
	display('DONE!');

case 'CheckLocaas',
	% read tables from file
	TableID = DATCOMTableMex(1,datcom_locaas);
	
	ALPHADEG = 00.0; MACH = 0.35025204587296; ALTITUDE = 800.0; SIDESLIP = -0.73452103425482; DEL1 = 0.0; DEL2 = 0.0; DEL3 = 0.0;
	ALPHADEG = 00.0; MACH = 0.35025204587296; ALTITUDE = 800.0; SIDESLIP = 0.0; DEL1 = 0.0; DEL2 = 0.0; DEL3 = 0.0;
	
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3];
	[DepDeltaIncrements DerivativesStability DepBaseIncrements] = DATCOMTableMex(2,TableID,IndVariables)
	
case 'CheckGlobalhawk',
	% read tables from file
	TableID = DATCOMTableMex(1,datcom_gblhwk);
	
	ALPHADEG = 00.0; MACH = 0.35025204587296; ALTITUDE = 800.0; SIDESLIP = -0.73452103425482; DEL1 = 0.0; DEL2 = 0.0; DEL3 = 0.0; DEL4 = 0.0;
	ALPHADEG = 00.0; MACH = 0.35025204587296; ALTITUDE = 800.0; SIDESLIP = 0.0; DEL1 = 0.0; DEL2 = 0.0; DEL3 = 0.0; DEL4 = 0.0;
	
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	[DepDeltaIncrements DerivativesStability DepBaseIncrements] = DATCOMTableMex(2,TableID,IndVariables)
	
	
case 'Type1',
	clf;
	tic;
	DeltaIncrementsAll = [];
	DerivativesAll = [];
	InterceptsAll = [];
	% read tables from file
	TableID = DATCOMTableMex(1,datcom_local);
	%set up independent variable/delta vector
	MACH = 0.4; ALPHADEG = 0.0; ALTITUDE = 0; SIDESLIP = 0; DEL1 = 0.0; DEL2 = 0; DEL3 = 0; DEL4 = 0;
	Delta1 = [-30:5.0:30];
	%Delta1 = [30];
	for (DEL1=Delta1),
		IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
		[DepDeltaIncrements DerivativesStability DepBaseIncrements] = DATCOMTableMex(2,TableID,IndVariables);
		DeltaIncrementsAll = [DeltaIncrementsAll;DepDeltaIncrements];
		[Derivatives Intercepts] = DATCOMTableMex(3,TableID,IndVariables);
		DerivativesAll = [DerivativesAll;Derivatives(3,:)];
		InterceptsAll = [InterceptsAll;Intercepts(3,:)];
	end;
	
	clf;
	IncrementIndex = 1;
	PointsX = [-30.0;30.0];
	
	plot(Delta1,DeltaIncrementsAll(:,IncrementIndex),'LineWidth',5);
	grid on;
	SizeDeflections = length(Delta1);
	hold on;
	for CountDeflection = 1:SizeDeflections,
		%for CountDeflection = SizeDeflections,
		PointsY = DerivativesAll(CountDeflection,IncrementIndex)*PointsX + InterceptsAll(CountDeflection,IncrementIndex);
		plot(PointsX,PointsY,'r');
		pause(1.0);
	end;
	hold off
	% clear out old stuff
	DATCOMTableMex(4);	%clear tables
	toc
	
case 'Type2',
	clf;
	%load sample data
	for021_020111a;	
	tic;
	TableID = DATCOMTableMex(1,datcom_local);
	Delta1 = [-30:5.0:30];
	
	for AlphaIndex = 1:19,
		ALPHADEG = Delta1Alphas(AlphaIndex);
		
		%set up independent variable/delta vector
		MACH = 0.4; ALPHADEG = 0.0; ALTITUDE = 0; SIDESLIP = 0; DEL1 = 0.0; DEL2 = 0; DEL3 = 0; DEL4 = 0;
		DeltaIncrementsTotal = [];
		for (DEL1=Delta1),
			IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
			[DepDeltaIncrements DerivativesStability DepBaseIncrements] = DATCOMTableMex(2,TableID,IndVariables);
			DeltaIncrementsTotal = [DeltaIncrementsTotal;DepDeltaIncrements];
		end;
		
		clf;
		for CountOutput = 1:6,
			subplot(2,3,CountOutput);
			plot(Delta1,DeltaIncrementsTotal(:,CountOutput));
			hold on
			PlotData = AlphaM30DeltaM0_4Del1All(AlphaIndex,:,CountOutput);
			PlotData = squeeze(PlotData)';
			plot(Delta1Deflections,PlotData,'r');
		end;
		pause(1.5);
	end;
	
	hold off
	% clear out old stuff
	DATCOMTableMex(4);	%clear tables
	toc
	
	
case 'Type3',
	
  tic;
	TableID = DATCOMTableMex(1,datcom_local);
	%set up independent variable/delta vector
	MACH = 0.4; ALPHADEG = -30.0; ALTITUDE = 0; SIDESLIP = 0; DEL1 = -30.0; DEL2 = 0; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	
	% check on time of execution by running the function many times and note the time it takes
	NumberRuns = 1000;
	tic
	for i=1:NumberRuns,
		[DepDeltaIncrements DerivativesStability DepBaseIncrements] = DATCOMTableMex(2,TableID,IndVariables);
	end;
	toc/NumberRuns
	
	% check on time of execution by running the function many times and note the time it takes
	NumberRuns = 1000;
	tic
	for i=1:NumberRuns,
		[Derivatives Intercepts] = DATCOMTableMex(3,TableID,IndVariables);
	end;
	toc/NumberRuns
	
	% clear out old stuff
	DATCOMTableMex(4);	%clear tables
  toc
	
	
	
case 'Type4',

 disp([TestType, ' is deprecated.']);
 return
	
	TableID = DATCOMTableMex(1,datcom_local);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% make sure entering deltas one at a time returns the same results as entering multiple deltas at one time.
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%set up independent variable/delta vector with only one delta changing
	MACH = 0.4; ALPHADEG = -30.0; ALTITUDE = 0; SIDESLIP = 10; DEL1 = 0.0; DEL2 = 0; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	%interpolate data
	DepVariable = DATCOMTableMex(2,TableID,IndVariables);
	TotalValues1 = DepVariable(1:6);
	TotalValues1Sum = TotalValues1Sum+TotalValues1;

	%set up independent variable/delta vector with only one delta changing
	MACH = 0.4; ALPHADEG = -30.0; ALTITUDE = 0; SIDESLIP = 0; DEL1 = -12.0; DEL2 = 0; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	%interpolate data
	DepVariable = DATCOMTableMex(2,TableID,IndVariables);
	TotalValues1 = DepVariable(1:6);
	TotalValues1Sum = TotalValues1Sum+TotalValues1;
	
	%set up independent variable/delta vector with only one delta changing
	MACH = 0.4; ALPHADEG = -30.0; ALTITUDE = 0; SIDESLIP = 0; DEL1 = 0.0; DEL2 = 13.6; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	%interpolate data
	DepVariable = DATCOMTableMex(2,TableID,IndVariables);
	TotalValues1 = DepVariable(1:6);
	TotalValues1Sum = TotalValues1Sum+TotalValues1;
	
	
	%set up independent variable/delta vector with multiple deltas changing
	MACH = 0.4; ALPHADEG = -30.0; ALTITUDE = 50000; SIDESLIP = 10; DEL1 = -12.0; DEL2 = 13.6; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	%interpolate data
	DepVariable = DATCOMTableMex(2,TableID,IndVariables);
	CombinedValues = DepVariable(1:6);
	
	%compare the results
	Comparison = CombinedValues - TotalValues1Sum
	
case 'Type5',

 disp([TestType, ' is deprecated.']);
 return
	
	TableID = DATCOMTableMex(1,datcom_local);
	MACH = 0.4; ALPHADEG = -30.0; ALTITUDE = 0; SIDESLIP = 0; DEL1 = 0.0; DEL2 = 0; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	DepVariable = DATCOMTableMex(2,TableID,IndVariables);
	BaseTable = DepVariable(1:6)
	
	MACH = 0.4; ALPHADEG = -30; ALTITUDE = 0; SIDESLIP = 0; DEL1 = -30; DEL2 = 0; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	DepVariable = DATCOMTableMex(2,TableID,IndVariables);
	TotalValues1 = DepVariable(1:6);
	
	MACH = 0.4; ALPHADEG = -25; ALTITUDE = 0; SIDESLIP = 0; DEL1 = -30; DEL2 = 0; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	DepVariable = DATCOMTableMex(2,TableID,IndVariables);
	TotalValues1 = DepVariable(1:6);
	
	MACH = 0.4; ALPHADEG = -27.5; ALTITUDE = 0; SIDESLIP = 0; DEL1 = -30; DEL2 = 0; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	DepVariable = DATCOMTableMex(2,TableID,IndVariables);
	TotalValues1 = DepVariable(1:6);
	
	InterpRow = DeltaM0_4Alt0Beta0Del1M30(2,:) - DeltaM0_4Alt0Beta0Del1M30(1,:);
	FinalRow = 0.5*InterpRow + DeltaM0_4Alt0Beta0Del1M30(1,:);
	FinalRow = FinalRow(2:7);
	Comparison = TotalValues1 - FinalRow
	
	MACH = 0.4; ALPHADEG = -30.0; ALTITUDE = 0; SIDESLIP = 0; DEL1 = -27.5; DEL2 = 0; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	DepVariable = DATCOMTableMex(2,TableID,IndVariables);
	TotalValues1 = DepVariable(1:6);
	
	InterpRow = DeltaM0_4Alt0Beta0Del1M25(1,:) - DeltaM0_4Alt0Beta0Del1M30(1,:);
	FinalRow = 0.5*InterpRow + DeltaM0_4Alt0Beta0Del1M30(1,:);
	FinalRow = FinalRow(2:7);
	
	Comparison = TotalValues1 - FinalRow
	
	MACH = 1.2; ALPHADEG = -30.0; ALTITUDE = 0; SIDESLIP = 0; DEL1 = -30.0; DEL2 = 0; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	DepVariable = DATCOMTableMex(2,TableID,IndVariables);
	TotalValues1 = DepVariable(1:6);
	
	InterpRow = DeltaM2_0Alt0Beta0Del1M30(1,:) - DeltaM0_4Alt0Beta0Del1M30(1,:);
	FinalRow = 0.5*InterpRow + DeltaM0_4Alt0Beta0Del1M30(1,:);
	FinalRow = FinalRow(2:7);
	
	Comparison = TotalValues1 - FinalRow
	
	MACH = 0.4; ALPHADEG = -30.0; ALTITUDE = 50000; SIDESLIP = 0; DEL1 = 0.0; DEL2 = 0; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	DepVariable = DATCOMTableMex(2,TableID,IndVariables);
	TotalValues1 = DepVariable(1:6)
	TotalValues1Sum = TotalValues1;
	
	MACH = 0.4; ALPHADEG = -30.0; ALTITUDE = 0; SIDESLIP = 10; DEL1 = 0.0; DEL2 = 0; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	DepVariable = DATCOMTableMex(2,TableID,IndVariables);
	TotalValues1 = DepVariable(1:6)
	TotalValues1Sum = TotalValues1Sum+TotalValues1;
	
	MACH = 0.4; ALPHADEG = -30.0; ALTITUDE = 10000; SIDESLIP = 10; DEL1 = 0.0; DEL2 = 0; DEL3 = 0; DEL4 = 0;
	IndVariables = [ALPHADEG,MACH,ALTITUDE,SIDESLIP,DEL1,DEL2,DEL3,DEL4];
	DepVariable = DATCOMTableMex(2,TableID,IndVariables);
	TotalValues1 = DepVariable(1:6);
	
	Comparison = TotalValues1 - TotalValues1Sum
	
end;	%switch(TestType),

return;
