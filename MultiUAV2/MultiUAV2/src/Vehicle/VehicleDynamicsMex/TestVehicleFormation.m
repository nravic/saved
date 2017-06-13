function TestVehicleFormation  % test VehicleFormation

%action flags for call to VehicleDynamicsMex
actionsInitialize = 1;
actionsUpdate = 2;
actionsClear = 3;
actionsPrintLabels = 4;

%Set Sim Time before indices, indices change for different control methods!!!
TimeIncrement = 0.01;
TimeStop = 10.0;

SimulationTime = [0.0:TimeIncrement:TimeStop]';
LengthTime = size(SimulationTime,1);

%Set Command System Type and Control Allocation method
cmdtypeAPBV = 0; % Alt, Psi, Beta, Vel command system
cmdtypePQRT = 1; % P, Q, R, Throttle command system
cmdtypePQBetaT = 2; % P, Q, Beta, Throttle command system
%cmdtypeLead = cmdtypeAPBV;
%cmdtypeLead = cmdtypePQRT;
cmdtypeLead = cmdtypePQBetaT;
%cmdtypeWing = cmdtypeAPBV;
%cmdtypeWing = cmdtypePQRT;
cmdtypeWing = cmdtypePQBetaT;

%Set Command System Type and Control Allocation method
ctlallcPseudo = 0; % Pseudo inverse control allocation 
ctlallcLinearProgram = 1; % Linear Program control allocation
%ctlallcmeth = ctlallcPseudo;
ctlallcmeth = ctlallcLinearProgram;

%Choose vehicle type Pararamter and Data files here
acftLocaas = 0;
acftGlobalHawk = 1;
acftICE = 2;

%acftTypeLead = acftGlobalHawk;
acftTypeLead = acftLocaas;
%acftTypeLead = acftICE;
%acftTypeWing = acftGlobalHawk;
acftTypeWing = acftLocaas;
%acftTypeWing = acftICE;

SubtractBaseTablesLead = 1;	% if the increment tables in the data file contain the base table data, then the base table data must be subtracted from the increment tables.
% set parameter and data file names
switch(acftTypeLead),
case acftLocaas,
	FileNameDataLead = 'DATCOM.locaas.dat';
	FileNameParametersLead = 'Parameters.locaas.dat';
case acftGlobalHawk,
	FileNameDataLead = 'DATCOM.globalhawk.dat';
	FileNameParametersLead = 'Parameters.globalhawk.dat';
case acftICE,
	FileNameDataLead = 'DATCOM.ice.dat';
	FileNameParametersLead = 'Parameters.ice.dat';
	SubtractBaseTablesLead = 0;
end;

SubtractBaseTablesWing = 1;	% if the increment tables in the data file contain the base table data, then the base table data must be subtracted from the increment tables.
switch(acftTypeWing),
case acftLocaas,
	FileNameDataWing = 'DATCOM.locaas.dat';
	FileNameParametersWing = 'Parameters.locaas.dat';
case acftGlobalHawk,
	FileNameDataWing = 'DATCOM.globalhawk.dat';
	FileNameParametersWing = 'Parameters.globalhawk.dat';
case acftICE,
	FileNameDataWing = 'DATCOM.ice.dat';
	FileNameParametersWing = 'Parameters.ice.dat';
	SubtractBaseTablesWing = 0;
end;

% build path info
tdir = ['..', filesep, '..', filesep, '..', filesep];
idir = [tdir, 'InputFiles', filesep];
mdir = [tdir, 'm-file', filesep];

% set path(s)
addpath( mdir );
addpath( GetLibDir(tdir) );

% prepend path info to data files:
FileNameDataLead = [idir, FileNameDataLead];
FileNameParametersLead = [idir, FileNameParametersLead];
FileNameDataWing = [idir, FileNameDataWing];
FileNameParametersWing = [idir, FileNameParametersWing];


% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %PRINT OUT STATE and OUTPUT LABELs
% VehicleModelInstance = VehicleDynamicsMex(actionsInitialize,[],[],cmdtypeLead,ctlallcmeth,FileNameDataLead,FileNameParametersLead,SubtractBaseTablesLead);
% VehicleDynamicsMex(actionsPrintLabels,VehicleModelInstance);
% clear all;fprintf('\n\r%s\r\r','All data has been cleared')
% return;
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%set-up output/state indicies
[IndexOutLead] = CreateIndicies(cmdtypeLead,acftTypeLead);
[IndexOutWing] = CreateIndicies(cmdtypeWing,acftTypeWing);

% select trim values
TrimU = 250.0;
TrimW = -5.0;
TrimTheta = 0.0*pi/180.0;
TrimAltitude = -5000.0;
TrimEnginePowerLevel = 0.4;

%build intial state vectors
[XinitLead] = TrimValues(acftTypeLead,IndexOutLead,TrimU,TrimW,TrimTheta,TrimAltitude,TrimEnginePowerLevel);
[XinitWing] = TrimValues(acftTypeWing,IndexOutWing,TrimU,TrimW,TrimTheta,TrimAltitude,TrimEnginePowerLevel);

XinitWing(IndexOutWing.stateX_Feet) = -310.0;
XinitWing(IndexOutWing.stateY_Feet) = XinitWing(IndexOutWing.stateY_Feet) - 200.0;
XinitWing(IndexOutWing.stateZ_Feet) = XinitWing(IndexOutWing.stateZ_Feet) - 0.0;

%create and initialize vehicle model
VehicleModelInstanceLead = VehicleDynamicsMex(actionsInitialize,[],XinitLead,cmdtypeLead,ctlallcmeth,FileNameDataLead,FileNameParametersLead,SubtractBaseTablesLead);
VehicleModelInstanceWing = VehicleDynamicsMex(actionsInitialize,[],XinitWing,cmdtypeWing,ctlallcmeth,FileNameDataWing,FileNameParametersWing,SubtractBaseTablesWing);

%build input vectors
if ((cmdtypeLead == cmdtypePQRT) | (cmdtypeLead == cmdtypePQBetaT)),
	ratePCmd = 0.0*ones(LengthTime,1);
	rateQCmd = 0.0*ones(LengthTime,1);
	rateRCmd = 0.0*ones(LengthTime,1);
	engThrottleCmd = 0.6*ones(LengthTime,1);
	
	%Step rate commands, Single Channel
	CmdMagP = 0.0;
	CmdMagQ = 0.00;
	CmdMagR = 0.00;
	
	MagnitudeP = CmdMagP; MagnitudeQ = CmdMagQ; MagnitudeR = CmdMagR;
	TimeOnset = floor(1*LengthTime/10); 
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
	
	Command.ratePCmd = ratePCmd;
	Command.rateQCmd = rateQCmd;
	Command.rateRCmd = rateRCmd;
	Command.engThrottleCmd = engThrottleCmd;
	InputVector = [SimulationTime,ratePCmd,rateQCmd,rateRCmd,engThrottleCmd];
	
else,	%if ((cmdtypeLead == cmdtypePQRT) | (cmdtypeLead == cmdtypePQBetaT)),
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
	
	Command.PsiCmd = PsiCmd;
	Command.AltitudeCmd = AltitudeCmd;
	Command.BetaCmd = BetaCmd;
	Command.VelocityCmd = VelocityCmd;
	InputVector = [SimulationTime,PsiCmd,AltitudeCmd,BetaCmd,VelocityCmd];
	
end;	%if ((cmdtypeLead == cmdtypePQRT) | (cmdtypeLead == cmdtypePQBetaT)),

[NumberTimeSteps,NumberInputs] = size(InputVector);

%preallocate matricies
OutputMatrixLead = zeros(NumberTimeSteps,IndexOutLead.TotalIndexOutput+1);
OutputMatrixWing = zeros(NumberTimeSteps,IndexOutWing.TotalIndexOutput+1);

SaveInputWing = zeros(NumberTimeSteps,8);
InputWing = [0.0,0.0,0.0,0.0,0.4];
%run simulation
tic
for(CountTimeStep = 1:NumberTimeSteps),
 	OutputMatrixLead(CountTimeStep,:) = VehicleDynamicsMex(actionsUpdate,VehicleModelInstanceLead,InputVector(CountTimeStep,:));
	
	LeadX = OutputMatrixLead(CountTimeStep,IndexOutLead.stateX_Feet);
	LeadY = OutputMatrixLead(CountTimeStep,IndexOutLead.stateY_Feet);
	LeadZ = OutputMatrixLead(CountTimeStep,IndexOutLead.stateZ_Feet);
	LeadU = OutputMatrixLead(CountTimeStep,IndexOutLead.stateU_FeetPerSec);
	LeadV = OutputMatrixLead(CountTimeStep,IndexOutLead.stateV_FeetPerSec);
	LeadW = OutputMatrixLead(CountTimeStep,IndexOutLead.stateW_FeetPerSec);
	LeadPhi = OutputMatrixLead(CountTimeStep,IndexOutLead.statePhi_Rad);
	LeadTheta = OutputMatrixLead(CountTimeStep,IndexOutLead.stateTheta_Rad);
	LeadPsi = OutputMatrixLead(CountTimeStep,IndexOutLead.statePsi_Rad);
	LeadP = OutputMatrixLead(CountTimeStep,IndexOutLead.stateP_RadPerSec);
	LeadQ = OutputMatrixLead(CountTimeStep,IndexOutLead.stateQ_RadPerSec);
	LeadR = OutputMatrixLead(CountTimeStep,IndexOutLead.stateR_RadPerSec);

	LeadPhi = NormalizeAngleRad(LeadPhi);
	LeadTheta = NormalizeAngleRad(LeadTheta);
	LeadPsi = NormalizeAngleRad(LeadPsi);

	LeadThetaDot = OutputMatrixLead(CountTimeStep,IndexOutLead.stateTheta_RadDot);
	LeadPsiDot = OutputMatrixLead(CountTimeStep,IndexOutLead.statePsi_RadDot);
	LeadUDot = OutputMatrixLead(CountTimeStep,IndexOutLead.stateU_FeetPerSecDot);
	
	if(CountTimeStep>1),
		WingX = OutputMatrixWing(CountTimeStep-1,IndexOutWing.stateX_Feet);
		WingY = OutputMatrixWing(CountTimeStep-1,IndexOutWing.stateY_Feet);
		WingZ = OutputMatrixWing(CountTimeStep-1,IndexOutWing.stateZ_Feet);
		WingPhi = OutputMatrixWing(CountTimeStep-1,IndexOutWing.statePhi_Rad);
		WingTheta = OutputMatrixWing(CountTimeStep-1,IndexOutWing.stateTheta_Rad);
		WingPsi = OutputMatrixWing(CountTimeStep-1,IndexOutWing.statePsi_Rad);
		WingU = OutputMatrixWing(CountTimeStep-1,IndexOutWing.stateU_FeetPerSec);
	else,	%if(CountTimeStep>1),
		WingX = XinitWing(IndexOutWing.stateX_Feet);
		WingY = XinitWing(IndexOutWing.stateY_Feet);
		WingZ = XinitWing(IndexOutWing.stateZ_Feet);
		WingPhi = XinitWing(IndexOutWing.statePhi_Rad);
		WingTheta = XinitWing(IndexOutWing.stateTheta_Rad);
		WingPsi = XinitWing(IndexOutWing.statePsi_Rad);
		WingU = XinitWing(IndexOutWing.stateU_FeetPerSec);
	end;	%if(CountTimeStep>1),
	WingPhi = NormalizeAngleRad(WingPhi);
	WingTheta = NormalizeAngleRad(WingTheta);
	WingPsi = NormalizeAngleRad(WingPsi);
	
	% find positon errors
	SlotAlongTrack = -200.0;
	SlotCrossTrack = 100.0;
	
	DifferenceX = WingX - LeadX;
	DifferenceY = WingY - LeadY;
	
	WingPositionCrossTrack = DifferenceX*sin(LeadPsi) - DifferenceY*cos(LeadPsi);
	WingPositionAlongTrack =  DifferenceX*cos(LeadPsi) + DifferenceY*sin(LeadPsi);
	
	AlongTrackError	 = WingPositionAlongTrack - SlotAlongTrack;
	CrossTrackError	 = WingPositionCrossTrack - SlotCrossTrack;
	AltitudeError = -(LeadZ - WingZ);
	
	
	PhiDotCmd = 0.0;
	
		
	Ktheta_1 = 0.0*0.001;
	Ktheta_2 = 0.0*0.000002*abs(AltitudeError);
	Ktheta_3 = 0.0*1.0;
	ThetaReference = NormalizeAngleRad(LeadTheta);
	ThetaDotCmd =  Ktheta_1*NormalizeAngleRad(ThetaReference - WingTheta) + Ktheta_2*AltitudeError + Ktheta_3*LeadThetaDot;
	
	Kpsi_1 = 0.0;
	Kpsi_2 = 0.005;
	Kpsi_3 = 0.0;
	PsiReference = LeadPsi;
	PsiDifference = PsiReference - WingPsi;
	if(PsiDifference>pi),
	end;
% 	PsiDotCmd = Kpsi_1*NormalizeAngleRad(PsiReference - WingPsi) + Kpsi_2*CrossTrackError + Kpsi_3*LeadPsiDot;
	PhiDotCmd = Kpsi_1*NormalizeAngleRad(PsiReference - WingPsi) + Kpsi_2*CrossTrackError + Kpsi_3*LeadPsiDot;
	PsiDotCmd = 0;
	
	Kvel_1 = 2.0;
	Kvel_2 = -1.0*((1.0/100)*abs(AlongTrackError) + 0.1);
	Kvel_3 = 1.0;
	VelocityReference = LeadU;	% for no turn
	VelocityDotCmd = Kvel_1*(VelocityReference - WingU) + Kvel_2*AlongTrackError + Kvel_3*LeadUDot;
	
	ElapsedTime = InputVector(CountTimeStep,1);
	P_cmd = PhiDotCmd + (-sin(WingTheta)*PsiDotCmd);
% 	Q_cmd = cos(WingPhi)*ThetaDotCmd + cos(WingTheta)*sin(WingPhi)*PsiDotCmd;
	Q_cmd = cos(WingPhi)*ThetaDotCmd;
	Beta_cmd = 0.0;
	Throttle_cmd = InputWing(5) + VelocityDotCmd*0.1/100.0;
	if(Throttle_cmd>1.0),
		Throttle_cmd = 1;
	elseif(Throttle_cmd<0),
		Throttle_cmd = 0;
	end;
	InputWing = [ElapsedTime,P_cmd,Q_cmd,Beta_cmd,Throttle_cmd];

	SaveInputWing(CountTimeStep,:) = [InputWing,AlongTrackError,CrossTrackError,AltitudeError];
	OutputMatrixWing(CountTimeStep,:) = VehicleDynamicsMex(actionsUpdate,VehicleModelInstanceWing,InputWing);
end;	%for(CountTimeStep = 1:NumberTimeSteps),

RunTime = toc;

RunTime
TimeStop
FractionSimTimeOverRunTime = TimeStop/RunTime


%save 'DataFile.dat' -ascii InputVector OutputMatrixLead OutputMatrixWing;
save DataFile InputVector SaveInputWing OutputMatrixLead OutputMatrixWing;

%save AVDS data
AVDSOutLead = [SimulationTime,OutputMatrixLead(:,[IndexOutLead.stateX_Feet,IndexOutLead.stateY_Feet,IndexOutLead.stateZ_Feet]), ...
		OutputMatrixLead(:,[IndexOutLead.statePhi_Rad,IndexOutLead.stateTheta_Rad,IndexOutLead.statePsi_Rad,IndexOutLead.outputAlpha_rad,IndexOutLead.outputBeta_rad])*180/pi, ...
		OutputMatrixLead(:,[IndexOutLead.outputVt_ftpersec]), ...
		OutputMatrixLead(:,[IndexOutLead.outputMach]), ...
		OutputMatrixLead(:,[IndexOutLead.outActuatorPosition0,IndexOutLead.outActuatorPosition1,IndexOutLead.outActuatorPosition2])*pi/180, ...
	];
delete 'VehicleLead.save.txt';
save VehicleLead.save.txt AVDSOutLead -ascii

AVDSOutWing = [SimulationTime,OutputMatrixWing(:,[IndexOutWing.stateX_Feet,IndexOutWing.stateY_Feet,IndexOutWing.stateZ_Feet]), ...
		OutputMatrixWing(:,[IndexOutWing.statePhi_Rad,IndexOutWing.stateTheta_Rad,IndexOutWing.statePsi_Rad,IndexOutWing.outputAlpha_rad,IndexOutWing.outputBeta_rad])*180/pi, ...
		OutputMatrixWing(:,[IndexOutWing.outputVt_ftpersec]), ...
		OutputMatrixWing(:,[IndexOutWing.outputMach]), ...
		OutputMatrixWing(:,[IndexOutWing.outActuatorPosition0,IndexOutWing.outActuatorPosition1,IndexOutWing.outActuatorPosition2])*pi/180, ...
	];
delete 'VehicleWing.save.txt';
save VehicleWing.save.txt AVDSOutWing -ascii


%clear instance of vehicle model
VehicleDynamicsMex(actionsClear,VehicleModelInstanceLead);
VehicleDynamicsMex(actionsClear,VehicleModelInstanceWing);
%VehicleDynamicsMex(actionsClear);

switch acftTypeLead,
case acftLocaas,
	PlotLocaas(OutputMatrixLead,SimulationTime,IndexOutLead,cmdtypeLead,Command);
case acftGlobalHawk,
	PlotGlobalHawk(OutputMatrixLead,SimulationTime,IndexOutLead,cmdtypeLead,Command);
case acftICE,
	PlotICE(OutputMatrixLead,SimulationTime,IndexOutLead,cmdtypeLead,Command);
otherwise,
	disp('ERROR:: Unrecognized vehicle type!')
end;

figure(5300);
clf;
subplot(4,2,1);
plot(SaveInputWing(:,1),[SaveInputWing(:,2)],'y');
grid;
title('P_cmd');
subplot(4,2,3);
plot(SaveInputWing(:,1),[SaveInputWing(:,3)]);
grid;
title('Q_cmd');
subplot(4,2,5);
plot(SaveInputWing(:,1),[SaveInputWing(:,4)]);
grid;
title('Beta_cmd');
subplot(4,2,7);
plot(SaveInputWing(:,1),[SaveInputWing(:,5)]);
grid;
title('Throttle_cmd');
subplot(4,2,2);
plot(SaveInputWing(:,1),[SaveInputWing(:,6)]);
grid;
title('AlongTrackError');
subplot(4,2,4);
plot(SaveInputWing(:,1),[SaveInputWing(:,7)]);
grid;
title('CrossTrackError');
subplot(4,2,6);
plot(SaveInputWing(:,1),[SaveInputWing(:,8)]);
grid;
title('AltitudeError');


clear all;fprintf('\n\r%s\r\r','All data has been cleared')

%save 'Results' OutputMatrix SimulationTime PsiCmd AltitudeCmd VelocityCmd
return;


function NormalAngle_rad = NormalizeAngleRad(Angle_rad,Reference_rad)
if(~exist('Reference_rad')),
	Reference_rad=0.0;
end;
NormalAngle_rad = rem(Angle_rad,(2*pi));
if(NormalAngle_rad < Reference_rad)
	NormalAngle_rad = NormalAngle_rad + 2.0*pi;
elseif(NormalAngle_rad >= (Reference_rad+2*pi))
	NormalAngle_rad = NormalAngle_rad - 2*pi;
end;
return;





