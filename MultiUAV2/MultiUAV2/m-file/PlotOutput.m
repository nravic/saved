function PlotOutput(Action, EndTime,RunSpeed,OneTime)
%PlotOutput - animates the vehicle trajectories and target data from the CATA/SIMULINK simulation
%
%  Inputs:
%    EndTime  - play the simulation until the simulation time is >= this time  
%    RunSpeed  - number of indicies to skip while animating the data  
%    OneTime  - draw a plot of the simulation for one time
%
%  Outputs:
%    (none)
%
%  $Id: PlotOutput.m,v 2.1.6.4.4.3 2004/05/06 12:47:26 rasmussj Exp $

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS
%  May 2001 - added buttons and slider for animation control - RAS
%  June 2001 - fix plots so elements are not continuously replotted - RAS
%  July 2001 - added options to GUI to make it easier to change the appearance of the charts - RAS
%  August 2001 - added "line width" option to GUI - RAS
%  September 2001 - changed order of variables in saved data - RAS
%  April 2002 - fixed position of target text identifiers - RAS
%  May 2003 - added global vrariable for axes limits and code to draw boxes for search space and target space - RAS


global g_Debug; if(g_Debug==1),disp('PlotOutput.m');end; 
global g_PlotAxesLimits;
global g_SearchSpace;	%for plotting search space box
global g_TargetSpace;	%for plotting target space box

%% This is a local value that controls waypoint label printing.
%% Currently, there is no a uicontrol element for this, so set to 
%% non-zero for labeled waypoints.
isPlotWaypointLabels = 1;

% DataIncrement is the value to increment the data between plots 
persistent DataIncrement;
if(~length(DataIncrement)),
	DataIncrement = 10;	%
end;
DataIncrements = [1:20];

% set PlotRabbits = 1 to plot squares that correspond to the rabbit positions for each vehicle
persistent PlotRabbits;
if(~length(PlotRabbits)),
	PlotRabbits = 0;	%
end;

% DelayTime is the length of time to delay between updates of the plot 
persistent DelayTime;
if(~length(DelayTime)),
	DelayTime = 0.1;	%
end;
DelayTimes = [0.1:0.1:1.0,2.0];

% PlotLineWidth controls the width, in points, of the lines that are plotted
persistent PlotLineWidth;
if(~length(PlotLineWidth)),
	PlotLineWidth = 0.5;	%  1/72 inch
end;
PlotLineWidths = [0.1,0.5,1.0,2.0,3.0,4.0,5.0];

% set PlotWaypoints = 1 to plot circles that correspond to the final set of waypoints for each vehicle
persistent PlotWaypoints;
if(~length(PlotWaypoints)),
	PlotWaypoints = 0;	%
end;

% set PlotUnits = 1 to label plot in feet, 2 to label plot in miles
persistent PlotUnits;
if(~length(PlotUnits)),
	PlotUnits = 2;	%
end;

% BackgroundColorIndex is used to select the background color for the plot 
persistent BackgroundColorIndex;
if(~length(BackgroundColorIndex)),
	BackgroundColorIndex = 2;	%
end;
persistent BackgroundColor;
if(~length(BackgroundColor)),
	BackgroundColor = [1.0 1.0 1.0];	%
end;
%BackgroundColors = [1.0 1.0 1.0; 0.95,0.95,0.85];
BackgroundColors = [1.0 1.0 1.0; 0.98,0.98,0.95];


global g_WaypointCells;
global g_MaxNumberVehicles;
global g_MaxNumberTargets;
global g_TargetTypes;
global g_TargetStates;
global g_EnableVehicle;
global g_VehicleColors;
global g_XYPositions g_TargetPositions; % won't stomp persistent values
global g_isSensorAlwaysPastel;

persistent handleSlider;
persistent handleText;
persistent handleButton;
persistent handleAnimateButton;
persistent handleCopyPlotButton;
persistent handleStopButton;
persistent handlePauseButton;
persistent handleTrajectoryTrail;
persistent handleWayPointDisplay;
persistent handleMilesFeet;
persistent handleRabbitDisplay;
persistent handleDelayTime;
persistent handlePlotLineWidth;
persistent handleDataIncrement;
persistent handleBackgroundColor;

persistent TargetGraphicsHandles;
persistent TargetTextHandles;

persistent VehicleAssignmentDiskHandles;
persistent VehicleTrajectoryHandles;
persistent VehicleRabbitHandles;

persistent TrajectoryCheck;
persistent StopAnimation;
persistent PauseAnimation;
persistent AnimateFlag;
persistent GraphicStructArray;
persistent VehiclesUsed;
persistent MatrixTargetRect;
persistent XYPositions;
persistent TargetPositions;

persistent pCurrentTime;
if(~length(pCurrentTime)),
	pCurrentTime = 0;	%
end;

AnimationFigure = findobj('tag','AnimationFigure');


if(~length(AnimateFlag)),
	AnimateFlag = '0';	%
end;
if(~exist('Action')),
	Action = 'PlotData';	% plot all of the data
end;
if(~exist('EndTime')),
	EndTime = realmax;	% plot all of the data
end;
if(~exist('RunSpeed')),
	RunSpeed = 20;	%only plot every 20th time step
	RunSpeed = 5;	%only plot every 20th time step
	RunSpeed = 1;	%only plot every 20th time step
end;
if(~exist('OneTime')),
 	OneTime = -1;	%less than zero is off
end;
if ((strcmp(Action,'PlotData'))&(OneTime < 0.0)),
	handleSlider = [];
end;
if (isempty(TrajectoryCheck)),
	TrajectoryCheck = 1;
end;

if (strcmp(Action,'StopAnimation')),
	StopAnimation = 1;
	return;
else,
	StopAnimation = 0;   
end;

if (strcmp(Action,'CopyPlotAnimation')),
	if(StopAnimation == 0),
		haxes = get(figure(25),'CurrentAxes');
		new_handle = copyobj(haxes,figure);
		clear haxes;
		clear new_handle;
	end;
end;


if (strcmp(Action,'PauseAnimation')),
	if(PauseAnimation == 1),
		PauseAnimation = 0;
	else,
		PauseAnimation = 1;
	end;
	if(~isempty(AnimationFigure))
		set(handlePauseButton,'Value',PauseAnimation);
	end;
	return;
else,
	PauseAnimation = 0;   
	if(~isempty(AnimationFigure))
		set(handlePauseButton,'Value',PauseAnimation);
	end;
end;

XYPositionsReloaded = 0;

% bring in the globally saved workspace values
if( ~isempty(g_XYPositions) ),
	disp([mfilename,'::attempting to use existing workspace data.']);
	XYPositions = g_XYPositions;
	TargetPositions = g_TargetPositions;
    XYPositionsReloaded = 1;
end

switch(Action)
case 'PlotData'
	ColorsArrayRGBVehicle = g_VehicleColors.ColorVehicles;
	ColorsArrayRGBTargetState = g_TargetStates.ColorTargetStates;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%% Vehicle Data
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if( isempty(XYPositions) & (OneTime <= 0) ),
		disp([mfilename,'::loading vehicle data from file.']);
		load SimPositionsOut;
		[iRows,iColumns] = size(XYPositions);
        XYPositionsReloaded = 1;
	end;
	OffsetCount = 0;
	RowOffsetVehicleX = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetVehicleY = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetVehicleZ = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetVehiclePhi = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetVehicleTheta = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetVehicleHeadingAngle = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetVehicleSensorOn = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetVehicleRabbitPositionN = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetVehicleRabbitPositionE = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetVehicleRabbitHeading = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetVehicleTargetAssignment = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetVehicleFinished = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	NumberRowsVehicle = OffsetCount;	% add 1 to last row index
	
    if(XYPositionsReloaded),
        XYPositions([2+RowOffsetVehicleHeadingAngle:NumberRowsVehicle:end],:) = HeadingToAngle(XYPositions([2+RowOffsetVehicleHeadingAngle:NumberRowsVehicle:end],:));
    end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%% Target Data
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if( isempty(TargetPositions) & (OneTime <= 0) ),
		disp([mfilename,'::loading target data from file.']);
		load SimTargetsOut;
	end;
	
	OffsetCount = 0;
	RowOffsetTargetX = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetTargetY = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetTargetZ = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetTargetType = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetTargetPsi = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	RowOffsetTargetAlive = OffsetCount;
	
	OffsetCount = OffsetCount + 1;
	NumberRowsTarget = OffsetCount;
	
	RowOffsetTargetStatus = 1+ NumberRowsTarget*g_MaxNumberTargets;
	
	WayPointSize = 300;
	%AssignmentDiskSize = 1500;
	AssignmentDiskSize = 500;
	AssignmentDiskOffset = 500;
	RabbitSize = 300;
	
	hFigure = figure(25);
	set(hFigure,'Toolbar','figure');
	set(hFigure,'tag','AnimationFigure');
	set(hFigure,'Units','normalized');
	set(hFigure,'PaperOrientation','landscape');
	%set(hFigure,'position',[96 118 1034 711]);
	% if(OneTime < 0)
	%    set(hFigure,'position',[0.1 0.1 0.75 0.7]);
	% end;
	
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%% Plot Setup
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if((AnimateFlag == 1)&(OneTime <= 0)&(~StopAnimation))
		handleAnimateButton = findobj('String', 'Animate');
		if(~isempty(AnimationFigure) )
			set(handleAnimateButton,'Value',AnimateFlag);
		end;
		return;
	end;
	
	if(OneTime < 0),
        cla;
	end;	%if(OneTime < 0),
	
	hold on;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%% Plot Search Space and target Space Rectangles
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	SearchSpaceWidth = g_SearchSpace(2) - g_SearchSpace(1);
	SearchSpaceHeight = g_SearchSpace(4) - g_SearchSpace(3);
	rectangle('Position',[g_SearchSpace(1),g_SearchSpace(3),SearchSpaceWidth,SearchSpaceHeight], ...
		'Curvature',[0,0],...
		... 'FaceColor',[0.1,0.1,0.1], ...
		'LineStyle','--', ...
		'LineWidth',2, ...
		'EdgeColor',[0.0,0.0,1.0]);
	
	TargetSpaceWidth = g_TargetSpace(2) - g_TargetSpace(1);
	TargetSpaceHeight = g_TargetSpace(4) - g_TargetSpace(3);
	rectangle('Position',[g_TargetSpace(1),g_TargetSpace(3),TargetSpaceWidth,TargetSpaceHeight], ...
		'Curvature',[0,0],...
		... 'FaceColor',[0.0,0.9,0.0], ...
		'LineStyle',':', ...
		'LineWidth',2, ...
		'EdgeColor',[0.0,1.0,0.0]);
	
	if(OneTime < 0),
		axis equal;
		grid on;
		axis(g_PlotAxesLimits);
		set(gcf,'DoubleBuffer','on');	%prevents flickering during the simulation
		
		hAxes = get(hFigure,'CurrentAxes');
		set(hAxes,'color',BackgroundColors(BackgroundColorIndex,:));
		
		switch(PlotUnits),
		case 2,
			XTicks = [sort(0:-5280:g_PlotAxesLimits(1)) 5280:5280:g_PlotAxesLimits(2)];
			YTicks = [sort(0:-5280:g_PlotAxesLimits(3)) 5280:5280:g_PlotAxesLimits(4)];
			set(gca,'XTick',XTicks,'YTick',YTicks);
			set(gca,'XTickLabel',num2str(XTicks'/5280),'YTickLabel',num2str(YTicks'/5280));
		otherwise,
		end;
	end;	%if(OneTime < 0),
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%% Initialize Vehicle Plot
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if(OneTime < 0),
		VehiclesUsed = [];
		for iCount = 1:g_MaxNumberVehicles
			TempWaypoints = g_WaypointCells{iCount};
			if (g_EnableVehicle(iCount) ~= 0),
				if(PlotWaypoints),
					[iWaypointRows,iWaypointColumns] = size(TempWaypoints);
					for (iWaypoints = 1:iWaypointRows),
						rectangle('Position',[TempWaypoints(iWaypoints,1)-WayPointSize/2,TempWaypoints(iWaypoints,2)-WayPointSize/2,WayPointSize,WayPointSize], ...
							'Curvature',[1,1],...
							'FaceColor',ColorsArrayRGBVehicle(iCount,:),'EdgeColor',ColorsArrayRGBVehicle(iCount,:));
					end;	%for (iWaypoints = 1:iWaypointRows),
					if( isPlotWaypointLabels )
						PlotWaypointLabels( TempWaypoints(:,1:2), iWaypointRows, WayPointSize );
					end
				end;	%PlotWaypoints
				VehiclesUsed = [VehiclesUsed; 1];
			else
				VehiclesUsed = [VehiclesUsed; 0];
			end
		end
	end;	%if(OneTime < 0),
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%% Initialize Target Plot
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if(OneTime < 0),
		MatrixTargetRect = [];
		%set up target sizes
		ScaleTarget = 30;
		Temp = 2;
		for iCount = 1:g_MaxNumberTargets
			TargetType = TargetPositions(Temp+RowOffsetTargetType,1);
			if(TargetType<=0),
				TargetType = 1;
			end;
			
			TargetTypeStruct = g_TargetTypes(TargetType);
			TargetLength = TargetTypeStruct.Length * ScaleTarget;	%% 
			TargetWidth = TargetTypeStruct.Width * ScaleTarget;	%%
			TargetRectanglePointsX = [-TargetWidth/2; 0.0; TargetWidth/2; TargetWidth/2; -TargetWidth/2];
			TargetRectanglePointsY = [TargetLength/2; TargetLength; TargetLength/2; -TargetLength/2; -TargetLength/2];
			[iRow,iCol] = size(TargetRectanglePointsX);
			TargetRectanglePointsZ = zeros(iRow,1);
			MatrixTargetRect = [MatrixTargetRect; {[TargetRectanglePointsX,TargetRectanglePointsY,TargetRectanglePointsZ]}];
			Temp = Temp + 6;
		end;		%for iCount = 1:g_MaxNumberTargets
		
	end;	%if(OneTime < 0),
	if((OneTime < 0)|(length(GraphicStructArray)==0)|(length(VehicleAssignmentDiskHandles)==0)|(length(VehicleRabbitHandles)==0)|(length(VehicleTrajectoryHandles)==0))
		GraphicStructArray = [];
		VehicleAssignmentDiskHandles = [];
		VehicleRabbitHandles = [];
		for iCount = 1:g_MaxNumberVehicles,
			if VehiclesUsed(iCount)==1,
				GraphicStructArray = [GraphicStructArray;CreateVehicleGraphic];
				%%%%% Initialize Vehicle Assignment Disks
				TempHandle = rectangle('Position',[realmax,realmax,AssignmentDiskSize,AssignmentDiskSize], ...
					'Curvature',[0.0,0.0],'Visible','off',...
					'FaceColor',ColorsArrayRGBVehicle(iCount,:),'EdgeColor',ColorsArrayRGBVehicle(iCount,:));
				VehicleAssignmentDiskHandles = [VehicleAssignmentDiskHandles;TempHandle];
				TempHandle = rectangle('Position',[realmax,realmax,RabbitSize ,RabbitSize ], ...
					'Curvature',[0,0],'Visible','off',...
					'FaceColor',ColorsArrayRGBVehicle(iCount,:),'EdgeColor',ColorsArrayRGBVehicle(iCount,:));
				VehicleRabbitHandles = [VehicleRabbitHandles;TempHandle];
			end;
		end;
	end;	%if((OneTime < 0)|(length(GraphicStructArray)==0)|(length(VehicleAssignmentDiskHandles)==0))
	
	if((OneTime < 0)|length(TargetGraphicsHandles)==0)
		TargetGraphicsHandles = [];
		TargetTextHandles = [];
		Temp = 2;
		for iCount = 1:g_MaxNumberTargets
			Rotation = pi/2 - TargetPositions(Temp+5,1);
			rotMatrix = [cos(Rotation) -sin(Rotation) 0 ; sin(Rotation) cos(Rotation) 0; 0 0 1];
			RotMatrixTargetRect =  MatrixTargetRect{iCount} * rotMatrix;
			TargetGraphicsHandles = [TargetGraphicsHandles;patch(RotMatrixTargetRect(:,1)+TargetPositions(Temp+RowOffsetTargetX,1), ...
					RotMatrixTargetRect(:,2)+TargetPositions(Temp+RowOffsetTargetY,1), ...
					RotMatrixTargetRect(:,3)+TargetPositions(Temp+RowOffsetTargetZ,1), ...
					'FaceColor',[0.9,0.9,0.9],'EdgeColor',[0.0,0.0,0.0],'Visible','off', ...
					'EraseMode','normal','FaceLighting','none')];
			TargetTextHandles = [TargetTextHandles,text(TargetPositions(Temp+RowOffsetTargetX,1),TargetPositions(Temp+RowOffsetTargetY,1),num2str(iCount), ...
					'HorizontalAlignment','left','VerticalAlignment','middle','Visible','off', ...
					'FontWeight','bold','FontSize',12)];
			
			Temp = Temp + NumberRowsTarget;
		end
	end;	%if((OneTime < 0)|(length(TargetGraphicsHandles)==0))
	
	
	
	% plot vehicle trajectories
	if(OneTime < 0),
		Temp = 2;
		VehicleTrajectoryHandles = [];
		for iCount = 1:g_MaxNumberVehicles
			if(TrajectoryCheck==1),
				TempHandle = plot(XYPositions(Temp+RowOffsetTargetX,[5:end]),XYPositions(Temp+RowOffsetTargetY,[5:end]),'Color',ColorsArrayRGBVehicle(iCount,:),'LineWidth',PlotLineWidth);
			elseif(TrajectoryCheck==2),
				TempHandle = plot(XYPositions(Temp+RowOffsetTargetX,1:2),XYPositions(Temp+RowOffsetTargetY,1:2),'Color',ColorsArrayRGBVehicle(iCount,:),'LineWidth',PlotLineWidth);
			else,
				TempHandle = plot(XYPositions(Temp+RowOffsetTargetX,1:2),XYPositions(Temp+RowOffsetTargetY,1:2),'Color',ColorsArrayRGBVehicle(iCount,:),'Visible','off');
			end;
			Temp = Temp + NumberRowsVehicle;
			VehicleTrajectoryHandles = [VehicleTrajectoryHandles;TempHandle];
		end
	end;	%if(OneTime < 0)
	
	SimulationTime = XYPositions(1,:);
	
	if(OneTime < 0),
		StartIndex = 5;
		if EndTime==0,
			EndTime = max(SimulationTime);
		end;
		EndIndex = max(find(SimulationTime<=EndTime));
		if(length(EndIndex)==0),
			EndIndex = 1;
		end;
	else, %if(OneTime < 0),
		EndIndex = max(find(SimulationTime<=OneTime));
		if(length(EndIndex)==0),
			EndIndex = 1;
		end;
		if(OneTime >= pCurrentTime),
			EndIndex = EndIndex + 1;
		end;
		StartIndex = EndIndex;
		LengthSimulationTime = size(SimulationTime,2);
		if (StartIndex > LengthSimulationTime)
			StartIndex = LengthSimulationTime;
			EndIndex = LengthSimulationTime;
		end;
	end;	%if(OneTime < 0),
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% Animate Button Control        %%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if ((OneTime <= 0)|(isempty(handleText)))
		handleText = text('String', '0.0','FontSize',18,...
			'HorizontalAlignment','right', ...
			'VerticalAlignment','bottom', ...
			'Units','normalized','Position', [1.0 1.0]);
		%                        'Units','normalized','Position', [0.75 0.85 0.15 0.07]);
	end;
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% Draw Slider Control        %%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handleSlider = findobj(hFigure,'String', 'SimulationTime');
	if (isempty(handleSlider))
		handleSlider = uicontrol('Style', 'slider', 'String', 'SimulationTime',...
			'Max', SimulationTime(end), ...
			'Min', 0.5, ...
			'Value', SimulationTime(EndIndex), ...
			'SliderStep',[1.01*(SimulationTime(2)-SimulationTime(1))/SimulationTime(end) 0.1], ...
			'Units','normalized','Position', [0.1 0.05 0.8 0.04], ...
			'Callback', 'PlotOutput(''SliderCallback'')');
		
	end;
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% Animate Button Control        %%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handleAnimateButton = findobj(hFigure,'String', 'Animate');
	if (isempty(handleAnimateButton))
		handleAnimateButton = uicontrol('Style', 'togglebutton', 'String', 'Animate',...
			'Units','normalized','Position', [0.05 0.05 0.05 0.04], ...
			'Callback', 'PlotOutput(''PlotData'')');
		
	end;
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% CopyPlot Button Control        %%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handleCopyPlotButton = findobj(hFigure,'String', 'CopyPlot');
	if (isempty(handleCopyPlotButton))
		handleCopyPlotButton = uicontrol('Style', 'pushbutton', 'String', 'CopyPlot',...
			'Units','normalized','Position', [0.9 0.09 0.05 0.04], ...
			'Callback', 'PlotOutput(''CopyPlotAnimation'')');
	end;
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% Stop Button Control        %%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handleStopButton = findobj(hFigure,'String', 'Stop');
	if (isempty(handleStopButton))
		handleStopButton = uicontrol('Style', 'pushbutton', 'String', 'Stop',...
			'Units','normalized','Position', [0.9 0.05 0.05 0.04], ...
			'Callback', 'PlotOutput(''StopAnimation'')');
	end;
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% Pause Button Control        %%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handlePauseButton = findobj(hFigure,'String', 'Pause');
	if (isempty(handlePauseButton))
		handlePauseButton = uicontrol('Style', 'togglebutton', 'String', 'Pause',...
			'Units','normalized','Position', [0.05 0.09 0.05 0.04], ...
			'Callback', 'PlotOutput(''PauseAnimation'')');
	end;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% Pull down menu definitions      %%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	PulldownWidth = 0.1;
	PulldownHeigth = 0.04;
	PulldownTextHeigth = 0.02;
	PulldownVeticalIncrement = 0.05;
	PulldownTextVertOffset = 0.04;
	LeftPullDown = 0.005;
	TopPullDown = 0.8;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% Complete Trajectory Control     %%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handleTrajectoryTrail = findobj(hFigure,'Tag', 'TrajectoryTrail');
	if (isempty(handleTrajectoryTrail))
		handleTrajectoryTrail = uicontrol( ...
			'Style', 'popupmenu', ...
			'Units','normalized', ...
			'Position', [LeftPullDown TopPullDown PulldownWidth PulldownHeigth], ...
			'Callback', 'PlotOutput(''CompleteTrajectoryCallback'')', ...
			'BackgroundColor',[1.0 1.0 1.0], ...
			'String',['Trajectory';'Trail     ';'None      '], ...
			'Style','popupmenu', ...
			'Tag','TrajectoryTrail', ...
			'Value',TrajectoryCheck);
		uicontrol( ...
			'Style', 'text', ...
			'Units','normalized', ...
			'Position', [LeftPullDown (TopPullDown+PulldownTextVertOffset) PulldownWidth PulldownTextHeigth], ...
			'String','Trajectory/Trail' ...
			);
	end;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% MilesFeet Control     %%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	TopPullDown = TopPullDown - PulldownVeticalIncrement;
    handleMilesFeet = findobj(hFigure,'Tag', 'MilesFeet');
	if (isempty(handleMilesFeet))
		handleMilesFeet = uicontrol( ...
			'Style', 'popupmenu', ...
			'Units','normalized', ...
			'Position', [LeftPullDown TopPullDown PulldownWidth PulldownHeigth], ...
			'Callback', 'PlotOutput(''CallbackMilesFeet'')', ...
			'BackgroundColor',[1.0 1.0 1.0], ...
			'String',['Feet ';'Miles'], ...
			'Style','popupmenu', ...
			'Tag','MilesFeet', ...
			'Value',PlotUnits);
		uicontrol( ...
			'Style', 'text', ...
			'Units','normalized', ...
			'Position', [LeftPullDown (TopPullDown+PulldownTextVertOffset) PulldownWidth PulldownTextHeigth], ...
			'String','Miles/Feet' ...
			);
	end;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% Waypoints Display Control     %%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	TopPullDown = TopPullDown - PulldownVeticalIncrement;
    handleWayPointDisplay = findobj(hFigure,'Tag', 'WayPointDisplay');
	if (isempty(handleWayPointDisplay))
		handleWayPointDisplay = uicontrol( ...
			'Style', 'popupmenu', ...
			'Units','normalized', ...
			'Position', [LeftPullDown TopPullDown PulldownWidth PulldownHeigth], ...
			'Callback', 'PlotOutput(''CallbackWayPointDisplay'')', ...
			'BackgroundColor',[1.0 1.0 1.0], ...
			'String',['Off';'On '], ...
			'Style','popupmenu', ...
			'Tag','WayPointDisplay', ...
			'Value',PlotWaypoints+1);
		uicontrol( ...
			'Style', 'text', ...
			'Units','normalized', ...
			'Position', [LeftPullDown (TopPullDown+PulldownTextVertOffset) PulldownWidth PulldownTextHeigth], ...
			'String','WayPoint Display' ...
			);
	end;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% Rabbit Display Control     %%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	TopPullDown = TopPullDown - PulldownVeticalIncrement;
    handleRabbitDisplay = findobj(hFigure,'Tag', 'RabbitDisplay');
	if (isempty(handleRabbitDisplay))
		handleRabbitDisplay = uicontrol( ...
			'Style', 'popupmenu', ...
			'Units','normalized', ...
			'Position', [LeftPullDown TopPullDown PulldownWidth PulldownHeigth], ...
			'Callback', 'PlotOutput(''CallbackRabbitDisplay'')', ...
			'BackgroundColor',[1.0 1.0 1.0], ...
			'String',['Off';'On '], ...
			'Style','popupmenu', ...
			'Tag','RabbitDisplay', ...
			'Value',PlotRabbits+1);
		uicontrol( ...
			'Style', 'text', ...
			'Units','normalized', ...
			'Position', [LeftPullDown (TopPullDown+PulldownTextVertOffset) PulldownWidth PulldownTextHeigth], ...
			'String','Rabbit Display' ...
			);
	end;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% Delay Time Control     %%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	TopPullDown = TopPullDown - PulldownVeticalIncrement;
    handleDelayTime = findobj(hFigure,'Tag', 'DelayTime');
	if (isempty(handleDelayTime))
		handleDelayTime = uicontrol( ...
			'Style', 'popupmenu', ...
			'Units','normalized', ...
			'Position', [LeftPullDown TopPullDown PulldownWidth PulldownHeigth], ...
			'Callback', 'PlotOutput(''CallbackDelayTime'')', ...
			'BackgroundColor',[1.0 1.0 1.0], ...
			'String',num2str(DelayTimes'), ...
			'Tag','DelayTime', ...
			'Value',find(DelayTime==DelayTimes));
		uicontrol( ...
			'Style', 'text', ...
			'Units','normalized', ...
			'Position', [LeftPullDown (TopPullDown+PulldownTextVertOffset) PulldownWidth PulldownTextHeigth], ...
			'String','Time Delay' ...
			);
	end;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% Plot Line Width Control     %%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	TopPullDown = TopPullDown - PulldownVeticalIncrement;
    handlePlotLineWidth = findobj(hFigure,'Tag', 'PlotLineWidth');
	if (isempty(handlePlotLineWidth))
		handlePlotLineWidth = uicontrol( ...
			'Style', 'popupmenu', ...
			'Units','normalized', ...
			'Position', [LeftPullDown TopPullDown PulldownWidth PulldownHeigth], ...
			'Callback', 'PlotOutput(''CallbackPlotLineWidth'')', ...
			'BackgroundColor',[1.0 1.0 1.0], ...
			'String',num2str(PlotLineWidths'), ...
			'Tag','PlotLineWidth', ...
			'Value',find(PlotLineWidth==PlotLineWidths));
		uicontrol( ...
			'Style', 'text', ...
			'Units','normalized', ...
			'Position', [LeftPullDown (TopPullDown+PulldownTextVertOffset) PulldownWidth PulldownTextHeigth], ...
			'String','Line Width' ...
			);
	end;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%      Data Increment Control     %%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	TopPullDown = TopPullDown - PulldownVeticalIncrement;
    handleDataIncrement = findobj(hFigure,'Tag', 'DelayTime');
	if (isempty(handleDataIncrement))
		handleDataIncrement = uicontrol( ...
			'Style', 'popupmenu', ...
			'Units','normalized', ...
			'Position', [LeftPullDown TopPullDown PulldownWidth PulldownHeigth], ...
			'Callback', 'PlotOutput(''CallbackDataIncrement'')', ...
			'BackgroundColor',[1.0 1.0 1.0], ...
			'String',num2str(DataIncrements'), ...
			'Tag','DelayTime', ...
			'Value',DataIncrement);
		uicontrol( ...
			'Style', 'text', ...
			'Units','normalized', ...
			'Position', [LeftPullDown (TopPullDown+PulldownTextVertOffset) PulldownWidth PulldownTextHeigth], ...
			'String','Data Increment' ...
			);
	end;
	
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%% Background Color Control      %%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	TopPullDown = TopPullDown - PulldownVeticalIncrement;
    handleBackgroundColor = findobj(hFigure,'Tag', 'BackgroundColor');
	if (isempty(handleBackgroundColor))
		handleBackgroundColor = uicontrol( ...
			'Style', 'popupmenu', ...
			'Units','normalized', ...
			'Position', [LeftPullDown TopPullDown PulldownWidth PulldownHeigth], ...
			'Callback', 'PlotOutput(''CallbackBackgroundColor'')', ...
			'BackgroundColor',[1.0 1.0 1.0], ...
			'String',['1';'2'], ...
			'Tag','BackgroundColor', ...
			'Value',BackgroundColorIndex);
		uicontrol( ...
			'Style', 'text', ...
			'Units','normalized', ...
			'Position', [LeftPullDown (TopPullDown+PulldownTextVertOffset) PulldownWidth PulldownTextHeigth], ...
			'String','Background Color' ...
			);
	end;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%% Animation Plot Begins here
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if(~isempty(AnimationFigure) )
		set(handlePauseButton,'Value',PauseAnimation);
	end;
	if(~isempty(AnimationFigure) )
		set(handleAnimateButton,'Value',1);
	end;
	iColCountLast = StartIndex;
	iColCount = StartIndex;
	AnimateFlag = 1;
	while(AnimateFlag),
		pCurrentTime = XYPositions(1,iColCount);
		if(PauseAnimation==1),
			iColCount = iColCountLast;
		else,	%if(PauseAnimation=1),
			iColCountLast = iColCount;
			ArrayCount = 1;
			Temp = 2;
			for iCount = 1:g_MaxNumberVehicles
				if VehiclesUsed(iCount)==1
					if(TrajectoryCheck==2),
						% plot vehicle trajectories up to where vehicle's current position
						set(VehicleTrajectoryHandles(iCount),'XData',XYPositions(Temp+RowOffsetTargetX,(2:iColCount)),'YData',XYPositions(Temp+RowOffsetTargetY,(2:iColCount)),'LineWidth',PlotLineWidth);
					end;
					if(XYPositions(Temp+RowOffsetVehicleFinished,iColCount)==0),
						
                        
						%if sensor if off set the color=0
						if( (XYPositions(Temp+RowOffsetVehicleSensorOn,iColCount)==0) ...
								| g_isSensorAlwaysPastel == 1 )
							CreateVehicleGraphic('Draw',GraphicStructArray(ArrayCount),XYPositions(Temp+RowOffsetVehicleX,iColCount),XYPositions(Temp+RowOffsetVehicleY,iColCount), ...
								(XYPositions(Temp+RowOffsetVehicleHeadingAngle,iColCount))*pi/180,1.0-(1.0-ColorsArrayRGBVehicle(iCount,:))*0.25,ColorsArrayRGBVehicle(iCount,:),iCount);
						else,
							CreateVehicleGraphic('Draw',GraphicStructArray(ArrayCount),XYPositions(Temp+RowOffsetVehicleX,iColCount),XYPositions(Temp+RowOffsetVehicleY,iColCount), ...
								(XYPositions(Temp+RowOffsetVehicleHeadingAngle,iColCount))*pi/180,ColorsArrayRGBVehicle(iCount,:),ColorsArrayRGBVehicle(iCount,:),iCount);
						end;
						
						if (PlotRabbits),                                   
							%%%%% Plot Vehicle Rabbit
							RabbitPositionN = XYPositions(Temp+RowOffsetVehicleRabbitPositionN,iColCount) - (RabbitSize*0.5);
							RabbitPositionE = XYPositions(Temp+RowOffsetVehicleRabbitPositionE,iColCount) - (RabbitSize*0.5);
							set(VehicleRabbitHandles(ArrayCount),'Visible','on','Position',[RabbitPositionN ,RabbitPositionE,RabbitSize,RabbitSize]);
						else,
							set(VehicleRabbitHandles(ArrayCount),'Visible','off');
						end;
						
						%%%%% Plot Vehicle Assignment Disk
						VehicleTargetAssignment = XYPositions(Temp+RowOffsetVehicleTargetAssignment,iColCount);
						if ((VehicleTargetAssignment > 0)&(VehicleTargetAssignment < g_MaxNumberTargets)),
							TargetPositionX = TargetPositions((VehicleTargetAssignment-1)*NumberRowsTarget+RowOffsetTargetX+2,iColCount) - (AssignmentDiskSize*0.5);
							TargetPositionY = TargetPositions((VehicleTargetAssignment-1)*NumberRowsTarget+RowOffsetTargetY+2,iColCount) - (AssignmentDiskSize*0.5);
							ThisVehicleAngle = (iCount-1) * (2*pi)/g_MaxNumberVehicles;
							TargetPositionX = TargetPositionX + AssignmentDiskOffset*cos(ThisVehicleAngle);
							TargetPositionY = TargetPositionY + AssignmentDiskOffset*sin(ThisVehicleAngle);
							set(VehicleAssignmentDiskHandles(ArrayCount),'Visible','on','Position',[TargetPositionX ,TargetPositionY, ...
									AssignmentDiskSize,AssignmentDiskSize]);
						else,	%if ((VehicleTargetAssignment > 0)&(VehicleTargetAssignment < g_MaxNumberTargets)),
							set(VehicleAssignmentDiskHandles(ArrayCount),'Visible','off','Position',[0,0,AssignmentDiskSize,AssignmentDiskSize]);
						end;	%if ((VehicleTargetAssignment > 0)&(VehicleTargetAssignment < g_MaxNumberTargets)),
						
					else
						CreateVehicleGraphic('Draw',GraphicStructArray(ArrayCount),1000000,1000000,XYPositions(Temp+RowOffsetVehicleHeadingAngle,iColCount)*pi/180,ColorsArrayRGBVehicle(iCount,:),ColorsArrayRGBVehicle(iCount,:),iCount);
						set(VehicleRabbitHandles(ArrayCount),'Visible','off','Position',[0,0,RabbitSize,RabbitSize]);
						set(VehicleAssignmentDiskHandles(ArrayCount),'Visible','off','Position',[0,0,AssignmentDiskSize,AssignmentDiskSize]);
					end;
					
					
					ArrayCount = ArrayCount + 1;
				end;	%if GraphicStructArray(iCount) ~= 0
				Temp = Temp + NumberRowsVehicle;
			end;	%for iCount = 1:g_MaxNumberVehicles
			
			%%%%%%%%%%%%%%%% Plot Targets   %%%%%%%%%%%%%%%%%%%%%%%%
			Temp = 2;
			for (iCount = 1:g_MaxNumberTargets),
				TargetStatus = TargetPositions(iCount+RowOffsetTargetStatus,iColCount) + 1;	%change from zero based index
				TargetStatus = rem(TargetStatus,g_TargetStates.IncAttack);
				TargetAlive = TargetPositions(Temp+RowOffsetTargetAlive,iColCount);	
				if (TargetAlive >= 0),
					if (TargetStatus > 0),
						if TargetStatus <= g_TargetStates.NumberStates,
							TargetFaceColor = ColorsArrayRGBTargetState(TargetStatus+1,:);  %add 1 to move undefined (-1) to the index 1
							TargetEdgeColor = ColorsArrayRGBTargetState(TargetStatus+1,:);
						else,	%if TargetStatus < 6
							TargetFaceColor = [0.0,0.0,0.0];
							TargetEdgeColor = [0.0,0.0,0.0];
						end;	%if TargetStatus < 6
						
						Rotation = TargetPositions(Temp+RowOffsetTargetPsi,iColCount);
						rotMatrix = [cos(Rotation) -sin(Rotation) 0 ; sin(Rotation) cos(Rotation) 0; 0 0 1];
						RotMatrixTargetRect =  MatrixTargetRect{iCount} * rotMatrix;
						set(TargetGraphicsHandles(iCount),'XData',RotMatrixTargetRect(:,1)+TargetPositions(Temp+RowOffsetTargetX,iColCount), ...
							'YData',RotMatrixTargetRect(:,2)+TargetPositions(Temp+RowOffsetTargetY,iColCount), ...
							'ZData',RotMatrixTargetRect(:,3)+TargetPositions(Temp+RowOffsetTargetZ,iColCount), ...
							'FaceColor',TargetFaceColor,'EdgeColor',TargetEdgeColor, ...
							'EraseMode','normal','FaceLighting','none','Visible','on');
						set(TargetTextHandles(iCount),'Position',[TargetPositions(Temp+RowOffsetTargetX,iColCount),TargetPositions(Temp+RowOffsetTargetY,iColCount)],'String',num2str(iCount), ...
							'HorizontalAlignment','left','VerticalAlignment','middle', ...
							'FontWeight','bold','FontSize',12,'Visible','on');
					end;	%      if (TargetStatus > 0),                                             
				else,	%      if (TargetAlive > 0),                                             
					set(TargetGraphicsHandles(iCount),'Visible','off');
					set(TargetTextHandles(iCount),'Visible','off');
				end;	%      if (TargetAlive > 0),                                             
				Temp = Temp + NumberRowsTarget;
			end;	%for (iCount = 1:g_MaxNumberTargets),
			%%%%%%%%%%%%%%%% Simulation Time Printout   %%%%%%%%%%%%%%%%%%%%%%%%
			set(handleText,'String',num2str(XYPositions(1,iColCount),'%4.2f'));
			%%%%%%%%%%%%%%%% Slider Position            %%%%%%%%%%%%%%%%%%%%%%%%
			set(handleSlider,'Value',XYPositions(1,iColCount));
			
			if (OneTime <= 0)
				iColCount = iColCount + RunSpeed + DataIncrement - 1;
			else,
				iColCount = iColCount + RunSpeed;
			end;
			
			if(iColCount >= EndIndex)
				iColCount = EndIndex;
				AnimateFlag = 0;
				PauseAnimation = 0;
				if(~isempty(AnimationFigure) )
					set(handlePauseButton,'Value',PauseAnimation);
				end;
				if(~isempty(AnimationFigure) )
					set(handleAnimateButton,'Value',0);
				end;
			end;
		end;	%if(PauseAnimation=1),
		
		%%%%%%%%%%%%%%%% pause between plot updates for animation          %%%%%%%%%%%%%%%%%%%%%%%%
		if(OneTime < 0),
			pause(DelayTime);
		end;
		
		if (StopAnimation),
			AnimateFlag = 0;
			PauseAnimation = 0;
			if(~isempty(AnimationFigure) )
				set(handlePauseButton,'Value',PauseAnimation);
			end;
			if(~isempty(AnimationFigure) )
				set(handleAnimateButton,'Value',0);
			end;
		end;
	end;	%while(AnimateFlag),
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'SliderCallback',
	SliderTime = get(handleSlider,'Value');
	PlotOutput('PlotData',0,1,SliderTime);
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'CompleteTrajectoryCallback',
	TrajectoryCheck = get(handleTrajectoryTrail,'Value');
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'CallbackDelayTime',
	DelayTime = DelayTimes(get(handleDelayTime,'Value'));
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'CallbackPlotLineWidth',
	PlotLineWidth = PlotLineWidths(get(handlePlotLineWidth,'Value'));
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'CallbackMilesFeet',
	PlotUnits = get(handleMilesFeet,'Value');
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'CallbackWayPointDisplay',
	PlotWaypoints = get(handleWayPointDisplay,'Value')-1;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'CallbackRabbitDisplay',
	PlotRabbits = get(handleRabbitDisplay,'Value')-1;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'CallbackBackgroundColor',
	BackgroundColorIndex = get(handleBackgroundColor,'Value');
	BackgroundColor = BackgroundColors(BackgroundColorIndex,:);
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'CallbackDataIncrement',
	DataIncrement = get(handleDataIncrement,'Value');
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end;	%switch(Action)
return	%PlotOutput
