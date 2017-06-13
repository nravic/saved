function [Xinit] = TrimValues(acftType,IndexOut,TrimU,TrimW,TrimTheta,TrimAltitude,TrimEnginePowerLevel)

%Set Vehicle Type
acftLocaas = 0;
acftGlobalHawk = 1;
acftICE = 2;

switch(acftType),
case acftLocaas,
	% select trim values
	TrimU = 380.0;
	TrimW = -5.0;
	TrimTheta = 0.0*pi/180.0;
	TrimAltitude = -5000.0;
	TrimEnginePowerLevel = 0.4;
	% set-up initial states
	Xinit = zeros(IndexOut.TotalIndexState,1);
	Xinit(IndexOut.stateActuator0) = 0.0;
	Xinit(IndexOut.stateActuator1) = 0.0;
	Xinit(IndexOut.stateActuator2) = 0.0;
	Xinit(IndexOut.stateU_FeetPerSec) = TrimU;
	Xinit(IndexOut.stateV_FeetPerSec) = 0.0;
	Xinit(IndexOut.stateW_FeetPerSec) = TrimW;
	Xinit(IndexOut.stateP_RadPerSec) = 0.0;
	Xinit(IndexOut.stateQ_RadPerSec) = 0.0;
	Xinit(IndexOut.stateR_RadPerSec) = 0.0;
	Xinit(IndexOut.statePhi_Rad) = 0.0;
	Xinit(IndexOut.stateTheta_Rad) = TrimTheta;
	Xinit(IndexOut.statePsi_Rad) = 0.0;
	Xinit(IndexOut.stateX_Feet) = 0.0;
	Xinit(IndexOut.stateY_Feet) = 0.0;
	Xinit(IndexOut.stateZ_Feet) = TrimAltitude;
	Xinit(IndexOut.statePowerLevel_pct) = TrimEnginePowerLevel;
case acftGlobalHawk,
	TrimU = 250.0;
	TrimW = -5.0;
	TrimTheta = 0.0*pi/180.0;
	TrimAltitude = -5000.0;
	TrimEnginePowerLevel = 0.4;
	% set-up initial states
	Xinit = zeros(IndexOut.TotalIndexState,1);
	Xinit(IndexOut.stateActuator0) = 0.0;
	Xinit(IndexOut.stateActuator1) = 0.0;
	Xinit(IndexOut.stateActuator2) = 0.0;
	Xinit(IndexOut.stateActuator3) = 0.0;
	Xinit(IndexOut.stateU_FeetPerSec) = TrimU;
	Xinit(IndexOut.stateV_FeetPerSec) = 0.0;
	Xinit(IndexOut.stateW_FeetPerSec) = TrimW;
	Xinit(IndexOut.stateP_RadPerSec) = 0.0;
	Xinit(IndexOut.stateQ_RadPerSec) = 0.0;
	Xinit(IndexOut.stateR_RadPerSec) = 0.0;
	Xinit(IndexOut.statePhi_Rad) = 0.0;
	Xinit(IndexOut.stateTheta_Rad) = TrimTheta;
	Xinit(IndexOut.statePsi_Rad) = 0.0;
	Xinit(IndexOut.stateX_Feet) = 0.0;
	Xinit(IndexOut.stateY_Feet) = 0.0;
	Xinit(IndexOut.stateZ_Feet) = TrimAltitude;
	Xinit(IndexOut.statePowerLevel_pct) = TrimEnginePowerLevel;
case acftICE,
	TrimU = 600.0;
	TrimU = 1200.0;
	TrimW = 40.0;
	TrimTheta = 3.7*pi/180.0;
	TrimAltitude = -5000.0;
	TrimEnginePowerLevel = 0.5;
	% set-up initial states
	Xinit = zeros(IndexOut.TotalIndexState,1);
	Xinit(IndexOut.stateActuator0) = 0.0;
	Xinit(IndexOut.stateActuator1) = 0.0;
	Xinit(IndexOut.stateActuator2) = 0.0;
	Xinit(IndexOut.stateActuator3) = 0.0;
	Xinit(IndexOut.stateActuator4) = 0.0;
	Xinit(IndexOut.stateActuator5) = 0.0;
	Xinit(IndexOut.stateActuator6) = 0.0;
	Xinit(IndexOut.stateActuator7) = 0.0;
	Xinit(IndexOut.stateActuator8) = 0.0;
	Xinit(IndexOut.stateU_FeetPerSec) = TrimU;
	Xinit(IndexOut.stateV_FeetPerSec) = 0.0;
	Xinit(IndexOut.stateW_FeetPerSec) = TrimW;
	Xinit(IndexOut.stateP_RadPerSec) = 0.0;
	Xinit(IndexOut.stateQ_RadPerSec) = 0.0;
	Xinit(IndexOut.stateR_RadPerSec) = 0.0;
	Xinit(IndexOut.statePhi_Rad) = 0.0;
	Xinit(IndexOut.stateTheta_Rad) = TrimTheta;
	Xinit(IndexOut.statePsi_Rad) = 0.0;
	Xinit(IndexOut.stateX_Feet) = 0.0;
	Xinit(IndexOut.stateY_Feet) = 0.0;
	Xinit(IndexOut.stateZ_Feet) = TrimAltitude;
	Xinit(IndexOut.statePowerLevel_pct) = TrimEnginePowerLevel;
end;
