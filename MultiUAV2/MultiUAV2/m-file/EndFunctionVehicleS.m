function [sys,x0,str,ts] = EndFunctionVehicles(t,x,u,flag)
%InitFunctionsS - S-function interface to SimulationFunctions. Used to initialize the simulation.
%
%  NOTE: see the function "SimulationFunctions" for details
%

%  AFRL/VACA
%  October 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('InitFunctionsS.m');end; 

global g_SampleTime;
global SaveVehicleForAVDS;

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

  case 4,
    sys = [];

  case 9,
    sys = [];
    SaveVehicleForAVDST = SaveVehicleForAVDS';
	save Vehicle.save.txt SaveVehicleForAVDST -ascii;

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %