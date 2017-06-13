
% setup path info
tdir = ['..', filesep, '..', filesep, '..', filesep];
mdir = [tdir, 'm-file'];

addpath(mdir);
addpath(GetLibDir(tdir));

%action = 'Speed';
action = 'Regression';
%action = 'Figures';

% used by both
VehicleZ = 500;

switch(action),

case 'Speed'
  format long;

  WayPointSize = 100;

  vID=1; vX=0.0; vY=0.0; vHeading=0.0; vStandoff=-1.0; vTurnRadius=500.0;vType=1;vTotalDistanceTraveled=6000.0;
  tID=1; tX=5000.0; tY=0.0; tHeading=0.0; tTaskRequired=1;dTimePrerequisite_ft=0;
  TargetHeadings = [0.0;0.5*pi;pi;1.5*pi];
  %VehicleHeadings = [0.25]'*pi;
  VehicleHeadings = [0.0:0.25:2.0]'*pi;
  NumberHeadings = size(VehicleHeadings,1);
    
  %TrajectoryMEX(1);
  tic;
  CountPath = 0;
  LengthenPaths = 0;
  for(VehicleX = 0.0:100.0:20000.0),
    for(VehicleY = -50000.0:1000.0:50000.0),
      for (CountHeadings = 1:NumberHeadings),
        VehicleState = [vID;VehicleX;VehicleY;VehicleZ;VehicleHeadings(CountHeadings);vStandoff;vTurnRadius;vType;vTotalDistanceTraveled];
        TargetState = [tID;tX;tY;tHeading;tTaskRequired;dTimePrerequisite_ft];
        [Waypoints,TotalDistance,FinalHeading] = TrajectoryMEX(VehicleState,TargetState,TargetHeadings,LengthenPaths);
        CountPath = CountPath + 1;
      end;
    end;		%for(VehicleY 
  end;		%for(VehicleX 

  TotalRunTime = toc;

  TimePerPath = TotalRunTime/CountPath;
  PrintString = sprintf('\n\nTotal Run Time = %6.2f secs  | %5.2f min', ...
                        TotalRunTime, TotalRunTime/60);
  disp(PrintString);
  PrintString = sprintf('Total paths calulated = %d',CountPath);
  disp(PrintString);
  PrintString = sprintf('Time per path = %g sec',TimePerPath);
  disp(PrintString);

  %TrajectoryMEX(3);

case 'Regression'
  format long;

  WayPointSize = 100;

  vID=1; vX=0.0; vY=0.0; vHeading=0.0; vStandoff=-1.0; vTurnRadius=500.0;vType=1;vTotalDistanceTraveled=6000.0;
  tID=1; tX=5000.0; tY=0.0; tHeading=0.0; tTaskRequired=1;dTimePrerequisite_ft=0;
  TargetHeadings = [0.0;0.5*pi;pi;1.5*pi];
  %VehicleHeadings = [0.25]'*pi;
  VehicleHeadings = [0.0:0.25:2.0]'*pi;
  NumberHeadings = size(VehicleHeadings,1);
    
  Xrng = [0.0:200.0:20000.0];
  Yrng = [-50000.0:1000.0:50000.0];
  Hrng = [1:NumberHeadings];

  TotalPaths = length(Xrng)*length(Yrng)*length(Hrng);
  disp(sprintf('\n\nTotal paths expected = %d', TotalPaths));

  % size(Waypoints) = 5x12, will this change?
  kb_to_b = 1024;
  mb_to_b = 1024^2;
  TotalMemMB = TotalPaths*( (5*12 + 2)*8 ) / mb_to_b;
  warn_lim_mb = 10;
  if( TotalMemMB > warn_lim_mb )
    disp(sprintf('  Need %4.2f MB of raw mem! (Ctrl-C to quit, space to continue)',TotalMemMB ));
    pause;
  end
  tic;
  data = struct('Waypoints',{cell(TotalPaths,1)}, ...
                'TotalDistance', {zeros(TotalPaths,1)}, ...
                'FinalHeading', {zeros(TotalPaths,1)});
%  [data.Waypoints{:}] = deal(zeros(5,12)); % unnecessary, in fact slower
  disp(sprintf('Allocation time:  %6.2f sec', toc));

  %TrajectoryMEX(1);
  LengthenPaths = 0;
  TotalRunTime = 0;
  k = 1;
  for(VehicleX = Xrng),
    for(VehicleY = Yrng),
      for (CountHeadings = Hrng),
        tic;
        VehicleState = [vID;VehicleX;VehicleY;VehicleZ;VehicleHeadings(CountHeadings);vStandoff;vTurnRadius;vType;vTotalDistanceTraveled];
        TargetState = [tID;tX;tY;tHeading;tTaskRequired;dTimePrerequisite_ft];
        [data.Waypoints{k}, ...
         data.TotalDistance(k),...
         data.FinalHeading(k)] = ...
           TrajectoryMEX(VehicleState,TargetState,TargetHeadings,LengthenPaths);
        TotalRunTime = TotalRunTime + toc;
        k = k + 1;
      end;
    end;
  end;

  TimePerPath = TotalRunTime/k;
  PrintString = sprintf('Total paths calulated = %d',k);
  disp(PrintString);
  PrintString = sprintf('Total Run Time = %6.2f secs  | %5.2f min', ...
                        TotalRunTime, TotalRunTime/60);
  disp(PrintString);
  PrintString = sprintf('Time per path = %g sec',TimePerPath);
  disp(PrintString);

	CheckRegression;
    
case 'Figures'
  format long e;

  WayPointSize = 100;

  vID=1; vX=0.0; vY=0.0; vHeading=0.0; vStandoff=-1.0; vTurnRadius=500.0;vType=1;vTotalDistanceTraveled=6000.0;
  tID=1; tX=5000.0; tY=0.0; tHeading=0.0; tTaskRequired=2;dTimePrerequisite_ft=10000.0;
  %TargetHeadings = [0.0;0.5*pi;pi;1.5*pi];
  TargetHeadings = [0.0;0.5*pi;pi;1.5*pi];
  VehicleHeadings = [0.25]'*pi;
  %VehicleHeadings = [0.0:0.25:2.0]'*pi;
  NumberHeadings = size(VehicleHeadings,1);

  figure (50);
  orient landscape;

  if(NumberHeadings > 3),
    NumberPlotColumns = 3;
  else,
    NumberPlotColumns = NumberHeadings;
  end;
  NumberPlotRows = fix(NumberHeadings/NumberPlotColumns) + round(mod(NumberHeadings,NumberPlotColumns));

  %TrajectoryMEX(1);
  for(VehicleX = 3000.0:1000.0:7000.0),
  %for(VehicleX = 5000.0),
  %for(VehicleX = 0.0),
    for(VehicleY = -5000.0:1000.0:5000.0),
    %for(VehicleY = 0.0),
      PlotCount = 1;
      clf;
      axis equal;
      for (CountHeadings = 1:NumberHeadings),
        VehicleState = [vID;VehicleX;VehicleY;VehicleZ;VehicleHeadings(CountHeadings);vStandoff;vTurnRadius;vType;vTotalDistanceTraveled];
        TargetState = [tID;tX;tY;tHeading;tTaskRequired;dTimePrerequisite_ft];
        LengthenPaths = 1;
        [Waypoints,TotalDistance,FinalHeading] = TrajectoryMEX(VehicleState,TargetState,TargetHeadings,LengthenPaths);
        TotalDistance
        subplot(NumberPlotRows,NumberPlotColumns,PlotCount);
        PlotCount = PlotCount + 1;
        ThisPointColor = [0.6,0.6,0.0];
        rectangle('Position',[TargetState(2)-WayPointSize/2,TargetState(3)-WayPointSize/2,WayPointSize,WayPointSize],'Curvature',[1,1],...
          'FaceColor',ThisPointColor,'EdgeColor',ThisPointColor);
        hold on;
        plot([Waypoints(end,1);TargetState(2)],[Waypoints(end,2);TargetState(3)]);
        TestPlotWaypoints('SinglePlot',Waypoints);
        hold off;
      end;
      disp('press any key to contiune...');
      pause
    end;		%for(VehicleY 
  end;		%for(VehicleX 

end; 	%switch

%TrajectoryMEX(3);

