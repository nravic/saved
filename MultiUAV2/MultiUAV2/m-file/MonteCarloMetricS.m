function [sys,x0,str,ts] = MonteCarloMetricS(t,x,InputVector,flag,MetricName)
%MonteCarloMetricS - S-function interface to save MonteCarlo Metric.
%
%  Outputs:

%  AFRL/VACA
%  May 2002 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('MonteCarloMetricS.m');end; 

global g_SampleTime;
global g_VehicleMemory;

switch flag,
	
case 0,
	sizes = simsizes;
	sizes.NumContStates  = 0;
	sizes.NumDiscStates  = 0;
	sizes.NumOutputs = 0;
	% VehicleID
	sizes.NumInputs = 2;
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
	if(InputVector(1)<=0),	% vehicle ID
		return;
	end;
	switch(MetricName),
	case 'TotalSearchTimeSeconds',
		g_VehicleMemory(InputVector(1)).MonteCarloMetrics.TotalSearchTimeSeconds = InputVector(2);
	case 'AliveTimeSeconds',
		g_VehicleMemory(InputVector(1)).MonteCarloMetrics.AliveTimeSeconds = InputVector(2);
	otherwise,
	end;
case 4,
	sys = [];
	
case 9,
	sys = [];
	
otherwise
	error(['Unhandled flag = ',num2str(flag)]);
	
end;

return; %