% trim_navion
% A Matlab script that trims the nonlinear aircraft model for a chosen
% flight condition and extracts the aircraft linear model
%
% Unmanned Dynamics, LLC
% October 1, 2002
%
% The trim parameters structure has the following components:
% 1. Simulation settings
% TrimParam.SampleTime = simulation sample time
% TrimParam.FinalTime = simulation final time (used only for trim function)
% TrimParam.SimModel = Simulink model name
% 2. Flight condition definition
% TrimParam.VelocitiesIni
% TrimParam.RatesIni
% TrimParam.AttitudeIni
% TrimParam.PositionIni
% TrimParam.FuelIni
% TrimParam.EngineSpeedIni
% TrimParam.Airspeed
% TrimParam.Altitude
% TrimParam.BankAngle
% TrimParam.Elevator
% TrimParam.Aileron
% TrimParam.Rudder
% TrimParam.Throttle
% TrimParam.Flap
% TrimParam.Mix
% TrimParam.Ign
% TrimParam.Winds
% 3. Miscellaneous parameters:
% TrimParam.StateIdx = state order index (order of states in Simulink block diagram usually
%                       different than the desired state order - velocities, angular rates,
%                       attitude angles, position, fuel, and engine speed)
% TrimParam.Options = trim function options
% TrimParam.SimOptions = the sim function options
% TrimParam.NAircraftStates = the size of the aircraft state vector,
%                               currently 14
% TrimParam.NSimulinkStates = the size of the state vector in the Simulink
%                               model (could be larger than aircraft state vector)
%
% The trim output structure has the following components:
% TrimOutput.States = Simulink model states at trim condition
% TrimOutput.Inputs = inputs at trim condition
% TrimOutput.Outputs = outputs at trim condition
% TrimOutput.Derivatives = model derivatives at trim condition

clear all;
clc;

fprintf('\nSetting initial trim parameters...');

% Simulation time settings
TrimParam.SampleTime = 0.04;
TrimParam.FinalTime = 60;

% Actuators
TrimParam.Flap = 0;
TrimParam.Mix = 13;
TrimParam.Ign = 1;

% Wind velocities
TrimParam.Winds = [0 0 0];

% Simulink model to trim
TrimParam.SimModel = 'navion_trim';
fprintf('\nThe Simulink model %s.mdl will be trimmed.', TrimParam.SimModel);

% Get the sim options structure
TrimParam.SimOptions = simget(TrimParam.SimModel);

% Set the model inputs
TrimInput = [0 0 0 0.5];

%%% IDENTIFY THE ORDER OF AIRCRAFT STATES  %%%

fprintf('\nIdentifying the order of the Simulink model states...');

% Set some easily-identifiable initial conditions
TrimParam.VelocitiesIni = [44 2 -1]';
TrimParam.RatesIni = [0.03 0.02 0.01]';
TrimParam.AttitudeIni = [0.1 0.05 0.6]';
TrimParam.PositionIni = [45*pi/180 -122*pi/180 1342]';
TrimParam.FuelIni = 56.567;
TrimParam.EngineSpeedIni = 2500*pi/30;

% Run Simulink model for a single sample period
[SimTime, SimStates, SimOutputs] = sim(TrimParam.SimModel, [0 TrimParam.SampleTime], TrimParam.SimOptions, ...
    [0 TrimInput; TrimParam.SampleTime TrimInput]);

% Find the state order
StateIni = [TrimParam.VelocitiesIni; TrimParam.RatesIni; TrimParam.AttitudeIni; TrimParam.PositionIni; TrimParam.FuelIni; TrimParam.EngineSpeedIni];
TrimParam.NAircraftStates = length(StateIni);
TrimParam.NSimulinkStates = length(SimStates(1,:));
TrimParam.StateIdx = zeros(TrimParam.NAircraftStates,1);
for i=1:TrimParam.NAircraftStates
    j = 1;
    while TrimParam.StateIdx(i) == 0
        value = SimStates(1,j);
        if value == StateIni(i)
            TrimParam.StateIdx(i) = j;
        end
        j = j + 1;
    end
end
clear SimTime SimStates SimOutputs;
fprintf('done.');

%%% DETERMINE THE INITIAL GUESS FOR AIRCRAFT CONTROLS %%%

% Flight condition
fprintf('\n');
fprintf('\n Choose flight condition:');
fprintf('\n--------------------------\n');
TrimParam.Airspeed = input('Trim airspeed [m/s]: ');
TrimParam.Altitude = input('Trim altitude [m]: ');
TrimParam.BankAngle = input('Trim bank angle [rad]: ');
TrimParam.FuelIni = input('Fuel mass [kg]: ');
TrimParam.Flap = input('Flap setting [frac]: ');

% The initial conditions for the flight condition above
TrimParam.VelocitiesIni = [TrimParam.Airspeed 0 0]';
TrimParam.RatesIni = [0 0 0]';
TrimParam.AttitudeIni = [TrimParam.BankAngle 0 0]';
TrimParam.PositionIni = [45*pi/180 -122*pi/180 TrimParam.Altitude]';
TrimParam.EngineSpeedIni = 2500*pi/30;

% The trim error threshold
MaxErrTAS = 0.5;
MaxErrAlt = 4;
MaxErrBank = 0.1*pi/180;

% The control surface gains
KElevator = -0.005;
KAileron = 0.01;
KThrottle = -0.0005;

fprintf('\nComputing the initial estimates for the trim inputs...');

GoodGuess = 0; Niter = 1;
while (~GoodGuess)&(Niter<30)
    % Run Simulink model for a short time (10 s)
    [SimTime, SimStates, SimOutputs] = sim(TrimParam.SimModel, [0 5], TrimParam.SimOptions, ...
        [0 TrimInput; 5 TrimInput]);
    % Compute errors in trim
    ErrTAS = SimOutputs(end,1) - TrimParam.Airspeed;
    ErrAlt = SimOutputs(end,7) - TrimParam.Altitude;
    ErrBank = SimOutputs(end,4) - TrimParam.BankAngle;
    fprintf('\nIteration #%2d, Airsp err = %6.2f m/s, Alt err = %8.2f m, phi err = %6.2f deg.', Niter, ErrTAS, ErrAlt, ErrBank*180/pi);
    
    % If all errors are within threshold    
    if (abs(ErrTAS)<MaxErrTAS)&(abs(ErrAlt)<MaxErrAlt)&(abs(ErrBank)<MaxErrBank)
        % We are done with the initial guess
        GoodGuess = 1;
    else
        % Adjust aircraft controls
        TrimInput(1) = TrimInput(1) + KElevator * ErrTAS;
        TrimInput(2) = TrimInput(2) + KAileron * ErrBank;
        TrimInput(4) = TrimInput(4) + KThrottle * ErrAlt;
    end
    Niter = Niter + 1;
end
% Save initial guess
TrimParam.VelocitiesIni = SimStates(end,TrimParam.StateIdx(1:3))';
TrimParam.AttitudeIni = SimStates(end, TrimParam.StateIdx(7:9))';
TrimParam.EngineSpeedIni = SimStates(end, TrimParam.StateIdx(14));
TrimParam.Elevator = TrimInput(1);
TrimParam.Aileron = TrimInput(2);
TrimParam.Rudder = TrimInput(3);
TrimParam.Throttle = TrimInput(4);
clear SimTime SimStates SimOutputs TrimInput;
fprintf('\nDone. Initial guesses for trim inputs are:');
fprintf('\n   Elevator = %6.4f', TrimParam.Elevator);
fprintf('\n   Aileron = %6.4f', TrimParam.Aileron);
fprintf('\n   Rudder = %6.4f', TrimParam.Rudder);
fprintf('\n   Throttle = %6.4f', TrimParam.Throttle);
 
%%% PERFORM AIRCRAFT TRIM %%%
fprintf('\n');
fprintf('\nPerforming the aircraft trim...\n');

% Set initial guesses
StateIni = zeros(TrimParam.NSimulinkStates,1);
StateIni(TrimParam.StateIdx(1)) = TrimParam.VelocitiesIni(1);
StateIni(TrimParam.StateIdx(2)) = TrimParam.VelocitiesIni(2);
StateIni(TrimParam.StateIdx(3)) = TrimParam.VelocitiesIni(3);
StateIni(TrimParam.StateIdx(4)) = TrimParam.RatesIni(1);
StateIni(TrimParam.StateIdx(5)) = TrimParam.RatesIni(2);
StateIni(TrimParam.StateIdx(6)) = TrimParam.RatesIni(3);
StateIni(TrimParam.StateIdx(7)) = TrimParam.BankAngle;
StateIni(TrimParam.StateIdx(8)) = TrimParam.AttitudeIni(2);
StateIni(TrimParam.StateIdx(9)) = TrimParam.AttitudeIni(3);
StateIni(TrimParam.StateIdx(10)) = TrimParam.PositionIni(1);
StateIni(TrimParam.StateIdx(11)) = TrimParam.PositionIni(2);
StateIni(TrimParam.StateIdx(12)) = TrimParam.Altitude;
StateIni(TrimParam.StateIdx(13)) = TrimParam.FuelIni;
StateIni(TrimParam.StateIdx(14)) = TrimParam.EngineSpeedIni;

InputIni = [TrimParam.Elevator; TrimParam.Aileron; TrimParam.Rudder; TrimParam.Throttle];
OutputIni = [TrimParam.Airspeed; 0; 0; TrimParam.BankAngle; 0; 0; TrimParam.Altitude];
DerivIni = zeros(TrimParam.NSimulinkStates,1);

% Set indices of fixed parameters
StateFixIdx = [TrimParam.StateIdx(2) TrimParam.StateIdx(4) TrimParam.StateIdx(5) TrimParam.StateIdx(6) TrimParam.StateIdx(7) TrimParam.StateIdx(12) TrimParam.StateIdx(13)];
InputFixIdx = [];
OutputFixIdx = [1 2 4 7];
DerivFixIdx = [TrimParam.StateIdx(1) TrimParam.StateIdx(2) TrimParam.StateIdx(3) TrimParam.StateIdx(4) TrimParam.StateIdx(5) TrimParam.StateIdx(6) ...
    TrimParam.StateIdx(7) TrimParam.StateIdx(8) TrimParam.StateIdx(9) TrimParam.StateIdx(12) TrimParam.StateIdx(14)];

% Set optimization parameters
TrimParam.Options(1)  = 1;     % show some output
TrimParam.Options(2)  = 1e-6;  % tolerance in X
TrimParam.Options(3)  = 1e-6;  % tolerance in F
TrimParam.Options(4)  = 1e-6;
TrimParam.Options(14) = 5000;  % max iterations

% Trim the airplane
[TrimOutput.States,TrimOutput.Inputs,TrimOutput.Outputs,TrimOutput.Derivatives] = trim(TrimParam.SimModel,StateIni,InputIni,OutputIni,...
    StateFixIdx,InputFixIdx,OutputFixIdx,DerivIni,DerivFixIdx,TrimParam.Options);

% Print the trim results
fprintf('\nFinished. The trim results are:');
fprintf('\nINPUTS:');
fprintf('\n   Elevator = %6.4f', TrimOutput.Inputs(1));
fprintf('\n   Aileron = %6.4f', TrimOutput.Inputs(2));
fprintf('\n   Rudder = %6.4f', TrimOutput.Inputs(3));
fprintf('\n   Throttle = %6.4f', TrimOutput.Inputs(4));
fprintf('\nSTATES:');
fprintf('\n   u = %6.2f m/s', TrimOutput.States(TrimParam.StateIdx(1)));
fprintf('\n   v = %6.2f m/s', TrimOutput.States(TrimParam.StateIdx(2)));
fprintf('\n   w = %6.2f m/s', TrimOutput.States(TrimParam.StateIdx(3)));
fprintf('\n   p = %6.2f deg/s', TrimOutput.States(TrimParam.StateIdx(4))*180/pi);
fprintf('\n   q = %6.2f deg/s', TrimOutput.States(TrimParam.StateIdx(5))*180/pi);
fprintf('\n   r = %6.2f deg/s', TrimOutput.States(TrimParam.StateIdx(6))*180/pi);
fprintf('\n   phi = %6.2f deg', TrimOutput.States(TrimParam.StateIdx(7))*180/pi);
fprintf('\n   theta = %6.2f deg', TrimOutput.States(TrimParam.StateIdx(8))*180/pi);
fprintf('\n   psi = %6.2f deg', TrimOutput.States(TrimParam.StateIdx(9))*180/pi);
% Geographic position is irrelevant
%fprintf('\n   Lat = %8.4f deg', TrimOutput.States(TrimParam.StateIdx(10))*180/pi);
%fprintf('\n   Lon = %8.4f deg', TrimOutput.States(TrimParam.StateIdx(11))*180/pi);
fprintf('\n   Alt = %6.2f m', TrimOutput.States(TrimParam.StateIdx(12)));
fprintf('\n   Fuel = %6.2f kg', TrimOutput.States(TrimParam.StateIdx(13)));
fprintf('\n   Engine = %6.0f rot/min', TrimOutput.States(TrimParam.StateIdx(14))*30/pi);
fprintf('\nOUTPUTS:');
fprintf('\n   Airspeed = %6.2f m/s', TrimOutput.Outputs(1));
fprintf('\n   Sideslip = %6.2f deg', TrimOutput.Outputs(2)*180/pi);
fprintf('\n   AOA = %6.2f deg', TrimOutput.Outputs(3)*180/pi);
fprintf('\n   Bank = %6.2f deg', TrimOutput.Outputs(4)*180/pi);
fprintf('\n   Pitch = %6.2f deg', TrimOutput.Outputs(5)*180/pi);
fprintf('\n   Heading = %6.2f deg', TrimOutput.Outputs(6)*180/pi);
fprintf('\n   Altitude = %8.2f m', TrimOutput.Outputs(7));

% Extract the linear model
fprintf('\n \nExtracting aircraft linear model...\n');
% Perturbation level
LinParam(1) = 10^-8;
[A, B, C, D] = linmod(TrimParam.SimModel, TrimOutput.States, TrimOutput.Inputs, LinParam);

% Longitudinal dynamics
% States: u w q theta h omega
% Inputs: elevator throttle
% Outputs: Va alpha q theta h
Alon = [
    A(TrimParam.StateIdx(1), [TrimParam.StateIdx(1) TrimParam.StateIdx(3) TrimParam.StateIdx(5) TrimParam.StateIdx(8) TrimParam.StateIdx(12) TrimParam.StateIdx(14)])
    A(TrimParam.StateIdx(3), [TrimParam.StateIdx(1) TrimParam.StateIdx(3) TrimParam.StateIdx(5) TrimParam.StateIdx(8) TrimParam.StateIdx(12) TrimParam.StateIdx(14)])
    A(TrimParam.StateIdx(5), [TrimParam.StateIdx(1) TrimParam.StateIdx(3) TrimParam.StateIdx(5) TrimParam.StateIdx(8) TrimParam.StateIdx(12) TrimParam.StateIdx(14)])
    A(TrimParam.StateIdx(8), [TrimParam.StateIdx(1) TrimParam.StateIdx(3) TrimParam.StateIdx(5) TrimParam.StateIdx(8) TrimParam.StateIdx(12) TrimParam.StateIdx(14)])
    A(TrimParam.StateIdx(12), [TrimParam.StateIdx(1) TrimParam.StateIdx(3) TrimParam.StateIdx(5) TrimParam.StateIdx(8) TrimParam.StateIdx(12) TrimParam.StateIdx(14)])
    A(TrimParam.StateIdx(14), [TrimParam.StateIdx(1) TrimParam.StateIdx(3) TrimParam.StateIdx(5) TrimParam.StateIdx(8) TrimParam.StateIdx(12) TrimParam.StateIdx(14)])
];
Blon = [
    B(TrimParam.StateIdx(1), [1 4])
    B(TrimParam.StateIdx(3), [1 4])
    B(TrimParam.StateIdx(5), [1 4])
    B(TrimParam.StateIdx(8), [1 4])
    B(TrimParam.StateIdx(12), [1 4])
    B(TrimParam.StateIdx(14), [1 4])
];
Clon = [
    C(1, [TrimParam.StateIdx(1) TrimParam.StateIdx(3) TrimParam.StateIdx(5) TrimParam.StateIdx(8) TrimParam.StateIdx(12) TrimParam.StateIdx(14)])
    C(3, [TrimParam.StateIdx(1) TrimParam.StateIdx(3) TrimParam.StateIdx(5) TrimParam.StateIdx(8) TrimParam.StateIdx(12) TrimParam.StateIdx(14)])
    zeros(2, 6)
    C(7, [TrimParam.StateIdx(1) TrimParam.StateIdx(3) TrimParam.StateIdx(5) TrimParam.StateIdx(8) TrimParam.StateIdx(12) TrimParam.StateIdx(14)])
];
Clon(3,3) = 1; Clon(4,4) = 1;

fprintf('\n');
fprintf('\n Longitudinal Dynamics');
fprintf('\n-----------------------');
fprintf('\n  State vector: x = [u w q theta h Omega]');
fprintf('\n  Input vector: u = [elevator throttle]');
fprintf('\n Output vector: y = [Va alpha q theta h]');
fprintf('\n State matrix: A = \n');
disp(Alon);
fprintf('\n Control matrix: B = \n');
disp(Blon);
fprintf('\n Observation matrix: C = \n');
disp(Clon);

% Eigenvalue analysis
eiglon = eig(Alon);
for i=1:length(eiglon)
    if imag(eiglon(i))>0
        [wd, T, wn, zeta] = eigparam(eiglon(i));
        fprintf('\n Eigenvalue: %6.4f +/- %6.4f i', real(eiglon(i)), imag(eiglon(i)));
        fprintf('\n Damping = %6.4f, natural frequency = %6.4f rad/s, period = %8.4f s', zeta, wn, T);
    elseif imag(eiglon(i))==0
        fprintf('\n Eigenvalue: %6.4f', eiglon(i));
        fprintf('\n Time constant = %6.4f s', -1/eiglon(i));
    end
end

% Lateral-directional dynamics
% States: v p r phi psi
% Inputs: aileron rudder
% Outputs: beta p r phi psi
Alat = [
    A(TrimParam.StateIdx(2), [TrimParam.StateIdx(2) TrimParam.StateIdx(4) TrimParam.StateIdx(6) TrimParam.StateIdx(7) TrimParam.StateIdx(9)])
    A(TrimParam.StateIdx(4), [TrimParam.StateIdx(2) TrimParam.StateIdx(4) TrimParam.StateIdx(6) TrimParam.StateIdx(7) TrimParam.StateIdx(9)])
    A(TrimParam.StateIdx(6), [TrimParam.StateIdx(2) TrimParam.StateIdx(4) TrimParam.StateIdx(6) TrimParam.StateIdx(7) TrimParam.StateIdx(9)])
    A(TrimParam.StateIdx(7), [TrimParam.StateIdx(2) TrimParam.StateIdx(4) TrimParam.StateIdx(6) TrimParam.StateIdx(7) TrimParam.StateIdx(9)])
    A(TrimParam.StateIdx(9), [TrimParam.StateIdx(2) TrimParam.StateIdx(4) TrimParam.StateIdx(6) TrimParam.StateIdx(7) TrimParam.StateIdx(9)])
];
Blat = [
    B(TrimParam.StateIdx(2), [2 3])
    B(TrimParam.StateIdx(4), [2 3])
    B(TrimParam.StateIdx(6), [2 3])
    B(TrimParam.StateIdx(7), [2 3])
    B(TrimParam.StateIdx(9), [2 3])
];
Clat = [
    C(2, [TrimParam.StateIdx(2) TrimParam.StateIdx(4) TrimParam.StateIdx(6) TrimParam.StateIdx(7) TrimParam.StateIdx(9)])
    zeros(4, 5)
];
Clat(2,2) = 1; Clat(3,3) = 1;
Clat(4,4) = 1; Clat(5,5) = 1;

fprintf('\n');
fprintf('\n Lateral-directional Dynamics');
fprintf('\n------------------------------');
fprintf('\n  State vector: x = [v p r phi psi]');
fprintf('\n  Input vector: u = [aileron rudder]');
fprintf('\n Output vector: y = [beta p r phi psi]');
fprintf('\n State matrix: A = \n');
disp(Alat);
fprintf('\n Control matrix: B = \n');
disp(Blat);
fprintf('\n Observation matrix: C = \n');
disp(Clat);

% Eigenvalue analysis
eiglat = eig(Alat);
for i=1:length(eiglat)
    if imag(eiglat(i))>0
        [wd, T, wn, zeta] = eigparam(eiglat(i));
        fprintf('\n Eigenvalue: %6.4f +/- %6.4f i', real(eiglat(i)), imag(eiglat(i)));
        fprintf('\n Damping = %6.4f, natural frequency = %6.4f rad/s, period = %8.4f s', zeta, wn, T);
    elseif (imag(eiglat(i))==0)&(real(eiglat(i))~=0)
        fprintf('\n Eigenvalue: %6.4f', eiglat(i));
        fprintf('\n Time constant = %6.4f s', -1/eiglat(i));
    end
end