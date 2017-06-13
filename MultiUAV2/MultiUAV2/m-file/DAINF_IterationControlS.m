function [sys,x0,str,ts] = DAINF_IterationControlS(t,x,u,flag)
% S-function interface to M-file
% Brandon Moore 20 AUG 03

global g_Debug; if(g_Debug==1),disp('DAINF_IterationControlS.m');end; 

global g_SampleTime;
global g_MaxNumberTargets;
global g_CommunicationMemory;

switch flag,

case 0,
    LengthAM = g_CommunicationMemory.Messages{g_CommunicationMemory.MsgIndicies.AuctionData}.NumberEntries;
    
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    % TargetStates, StoreBenefits, AssignmentComplete, NewAssignmentTime
    sizes.NumOutputs = g_MaxNumberTargets+1+1 + 1;
    % RoundComplete, ReplanTrigger,VehicleID, TargetStatus, WaypointNumber,PositionX,PositionY,Psi
	sizes.NumInputs = 1+1+1+g_MaxNumberTargets+1+1+1+1;
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
         
    sys = DAINF_IterationControl(u,t);     % the function to call

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %