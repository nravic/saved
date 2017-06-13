    function [sys,x0,str,ts] = MultiTaskAssignIOS(t,x,InputVector,flag,AlgorithmType,MaxNumberTargets,MaxNumberVehicles)
    %MultiTaskAssignIOS - S-function interface to MultiTaskAssignIO('Input',u).
    %
    %  NOTE: see the function "MultiTaskAssignIO" for details
    %  Outputs:
    
    %  AFRL/VACA
    %  March 2002 - Created and Debugged - RAS
    
    
    global g_Debug; if(g_Debug==1),disp('MultiTaskAssignIOS.m');end; 
    
    global g_SampleTime;
    global g_NumberTargetOutputs;
    global g_MaxNumberDesiredHeadings;
    
    switch flag,
    
    case 0,
        sizes = simsizes;
        sizes.NumContStates  = 0;
        sizes.NumDiscStates  = 0;
        sizes.NumOutputs = 3;
    	% TriggerReplan Flags VehicleID, TargetStatus,ReplanETAsAndCosts, TargetAttacked , DesiredHeadings (1-4), CommandedTrunRadius, current waycount, Last Waypoint Type, 
	sizes.NumInputs = MaxNumberTargets*(g_NumberTargetOutputs+1+g_MaxNumberDesiredHeadings) + 6*MaxNumberVehicles + 4 + MaxNumberVehicles;
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
     	sys = MultiTaskAssignIO(AlgorithmType,InputVector,t);     % the function to call
    
      case 4,
        sys = t + g_SampleTime;
    
      case 9,
        sys = [];
    
      otherwise
        error(['Unhandled flag = ',num2str(flag)]);
    
    end;
    
    return; %