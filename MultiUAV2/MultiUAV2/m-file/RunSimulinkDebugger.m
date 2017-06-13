%RunSimulinkDebugger - this script starts the simulink debugger, used to remember the command
%
%  Inputs:
%    (none) 
%
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS

global g_SampleTime;
global g_StopTime;

run;
% [t,x,y] = sim('MultiUAV');

% set_param('MultiUAV','SimulationMode','external')
% set_param('MultiUAV','SimulationCommand','connect');

set_param('MultiUAV','SimulationCommand','start');

% input('hit a key!');;
% SimulationStatus = get_param('MultiUAV','simulationstatus');

CountMessages = 0;
for Loop = [0.0:g_SampleTime:g_StopTime+100000],
% pause;
set_param('MultiUAV', 'SimulationCommand', 'continue');
	CountMessages = CountMessages + 1;
	if(CountMessages > 20),
		display(Loop);
	end;
end;

set_param('MultiUAV','SimulationCommand','stop');
% set_param('MultiUAV','SimulationCommand','disconnect');


return;


run;
diary('CompileMultiUAV.txt');

SimOptions = simset('Trace','compile');
SimTime = 1;
[t,x,y] = sim('MultiUAV',SimTime,SimOptions);

diary off;

return;

run;
SimTime = 200;
tic;
%SimOptions = simset('Trace','compile');
NumberRuns = 3;
for iCount = 1:NumberRuns,
	[t,x,y] = sim('MultiUAV',SimTime);
	toc
end;	%for

DeltaTime = toc
RealTimeMetric = DeltaTime/SimTime/NumberRuns
RateTimesRealTime = 1/RealTimeMetric

return;

SimTime = 43.1;
[t,x,y] = sim('MultiUAVR12',SimTime);

return;

diary('CompileMultiUAVR12.txt');

SimOptions = simset('Trace','compile');
SimTime = 1;
[t,x,y] = sim('MultiUAVR12',SimTime,SimOptions);

diary off;

return;


sldebug 'MultiUAVR12'

return;

diary on;

SimTime = 1;
SimOptions = simset('Trace','compile');
[t,x,y] = sim('MultiUAVR12',SimTime,SimOptions);

diary off;

SimTime = 1;
SimOptions = simset('Trace','siminfo');
[t,x,y] = sim('MultiUAVR12',SimTime,SimOptions);

tic;
disp(toc);
SimTime = 1;
[t,x,y] = sim('MultiUAVR12',SimTime);
disp(toc);

tic;
disp(toc);
SimTime = 1;
[t,x,y] = sim('MultiUAVR12_old',SimTime);
disp(toc);

diary('TestSamp0_01.txt');
SimTime = 100;
g_SampleTime = 0.1;
tic;
[t,x,y] = sim('MultiUAVR12',SimTime);
disp(toc);
diary off;

diary('TestSamp0_001.txt');
SimTime = 100;
g_SampleTime = 0.01;
tic;
[t,x,y] = sim('MultiUAVR12',SimTime);
disp(toc);
diary off;