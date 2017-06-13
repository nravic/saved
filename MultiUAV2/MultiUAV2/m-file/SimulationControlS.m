function [sys,x0,str,ts] = SimulationControlS(t,x,u,flag)
%SimulationControlS - S-function that makes it possible to puase the simulation at the end of each major update.
% 
%  NOTE 1: the block that calls this S-function must be scheduled to run first
%  NOTE 2: see the function "SimulationFunctions" for details
%

%  AFRL/VACA
%  October 2003 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('SimulationControlS.m');end; 

global g_SampleTime;
global g_PauseAfterEachTimeStep;

switch flag,
	
case 0,
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
	
	
case 1,
	sys = [];
	
case 2,
	sys = [];
	
case 3,
	sys = [];
    global g_TimePrintInterval_sec;
    if(mod(t,g_TimePrintInterval_sec)==0)
        fprintf('%3.2f:\n',t);
    end;
	if(g_PauseAfterEachTimeStep==1),
		set_param('MultiUAV','SimulationCommand','pause');
	end;
case 4,
	sys = [];
	
case 9,
	sys = [];
otherwise
	error(['Unhandled flag = ',num2str(flag)]);
	
end;

return; %