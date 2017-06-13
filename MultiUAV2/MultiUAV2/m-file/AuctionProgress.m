function AuctionProgress(M)
% AuctionProgress.m
% generates a graphical display of the bids, assignments, and task prices for validation & debugging purposes
% Usage: AuctionProgress(g_CommunicationMemory.Messages{#}.Data, where # is the ID number for AuctionData Messages

% 5 SEP 03  Brandon Moore  OSU


global g_MaxNumberVehicles
global g_BiddingIncrement

NumRR=max(M(4,:));
StartRR=min(M(4,:),1);
for RR=StartRR:NumRR
    indexRR=find(M(4,:)==RR);
    N=M(:,indexRR);
    NumII=max(N(5,:));
    StartII=min(N(5,:));
    
    for II=StartII:NumII
        indexII=find(N(5,:)==II);
        Messages=N(:,indexII);
        
        IDPool=Messages([6 7 8 9 10 11 12 13],:);
        indexIDs=find(IDPool~=0);
        IDPool=IDPool(indexIDs);
        TargetIDs=[];
        while ~isempty(IDPool)
            TargetIDs=[TargetIDs, max(IDPool)];
            indexIDs=find(IDPool~=max(IDPool));
            IDPool=IDPool(indexIDs);
                 
        end
        
        
  
        
        
        
        
        
        
        
        
        TimeStamps=Messages(3,:);
        Assignments=Messages([30 31 32 33 34 35 36 37],:);
        Prices=Messages([38 39 40 41 42 43 44 45],:);
        BidTargets=Messages([6 7 8 9 10 11 12 13],:);
        BidPrices=Messages([14 15 16 17 18 19 20 21],:);
        %indexReassign=find(sum(abs(Assignment),1));
        
        
        index1=cell(1);
        index2=cell(1);
        Time=cell(1);
        Vehicle=cell(1);
        Price=cell(1);
        
        
        for k=1:length(TargetIDs)
            index2{k}=ceil(find(Assignments==TargetIDs(k))/g_MaxNumberVehicles);
            index1{k}=mod(find(Assignments==TargetIDs(k))-1,g_MaxNumberVehicles)+1;
            
            Time{k}=TimeStamps(index2{k});
            Vehicle{k}=index1{k}';
            
            if length(index1{k})==0
                Price{k}=[];
                Time{k}=[];
                Vehicle{k}=[];
            end
            
            
            for m=1:length(index1{k})
                Price{k}(m)=Prices(index1{k}(m),index2{k}(m));
            end
            
            
        end
        
        BidTime=cell(g_MaxNumberVehicles,length(TargetIDs));
        BidPrice=cell(g_MaxNumberVehicles,length(TargetIDs));
        
        for v=1:g_MaxNumberVehicles
            
            for k=1:length(TargetIDs)
                
                clear index1 
                clear index2
                
                index2=find(BidTargets(v,:)==TargetIDs(k))';
                
                
                BidTime{v,k}=TimeStamps(index2);
                
                BidPrice{v,k}=BidPrices(v,index2);
            end
            
        end
        
        
        
        
        
        
        figure(822);clf;
        for k=1:length(TargetIDs)
            subplot(2,length(TargetIDs)/2+1,k)
            hold on
            
            
            if TargetIDs(k)>0     
                T=sprintf('Target %d',TargetIDs(k));
            else
                T=sprintf('Search %d',-TargetIDs(k));
            end
            
            title(T);
            
            if ~isempty(Price{k})
                
                stairs([Time{k}';TimeStamps(end)+.1],[Price{k}';Price{k}(end)],'k:')
                stairs([Time{k}';TimeStamps(end)+.1],[Price{k}';Price{k}(end)]+g_BiddingIncrement,'k:')
                
                
                
                s=['b. ';'g. ';'k. ';'y. ';'r. ';'m. ';'c. ';'rx:'];
                
                % kTimes=[];
                % for v=1:g_MaxNumberVehicles
                %     kTimes=[kTimes,Time{v}(find(Vehicle{v}==k))];
                % end
                
                
                
                for v=1:g_MaxNumberVehicles
                    
                    hasit=find(Vehicle{k}==v);
                    
                    if ~isempty(hasit)
                        for m=1:length(hasit)
                            if hasit(m)<length(Vehicle{k})
                                NextTime=Time{k}(hasit(m)+1);  %min(Times{k}(find(Times{k>Time{k}(hasit(m)))));
                                plot([Time{k}(hasit(m)),NextTime],Price{k}(hasit(m)).*[1 1],s(v,[1 3]));
                            else
                                plot([Time{k}(hasit(m)),TimeStamps(end)+.1],Price{k}(hasit(m)).*[1 1],s(v,[1 3]));
                            end
                        end
                    end
                    
                    
                    
                    plot(BidTime{v,k},BidPrice{v,k},s(v,1:2))
                end
                limits=axis;
                axis([TimeStamps(1) TimeStamps(end)+.1 limits(3:4)]);
            end
        end
        
        
        subplot(2,length(TargetIDs)/2+1,k+1:k+2);
        hold on;axis off
        T=sprintf('Round %d %d',RR,II);
        title(T);
        for v=1:g_MaxNumberVehicles
            plot([0 0],[0 0],s(v,:))
        end
        legend(num2str([1:g_MaxNumberVehicles]'),0)
        
        
        pause
    end %II
    
end %RR


return