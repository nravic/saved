function [Output] = DAINF_MessageControl(Input,CurrentTime)
%  DAINF_MessageControl.m
%  Processes distributed auction messages for Iterated Network Flow routine
%  and maintains g_g_VehicleMemory.CooperationManager.AuctionInformation  
%
%  AFRL/VACA
%  Brandon Moore 20 AUG 03

global g_Debug; if(g_Debug==1),disp('DAINF_MessageControl.m');end; 

global g_MaxNumberVehicles;
global g_MaxNumberTargets;
global g_VehicleMemory;
global g_CommunicationMemory
global g_AssignToSearchMethod
global g_AssignmentTypes

if CurrentTime>35.7
    CurrentTime;
end



% define some indexs
AM_Fields = g_CommunicationMemory.Messages{g_CommunicationMemory.MsgIndicies.AuctionData};
LengthAM=AM_Fields.NumberEntries;
indexAM_Round=AM_Fields.ReplanRound;
indexAM_Time=AM_Fields.TimeStamp;
indexAM_BidT=AM_Fields.BidTarget;
indexAM_BidP=AM_Fields.BidPrice;
indexAM_BidE=AM_Fields.BidTargetETA;
indexAM_AssignT=AM_Fields.AssignedTarget;
indexAM_AssignP=AM_Fields.AssignedPrice;
indexAM_AssignE=AM_Fields.AssignedTargetETA;





% process input vector
index=1;

step=1;
VehicleID=Input(index:index+step-1);        % Vehicle Number
index=index+step;

step=g_MaxNumberVehicles;
ActiveVehicles=Input(index:index+step-1);   % Active Vehicles
index=index+step;


step=g_MaxNumberVehicles*LengthAM;
AuctionMessages=reshape(Input(index:index+step-1),LengthAM,g_MaxNumberVehicles);  % Latest Auction Messages
index=index+step;

step=1;
ReplanTrigger=Input(index:index+step-1);    % Replan Trigger
index=index+step;


% load some variables from vehicle memory
MyReplanRound=g_VehicleMemory(VehicleID).CooperationManager.ReplanRound;
AuctInfo=g_VehicleMemory(VehicleID).CooperationManager.AuctionInformation;
AuctioneerDuty=g_VehicleMemory(VehicleID).CooperationManager.AuctioneerDuty;

% default output values
NewBid=0;
NewAssignment=0;
RoundComplete=0;
Output=[NewBid;NewAssignment;RoundComplete];

% break up messages
ReplanRounds=AuctionMessages(indexAM_Round,:);
TimeStamps=AuctionMessages(indexAM_Time,:);
BidTargets=AuctionMessages(indexAM_BidT,:);
BidPrices=AuctionMessages(indexAM_BidP,:);
BidETAs=AuctionMessages(indexAM_BidE,:);
AssignedTargets=AuctionMessages(indexAM_AssignT,:);
AssignedPrices=AuctionMessages(indexAM_AssignP,:);
AssignedETAs=AuctionMessages(indexAM_AssignE,:);


% replan actions
if ReplanTrigger~=0
    % clear plan & auction info
    g_VehicleMemory(VehicleID).CooperationManager.AuctionInformation=CreateStructure('AuctionInformation');
    g_VehicleMemory(VehicleID).CooperationManager.TargetSchedule=zeros(g_MaxNumberTargets,3);
    
    % store ActiveVehicles vector
    g_VehicleMemory(VehicleID).CooperationManager.AuctionInformation.ActiveVehicles=ActiveVehicles';
    
    % see if vehicle was supposed to take responsibility for a target
    for indexVehicle=1:g_MaxNumberVehicles
        if ReplanRounds(1,indexVehicle)<=MyReplanRound(1) & AssignedTargets(VehicleID,indexVehicle)>0
            LastAssignment=find(AuctInfo.VehiclesTarget==AssignedTargets(VehicleID,indexVehicle));
            if ~isempty(LastAssignment) & TimeStamps(indexVehicle)>AuctInfo.AssignmentTime(LastAssignment)
                if isempty(find(AuctioneerDuty==AssignedTargets(VehicleID,indexVehicle)))
                    AuctioneerDuty=[AuctioneerDuty,AssignedTargets(VehicleID,indexVehicle)];
                end
            else %no one had it before, no need to check time stamps
				if(isempty(AuctioneerDuty)),
					AuctioneerDuty=[AssignedTargets(VehicleID,indexVehicle)];
				elseif isempty(find(AuctioneerDuty==AssignedTargets(VehicleID,indexVehicle)))
                    AuctioneerDuty=[AuctioneerDuty,AssignedTargets(VehicleID,indexVehicle)];
                end
            end
        end
    end
    g_VehicleMemory(VehicleID).CooperationManager.AuctioneerDuty=AuctioneerDuty;
    
    return;
end % ReplanTrigger


% START -- Process New Auction Messages



% if someone else is doing a replan, do nothing (except auctioneer duty changes) until I get the ReplanTrigger as well
% TODO: fix this and the rest of the code so that I can handle getting messages for a ReplanRound I havn't 
%       gotten a trigger for yet(yucky), or I could just have auctioneers retransmit prices if they get bad bids...
if sum(ReplanRounds(1,:) > MyReplanRound(1))~=0
    for indexVehicle=1:g_MaxNumberVehicles
        if ReplanRounds(1,indexVehicle)<=MyReplanRound(1) & AssignedTargets(VehicleID,indexVehicle)>0
            LastAssignment=find(AuctInfo.VehiclesTarget==AssignedTargets(VehicleID,indexVehicle));
            if ~isempty(LastAssignment) & TimeStamps(indexVehicle)>AuctInfo.AssignmentTime(LastAssignment)
                if isempty(find(AuctioneerDuty==AssignedTargets(VehicleID,indexVehicle)))
                    AuctioneerDuty=[AuctioneerDuty,AssignedTargets(VehicleID,indexVehicle)];
                end
            end
        end
    end
    
    return; 
end 

% someone else knows the round is over and this is the first I've heard of it
if (sum(ReplanRounds(2,:) > MyReplanRound(2)) & ~sum(ReplanRounds(1,:)~=MyReplanRound(1)))...
        & ~(sum(AuctInfo.PreviousRoundVehiclesTarget~=0))

    % save assignment info for this round (the only thing I should be waiting on for this round)
    % then clear assignments and bids so I can start processing messages for the next round 
    NewAuctInfo=CreateStructure('AuctionInformation');
    NewAuctInfo.PreviousRoundVehiclesTarget=AuctInfo.VehiclesTarget;
    NewAuctInfo.PreviousRoundTargetPrice=AuctInfo.TargetPrice;
    NewAuctInfo.PreviousRoundAssignmentTime=AuctInfo.AssignmentTime;
    NewAuctInfo.PreviousRoundAssignmentETA=AuctInfo.AssignmentETA;
    
    AuctInfo=NewAuctInfo;
    
    CurrentRound=MyReplanRound(2)+1;    % for use later
else
    CurrentRound=MyReplanRound(2);      % for use later
end


% store new bids for the current round
for indexVehicle=1:g_MaxNumberVehicles
    if ReplanRounds(2,indexVehicle)==CurrentRound & ReplanRounds(1,indexVehicle)==MyReplanRound(1);
        
        indexBidMsg=find(BidPrices(:,indexVehicle)~=0);   
        
        for indexBid=1:length(indexBidMsg)
            
            CurrentBidder=indexBidMsg(indexBid);
            CurrentTarget=BidTargets(CurrentBidder,indexVehicle);
            CurrentBid=BidPrices(CurrentBidder,indexVehicle);
            CurrentBidETA=BidETAs(CurrentBidder,indexVehicle);
            
            if  TimeStamps(indexVehicle)>AuctInfo.LastBidTime(CurrentBidder)
               
                AuctInfo.VehiclesLastBid(CurrentBidder)=CurrentBid;
                AuctInfo.VehiclesLastBidTarget(CurrentBidder)=CurrentTarget;
                AuctInfo.LastBidETA(CurrentBidder)=CurrentBidETA;
                AuctInfo.LastBidTime(CurrentBidder)=TimeStamps(indexVehicle);
                
                NewBid=1;
            end            
            
        end %for:indexBid
    end %if:CurrentRound
end %for:indexVehicle



% store assignments for previous round if necessary
if CurrentRound>MyReplanRound(2)
    
    indexLastRoundMsgs=find(ReplanRounds(2,:)==MyReplanRound(2) & ReplanRounds(1,:)==MyReplanRound(1));  % IDs of vehicles sending messages for the last round
    
    for indexVehicle=1:length(indexLastRoundMsgs)   % cycle through those messages
        
        indexAssignMsg=find(AssignedPrices(:,indexVehicle)~=0);  % IDs of vehicles being assigned
        
        for indexAssignment=1:length(indexAssignMsg) % cycle through those assignments
            
            CurrentAssignment=indexAssignMsg(indexAssignment);                  % vehicle ID
            CurrentTarget=AssignedTargets(CurrentAssignment,indexVehicle);      % assigned Target
            CurrentPrice=AssignedPrices(CurrentAssignment,indexVehicle);        % new price
            CurrentETA=AssignedETAs(CurrentAssignment,indexVehicle);            % target ETA
            
            % find last vehicle assigned to this target if any
            LastAssignment=find(AuctInfo.PreviousRoundVehiclesTarget==CurrentTarget);
            TimeLastAssigned=AuctInfo.PreviousRoundAssignmentTime(LastAssignment);
            
            % only change assignment if last assignment message is outdated
            if  TimeStamps(indexVehicle)>TimeLastAssigned
                
                AuctInfo.PreviousRoundVehiclesTarget(CurrentAssignment)=CurrentTarget;
                AuctInfo.PreviousRoundTargetPrice(CurrentAssignment)=CurrentPrice;
                AuctInfo.PreviousRoundAssignmentETA(CurrentAssignment)=CurrentETA;
                AuctInfo.PreviousRoundAssignmentTime(CurrentAssignment)=TimeStamps(indexVehicle);                       
                
                NewAssignment=1;
                
                % clear old assignment
                
                AuctInfo.PreviousRoundVehiclesTarget(LastAssignment)=0;
                AuctInfo.PreviousRoundTargetPrice(LastAssignment)=0;
                AuctInfo.PreviousRoundAssignmentETA(LastAssignment)=0;
                AuctInfo.PreviousRoundAssignmentTime(LastAssignment)=0;    
                
            end                    
        end %for:indexAssignment
    end %for:indexVehicle
end %if:CurrentRound>MyReplanRound


if CurrentTime>60
    
    
    CurrentTime;
end



% store assignments for current round
indexThisRoundMsgs=find(ReplanRounds(2,:)==CurrentRound & ReplanRounds(1,:)==MyReplanRound(1));

for indexVehicle=1:length(indexThisRoundMsgs)
    
    indexAssignMsg=find(AssignedTargets(:,indexThisRoundMsgs(indexVehicle))~=0);
    
    for indexAssignment=1:length(indexAssignMsg)
        
        CurrentAssignment=indexAssignMsg(indexAssignment);
        CurrentTarget=AssignedTargets(CurrentAssignment,indexThisRoundMsgs(indexVehicle));
        CurrentPrice=AssignedPrices(CurrentAssignment,indexThisRoundMsgs(indexVehicle));
        CurrentETA=AssignedETAs(CurrentAssignment,indexThisRoundMsgs(indexVehicle));
        
        % find last vehicle assigned to this target if any
        if g_AssignToSearchMethod==g_AssignmentTypes.Individual & CurrentTarget==-1
            LastAssignment=[];
        else
            LastAssignment=find(AuctInfo.VehiclesTarget==CurrentTarget);
            
        end
        
        
        if isempty(LastAssignment)
            TimeLastAssigned=0;
        else
            TimeLastAssigned=AuctInfo.AssignmentTime(LastAssignment);
        end
        
        % only change assignment if last assignment message is outdated
        if  TimeStamps(indexVehicle)>TimeLastAssigned
            
            AuctInfo.VehiclesTarget(CurrentAssignment)=CurrentTarget;
            AuctInfo.TargetPrice(CurrentAssignment)=CurrentPrice;
            AuctInfo.AssignmentETA(CurrentAssignment)=CurrentETA;
            AuctInfo.AssignmentTime(CurrentAssignment)=TimeStamps(indexVehicle);                       
            
            %add to vehicle's auctioneer duty if assignment is for it
            if CurrentAssignment==VehicleID
                if (g_AssignToSearchMethod==g_AssignmentTypes.Common & CurrentTarget~=0) | (g_AssignToSearchMethod==g_AssignmentTypes.Individual & CurrentTarget>0)
                    if isempty(AuctioneerDuty)
                        CheckDuty=[];
                    else
                        CheckDuty=find(AuctioneerDuty==CurrentTarget);
                    end
                    
                    if isempty(CheckDuty)
                        AuctioneerDuty=[AuctioneerDuty,CurrentTarget];
                    end
                end
            end
            
            NewAssignment=1;
            
            % clear old assignment (unless it was for this vehicles)
            if ~isempty(LastAssignment)
                if LastAssignment~=CurrentAssignment
                    AuctInfo.VehiclesTarget(LastAssignment)=0;
                    AuctInfo.TargetPrice(LastAssignment)=0;
                    AuctInfo.AssignmentETA(LastAssignment)=0;
                    AuctInfo.AssignmentTime(LastAssignment)=0;    
                end
            end
        end
        
    end %for:indexAssignment
end %for:indexVehicle

%check old messages from previous replan phases (i.e. replan triggered events) 
%to see if vehicle was supposed to take responsibility for a target
for indexVehicle=1:g_MaxNumberVehicles
    if ReplanRounds(1,indexVehicle)<MyReplanRound(1) & AssignedTargets(VehicleID,indexVehicle)>0
        LastAssignment=find(AuctInfo.VehiclesTarget==AssignedTargets(VehicleID,indexVehicle));
        if ~isempty(LastAssignment) & TimeStamps(indexVehicle)>AuctInfo.AssignmentTime(LastAssignment)
            if isempty(find(AuctioneerDuty==AssignedTargets(VehicleID,indexVehicle)))
                AuctioneerDuty=[AuctioneerDuty,AssignedTargets(VehicleID,indexVehicle)];
            end
        end
    end
end

% END -- Process New Auction Messages


% check to see if a round is complete
ActiveIDs=find(ActiveVehicles==1);

if CurrentRound>MyReplanRound(2)
    if sum(AuctInfo.PreviousRoundVehiclesTarget(ActiveIDs)==0)==0
        RoundComplete=1;
    end
else
    if sum(AuctInfo.VehiclesTarget(ActiveIDs)==0)==0
        RoundComplete=1;
    end
end


% store new information in g_VehicleMemory
g_VehicleMemory(VehicleID).CooperationManager.AuctionInformation=AuctInfo;
g_VehicleMemory(VehicleID).CooperationManager.AuctioneerDuty=AuctioneerDuty;

% output flags
Output=[NewBid;NewAssignment;RoundComplete];

return  % that's all folks...