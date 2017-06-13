function [sys,x0,str,ts] = DAINF_AssumeDutyS(t,x,u,flag)
% DAINF_StoreBenefitsS
% Stores benefits from DINF_CalculateBenefits in g_VehicleMemory.CooperationManager.CurrentBenefits
% Brandon Moore 20 AUG 03

global g_Debug; if(g_Debug==1),disp('DAINF_AssumeDutyS');end; 

global g_SampleTime;
global g_MaxNumberTargets;
global g_VehicleMemory;

switch flag,

case 0,
    
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    % no outputs
    sizes.NumOutputs =0;
	% VehicleID,NewTargets
	sizes.NumInputs = 1+g_MaxNumberTargets;
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
         
    
    
    
    VehicleID=u(1);
    NewTargets=u(2:end)';
    
       
%     duty=find(NewTargets);
%     disp(sprintf('%.2f Vehicle-%d Assumes First Auctioneer Duty for Target-%d',t,VehicleID,duty));
    
    
    %append new targets to the auctioneer duty of the vehicle that found them
    %this should happen only once per target and on only one vehicle
    % NOTE! there will be trouble with delays (i.e. when two vehicles both think they found a target first)
    AD=g_VehicleMemory(VehicleID).CooperationManager.AuctioneerDuty;
    AD=[AD, find(NewTargets>0)];
    g_VehicleMemory(VehicleID).CooperationManager.AuctioneerDuty=AD;
    
    sys = [];
    

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %