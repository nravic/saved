function [sys,x0,str,ts] = DAINF_AuctionS(t,x,u,flag)
% S-function interface to M-file
% Brandon Moore 20 AUG 03

global g_Debug; if(g_Debug==1),disp('DAINF_AuctionS.m');end; 

global g_SampleTime;
global g_MaxNumberVehicles;
global g_CommunicationMemory;

switch flag,

case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    % Replan Round, auction message data fields, MessageNumber
    sizes.NumOutputs = 2+6*g_MaxNumberVehicles+1;
	% VehicleID
	sizes.NumInputs = 1;
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
         
    sys = DAINF_Auction(u,t);     % the function to call

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %