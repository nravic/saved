load 'SimulationData.txt'
	DebugTime = 1;
	fcsinThrottle = 2;
	fcsinPitchRateCmdDegPerSec = 3;
	fcsinRollRateCmdDegPerSec = 4;
	fcsinYawRateCmdDegPerSec = 5;
	stateVTFeetPerSec = 6;
	stateAlphaRad = 7;
	stateBetaRad = 8;
	statePhiRad = 9;
	stateThetaRad = 10;
	statePsiRad = 11;
	statePRadPerSec = 12;
	stateQRadPerSec = 13;
	stateRRadPerSec = 14;
	stateNorthFeet = 15;
	stateEastFeet = 16;
	stateAltitudeFeet = 17;
	statePower = 18;
	stateElevatorDeg = 19;
	stateAileronDeg = 20;
	stateRudderDeg = 21;

LengthData = size(SimulationData,1);
PlotRange = [1:LengthData];
figure(5100);
clf;
subplot(3,2,1);
plot(SimulationData(PlotRange,DebugTime), ...
	[SimulationData(PlotRange,fcsinPitchRateCmdDegPerSec),SimulationData(PlotRange,stateQRadPerSec)*180/pi,SimulationData(PlotRange,stateElevatorDeg)]);
title 'Pitch';
legend('Pitch Rate Command','Pitch Rate','Elevator Deflection');
subplot(3,2,3);
plot(SimulationData(PlotRange,DebugTime), ...
	[SimulationData(PlotRange,fcsinRollRateCmdDegPerSec),SimulationData(PlotRange,statePRadPerSec)*180/pi,SimulationData(PlotRange,stateAileronDeg)]);
title 'Roll';
legend('Roll Rate Command','Roll Rate','Aileron Deflection');
subplot(3,2,5);
plot(SimulationData(PlotRange,DebugTime), ...
	[SimulationData(PlotRange,fcsinYawRateCmdDegPerSec),SimulationData(PlotRange,statePsiRad)*180/pi,SimulationData(PlotRange,stateRudderDeg)]);
title 'Yaw';
legend('Yaw Rate Command','Beta (deg)','Rudder Deflection');
subplot(3,2,2);
plot(SimulationData(PlotRange,DebugTime), ...
	[SimulationData(PlotRange,stateAltitudeFeet)]);
title 'Altitude';
subplot(3,2,4);
plot(SimulationData(PlotRange,DebugTime), ...
	[SimulationData(PlotRange,stateVTFeetPerSec)]);
title 'Velocity';
subplot(3,2,6);
plot(SimulationData(PlotRange,DebugTime), ...
	[SimulationData(PlotRange,fcsinThrottle)*100,SimulationData(PlotRange,statePower)]);
title 'Throttle';



