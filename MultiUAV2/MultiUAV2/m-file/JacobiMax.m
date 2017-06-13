function Assignment = JacobiMax(CostMatrix,NumberOfVehicles,NumberOfTargets)


global g_Debug; if(g_Debug==1),disp('JacobiMax.m');end; 
global g_MonteCarloMetrics;

g_MonteCarloMetrics.NumberAuctionCalls = g_MonteCarloMetrics.NumberAuctionCalls + 1;

UnsignedPersons = 1:1:NumberOfVehicles; 
Mate = zeros(1,NumberOfTargets);
Price = Mate;
Epsilon = 1/(NumberOfVehicles+1);

% Forward iteration and initial assignment
TotalNumberAuctionBids = 0;
while ~isempty(UnsignedPersons)
	TotalNumberAuctionBids = TotalNumberAuctionBids + 1;
   AssignedObjects = [];
   Bids = [];
   for FirstLoop = 1:length(UnsignedPersons);
      Person = UnsignedPersons(FirstLoop);
      size(CostMatrix);
      s = CostMatrix(Person,:)-Price;
      [BestCost,BestObject] = max(s);
      s(BestObject) = [];
      [NextCost,k2] = max(s);
      if((~isempty(AssignedObjects))&(~isempty(BestObject)))
        a = find(AssignedObjects == BestObject);
      else,
          a=[];
      end;
      if isempty(a) 
         AssignedObjects = [AssignedObjects BestObject];
      end
      Bids(Person,BestObject) = BestCost-NextCost+Epsilon;
   end
   
   for SecondLoop = 1:length(AssignedObjects)
      j = AssignedObjects(SecondLoop);
      [BestBid,iStar] = max(Bids(:,j));
      Price(j) = Price(j) + BestBid;
      if Mate(j) ~= 0
         UnsignedPersons = [UnsignedPersons Mate(j)];
         d = find(Mate == iStar);
         Mate(d) = 0;
         d = find(UnsignedPersons == iStar);
         UnsignedPersons(d) = [];
      else
         d=find(UnsignedPersons == iStar);
         UnsignedPersons(d) = [];
      end
      Mate(j) = iStar;
   end
end

g_MonteCarloMetrics.TotalNumberAuctionBids = [g_MonteCarloMetrics.TotalNumberAuctionBids;TotalNumberAuctionBids];


if 0
   % Check the prices of all unassigned objects to see if they are all lower
   % than the minimum price among the assigned objects. If not, then execute
   % the reverse auction to obtain optimality.
   UnsignedObjects = find(Mate == 0);
   AssignedObjects = find(Mate);
   Lambda = min(nonzeros(Price));
   Price(UnsignedObjects)=2*Lambda;
   Profits = [];
   for i = 1:length(AssignedObjects)
      Person = Mate(AssignedObjects(i));
      Profits(Person) = CostMatrix(Person,AssignedObjects(i))-Price(AssignedObjects(i));
   end
   t= 0;
   while max(Price(UnsignedObjects)) > Lambda
      for i = 1:length(UnsignedObjects)
         Object = UnsignedObjects(i);
         s = CostMatrix(:,Object)-Profits';
         [BestValue,BestPerson] = max(s);
         if length(UnsignedObjects) > 1
            s(BestPerson) = [];
            [NextBest,NextPerson] = max(s);
         else
            NextBest = -inf;
         end
         if Lambda >= BestValue-Epsilon
            Price(Object) = Lambda;
         else
            Delta = min([BestValue-Lambda BestValue-NextBest+Epsilon]);
            Price(Object) = BestValue - Delta;
            Profits(BestPerson) = Profits(BestPerson) + Delta;
            Index = find(Mate == BestPerson);
            Mate(Index) = 0;
            Mate(Object) = BestPerson;
         end
      end
      UnsignedObjects = find(Mate == 0);
      t=t+1;
   end
end

% Decode Mate Vector into Assignment
for p = 1:length(Mate)
   if Mate(p) == 0
   else
      Assignment(Mate(p)) = p;
   end
end
