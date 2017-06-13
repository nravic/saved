function PlotGlobalHawk(OutputMatrix,Time,IndexOut,cmdtype,Command)


%Set Command System Type and Control Allocation method
cmdtypeAPBV = 0; % Alt, Psi, Beta, Vel command system
cmdtypePQRT = 1; % P, Q, R, Throttle command system



%save AVDS data
AVDSOut = [Time,OutputMatrix(:,[IndexOut.stateX_Feet,IndexOut.stateY_Feet,IndexOut.stateZ_Feet]), ...
		OutputMatrix(:,[IndexOut.statePhi_Rad,IndexOut.stateTheta_Rad,IndexOut.statePsi_Rad,IndexOut.outputAlpha_rad,IndexOut.outputBeta_rad])*180/pi, ...
		OutputMatrix(:,[IndexOut.outputVt_ftpersec]), ...
		OutputMatrix(:,[IndexOut.outputMach]), ...
		OutputMatrix(:,[IndexOut.outActuatorPosition0,IndexOut.outActuatorPosition1,IndexOut.outActuatorPosition2,IndexOut.outActuatorPosition3])*pi/180, ...
	];
save VehicleDynamic.save.txt AVDSOut -ascii


%plot results
LengthData = size(OutputMatrix,1);
PlotRange = [1:LengthData];

figure(5101);
clf;
subplot(4,3,1);
plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.stateTheta_Rad)*180/pi]);
grid;
title('Theta (deg)');
subplot(4,3,2);
plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.stateQ_RadPerSec)*180/pi]);
grid;
title('Pitch Rate (deg/sec)');
subplot(4,3,3);
plot(Time(PlotRange),[OutputMatrix(PlotRange,[IndexOut.outActuatorPosition0,IndexOut.outDeltaCmd_deg0])]);
grid;
title('Actuator1 and ActuatorCmd1');
subplot(4,3,4);
plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.statePhi_Rad)*180/pi]);
grid;
title('Phi (deg)');
subplot(4,3,5);
plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.stateP_RadPerSec)*180/pi]);
grid;
title('Roll Rate (deg/sec)');
subplot(4,3,6);
plot(Time(PlotRange),[OutputMatrix(PlotRange,[IndexOut.outActuatorPosition1,IndexOut.outDeltaCmd_deg1])]);
grid;
title('Actuator2 and ActuatorCmd2');
if cmdtype == cmdtypeAPBV
	subplot(4,3,7);
	plot(Time(PlotRange),[(OutputMatrix(PlotRange,IndexOut.statePsi_Rad)*180/pi) Command.PsiCmd(PlotRange)*180/pi]);
	grid;
	title('Psi and Psi Cmd (deg)');
elseif  cmdtype == cmdtypePQRT
	subplot(4,3,7);
	plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.statePsi_Rad)]*180/pi);
	grid;
	title('Psi(deg)');
end
subplot(4,3,8);
plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.stateR_RadPerSec)*180/pi]);
grid;
title('Yaw Rate (deg/sec)');
subplot(4,3,9);
plot(Time(PlotRange),[OutputMatrix(PlotRange,[IndexOut.outActuatorPosition2,IndexOut.outDeltaCmd_deg2])]);
grid;
title('Actuator3 and ActuatorCmd3');
subplot(4,3,10);
plot(Time(PlotRange),[OutputMatrix(PlotRange,[IndexOut.outputVelocityX_feetpersec,IndexOut.outputVelocityY_feetpersec,IndexOut.outputVelocityZ_feetpersec])]);
grid;
title('X, Y and Z velocities (fps)');
subplot(4,3,11);
plot(Time(PlotRange),[OutputMatrix(PlotRange,[IndexOut.outputFlightPathAngle_rad])*180/pi]);
grid;
title('Flight Path Angles (deg)');
subplot(4,3,12);
plot(Time(PlotRange),[OutputMatrix(PlotRange,[IndexOut.outActuatorPosition3,IndexOut.outDeltaCmd_deg3])]);
grid;
title('Actuator4 and ActuatorCmd4');



figure(5100);
clf;
subplot(3,3,1);
plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.stateX_Feet)]);
grid;
title('X feet');
subplot(3,3,2);
plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.stateY_Feet)]);
grid;
title('Y feet');
subplot(3,3,3);
if cmdtype == cmdtypeAPBV
	plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.outputAltitude_ft),Command.AltitudeCmd(PlotRange)]);
	grid;
	title('Altitude and Altitude Cmd(feet)');
	subplot(3,3,4);
	plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.outputVt_ftpersec),Command.VelocityCmd(PlotRange)]);
	grid;
	title('Total Velocity and Velocity Cmd(feet/sec)');
	subplot(3,3,6);
	plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.outputBeta_rad)*180/pi,Command.BetaCmd(PlotRange)]);
	grid;
	title('Beta and Beta Cmd(deg)');
elseif  cmdtype == cmdtypePQRT
	plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.outputAltitude_ft)]);
	grid;
	title('Altitude(feet)');
	subplot(3,3,4);
	plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.outputVt_ftpersec)]);
	grid;
	title('Total Velocity(feet/sec)');
	subplot(3,3,6);
	plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.outputBeta_rad)*180/pi]);
	grid;
	title('Beta(deg)');
end
subplot(3,3,5);
plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.outputAlpha_rad)*180/pi]);
grid;
title('Alpha (deg)');
subplot(3,3,7);
plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.stateU_FeetPerSec)]);
grid;
title('U (ft/sec)');
subplot(3,3,8);
plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.stateV_FeetPerSec)]);
grid;
title('V (ft/sec)');
subplot(3,3,9);
plot(Time(PlotRange),[OutputMatrix(PlotRange,IndexOut.stateW_FeetPerSec)]);
grid;
title('W (ft/sec)');

% Added for Linear Solver Control Allocation testing
figure(5099);
clf;
if cmdtype == cmdtypeAPBV
	subplot(4,3,1);
	plot(Time(PlotRange),[[OutputMatrix(PlotRange,IndexOut.stateP_RadPerSec)],[OutputMatrix(PlotRange,IndexOut.outCmdP_radpersec)]]);
	grid;
	title('Vehicle P and Commanded P (rad/sec)');
	%legend('Vehicle','Commanded',-1);
	subplot(4,3,4);
	plot(Time(PlotRange),[[OutputMatrix(PlotRange,IndexOut.stateQ_RadPerSec)],[OutputMatrix(PlotRange,IndexOut.outCmdQ_radpersec)]]);
	grid;
	title('Vehicle Q and Commanded Q (rad/sec)');
	subplot(4,3,7);
	plot(Time(PlotRange),[[OutputMatrix(PlotRange,IndexOut.stateR_RadPerSec)],[OutputMatrix(PlotRange,IndexOut.outCmdR_radpersec)]]);
	grid;
	title('Vehicle R and Commanded R (rad/sec)');
elseif  cmdtype == cmdtypePQRT
	subplot(4,3,1);
	plot(Time(PlotRange),[[OutputMatrix(PlotRange,IndexOut.stateP_RadPerSec)],Command.ratePCmd(PlotRange)]);
	grid;
	title('Vehicle P and Commanded P (rad/sec)');
	%legend('Vehicle','Commanded',-1);
	subplot(4,3,4);
	plot(Time(PlotRange),[[OutputMatrix(PlotRange,IndexOut.stateQ_RadPerSec)],Command.rateQCmd(PlotRange)]);
	grid;
	title('Vehicle Q and Commanded Q (rad/sec)');
	subplot(4,3,7);
	plot(Time(PlotRange),[[OutputMatrix(PlotRange,IndexOut.stateR_RadPerSec)],Command.rateRCmd(PlotRange)]);
	grid;
	title('Vehicle R and Commanded R (rad/sec)');
end
subplot(4,3,2);
plot(Time(PlotRange),abs(OutputMatrix(PlotRange,IndexOut.outDeltaCmd_deg0)-OutputMatrix(PlotRange,IndexOut.outActuatorPosition0)));
grid;
title('ABS(Diff between Commanded and Actual, Surface 1)');
subplot(4,3,5);
plot(Time(PlotRange),abs(OutputMatrix(PlotRange,IndexOut.outDeltaCmd_deg1)-OutputMatrix(PlotRange,IndexOut.outActuatorPosition1)));
grid;
title('ABS(Diff between Commanded and Actual, Surface 2)');
subplot(4,3,8);
plot(Time(PlotRange),abs(OutputMatrix(PlotRange,IndexOut.outDeltaCmd_deg2)-OutputMatrix(PlotRange,IndexOut.outActuatorPosition2)));
grid;
title('ABS(Diff between Commanded and Actual, Surface 3)');
subplot(4,3,11);
plot(Time(PlotRange),abs(OutputMatrix(PlotRange,IndexOut.outDeltaCmd_deg3)-OutputMatrix(PlotRange,IndexOut.outActuatorPosition3)));
grid;
title('ABS(Diff between Commanded and Actual, Surface 4)');

subplot(4,3,3);
plot(Time(PlotRange),[OutputMatrix(PlotRange,[IndexOut.outActuatorPosition0,IndexOut.outDeltaCmd_deg0])]);
grid;
title('Actuator1 and ActuatorCmd1 (deg)');
subplot(4,3,6);
plot(Time(PlotRange),[OutputMatrix(PlotRange,[IndexOut.outActuatorPosition1,IndexOut.outDeltaCmd_deg1])]);
grid;
title('Actuator2 and ActuatorCmd2 (deg)');
subplot(4,3,9);
plot(Time(PlotRange),[OutputMatrix(PlotRange,[IndexOut.outActuatorPosition2,IndexOut.outDeltaCmd_deg2])]);
grid;
title('Actuator3 and ActuatorCmd3 (deg)');
subplot(4,3,12);
plot(Time(PlotRange),[OutputMatrix(PlotRange,[IndexOut.outActuatorPosition3,IndexOut.outDeltaCmd_deg3])]);
grid;
title('Actuator4 and ActuatorCmd4 (deg)');
subplot(4,3,10);
plot(Time(PlotRange),OutputMatrix(PlotRange,[IndexOut.outThrustX_lbs]));
grid;
title 'Engine Thrust (lbs)';


% PID tuning
if cmdtype == cmdtypePQRT
	if max(Command.rateQCmd(PlotRange)) ~= 0.0
		figure(5098)
		clf;
		subplot(2,1,1);
		plot(Time(PlotRange),[[OutputMatrix(PlotRange,IndexOut.stateQ_RadPerSec)],Command.rateQCmd(PlotRange)]);
		grid;
		title('Vehicle Q and Commanded Q (rad/sec)');
		subplot(2,1,2);
		plot(Time(PlotRange),[[-OutputMatrix(PlotRange,IndexOut.outputQdotNeutral_radpersec2)],[OutputMatrix(PlotRange,IndexOut.outPIDQdotOutput)]]);
		grid;
		title('Vehicle Qdot and Commanded Qdot (rad/sec^2)');
	end
	if max(Command.ratePCmd(PlotRange)) ~= 0.0
		figure(5097)
		clf;
		subplot(2,1,1);
		plot(Time(PlotRange),[[OutputMatrix(PlotRange,IndexOut.stateP_RadPerSec)],Command.ratePCmd(PlotRange)]);
		grid;
		title('Vehicle P and Commanded P (rad/sec)');
		subplot(2,1,2);
		plot(Time(PlotRange),[[-OutputMatrix(PlotRange,IndexOut.outputPdotNeutral_radpersec2)],[OutputMatrix(PlotRange,IndexOut.outPIDPdotOutput)]]);
		grid;
		title('Vehicle Pdot and Commanded Pdot (rad/sec^2)');
	end
	if max(Command.rateRCmd(PlotRange)) ~= 0.0
		figure(5096)
		clf;
		subplot(2,1,1);
		plot(Time(PlotRange),[[OutputMatrix(PlotRange,IndexOut.stateR_RadPerSec)],Command.rateRCmd(PlotRange)]);
		grid;
		title('Vehicle R and Commanded R (rad/sec)');
		subplot(2,1,2);
		plot(Time(PlotRange),[[-OutputMatrix(PlotRange,IndexOut.outputRdotNeutral_radpersec2)],[OutputMatrix(PlotRange,IndexOut.outPIDRdotOutput)]]);
		grid;
		title('Vehicle Rdot and Commanded Rdot (rad/sec^2)');
	end
end

% figure(5097)
% cmprT = PlotRange(400:LengthData);
% plot(Time(cmprT),[[OutputMatrix(cmprT,IndexOut.stateQ_RadPerSec)+0.0743],rateQCmd(cmprT)]);
% grid;

% %Pseudo and LP comparison
% if cmdtype == cmdtypePQRT
%     if ctlallcmeth == ctlallcPseudo
%         compare = [Time,OutputMatrix(:,[outActuatorPosition0,outDeltaCmd_deg0,outActuatorPosition1,outDeltaCmd_deg1,outActuatorPosition2,outDeltaCmd_deg2,...
%                    stateP_RadPerSec,IndexOut.stateQ_RadPerSec,IndexOut.stateR_RadPerSec]),ratePCmd(PlotRange),rateQCmd(PlotRange),rateRCmd(PlotRange)];
%         save CntrlAllocCmpr.save.mat compare
%     elseif  ctlallcmeth == ctlallcLinearProgram
%         compareLP = [Time,OutputMatrix(:,[outActuatorPosition0,outDeltaCmd_deg0,outActuatorPosition1,outDeltaCmd_deg1,outActuatorPosition2,outDeltaCmd_deg2,...
%                    stateP_RadPerSec,IndexOut.stateQ_RadPerSec,IndexOut.stateR_RadPerSec]),ratePCmd(PlotRange),rateQCmd(PlotRange),rateRCmd(PlotRange)];
%         save CntrlAllocCmprLP.save.mat compareLP
%     end
% elseif cmdtype == cmdtypeAPBV
%     if ctlallcmeth == ctlallcPseudo
%         compare = [Time,OutputMatrix(:,[outActuatorPosition0,outDeltaCmd_deg0,outActuatorPosition1,outDeltaCmd_deg1,outActuatorPosition2,outDeltaCmd_deg2,...
%                    stateP_RadPerSec,IndexOut.stateQ_RadPerSec,IndexOut.stateR_RadPerSec,IndexOut.outputPCmd,IndexOut.outputQCmd,IndexOut.outputRCmd])];
%         save CntrlAllocCmpr.save.mat compare
%     elseif  ctlallcmeth == ctlallcLinearProgram
%         compareLP = [Time,OutputMatrix(:,[outActuatorPosition0,outDeltaCmd_deg0,outActuatorPosition1,outDeltaCmd_deg1,outActuatorPosition2,outDeltaCmd_deg2,...
%                    stateP_RadPerSec,IndexOut.stateQ_RadPerSec,IndexOut.stateR_RadPerSec,IndexOut.outputPCmd,IndexOut.outputQCmd,IndexOut.outputRCmd])];
%         save CntrlAllocCmprLP.save.mat compareLP
%     end
% end


return;	%PlotLocaas