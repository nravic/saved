function	InitializeVehicleTypes()
%InitializeVehicleTypes - sets the vehicle type data in the global vehicle type array.
%
%  Inputs:
%    None. 
%
%  Outputs:
%    None. 
%

%  AFRL/VACA
%  March 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('InitializeVehicleTypes.m');end; 

global g_VehicleTypes;
global g_EntityTypes;

g_VehicleTypes = [];

TempType = CreateStructure('VehicleTypeDefinitions');
TempType.EntityType = g_EntityTypes.Aircraft;
TempType.WeaponType1 = 1;
TempType.WeaponQuantity1 = 10;
TempType.WeaponType2 = 1;
TempType.WeaponQuantity2 = 10;
TempType.SensorType1 = 1;
TempType.SensorType2 = 1;
g_VehicleTypes = [g_VehicleTypes;TempType];
						
TempType = CreateStructure('VehicleTypeDefinitions');
TempType.EntityType = g_EntityTypes.Munition;
TempType.WeaponType1 = 1;
TempType.WeaponQuantity1 = 1;
TempType.WeaponType2 = 0;
TempType.WeaponQuantity2 = 0;
TempType.SensorType1 = 1;
TempType.SensorType2 = 1;
g_VehicleTypes = [g_VehicleTypes;TempType];
						

return;	%InitializeVehicleTypes.m
