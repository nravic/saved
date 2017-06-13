function [sys,x0,str,ts] = InitFunctionsS(t,x,u,flag)
%InitFunctionsS - S-function interface to SimulationFunctions. Used to initialize the simulation.
% 
%  NOTE 1: the block that calls this S-function must be scheduled to run first
%  NOTE 2: see the function "SimulationFunctions" for details
%

%  AFRL/VACA
%  October 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('InitFunctionsS.m');end; 

global g_SampleTime;
global g_isMonteCarloRun;
global g_SimulationRunNumber;
global g_SimulationTime;

persistent FirstTime;
persistent ResolutionTimeBegin;
persistent ResolutionTime;
persistent SimulationTimeBegin;
persistent SimulationTime;

switch flag,
	
case 0,
	FirstTime = 1;
	ResolutionTimeBegin = clock;
	disp(' ');
	disp('******************************************************************');
	disp('******************************************************************');
	disp('********** InitFunctionsS:: Starting MultiUAV simulation *********');
	disp('******************************************************************');
	disp('******************************************************************');
	disp(' ');
	disp('******************************************************************');
	disp('***** InitFunctionsS:: initializing and resolving connections ****');
	disp('******************************************************************');
	disp(' ');
	sizes = simsizes;
	sizes.NumContStates  = 0;
	sizes.NumDiscStates  = 0;
	sizes.NumOutputs = 0;
	sizes.NumInputs = 0;
	sizes.DirFeedthrough = 1;
	sizes.NumSampleTimes = 1;   % at least one sample time is needed
	sys = simsizes(sizes);
	x0  = [];
	str = [];
	ts  = [g_SampleTime];
	if(g_isMonteCarloRun == 0),
		g_SimulationRunNumber = 1;
	end;
	SimulationFunctions('InitializeSimulation');     % the function to call
	g_SimulationTime = 0.0;
	
	
case 1,
	sys = [];
	
case 2,
	sys = [];
	
case 3,
	sys = [];
	if(FirstTime),
		disp(' ');
		disp('*************************************************************');
		disp('************ InitFunctionsS:: Starting simulation ***********');
		disp('*************************************************************');
		disp(' ');
		FirstTime = 0;
		ResolutionTime = etime(clock,ResolutionTimeBegin);
		SimulationTimeBegin = clock;
	end;
	g_SimulationTime = t;

case 4,
	sys = [];
	
case 9,
	sys = [];
	Summary;	% write summary information to a file.
	SimulationTime = etime(clock,SimulationTimeBegin);
	disp(' ');
	disp('*************************************************************');
	disp('******************** SIMULATION COMPLETE ********************');
	disp(sprintf('***** Connection Resolution Time (%g) ',ResolutionTime));
	disp(sprintf('***** Simulation Time (%g) ',SimulationTime));
	disp(sprintf('***** Simulated Time (%g) ',t));
	disp('*************************************************************');
	disp('*************************************************************');
	disp(' ');
	disp(' ');
	g_SimulationTime = t;
otherwise
	error(['Unhandled flag = ',num2str(flag)]);
	
end;

return; %
