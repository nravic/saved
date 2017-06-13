function Output=DAINF_Auction(VehicleID,CurrentTime);
% AFRL/VACA  & Ohio State University
% Brandon Moore 25 AUG 03

% note: Target assignment of -1 denotes assignment to search

global g_MaxNumberTargets
global g_MaxNumberVehicles
global g_VehicleMemory
global g_BiddingIncrement
global g_AssignToSearchMethod
global g_AssignmentTypes
global g_TargetStates

%load from vehicle memory
AuctInfo=g_VehicleMemory(VehicleID).CooperationManager.AuctionInformation;
ReplanRound=g_VehicleMemory(VehicleID).CooperationManager.ReplanRound;
AuctioneerDuty=g_VehicleMemory(VehicleID).CooperationManager.AuctioneerDuty;
CurrentBenefits=g_VehicleMemory(VehicleID).CooperationManager.CurrentBenefits;
Message=g_VehicleMemory(VehicleID).CooperationManager.MessageNumber;



% output defaults;
BidTarget=zeros(1,g_MaxNumberVehicles);
BidPrice=zeros(1,g_MaxNumberVehicles);
BidTargetETA=zeros(1,g_MaxNumberVehicles);
AssignedTarget=zeros(1,g_MaxNumberVehicles);
AssignedPrice=zeros(1,g_MaxNumberVehicles);
AssignedTargetETA=zeros(1,g_MaxNumberVehicles);
MessageNumber=Message;


% make a vector of target prices indexed by target (instead of current vehicle assigned)
indexVehicles=find(AuctInfo.VehiclesTarget>0); % vehicles w/ targets
indexTargets=AuctInfo.VehiclesTarget(indexVehicles); % targets assigned
PricesByTarget=zeros(1,g_MaxNumberTargets);
PricesByTarget(indexTargets)=AuctInfo.TargetPrice(indexVehicles);

% some things to prep if doing a symmetric assignment problem
if g_AssignToSearchMethod==g_AssignmentTypes.Common
    
    % set initial prices of target tasks to a guess of the likely final prices
    % WARNING! this is based on how benefits are calculated as of SEP 2003 and will probably  not work well (or at all) if that changes
    for indexTarget=1:g_MaxNumberTargets
        TaskToDo=CurrentBenefits.TargetStatus(indexTarget);
        if TaskToDo~=0 & PricesByTarget(indexTarget)==0
            switch TaskToDo
            case g_TargetStates.StateDetectedNotClassified
                PricesByTarget(indexTarget)=9800-5000; %maximum classify benefit minus search benefit
            case g_TargetStates.StateClassifiedNotAttacked
                PricesByTarget(indexTarget)=7200-5000; %maximum attack benefit minus search benefit
            case g_TargetStates.StateKilledNotConfirmed
                PricesByTarget(indexTarget)=6800-5000; %maximum verify benefit minus search benefit
            end
        end
    end
    
    
    % make a vector of search task contention thresholds
    indexVehicles=find(AuctInfo.VehiclesTarget<0); % vehicles w/ search tasks
    SearchsAssigned=-AuctInfo.VehiclesTarget(indexVehicles); % searchs assigned so far
    ContentionThresholdsBySearch=zeros(1,g_MaxNumberVehicles);
    ContentionThresholdsBySearch(SearchsAssigned)=AuctInfo.TargetPrice(indexVehicles);
    
    % for searchs not yet assigned (i.e. with price zero) make sure vehicles know which one for which they have auctioneer duty
    NumberTargets=length(find(CurrentBenefits.TargetStatus>=g_TargetStates.StateDetectedNotClassified & CurrentBenefits.TargetStatus<=g_TargetStates.StateKilledNotConfirmed));
    NumberVehicles=length(find(AuctInfo.ActiveVehicles~=0));
    NumberSearchs=NumberVehicles-NumberTargets;
    InitialSearchDuty=find(VehicleID==find(AuctInfo.ActiveVehicles~=0));  % search task vehicle will be first auctioneer for (if necessary)
    
    if InitialSearchDuty<=NumberSearchs & ContentionThresholdsBySearch(InitialSearchDuty)==0
        if isempty(AuctioneerDuty)
            CheckDuty=[];
        else
            CheckDuty=find(AuctioneerDuty== -InitialSearchDuty);
        end
        
        if isempty(CheckDuty)
            AuctioneerDuty=[AuctioneerDuty, -InitialSearchDuty];
        end
    else         
        AuctioneerDuty=AuctioneerDuty(find(AuctioneerDuty>0));  % clear old search tasks from auctioneer duty
    end        
        
end


% check this vehicle's assignment
AssignmentTarget=AuctInfo.VehiclesTarget(VehicleID);

% make sure it knows it has to act as auctioneer for it's current target -- REDUNDANT
if (g_AssignToSearchMethod==g_AssignmentTypes.Common & AssignmentTarget~=0) | (g_AssignToSearchMethod==g_AssignmentTypes.Individual & AssignmentTarget>0)
    if isempty(AuctioneerDuty)
        CheckDuty=[];
    else
        CheckDuty=find(AuctioneerDuty==AssignmentTarget);
    end
    
    if isempty(CheckDuty)
        AuctioneerDuty=[AuctioneerDuty,AssignmentTarget];
    end
end

% check to see if this vehicle is acting as auctioneer for a target he's not supposed to (shouldn't happen)
for indexDuty=1:length(AuctioneerDuty)
    CheckOthers=find(AuctInfo.VehiclesTarget([1:VehicleID-1,VehicleID+1:end])==AuctioneerDuty(indexDuty));
    if ~isempty(CheckOthers)
        error('wrong auctioneer!');
    end
end


% if currently unassigned and w/o pending bid...
LastBidTarget=AuctInfo.VehiclesLastBidTarget(VehicleID);
LastBid=AuctInfo.VehiclesLastBid(VehicleID);

if AssignmentTarget==0  
    if LastBid==0   % never bid before - bid now
        BidFlag=1;                
    else
        if LastBidTarget>0
            if LastBid>=PricesByTarget(LastBidTarget)+g_BiddingIncrement;
                BidFlag=0;   % vehicle has bid out it thinks should win - don't bid
            else
                BidFlag=1;   % price of target last bid on increased past this vehicle bid - bid now
            end
        else %LastBidTarget<1
            if LastBid>=ContentionThresholdsBySearch(-LastBidTarget)+g_BiddingIncrement;
                BidFlag=0;   % vehicle has bid out it thinks should win - don't bid
            else
                BidFlag=1;   % price of target last bid on increased past this vehicle bid - bid now
            end
        end
    end
else
    %look ahead to see if current assignment will be bid away
    VehicleMask=ones(1,g_MaxNumberVehicles);VehicleMask(VehicleID)=0;
    BiddersForCurrentAssignment=find(VehicleMask.*AuctInfo.VehiclesLastBidTarget==AssignmentTarget);
    if isempty(BiddersForCurrentAssignment)
        BidFlag=0;   % have an assignment and no one else wants it - don't bid
    else
        HostileBids=AuctInfo.VehiclesLastBid(BiddersForCurrentAssignment);
        
        if max(HostileBids)<AuctInfo.TargetPrice(VehicleID)+g_BiddingIncrement
            BidFlag=0; % have an assignment and no one can take it away this round - don't bid
        else
            BidFlag=2; % vehicle's going to lose its assignment - update that task's price and then be free to bid
                        
            if g_AssignToSearchMethod==g_AssignmentTypes.Common & AssignmentTarget<0
                ContentionThresholdsBySearch(-AssignmentTarget)=max(HostileBids);
            else
                PricesByTarget(AssignmentTarget)=max(HostileBids);
            end
        end
    end   
    
end



if BidFlag
    
    % ... then find the best value target and post a bid
    ActiveTargets=find(CurrentBenefits.TargetStatus~=0);    
    
    TargetBenefits=CurrentBenefits.TaskBenefits(ActiveTargets);
    TargetETAs=CurrentBenefits.TimeToComplete;
    SearchBenefit=CurrentBenefits.SearchBenefit;
    
    TargetValues=TargetBenefits-PricesByTarget(ActiveTargets);
    [BestValue,indexDesiredTarget]=max(TargetValues);
    DesiredTarget=ActiveTargets(indexDesiredTarget);   
    
    if g_AssignToSearchMethod==g_AssignmentTypes.Common
        
        %find best search value & search task number
        SearchValues=SearchBenefit-ContentionThresholdsBySearch(1:NumberSearchs);
        [BestSearchValue]=max(SearchValues);
        BestSearches=find(SearchValues==BestSearchValue);
        % pick a random search task from the ones that give the best value
        % unless one or more of those is what vehicle is currently auctioneer for
        % (then pick the one from that with the lowest contention threshold)
        DesiredSearch=BestSearches(ceil(rand*length(BestSearches))); 
        for index=1:length(AuctioneerDuty)
            if sum(-AuctioneerDuty(index)==BestSearches)~=0
                DesiredSearch=-AuctioneerDuty(index);
            end
        end
        
        
        
        if BestValue>=BestSearchValue
            NextBestValue=max([TargetValues(1:indexDesiredTarget-1),TargetValues(indexDesiredTarget+1:end),BestSearchValue]);
            BidTarget(VehicleID)=DesiredTarget;
            BidPrice(VehicleID)=PricesByTarget(DesiredTarget)+(BestValue-NextBestValue)+g_BiddingIncrement;
            BidTargetETA(VehicleID)=TargetETAs(DesiredTarget);
        else
            NextBestValue=BestValue; %best value outside of similarity class (i.e. non-search tasks)
            BidTarget(VehicleID)=-DesiredSearch;
            BidPrice(VehicleID)=ContentionThresholdsBySearch(DesiredSearch)+(BestSearchValue-NextBestValue)+g_BiddingIncrement;   
            BidTargetETA(VehicleID)=0;                                   % no other vehicle will bid for this vehicle's search task

        end
        
        
        
    elseif g_AssignToSearchMethod==g_AssignmentTypes.Individual
        
        if SearchBenefit>BestValue          % search is best value, vehicle won't bid anymore  
            BidTarget(VehicleID)=-1;
            BidPrice(VehicleID)=g_BiddingIncrement;     % not actual bid calculation, but it doesn't matter since
            BidTargetETA(VehicleID)=0;                                   % no other vehicle will bid for this vehicle's search task
        else
            NextBestValue=max([TargetValues(1:DesiredTarget-1),TargetValues(DesiredTarget+1:end),SearchBenefit]);
            BidTarget(VehicleID)=DesiredTarget;
            BidPrice(VehicleID)=PricesByTarget(DesiredTarget)+(BestValue-NextBestValue)+g_BiddingIncrement;
            BidTargetETA(VehicleID)=TargetETAs(DesiredTarget);
        end
        
    else
        error('Assignment problem type not defined in DAINF_Auction.m');
    end
    
    % store this vehicles bid in AuctInfo so it can be included in the assignment phase
    AuctInfo.VehiclesLastBidTarget(VehicleID)=BidTarget(VehicleID);
    AuctInfo.VehiclesLastBid(VehicleID)=BidPrice(VehicleID);
    AuctInfo.LastBidETA(VehicleID)=BidTargetETA(VehicleID);
    
    
end % calculate bid


% if vehicle did a look ahead bid, reset the price of its current assignment
if BidFlag==2
    if g_AssignToSearchMethod==g_AssignmentTypes.Common & AssignmentTarget<0
        ContentionThresholdsBySearch(-AssignmentTarget)=AuctInfo.TargetPrice(VehicleID);
    else
        PricesByTarget(AssignmentTarget)=AuctInfo.TargetPrice(VehicleID);
    end
end
     

% check for any pending bids on targets for which this vehicle is currently assigned as auctioneer 
for indexDuty=1:length(AuctioneerDuty)
    
    Target=AuctioneerDuty(indexDuty);
    
    if g_AssignToSearchMethod==g_AssignmentTypes.Common & Target<0
        Price=ContentionThresholdsBySearch(-Target);
    else
        Price=PricesByTarget(Target);
    end
        
    indexVehicle=find(AuctInfo.VehiclesLastBidTarget==Target);  % vehicles bidding on current target under auction
  
    
    if ~isempty(indexVehicle)
        [MaxBid,indexWinningVehicle]=max(AuctInfo.VehiclesLastBid(indexVehicle));
        WinningVehicle=indexVehicle(indexWinningVehicle);
        
        % we have a winner...
        if MaxBid>=Price+g_BiddingIncrement
            
            % report new assignment
            AssignedTarget(WinningVehicle)=Target;
            AssignedPrice(WinningVehicle)=MaxBid;
            AssignedTargetETA(WinningVehicle)=AuctInfo.LastBidETA(WinningVehicle);
            
%             if Target>0
%                 disp(sprintf('%.2f <<AUCTION>> Vehicle-%d wins Target-%d @ Price %.1f',...
%                     CurrentTime,WinningVehicle,Target,MaxBid));
%             elseif Target<0
%                 disp(sprintf('%.2f <<AUCTION>> Vehicle-%d wins Search-%d @ Price %.1f',...
%                     CurrentTime,WinningVehicle,-Target,MaxBid));
%             end
            
            
            % make note to give up auctioneer duty for that target
            % (only if this vehicle wasn't the winner!)
            if WinningVehicle~=VehicleID 
                AuctioneerDuty(indexDuty)=0;
            end
        end
    end
end
% give up auctioneer duty for released targets
AuctioneerDuty=AuctioneerDuty(find(AuctioneerDuty));
g_VehicleMemory(VehicleID).CooperationManager.AuctioneerDuty=AuctioneerDuty;

% report assignment if this vehicle bid for its search task
if g_AssignToSearchMethod==g_AssignmentTypes.Individual & BidTarget(VehicleID)==-1
    AssignedTarget(VehicleID)=BidTarget(VehicleID);
    AssignedPrice(VehicleID)=BidPrice(VehicleID);
    AssignedTargetETA(VehicleID)=BidTargetETA(VehicleID);
end


% increment message number if we made any bids or assignments
if sum(abs([BidTarget,BidPrice,BidTargetETA,AssignedTarget,AssignedPrice,AssignedTargetETA]))
    MessageNumber=Message+1;
    g_VehicleMemory(VehicleID).CooperationManager.MessageNumber=MessageNumber;
end


Output=[ReplanRound,BidTarget,BidPrice,BidTargetETA,AssignedTarget,AssignedPrice,AssignedTargetETA,MessageNumber]; 

return