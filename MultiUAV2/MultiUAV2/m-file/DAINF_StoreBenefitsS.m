function [sys,x0,str,ts] = DAINF_StoreBenefitsS(t,x,u,flag)
% DAINF_StoreBenefitsS
% Stores benefits from DINF_CalculateBenefits in g_VehicleMemory.CooperationManager.CurrentBenefits
% Brandon Moore 20 AUG 03

global g_Debug; if(g_Debug==1),disp('DAINF_StoreBenefitsS.m');end; 

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
	% VehicleID, TaskBenefits, TimeToComplete, SearchBenefit, TargetStates
	sizes.NumInputs = 1 + g_MaxNumberTargets + g_MaxNumberTargets +1 + g_MaxNumberTargets;
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
    
    VehicleID=u(1);
    TaskBenefits=u(2:g_MaxNumberTargets+1)';
    TimeToComplete=u(g_MaxNumberTargets+2:2*g_MaxNumberTargets+1)';
    SearchBenefit=u(2*g_MaxNumberTargets+2);
    TargetStatus=u(2*g_MaxNumberTargets+3:end)';
    
    % Use of realmax for SearchBenefit when vehicle has previously planned attack task
    % causes failure of necessary comparison operators in DAINF_Auction.
    % Use 5000 instead and reduce benefits of task items to -10^5
    
    if SearchBenefit==realmax
        SearchBenefit=5000;
        TaskBenefits=-10^5*ones(1,g_MaxNumberTargets);
    end
    
    
    
    g_VehicleMemory(VehicleID).CooperationManager.CurrentBenefits.TaskBenefits=TaskBenefits;
    g_VehicleMemory(VehicleID).CooperationManager.CurrentBenefits.TimeToComplete=TimeToComplete;
    g_VehicleMemory(VehicleID).CooperationManager.CurrentBenefits.SearchBenefit=SearchBenefit;
    g_VehicleMemory(VehicleID).CooperationManager.CurrentBenefits.TargetStatus=TargetStatus;   
    
    
    

  case 4,
    sys = t + g_SampleTime;

  case 9,
    sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end;

return; %