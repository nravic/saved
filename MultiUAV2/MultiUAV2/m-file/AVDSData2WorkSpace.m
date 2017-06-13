function AVDSData2WorkSpace(InputData)
%AVDSData2WorkSpace - This function saves AVDS Playback data from SIMULINK to the Global Workspace.
%
%  Inputs:
%    InputData - This is a vector that contains the data to be saved. The order of the elements
%      of the vector is defined by the connections to the SIMULINK blocks that calls this function.
%      Required elements in the vector are:
%        InputVector(1) - Vehicle identification number.
%        InputVector(2) - elapsed simulation time.
%        InputVector(3) - type of data.
%          The data types of SIMULINK inputs supported are:
%           1 - The trajectory data from the aircraft.
%           2 - The trajectory data from the targets.
%		For all data types the input column definitions are listed below in the code.
%
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS
%  October 2000 - Modified to take advantage of new AVDS functions - RAS


global g_Debug; if(g_Debug==1),disp('AVDSData2WorkSpace.m');end; 

GroundHeightCorrection = 1000;
GroundHeightCorrection = 100;
GroundHeightCorrection = 10;

global g_AVDSVehicleCells;
global g_AVDSTargetCells;
global g_MaxNumberVehicles;
global g_Tasks;
global g_TargetStates;
global g_TargetMemory;
global g_SampleTime;
global g_EntityTypes;
global g_DefaultWaypointAltitude;
global g_VehicleColors;
global g_Colors;

VehicleID = InputData(1);
iLength = length(InputData);
Data = InputData(2:(iLength-1))';
DataType = InputData(iLength);

iIndexAliveAircraft = length(Data);
iIndexTargetStatus = length(Data);

SamplePeriod = g_SampleTime;	%sample period for saved data 
if rem(InputData(2),SamplePeriod) ~= 0,	%% sets frequency of data saved to 1/SamplePeriod
   if (DataType==g_EntityTypes.Aircraft),
      AliveCheck = Data(iIndexAliveAircraft);
      if AliveCheck ~= 0
         AliveCheck = 0;	%dead
      else,
         AliveCheck = 1;
      end;
   elseif (DataType==g_EntityTypes.Target),
      AliveCheck = Data(iIndexTargetStatus);
   else
      AliveCheck = 1;
   end;
   
   if (AliveCheck <= 3 ), 	%if vehicle is not alive then need to save the data so don't return here
      return;
   end;
end;

% The next few lines set up the AVDS craft type to use for various situations, i.e. different 
% types of vehicles, different colors, etc. The craftcap.txt must match these entries
%vehicles
CraftVehicleUCAV = 0;
CraftVehicleSensorRectangle = 1;
CraftVehicleMarker = 2;
CraftInvisibleNoTrail = 3;
%targets
CraftVehicleSATrailerUp = 4;
CraftVehicleSATrailerDown = 5;
CraftVehicleRadarUp = 6;
CraftVehicleRadarDown = 7;
CraftVehicleNonTarget = 8;
CraftExplosion = 9;
CraftRabbit = 10;

%targets
NumberTargetTypes = 5;
CraftTargets = zeros(NumberTargetTypes ,1);
CraftTargets(1) = CraftVehicleSATrailerUp;
CraftTargets(2) = CraftVehicleSATrailerDown;
CraftTargets(3) = CraftVehicleRadarUp;
CraftTargets(4) = CraftVehicleRadarDown;
CraftTargets(5) = CraftVehicleNonTarget;



switch (DataType)
case g_EntityTypes.Aircraft,
   
   [CellRows, CellCols] = size(g_AVDSVehicleCells{VehicleID});
	%% data type column definitions (for 'Data' vector)
	iIndexCount = 1;
	iIndexTime = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexPositionX = iIndexCount; 	iIndexCount = iIndexCount + 1; 
	iIndexPositionY = iIndexCount; 	iIndexCount = iIndexCount + 1; 
	iIndexPositionZ = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexRotationX = iIndexCount; 	iIndexCount = iIndexCount + 1; 
	iIndexRotationY = iIndexCount; 	iIndexCount = iIndexCount + 1; 
	iIndexRotationZ = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexAlpha = iIndexCount; 	iIndexCount = iIndexCount + 1; 
	iIndexBeta = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexVelocityFPS = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexMach = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexAssignedTarget = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexAssignedTask = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexRabbitY = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexRabbitX = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexRabbitHeading = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexCommandedAltitude = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexCommandedSensorOn = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexAlive = iIndexCount;

	ScanCircleStandOff = 2.870734908125e+003;	% 1000 meters - 125 meter (this makes the leading edge of the rectangular sensor 1000m from the vehicle;
	Rotation = HeadingToAngle(Data(iIndexRotationZ));
   
 	TargetPositionX = realmax;
	TargetPositionY = realmax;
	
	TargetMarkerColorOffset = g_VehicleColors.ColorVehiclesAVDS(VehicleID) - (g_Colors.AVDSTransparent1*180); %make the sensor transparent
	AssignmentDiskOffset = 500;
	if(Data(iIndexAssignedTarget) > 0),
		TargetPositionX = g_TargetMemory(Data(iIndexAssignedTarget)).PositionX;
		TargetPositionY = g_TargetMemory(Data(iIndexAssignedTarget)).PositionY;
		TargetMarkerX = TargetPositionX;
		TargetMarkerY = TargetPositionY;
		ThisVehicleAngle = (VehicleID-1) * (2*pi)/g_MaxNumberVehicles;
		TargetMarkerX = TargetMarkerX + AssignmentDiskOffset*cos(ThisVehicleAngle);
		TargetMarkerY = TargetMarkerY + AssignmentDiskOffset*sin(ThisVehicleAngle);
		
		TargetMarkerCraftType = CraftVehicleMarker;
		TargetMarkerZ = GroundHeightCorrection + 10;
	else,	%if(iIndexAssignedTarget > 0),
		TargetMarkerX = realmax;
		TargetMarkerY = realmax;
		TargetMarkerCraftType = CraftInvisibleNoTrail;
   		TargetMarkerZ = -1000.0;
	end;	%if(iIndexAssignedTarget > 0),
   
	SensorX = Data(iIndexPositionX) + ScanCircleStandOff*sin(Rotation*pi/180);	
	SensorY = Data(iIndexPositionY) + ScanCircleStandOff*cos(Rotation*pi/180);
    SensorScale = 1.0;
  
	if(Data(iIndexAssignedTask) == g_Tasks.Attack),
		DistanceToTarget = ((Data(iIndexPositionX) - TargetPositionX)^2+(Data(iIndexPositionY) - TargetPositionY)^2)^0.5;
		if(DistanceToTarget < ScanCircleStandOff),
			SensorX = TargetPositionX;	
			SensorY = TargetPositionY;
		end;
		SensorScale = Data(iIndexPositionZ)/g_DefaultWaypointAltitude;
		if(SensorScale > 1.0),
			SensorScale = 1.0;
		elseif (SensorScale < -1.0),
			SensorScale = 0.0;
		end;
   	end;    %if(Data(iIndexAssignedTask) == g_Tasks.Attack),
    SensorScaleX = SensorScale;
    SensorScaleY = SensorScale;

	SensorColorOffset = g_VehicleColors.ColorVehiclesAVDS(VehicleID);
   	if Data(iIndexAlive) ~= 0
   		SensorCraftType = CraftInvisibleNoTrail;
		SensorX = realmax;
		SensorY = realmax;
   	else,
	    SensorCraftType = CraftVehicleSensorRectangle;
        if(Data(iIndexCommandedSensorOn)),
			SensorColorOffset = SensorColorOffset - (g_Colors.AVDSTransparent1*130); %make the sensor transparent
		else,
			SensorColorOffset = SensorColorOffset - (g_Colors.AVDSTransparent1*200); %make the sensor transparent
		end;	%if(SensorOn),
   	end;
   %SensorAltitude = 200 + VehicleID*20;
   %SensorAltitude = 20 + VehicleID*20 + GroundHeightCorrection;
   SensorAltitude = VehicleID*2 + GroundHeightCorrection + 15.0;
   
   % for displaying the control system "rabbit"
	if Data(iIndexAlive) ~= 0
		RabbitX = g_AVDSVehicleCells{VehicleID}(CellRows,CellCols-4);
		RabbitY = g_AVDSVehicleCells{VehicleID}(CellRows,CellCols-3);
		RabbitZ = g_AVDSVehicleCells{VehicleID}(CellRows,CellCols-2);
		RabbitHeading = g_AVDSVehicleCells{VehicleID}(CellRows,CellCols-1);
	else,
		RabbitX = Data(iIndexRabbitX);
		RabbitY = Data(iIndexRabbitY);
		RabbitZ = Data(iIndexCommandedAltitude);
		RabbitHeading = 90 - Data(iIndexRabbitHeading) * 180 / pi;
	end;
	
	
	if Data(iIndexAlive) ~= 0
		TargetMarkerX = realmax;
		TargetMarkerY = realmax;
		TargetMarkerCraftType = CraftInvisibleNoTrail;
   		TargetMarkerZ = -1000.0;
	end;
		
	VehicleColorOffset = g_VehicleColors.ColorVehiclesAVDS(VehicleID);
	VehicleType = CraftVehicleUCAV;
	IndexCraftType = 12;
	if Data(iIndexAlive) ~= 0
		if(g_AVDSVehicleCells{VehicleID}(end,IndexCraftType)~= CraftInvisibleNoTrail),	%don't do this more than once
			[AddtionalTimeVector,VectorAVDSCraftType,VectorAVDSColors, VectorAVDSXYZSize] = CreateExplosion(g_AVDSVehicleCells{VehicleID}(end,iIndexTime),CraftExplosion);
			RowsTime = size(AddtionalTimeVector,1);
			for (iAddExplosion = 1:RowsTime),
   				g_AVDSVehicleCells{VehicleID} = [g_AVDSVehicleCells{VehicleID};...
         									[AddtionalTimeVector(iAddExplosion),Data((iIndexTime+1):iIndexRotationY),Rotation,Data(iIndexAlpha:iIndexMach), ...
											VectorAVDSCraftType(iAddExplosion),VectorAVDSColors(iAddExplosion), ...
                                       SensorX,SensorY,SensorAltitude,SensorCraftType,SensorScaleX,SensorScaleY,SensorColorOffset, ...
									   TargetMarkerX,TargetMarkerY,TargetMarkerZ,TargetMarkerCraftType,TargetMarkerColorOffset, ...
                                       RabbitX, RabbitY, RabbitZ, RabbitHeading, CraftRabbit,VectorAVDSXYZSize(iAddExplosion)]];
			end;
		end;	%if(g_AVDSVehicleCells{VehicleID}(end,IndexCraftType)~= CraftInvisibleNoTrail),
		VehicleColorOffset = VehicleColorOffset - g_Colors.AVDSTransparent255;	%make the vehicle transparent
		VehicleType = CraftInvisibleNoTrail;
	end;	%if Data(iIndexAlive) ~= 0

	VehicleScale = 1.0;
   g_AVDSVehicleCells{VehicleID} = [g_AVDSVehicleCells{VehicleID};...
         									[Data(iIndexTime:iIndexRotationY),Rotation,Data(iIndexAlpha:iIndexMach),VehicleType,VehicleColorOffset, ...
                                       SensorX,SensorY,SensorAltitude,SensorCraftType,SensorScaleX,SensorScaleY,SensorColorOffset, ...
									   TargetMarkerX,TargetMarkerY,TargetMarkerZ,TargetMarkerCraftType,TargetMarkerColorOffset, ...
                                       RabbitX, RabbitY, RabbitZ, RabbitHeading, CraftRabbit,VehicleScale]];
case g_EntityTypes.Target,
	%% data type column definitions (for 'Data' vector)
	iIndexCount = 1;
	iIndexTime = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexPositionX = iIndexCount; 	iIndexCount = iIndexCount + 1; 
	iIndexPositionY = iIndexCount; 	iIndexCount = iIndexCount + 1; 
	iIndexPositionZ = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexType = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexPsi = iIndexCount; 	iIndexCount = iIndexCount + 1;
	iIndexStatus = iIndexCount;
	
	Explode = 0;
	ColorOffset = g_TargetStates.ColorTargetStatesAVDS(-1+2);   %add 2 to move -1 to 1 for 1-based index of the array 
	Data(iIndexPositionZ) = Data(iIndexPositionZ) + GroundHeightCorrection;
	if ((Data(iIndexType) ~= 0)&(Data(iIndexType) <= NumberTargetTypes)),
		Data(iIndexType) = CraftTargets(Data(iIndexType));
		Data(iIndexStatus) = rem(Data(iIndexStatus),g_TargetStates.IncAttack);
		ColorOffset = g_TargetStates.ColorTargetStatesAVDS(Data(iIndexStatus)+2);   %add 2 to move -1 to 1 for 1-based index of the array
		Data(iIndexPsi) = Data(iIndexPsi) * (180.0/pi); 
		g_AVDSTargetCells{VehicleID} = [g_AVDSTargetCells{VehicleID};[Data,Explode,ColorOffset]];
    end;	%if (Data(iIndexType) ~= 0),
    
end;	%switch(DataType)

