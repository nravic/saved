% Three part sequential auction. First consider the assignment to 
% classify all non-classified targets. Then consider the 
% the assignment to attack all non-attacked targets. Then
% consider the assignment to BDA all non-BDAed targets.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Added 2 / 8 / 02 
%
% Previously, execution of this code proceeded as described by the above paragraph.  The modifications made here 
% are as follows:
%
% 1. For each execution of the main loop, benefits are calculated for each vehicle to service each target.  A total benefit
% matrix is computed by adding all of the benefits from classifying the required targets, attacking the targets that need 
% attacked, and performing BDA on previously attacked targets.  This total benefits matrix is introduced into the Jacobi 
% auction algorithm upon which a best assignment (smallest ETA) is selected and "frozen".  This assignment uses one vehicle
% to service one target - this vehicle's position is updated and this target's state is updated.  
% The main loop finishes one run and begins execution again, upon which, the same process is repeated.  
%
% 2. Two modifications were made in GetBenefits.m.  The first involves sizing the TaskValue matrix.  Previously, the following
% command was used (check around line 20 of GetBenefits.m):  TaskValue = zeros(size(TargetSchedule));  In this case, 
% TaskValue turned out to be a NumberOfTasks by NumberOfVehicles matrix.  This caused sporadic execution crashes.  
% To eliminate this problem, the following command is now used: TaskValue = zeros(NumberOfVehicles,NumTargets);.  
% The second modification comes at the bottom of GetBenefits.m.  Before, the following three lines of code were used:
%
% Index = find(TaskValue);
% TaskValue(Index) = TaskValue(Index)-MinValue;
% Scale = (ScaleFactor-1)/(MaxValue - MinValue);
% TaskValue(Index) = round(TaskValue(Index)*Scale+1);
%
% This did not take into account the case when TaskValue was a matrix of all zeros.  Again, execution crashes would result.  To
% eliminate this problem, the following six lines of code are used:  Note - the only additions are the first and last lines.
% if (~isempty(Index))
% Index = find(TaskValue);
% TaskValue(Index) = TaskValue(Index)-MinValue;
% Scale = (ScaleFactor-1)/(MaxValue - MinValue);
% TaskValue(Index) = round(TaskValue(Index)*Scale+1);
% end
%
% 3. Added a cell array called CellWayPointsTotal in MultiAssign.m.  The waypoints are calculated during the calls to GetBenefits.m.
% WayPoints for each task are stored in CellWayPointsTotal.  Then, after selecting a particular assignment, the corresponding
% waypoints are extracted from CellWayPointsTotal and are stored in another cell array called VehicleWayPoints.
%
% 4. Added switch to select between the Jacobi auction algorithm and the capacitative transshipment algorithm.
%
% 5. Added Capacitative TransShipment Algorithm
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Note : This code is not optimized in at least one way.  First, consider calculation of the benefits matrix.  Pictorially, the 
% benefits matrix is (Vi = ith vehicle, Ti = ith target) :
%
%       T1  T2  ... Tm              Say, for instance, that an assignment is made where Vehicle 2 (V2) is going to service target
%   V1  B11 B12     B1m             1 (T1).  In this case, benefit B21 is used.  When the main loop executes the next iteration,
%   V2  B21 B22 ... B2m             all benefits are currently calculated.  This is not necessary.  The only altered items after the
%   .   .   .                       first iteration are the position of V2 and the state of T1.  Hence, only the benefits 
%   .   .   .                       corresponding to the V2 row (Row 2) and the T1 column (Column 1) need be calculated.  The other
%   .   .   .                       benefits have not changed.  
%   Vn  Bn1 Bn2 ... Bnm
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Problem definition and variable initialization (temporary)
%clear all
%close all
%clc
% default output format
format long e

% add the library path to the current path
%path('..\',path);
%path('..\MultiUAVDLLs',path);

% intialize global variables
InitializeGlobals;

global g_TypeAssignment;

%initialize simulation functions
SimulationFunctions('InitializeSimulation');

PathColors = (.8/.6)*[0.6 0.0 0.0;0.0 0.6 0.0;0.0 0.0 0.6;0.6 0.6 0.;0.0 0.6 0.6;0.6 0.0 0.6;0.6 0.6 0.6;0.3 0.3 0.3];

Vehicles = [0 0 90 1;-1000 -2000 90 2;-2000 -4000 90 3;-3000 -6000 90 4;-4000 -8000 90 5;-5000 -10000 90 6;-6000 -12000 90 7;-7000 -14000 90 8];
%Vehicles = [0 0 90 1;-1000 -2000 90 2;-2000 -4000 90 3;-6000 -12000 90 7;-7000 -14000 90 8];
Vehicles(:,3) = Vehicles(:,3)*pi/180; %change headings to degrees
NumberOfVehicles = size(Vehicles,1);

%Targets =[1000 1000 0 10;5000 6000 0 1;3000 -2000 0 5;3000 -1500 0 8;-5000 -14000 0 6];
Targets =[10000 7000 0 1;10000 5000 0 1];
TargetState = [1 1 1 3 1 1 1];
TargetState = TargetState(1:size(Targets,1));
NumberOfTargets = length(TargetState);

% Switch to select between algorithms
AlgorithmType = g_TypeAssignment.ItCapTransShip;
AlgorithmType = g_TypeAssignment.ItAuctionJacobi;
AlgorithmType = g_TypeAssignment.RelativeBenefits;

DesiredHeadings = 1.5*pi*ones(NumberOfTargets,1);
CommandTurnRadius = 1700.0;
Time = 0.0;
VehicleID = 0;
tic
[VehicleWayPoints,VehicleSchedule,AllAssignments] = MultiTaskAssign(Vehicles,Targets,TargetState,DesiredHeadings,CommandTurnRadius,AlgorithmType,Time,VehicleID);
toc

TestPlotWaypoints('MultiplePlot',VehicleWayPoints);

% plot targets
TargetSize = 500;
hold on
for(Count=1:NumberOfTargets),
	PosX = Targets(Count,1);
	PosY = Targets(Count,2);
   	rectangle('Position',[PosX-TargetSize/2,PosY-TargetSize/2,TargetSize,TargetSize],'Curvature',[.1,.1],...
        		 		'FaceColor',[0.6,0.6,0.6],'EdgeColor',[0.1,0.1,0.1]);
    text('String', num2str(Count),'Position', [PosX,PosY],'FontSize',18,'HorizontalAlignment','center','VerticalAlignment','bottom','Color',[0.2,0.6,0.2]);
end;
hold off;
return;

% Plot Vehicle Trajectories - use basic plot routine to connect, with straight line segments, the waypoints

     % Target locations
         TargetXCoordinate = Targets(:,1) ; TargetYCoordinate = Targets(:,2) ; 
     % Vehicle Start Locations
         VehicleXCoordinateStart = Vehicles(:,1) ; VehicleYCoordinateStart = Vehicles(:,2) ;
     % Set max and min values for the plots
     Xmin = min([TargetXCoordinate ; VehicleXCoordinateStart]) ; Xmax = max([TargetXCoordinate ; VehicleXCoordinateStart]) ;
     Ymin = min([TargetYCoordinate ; VehicleYCoordinateStart]) ; Ymax = max([TargetYCoordinate ; VehicleYCoordinateStart]) ;
     % Build Label Vectors
          for j=1:NumberOfVehicles
             VText(j,1:2) = ['V' num2str(j)];
          end
          for j=1:NumberOfTargets
             TText(j,1:2) = ['T' num2str(j)];
          end
          plot_offset_text = 100 ; % Simply moves the vehicle and target figure designators (V1,V2,... and T1,T2,...)
                                   % a little to the right of the actual location - better visibility
          DisplayOffset = 3000 ;
    
     % Get target headings
       TargetHeadings = Targets(:,3)*pi/180 ; plot_offset_arrow = 500 ;
       
       axis([Xmin-DisplayOffset Xmax+DisplayOffset Ymin-DisplayOffset Ymax+DisplayOffset])
       axis square
       hold on
       plot(TargetXCoordinate, TargetYCoordinate, 'o')
       text(TargetXCoordinate+plot_offset_text, TargetYCoordinate, TText)
       plot(VehicleXCoordinateStart, VehicleYCoordinateStart, 'x')
       text(VehicleXCoordinateStart+plot_offset_text, VehicleYCoordinateStart, VText)
       for i = 1 : NumberOfTargets
           plot([TargetXCoordinate(i);TargetXCoordinate(i)+plot_offset_arrow*cos(TargetHeadings(i))],[TargetYCoordinate(i);TargetYCoordinate(i)+plot_offset_arrow*sin(TargetHeadings(i))])
       end       
       for i = 1:NumberOfVehicles
       %    if (~isempty(VehicleWayPoints{i}))
       %        plot(VehicleWayPoints{i}(:,1), VehicleWayPoints{i}(:,2),'Color',PathColors(i,:))
       %    end
       end
       
       hold off
   
       
       
 return;
 
 
% The Fluffy Stuff
%if 1
   totallength = zeros(NumberOfVehicles,1);
   xxpath = [];
   yypath = [];
   for i = 1:NumberOfVehicles
      TaskOrder = AllAssignments(:,i);
      flag = 1;
      if ~isempty(intersect(TaskOrder,2:3:NumberOfTargets*3-1))
         Index = [];
         j = 1;
         while isempty(Index)
            KillVector = 2:3:NumberOfTargets*3-1;
            Index = find(TaskOrder == KillVector(j));
            j = j+1;
         end
         TaskOrder(Index+1:end) = [];
         flag = 0;
      end
      Index = find(TaskOrder <= 0);
      TaskOrder(Index) =[];
      if (flag)&(~isempty(TaskOrder))
         TaskOrder = [TaskOrder;0];
      end
      
      Orig =VehicleSchedule(1:3,1,i);
     % [Ways] = tourpath2(TaskOrder,Targets,Orig);
      
      %Waypoints = Ways;
      Waypoints = VehicleWayPoints{i} ;
      WayPointsCheck{i} = Waypoints ;
      xf = []; yf = [];
      x0 = VehicleSchedule(1,1,i);
      y0 = VehicleSchedule(2,1,i);
      xpath = [];
      ypath = [];
      for k = 1:length(TaskOrder)
          %if (TaskOrder(k) ~= 0)
          
         [n,m] = size(Waypoints);
         if (n > 5)
         Ways = Waypoints(1+4*(k-1):4+4*(k-1),:);
     else
         Ways = Waypoints ;
        end
         xf = Ways(4,1);
         yf = Ways(4,2);
         [pathlength,x,y]=drawtrack(Ways,x0,y0,xf,yf,Targets);
         xpath = [xpath x];
         ypath = [ypath y];
         totallength(i) = totallength(i)+pathlength;
         x0 = xf;
         y0 = yf;
         %end
      end
      if isempty(TaskOrder)
         xpath = [VehicleSchedule(1,1,i) VehicleSchedule(1,1,i)+20000*cos(pi/2-VehicleSchedule(3,1,i))];
         ypath = [VehicleSchedule(2,1,i) VehicleSchedule(2,1,i)+20000*sin(pi/2-VehicleSchedule(3,1,i))];
      end
      
      xp = [];
      yp = [];
      for j = 1:length(xpath)-1
         xstep = 5.5*cos(atan((ypath(j+1)-ypath(j))/(xpath(j+1)-xpath(j))));
         if abs(xpath(j)-xpath(j+1))>2*xstep
            a = (xpath(j)+xstep);
            b = (xpath(j+1)-xstep);
            if b<a
               xstep = -xstep;
            end
            xequal = a:xstep:b;
            yequal=interp1(xpath(j:j+1),ypath(j:j+1),xequal);
         else
            xequal = [];
            yequal = [];
         end
         xp = [xp xpath(j) xequal xpath(j+1)];
         yp = [yp ypath(j) yequal ypath(j+1)];
      end
      
      xpath = [VehicleSchedule(1,1,i) xp xf];
      ypath = [VehicleSchedule(2,1,i) yp yf];
      a = length(xpath);
      b = length(ypath);
      [M,N] = size(xxpath);
      
      if ~isempty(xxpath)
         if (a < N)
            xpath = [xpath xpath(a)*ones(1,N-a)];
         else
            for r = 1:M
               xxpath(r,N:a) = xxpath(r,N);
            end
         end
         if (b < N)&(~isempty(yypath))
            ypath = [ypath ypath(b)*ones(1,N-b)];
         else
            for r = 1:M
               yypath(r,N:a) = yypath(r,N);
            end
         end
      end
      xxpath = [xxpath; xpath];
      yypath = [yypath; ypath];
   end
   totallength(i+1) = sum(totallength);
   totallength
   % Build Label Vectors
   for j=1:NumberOfVehicles
      VText(j,1:2) = ['V' num2str(j)];
   end
   for j=1:NumberOfTargets
      TText(j,1:2) = ['T' num2str(j)];
   end
      
   figure(2)
   clf
   axis([(min(min(xxpath))-500) (max(max(xxpath))+500) (min(min(yypath))-500) (max(max(yypath))+500)])
   axis equal
   %axis image
   %axis square
   hold on
   plot(Targets(:,1),Targets(:,2),'b*');
   text(VehicleSchedule(1,1,:),VehicleSchedule(2,1,:),VText);
   text(Targets(:,1),Targets(:,2),TText);
   jcomet(xxpath,yypath)
   
   %end





