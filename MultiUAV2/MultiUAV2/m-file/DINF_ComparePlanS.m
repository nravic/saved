function [sys,x0,str,ts] = DINF_ComparePlanS(t,x,u,flag,MaxNumberVehicles,MaxNumberTargets)
%  DINF_ComparePlan.m
%
%  Compares Planning Data (Round # and Target States)
%  
%  Inputs:  ActiveVehicles;
%           [ReplanRound;TargetStates;TaskBenefits;TimeToComplete] x MaxNumberVehicles
%  Outputs: ReplanRound     <- "agreed upon" data
%           TargetStates    <- for this information
%           TaskBenefits
%           TimeToComplete
%           SyncSignal
%  
%  AFRL/VACA
%  July 2003 - Brandon Moore


global g_Debug; if(g_Debug==1),disp('DINF_ComparePlan.m');end; 

global g_SampleTime;


switch flag,
    
case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs = 2 + MaxNumberTargets + 2*MaxNumberVehicles*MaxNumberTargets + MaxNumberVehicles + 1;
    sizes.NumInputs = MaxNumberVehicles +  MaxNumberVehicles*(2+3*MaxNumberTargets+1);
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
    
    % parse input vector
    ActiveVehicles=u(1:MaxNumberVehicles);     % vehicles still alive 
    ActiveIDs=find(ActiveVehicles~=0);
    CommVector=u(MaxNumberVehicles+1:end);     % vectorized TaskBenefits messages from ReceiveMessages
    CommMatrix=reshape(CommVector,2+3*MaxNumberTargets+1,MaxNumberVehicles);
    
    
    % pull out ReplanRound & TargetStates data for active vehicles
    SyncMatrix=CommMatrix(1:2+MaxNumberTargets,ActiveIDs); 
    
    % test to see if all are the same (if they are SyncSignal will be set high)
    for k=1:length(ActiveIDs);
        if sum(SyncMatrix(:,1)~=SyncMatrix(:,k))>0
            SyncSignal=0;
            break;
        else
            SyncSignal=1;
        end
    end
    
    if SyncSignal==1
        ReplanRound=SyncMatrix(1:2,1);
        TargetStates=SyncMatrix(3:end,1);
    else 
        ReplanRound= [-1;-1];
        TargetStates= -ones(MaxNumberTargets,1);
    end
           
    % pull benefits out of 
    TaskBenefits=CommMatrix(3+MaxNumberTargets:2+2*MaxNumberTargets,:);
    TaskBenefits=reshape(TaskBenefits,MaxNumberVehicles*MaxNumberTargets,1);

    TimeToComplete=CommMatrix(3+2*MaxNumberTargets:2+3*MaxNumberTargets,:);
    TimeToComplete=reshape(TimeToComplete,MaxNumberVehicles*MaxNumberTargets,1);
    
    SearchBenefits=CommMatrix(3+3*MaxNumberTargets,:);
    SearchBenefits=SearchBenefits';    
    
    sys = [ReplanRound;TargetStates;TaskBenefits;TimeToComplete;SearchBenefits;SyncSignal];
    
case 4,
    sys = t + g_SampleTime;
    
case 9,
    sys = [];
    
otherwise
    error(['Unhandled flag = ',num2str(flag)]);
    
end;

return; %