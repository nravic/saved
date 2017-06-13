function VehicleGraphicStruct = CreateVehicleGraphic(action,VehicleGraphicIn,XPosition,YPosition,Heading,DiskColor,VehicleColor,VehicleID);
%CreateVehicleGraphic - creates, displays and repositions a graphic that represents a vehicle and sensor footprint
%
%  Inputs:
%    action - this is the mode in which the function will operate. Values include:
%      'Initialize' -  this mode builds a new vehicle graphic structure and returns it 
%      'Draw' - this mode is used to display the vehicle graphic in the location given 
%        by the rest of the inputs.
%     NOTE: the following inputs are only used in 'Draw' mode
%    VehicleGraphicIn - this is a exsiting vehicle graphics structure created using 'Initialize'
%    XPosition - the new X position of the vehicle graphic  (feet)
%    YPosition - the new X position of the vehicle graphic (feet)
%    Heading - the new heading of the vehicle graphic (radians)
%
%  Outputs:
%    VehicleGraphicStruct - this is the new vehicle graphics structure, 
%      built during 'Initialize' mode.
%

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS
%  June 2000 - Changed sensor footprint to rectangle - RAS



global g_Debug; if(g_Debug==1),disp('CreateVehicleGraphic.m');end; 

VehicleGraphicStruct = [];

if nargin <1,
   XPosition = 0;
   YPosition = 0;
   Heading = 0;
   action = 'Initialize';
end

Rotation = -(-Heading + pi/2);
rotMatrix = [cos(Rotation) -sin(Rotation) 0 ; sin(Rotation) cos(Rotation) 0; 0 0 1];

switch(action)
case 'Initialize'
	VehicleGraphicStruct = struct('HandleSensor',0,'MatrixSensor',0, ...
   									'HandleVehicleRect',0,'MatrixVehicleRect',0,...
                              'HandleVehicleWing',0,'MatrixVehicleWing',0,'HandleText',0);
   DrawCircle = 0;                        
	if DrawCircle == 1,
		ScanCircleX = 3280.839895;	%% 1000 meters;
		ScanCircleY = 0;
		ScanCircleRadius = 984.2519685;	%% 300 meters
		ScanCirclePointsX = [];
		ScanCirclePointsY = [];
		for Angle = 0:pi/6:2*pi
   		ScanCirclePointsX = [ScanCirclePointsX; ScanCircleRadius*cos(Angle) + ScanCircleX];
   		ScanCirclePointsY = [ScanCirclePointsY; ScanCircleRadius*sin(Angle) + ScanCircleY];
		end
   	[iRow,iCol] = size(ScanCirclePointsX);
   	ScanCirclePointsZ = zeros(iRow,1);
		VehicleGraphicStruct.MatrixSensor = [ScanCirclePointsX,ScanCirclePointsY,ScanCirclePointsZ];
   	VehicleGraphicStruct.HandleSensor = patch(ScanCirclePointsX,ScanCirclePointsY,ScanCirclePointsZ, ...
         'r','EraseMode','normal','FaceLighting','none');
   else,	%if DrawCircle == 1,
		ScanOffsetMax = 3280.839895;	%% 1000 meters;
		ScanOffsetMin = 2460.62992125;	%% 750 meters;
		ScanWidthO2 = 984.2519685;		%%600/2.0 meters
		ScanRectanglePointsX = [ScanOffsetMax;ScanOffsetMax;ScanOffsetMin;ScanOffsetMin];
		ScanRectanglePointsY = [ScanWidthO2;-ScanWidthO2;-ScanWidthO2;ScanWidthO2];
   	iLength = length(ScanRectanglePointsX);
   	ScanRectanglePointsZ = zeros(iLength,1);
		VehicleGraphicStruct.MatrixSensor = [ScanRectanglePointsX,ScanRectanglePointsY,ScanRectanglePointsZ];
   	VehicleGraphicStruct.HandleSensor = patch(ScanRectanglePointsX,ScanRectanglePointsY,ScanRectanglePointsZ, ...
         'r','EraseMode','normal','FaceLighting','none');
   end;	%if DrawCircle == 1,
   
   VehicleLength = 200;
	VehicleWidth = 30;
	VehicleRectanglePointsX = [-VehicleLength/2; VehicleLength/2; VehicleLength/2; -VehicleLength/2];
	VehicleRectanglePointsY = [VehicleWidth/2; VehicleWidth/2; -VehicleWidth/2; -VehicleWidth/2];
   [iRow,iCol] = size(VehicleRectanglePointsX);
   VehicleRectanglePointsZ = zeros(iRow,1);
	VehicleGraphicStruct.MatrixVehicleRect = [VehicleRectanglePointsX,VehicleRectanglePointsY,VehicleRectanglePointsZ];
   VehicleGraphicStruct.HandleVehicleRect = patch(VehicleRectanglePointsX,VehicleRectanglePointsY,VehicleRectanglePointsZ, ...
      															'r','EraseMode','normal','FaceLighting','none');

	WingOffsetX = (0.7*VehicleLength) - VehicleLength/2;
	WingOffsetY = 0/2;
	WingLength = 0.85*VehicleLength;
	WingWidth = 0.5*VehicleWidth;
	WingPointsX = [-WingWidth/2; WingWidth/2; WingWidth/2; -WingWidth/2] + WingOffsetX;
	WingPointsY = [WingLength/2; WingLength/2; -WingLength/2; -WingLength/2] + WingOffsetY;
   [iRow,iCol] = size(WingPointsX);
   WingPointsPointsZ = zeros(iRow,1);
	VehicleGraphicStruct.MatrixVehicleWing = [WingPointsX,WingPointsY,WingPointsPointsZ];
   VehicleGraphicStruct.HandleVehicleWing = patch(WingPointsX,WingPointsY,WingPointsPointsZ, ...
      														'g','EraseMode','xor');
   VehicleGraphicStruct.HandleText = text(XPosition,YPosition,' ', ...
   	'HorizontalAlignment','center','VerticalAlignment','middle', ...
   	'FontWeight','bold','FontSize',12);
   
case 'Draw'

	DataPoints = VehicleGraphicIn.MatrixSensor * rotMatrix;
	DataPointsX = DataPoints(:,1) + XPosition;
	DataPointsY = DataPoints(:,2) + YPosition;
   DataPointsZ = DataPoints(:,3) + YPosition;
   if(DiskColor == 0)
      set(VehicleGraphicIn.HandleSensor,'XData',DataPointsX,'YData',DataPointsY,'ZData',DataPointsZ,'FaceColor','none');
   else,
      set(VehicleGraphicIn.HandleSensor,'XData',DataPointsX,'YData',DataPointsY,'ZData',DataPointsZ,'FaceColor',DiskColor);
   end;
	DataPoints = VehicleGraphicIn.MatrixVehicleRect * rotMatrix;
	DataPointsX = DataPoints(:,1) + XPosition;
	DataPointsY = DataPoints(:,2) + YPosition;
	DataPointsZ = DataPoints(:,3) + YPosition;
	set(VehicleGraphicIn.HandleVehicleRect,'XData',DataPointsX,'YData',DataPointsY,'ZData',DataPointsZ)
	DataPoints = VehicleGraphicIn.MatrixVehicleWing * rotMatrix;
	DataPointsX = DataPoints(:,1) + XPosition;
	DataPointsY = DataPoints(:,2) + YPosition;
	DataPointsZ = DataPoints(:,3) + YPosition;
   set(VehicleGraphicIn.HandleVehicleWing,'XData',DataPointsX,'YData',DataPointsY,'ZData',DataPointsZ)
   VehicleIDString = sprintf('%1.1d',VehicleID);
   set(VehicleGraphicIn.HandleText,'Position',[XPosition,YPosition],'String',VehicleIDString,'Color',VehicleColor)
   
end;	%% switch(action)
return
