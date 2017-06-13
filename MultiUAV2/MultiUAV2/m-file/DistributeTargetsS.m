function [sys,x0,str,ts] = DistributeTargetsS(t,x,u,flag)
%DistributeTargetsS -  - call function to change the disribution of the targets during the simulation. % 
% INPUTS:
%    Vehicle XPosition, YPosition, PsiFIlteredDegv  (repeated for g_MaxNumberVehicles)
%    Vehicle Finished (repeated for g_MaxNumberVehicles)
%
% NOTES:
%    0. Target assignment is sensetive to the size of g_TargetSpace.  So that if a vehicle is
%       outside g_TargetSpace, its assignment time (all all remaining times) are bumped by dt
%       defined below.  A better method is make the killbox bigger, control the turning
%       points of the serpentine pattern, and alter the starting point of vehicle one with the
%       variables 'g_KillboxOffsetX' & 'g_StartingPointOffsetXY' defined in InitializeGlobals.m

%  AFRL/VACA
%  February 2004 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('DistributeTargetsS.m');end; 

global g_SampleTime;

global g_RandomTargetPosition;
global g_MaxNumberVehicles;
global g_TruthMemory;

switch flag,
    
case 0,
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs = 0;
    sizes.NumInputs = (g_TruthMemory.Messages{g_TruthMemory.MsgIndicies.VehicleState}.NumberEntries)*g_MaxNumberVehicles;
    sizes.DirFeedthrough = 1;
    sizes.NumSampleTimes = 1;   % at least one sample time is needed
    sys = simsizes(sizes);
    x0  = [];
    str = [];
    ts  = [g_SampleTime];
    
    if(strcmp(g_RandomTargetPosition, 'TimeBasedDistribution')),
        DistributeTargets('initialize',t);
    end;
    
    
case 1,
    sys = [];
    
case 2,
    sys = [];
    
case 3,
    sys = [];
    if(strcmp(g_RandomTargetPosition, 'TimeBasedDistribution')),
        DistributeTargets('update',t,u);
    end;
    
case 4,
    sys = [];
    
case 9,
    sys = [];
otherwise
    error(['Unhandled flag = ',num2str(flag)]);
    
end;

return; %DistributeTargetsS



function DistributeTargets(action,Time,InputVector)
%DistributeTargets - changes the disribution of the targets during the simulation. 
% %  Inputs:
%    action - type of call ('initialize,'update')
%    Time - simulation time in seconds
%  Outputs:

%  AFRL/VACA
%  February 2004 - Created and Debugged - RAS

% INPUTS:
%    Vehicle XPosition, YPosition, PsiFIlteredDegv  (repeated for g_MaxNumberVehicles)
%    Vehicle Finished (repeated for g_MaxNumberVehicles)


global g_StopTime;
global g_SampleTime;
global g_RandomTargetPosition;
global g_MaxNumberVehicles;
global g_ActiveTargets;
global g_ActiveVehicles;

global g_TruthMemory;
global g_TargetMemory;
global g_SensorTrailingEdge_ft;
persistent TargetDiscoveryTimes;
persistent TargetCount;

if(strcmp(action, 'initialize')),
    %TargetDiscoveryTimes = sort(rand(g_ActiveTargets,1)*g_StopTime);
    %TargetDiscoveryTimes = [15.0 30.0 45.0 45.0 ];
    %TargetDiscoveryTimes = [25.0 30.0 70.0 70.0 ];
    
    shft = 1/g_SampleTime; % expects it to be like 10^{-n} seconds...
    
    % poisson 
    %mean = 20;
    %mean = 10;
    mean = 2;
    toffset = 30.0; % (must be > 15s) should be a global controled offset value...
    TargetDiscoveryTimes = toffset +floor(shft*cumsum(mean*sort(rand(g_ActiveTargets,1))))/shft; 
    TargetCount = 1;
else,
    TimeStepOffset = 2*g_SampleTime;
    if((~isempty(TargetDiscoveryTimes))&(Time>=(TargetDiscoveryTimes(1) - TimeStepOffset))),
        NumberTargets = size(g_TargetMemory,1);
        if(TargetCount > NumberTargets),
            return;
        end;
        
        %% need to decode the input vector's TRUTH_VehicleState message
        msg_t = g_TruthMemory.MsgIndicies.VehicleState;
        nr = g_TruthMemory.Messages{msg_t}.NumberEntries;		
        nc = g_MaxNumberVehicles;
        input = reshape(InputVector,nr,nc);
        VehicleXYPsi = input([1 2 6],:);  % 1:X 2:Y 6:Psi (see TRUTH_VehicleState)
        VehicleFinished = input(7,:);     % 7:VehicleIsDead
        
        TimeStepOffset = 2.0*g_SampleTime;
        DiscoveryTime = -1.0;
        wasAssigned = 0;
        
        %% find eligible vehicles; NOTE: this expects the initial vehicle set 
        %% to be contiguous from 1 to g_ActiveVehicles!
        V = [];
        for( k = 1:g_ActiveVehicles ),
            if( ~VehicleFinished(k) & isSensorInKillbox(VehicleXYPsi(:,k)) ),
                V(k) = k;
            end
        end
        
        while((~isempty(TargetDiscoveryTimes))&(Time>=(TargetDiscoveryTimes(1) - TimeStepOffset))),
            %% if we're here, we have a time-based target assignment to make...
            DiscoveryTime = TargetDiscoveryTimes (1);
            TargetDiscoveryTimes = TargetDiscoveryTimes(2:end);
            
            if(~isempty(V))
                %% uniformly randomly select an eligible vehicle
                %% (account for lower [floor] bound being 0)
                l = floor(length(V)*rand) + 1;
                
                %calculate new position for target
                [g_TargetMemory(TargetCount).PositionX, ...
                        g_TargetMemory(TargetCount).PositionY ] = CalcSensorPosition(VehicleXYPsi(:,l));
                
                %% let the user know something happened
                fmt = '%.2f : %s adding T#%d to field at %.2f s for V#%d.';
                disp(sprintf(fmt, Time, mfilename, TargetCount, DiscoveryTime, l));
                
                %% remove the assigned vehicle from the eligible list
                V = setdiff(V,l);
                
                %% flag that a target was assigned
                wasAssigned = 1;
            end; % if(~isempty(V))
            
            %% check to see if we picked up an assignment, or if everyone was outta da box
            if( DiscoveryTime > 0 & ~wasAssigned )
                dt = 4*g_SampleTime;
                TargetDiscoveryTimes = [DiscoveryTime; TargetDiscoveryTimes] + dt;
                fmt='%.2f :WARNING - Unable to assign timed target(s) at %.2f s, bumped to %.2f';
                disp(sprintf(fmt, Time, TargetDiscoveryTimes(1), dt));
            else
                TargetCount = TargetCount + 1;
            end
            
            if(TargetCount > NumberTargets),
                break;
            end;
            
        end; % while((~isempty(TargetDiscoveryTimes))& ...
        
    end % if((~isempty(TargetDiscoveryTimes))& ...
    
end %if(strcmp...


function ret = isSensorInKillbox(xyp)

global g_TargetSpace;
global g_SensorTrailingEdge_ft;

[X, Y] = CalcSensorPosition(xyp);

ret = 0;
if( X >= g_TargetSpace(1) & X <= g_TargetSpace(2) & ...
        Y >= g_TargetSpace(3) & Y <= g_TargetSpace(4) )
    ret = 1;
end

return;

function [X, Y] = CalcSensorPosition( xyp )

global g_SensorLeadingEdge_ft;

l_offset = 0; % ft

H = xyp(3) * pi/180;
X = (g_SensorLeadingEdge_ft+l_offset) * cos(H) + xyp(1);
Y = (g_SensorLeadingEdge_ft+l_offset) * sin(H) + xyp(2);

return;
