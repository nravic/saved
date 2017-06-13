function TestVehicleGraphics
%TestVehicleGraphics - this is a simple function used to debug the 'CreateVehicleGraphic' function
%
%  Inputs:
%    (none) 
%
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS



global g_Debug; if(g_Debug==1),disp('TestVehicleGraphics.m');end; 

clf
axis equal;
axis([-10000 10000 -10000  10000]);
light('Position',[10000 10000 1000000]);	%prevents flickering during the simulation (I don't know why)

VehicleGraphicIn = CreateVehicleGraphic;

positionX = 0;
DeltaPositionX = 0;
DeltaPositionX = 10000/100;
positionY = 0;
DeltaPositionY = 0;
DeltaPositionY = -10000/100;
Heading = 0;
DeltaHeading = 0;
DeltaHeading = pi/50;
for iCount = 1:101
   GraphicsStruct = CreateVehicleGraphic('Draw',VehicleGraphicIn,positionX,positionY,Heading,[0.1,0.7,0.1]);
   Heading = Heading + DeltaHeading;
   positionX = positionX + DeltaPositionX;
   positionY = positionY + DeltaPositionY;
	pause(0.01);
end;
