% test VehicleDynamicsMex

%action flags for call to VehicleDynamicsMex
actionsInitialize = 1;
actionsUpdate = 2;
actionsClear = 3;
actionsPrintLabels = 4;

%Set Sim Time before indices, indices change for different control methods!!!
TimeIncrement = 0.01;
TimeStop = 50.0;

SimulationTime = [0.0:TimeIncrement:TimeStop]';
LengthTime = size(SimulationTime,1);

%Set Command System Type and Control Allocation method
cmdtypeAPBV = 0; % Alt, Psi, Beta, Vel command system
cmdtypePQRT = 1; % P, Q, R, Throttle command system
cmdtype = cmdtypeAPBV;
%cmdtype = cmdtypePQRT;

%Set Command System Type and Control Allocation method
ctlallcPseudo = 0; % Pseudo inverse control allocation 
ctlallcLinearProgram = 1; % Linear Program control allocation
%ctlallcmeth = ctlallcPseudo;
ctlallcmeth = ctlallcLinearProgram;

%Choose vehicle type Pararamter and Data files here
acftLocaas = 0;
acftGlobalHawk = 1;
acftICE = 2;
acftType = acftGlobalHawk;
%acftType = acftLocaas;
% acftType = acftICE;

SubtractBaseTables = 1;	% if the increment tables in the data file contain the base table data, then the base table data must be subtracted from the increment tables.
% set parameter and data file names

switch(acftType),
case acftLocaas,
	FileNameData = 'DATCOM.locaas.dat';
	FileNameParameters = 'Parameters.locaas.dat';
case acftGlobalHawk,
	FileNameData = 'DATCOM.globalhawk.dat';
	FileNameParameters = 'Parameters.globalhawk.dat';
case acftICE,
	FileNameData = 'DATCOM.ice.dat';
	FileNameParameters = 'Parameters.ice.dat';
	SubtractBaseTables = 0;
end;

% build path info
tdir = ['..', filesep, '..', filesep, '..', filesep];
idir = [tdir, 'InputFiles', filesep];
mdir = [tdir, 'm-file', filesep];

% set path(s)
addpath( mdir );
addpath( GetLibDir(tdir) );

% prepend path info to data files:
FileNameData = [idir, FileNameData];
FileNameParameters = [idir, FileNameParameters];


% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %PRINT OUT STATE and OUTPUT LABELs
% VehicleModelInstance = VehicleDynamicsMex(actionsInitialize,[],[],cmdtype,ctlallcmeth,FileNameData,FileNameParameters,SubtractBaseTables);
% VehicleDynamicsMex(actionsPrintLabels,VehicleModelInstance);
% clear all;fprintf('\n\r%s\r\r','All data has been cleared')
% return;
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%set-up output/state indicies
[IndexOut] = CreateIndicies(cmdtype,acftType);

if cmdtype == cmdtypePQRT
	ratePCmd = 0.0*ones(LengthTime,1);
	rateQCmd = 0.0*ones(LengthTime,1);
	rateRCmd = 0.0*ones(LengthTime,1);
	engThrottleCmd = 0.6*ones(LengthTime,1);
	
	%Step rate commands, Single Channel
	CmdMagP = 0.3;
	CmdMagQ = 0.00;
	CmdMagR = 0.00;
	
	MagnitudeP = CmdMagP; MagnitudeQ = CmdMagQ; MagnitudeR = CmdMagR;
	TimeOnset = 1;%floor(2*LengthTime/10); 
	TimeEnd = floor(10*LengthTime/10);
	TimeSpan = [TimeOnset:TimeEnd]; TimeSpanLength = length(TimeSpan);
	ratePCmd(TimeSpan) = MagnitudeP*ones(TimeSpanLength,1) + ratePCmd(TimeSpan);
	rateQCmd(TimeSpan) = MagnitudeQ*ones(TimeSpanLength,1) + rateQCmd(TimeSpan);
	rateRCmd(TimeSpan) = MagnitudeR*ones(TimeSpanLength,1) + rateRCmd(TimeSpan);
	
	    MagnitudeP = -CmdMagP; MagnitudeQ = -CmdMagQ; MagnitudeR = -CmdMagR;
	    TimeOnset = floor(2*LengthTime/10); 
	    TimeEnd = floor(10*LengthTime/10);
	    TimeSpan = [TimeOnset:TimeEnd]; TimeSpanLength = length(TimeSpan);
	    ratePCmd(TimeSpan) = MagnitudeP*ones(TimeSpanLength,1) + ratePCmd(TimeSpan);
	    rateQCmd(TimeSpan) = MagnitudeQ*ones(TimeSpanLength,1) + rateQCmd(TimeSpan);
	    rateRCmd(TimeSpan) = MagnitudeR*ones(TimeSpanLength,1) + rateRCmd(TimeSpan);
	%  
	%     MagnitudeP = CmdMagP; MagnitudeQ = CmdMagQ; MagnitudeR = CmdMagR;
	%     TimeOnset = floor(4*LengthTime/6); 
	%     TimeEnd = floor(5*LengthTime/6);
	%     TimeSpan = [TimeOnset:TimeEnd]; TimeSpanLength = length(TimeSpan);
	%     ratePCmd(TimeSpan) = MagnitudeP*ones(TimeSpanLength,1) + ratePCmd(TimeSpan);
	%     rateQCmd(TimeSpan) = MagnitudeQ*ones(TimeSpanLength,1) + rateQCmd(TimeSpan);
	%     rateRCmd(TimeSpan) = MagnitudeR*ones(TimeSpanLength,1) + rateRCmd(TimeSpan);
	
	%     %Multi-Channel Commands
	%     Magnitude = 0.1;
	%     TimeOnset = floor(1*LengthTime/5); 
	%     TimeEnd = floor(5*LengthTime/5);
	%     TimeSpan = [TimeOnset:TimeEnd]; TimeSpanLength = length(TimeSpan);
	%     ratePCmd(TimeSpan) = Magnitude*ones(TimeSpanLength,1) + ratePCmd(TimeSpan);
	% 
	%     Magnitude = -0.01;
	%     TimeOnset = floor(0.01*LengthTime/10); 
	%     TimeEnd = floor(5*LengthTime/5);
	%     TimeSpan = [TimeOnset:TimeEnd]; TimeSpanLength = length(TimeSpan);
	%     rateQCmd(TimeSpan) = Magnitude*ones(TimeSpanLength,1) + rateQCmd(TimeSpan);
	%     
	%     Magnitude = 0.0;
	%     TimeOnset = floor(0.5*LengthTime/6); 
	%     TimeEnd = floor(6*LengthTime/6);
	%     TimeSpan = [TimeOnset:TimeEnd]; TimeSpanLength = length(TimeSpan);
	%     rateRCmd(TimeSpan) = Magnitude*ones(TimeSpanLength,1) + rateRCmd(TimeSpan);
	
end

% select trim values
TrimU = 250.0;
TrimW = -5.0;
TrimTheta = 0.0*pi/180.0;
TrimAltitude = -5000.0;
TrimEnginePowerLevel = 0.4;

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

%create and initialize vehicle model
VehicleModelInstance = VehicleDynamicsMex(actionsInitialize,[],Xinit,cmdtype,ctlallcmeth,FileNameData,FileNameParameters,SubtractBaseTables);
%build input vectors
AltitudeTrim_ft = -TrimAltitude;
HeadingTrim_deg = 0.0;
VelocityTrim_fps = TrimU;

AltitudeCmd1 = 0.0*ones(LengthTime,1) + AltitudeTrim_ft;
HeadingCmd1 = 0.0*ones(LengthTime,1) + HeadingTrim_deg;
VelocityCmd1 = 0.0*ones(LengthTime,1) + VelocityTrim_fps;

MagnitudeCmd = 500;
Magnitude = MagnitudeCmd;
TimeOnset = floor(0.5*LengthTime/5);
TimeEnd = floor(2*LengthTime/5);
% 	TimeOnset = 1;
% 	TimeStop = LengthTime;
TimeSpan = [TimeOnset:TimeEnd];TimeSpanLength = length(TimeSpan);
AltitudeCmd1(TimeSpan) = Magnitude*ones(TimeSpanLength,1) + AltitudeTrim_ft;

Magnitude = 500;
TimeOnset = floor(2*LengthTime/5);
TimeEnd = floor(5*LengthTime/5);
%	TimeStop = LengthTime;
TimeSpan = [TimeOnset:TimeEnd];TimeSpanLength = length(TimeSpan);
AltitudeCmd1(TimeSpan) = Magnitude*ones(TimeSpanLength,1) + AltitudeTrim_ft;

Magnitude = 179.0*pi/180.0;
TimeOnset = floor(0.5*LengthTime/5);
TimeEnd = floor(5*LengthTime/5);
% 	TimeOnset = 1;
% 	TimeStop = LengthTime;
TimeSpan = [TimeOnset:TimeEnd];TimeSpanLength = length(TimeSpan);
HeadingCmd1(TimeSpan) = Magnitude*ones(TimeSpanLength,1) + HeadingTrim_deg;

% Magnitude = 180.0*pi/180.0;
% TimeOnset = floor(3*LengthTime/5);
% TimeEnd = floor(5*LengthTime/5);
% %	TimeStop = LengthTime;
% TimeSpan = [TimeOnset:TimeEnd];TimeSpanLength = length(TimeSpan);
% HeadingCmd1(TimeSpan) = Magnitude*ones(TimeSpanLength,1) + HeadingTrim_deg;

% Magnitude = 90.0*pi/180.0;
% TimeOnset = floor(3*LengthTime/5);
% TimeEnd = floor(5*LengthTime/5);
% %	TimeStop = LengthTime;
% TimeSpan = [TimeOnset:TimeEnd];TimeSpanLength = length(TimeSpan);
% HeadingCmd1(TimeSpan) = Magnitude*ones(TimeSpanLength,1) + HeadingTrim_deg;

Magnitude = -100;
TimeOnset = floor(1*LengthTime/5);
TimeEnd = floor(2*LengthTime/5);
% 	TimeOnset = 1;
% 	TimeStop = LengthTime;
TimeSpan = [TimeOnset:TimeEnd];TimeSpanLength = length(TimeSpan);
VelocityCmd1(TimeSpan) = Magnitude*ones(TimeSpanLength,1) + VelocityTrim_fps;

Magnitude = -100;
TimeOnset = floor(2*LengthTime/5);
TimeEnd = floor(5*LengthTime/5);
%	TimeStop = LengthTime;
TimeSpan = [TimeOnset:TimeEnd];TimeSpanLength = length(TimeSpan);
VelocityCmd1(TimeSpan) = Magnitude*ones(TimeSpanLength,1) + VelocityTrim_fps;

AltitudeCmd2 = -TrimAltitude*ones(LengthTime,1);
HeadingCmd2 = 0.0*pi/180*ones(LengthTime,1);
VelocityCmd2 = TrimU*ones(LengthTime,1);
BetaCmd = zeros(LengthTime,1);

PsiCmd = HeadingCmd1;
AltitudeCmd = AltitudeCmd1;
VelocityCmd = VelocityCmd2;

%run simulation
tic
if cmdtype == cmdtypeAPBV,
	Command.PsiCmd = PsiCmd;
	Command.AltitudeCmd = AltitudeCmd;
	Command.BetaCmd = BetaCmd;
	Command.VelocityCmd = VelocityCmd;
	InputVector = [SimulationTime,PsiCmd,AltitudeCmd,BetaCmd,VelocityCmd];
elseif  cmdtype == cmdtypePQRT
	Command.ratePCmd = ratePCmd;
	Command.rateQCmd = rateQCmd;
	Command.rateRCmd = rateRCmd;
	Command.engThrottleCmd = engThrottleCmd;
	InputVector = [SimulationTime,ratePCmd,rateQCmd,rateRCmd,engThrottleCmd];
end
OutputMatrix = VehicleDynamicsMex(actionsUpdate,VehicleModelInstance,InputVector);
SaveTime = SimulationTime;
RunTime = toc;

RunTime
TimeStop
FractionSimTimeOverRunTime = TimeStop/RunTime

%clear instance of vehicle model
VehicleDynamicsMex(actionsClear,VehicleModelInstance);
%VehicleDynamicsMex(actionsClear);

switch acftType,
case acftLocaas,
	PlotLocaas(OutputMatrix,SaveTime,IndexOut,cmdtype,Command);
case acftGlobalHawk,
	PlotGlobalHawk(OutputMatrix,SaveTime,IndexOut,cmdtype,Command);
case acftICE,
	PlotICE(OutputMatrix,SaveTime,IndexOut,cmdtype,Command);
otherwise,
	disp('ERROR:: Unrecognized vehicle type!')
end;



clear all;fprintf('\n\r%s\r\r','All data has been cleared')

%save 'Results' OutputMatrix SimulationTime PsiCmd AltitudeCmd VelocityCmd
return;


