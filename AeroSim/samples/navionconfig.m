%%% AIRCRAFT CONFIGURATION SCRIPT %%%
%%% Navion GA airplane - sample model from AeroSim Library %%%

%   Copyright 2002 Unmanned Dynamics, LLC
%   Revision: 1.0   Date: 05/13/2002

% Clear workspace
clear all;

% Name of the MAT-file that will be generated
cfgmatfile = 'navioncfg';

%%% AERODYNAMICS %%%
% Aerodynamic force application point (usually the aerodynamic center)[x y z]
rAC = [0 0 0]; % m

%%% Aerodynamic parameter bounds %%%
% Airspeed bounds
VaBnd = [30 100]; % m/s
% Sideslip angle bounds
BetaBnd = [-0.5 0.5]; % rad
% Angle of attack bounds
AlphaBnd = [-0.1 0.5]; % rad

%%% Aerodynamic reference parameters %%%
% Mean aerodynamic chord
MAC = 1.73736; % m
% Wind span
b = 10.18032; % m
% Wing area
S = 184*0.3048^2; % m^2

% ALL aerodynamics derivatives are per radian:
%%% Lift coefficient %%%
% Zero-alpha lift
CL0 = 0.3;
% alpha derivative
CLa = 4.44;
% Lift control (flap) derivative
CLdf = 0;
% Pitch control (elevator) derivative
CLde = 0.355;
% alpha-dot derivative
CLalphadot = 0;
% Pitch rate derivative
CLq = 3.8;
% Mach number derivative
CLM = 0;

%%% Drag coefficient %%%
% Lift at minimum drag
CLmind = 0.3;
% Minimum drag
CDmin = 0.04;
% Lift control (flap) derivative
CDdf = 0;
% Pitch control (elevator) derivative
CDde = 0;
% Roll control (aileron) derivative
CDda = 0;
% Yaw control (rudder) derivative
CDdr = 0;
% Mach number derivative
CDM = 0;
% Oswald's coefficient
osw = 0.7;

%%% Side force coefficient %%%
% Sideslip derivative
CYbeta = -0.564;
% Roll control derivative
CYda = 0;
% Yaw control derivative
CYdr = 0.157;
% Roll rate derivative
CYp = 0;
% Yaw rate derivative
CYr = 0;

%%% Pitch moment coefficient %%%
% Zero-alpha pitch
Cm0 = 0;
% alpha derivative
Cma = -0.683;
% Lift control derivative
Cmdf = 0;
% Pitch control derivative
Cmde = -0.923;
% alpha_dot derivative
Cmalphadot = -4.36;
% Pitch rate derivative
Cmq = -9.96;
% Mach number derivative
CmM = 0;

%%% Roll moment coefficient %%%
% Sideslip derivative
Clbeta = -0.074;
% Roll control derivative
Clda = -0.134;
% Yaw control derivative
Cldr = 0.107;
% Roll rate derivative
Clp = -0.41;
% Yaw rate derivative
Clr = 0.107;

%%% Yaw moment coefficient %%%
% Sideslip derivative
Cnbeta = 0.071;
% Roll control derivative
Cnda = -0.0035;
% Yaw control derivative
Cndr = -0.072;
% Roll rate derivative
Cnp = -0.0575;
% Yaw rate derivative
Cnr = -0.125;


%%% PROPELLER %%%
%Propulsion force application point (usually propeller hub) [x y z]
rHub = [1.25*1.75 0 0]; % m
% Advance ratio vector
J = [-1 0 0.1 0.2 0.3 0.35 0.4 0.45 0.5 0.6 0.7 0.8 0.9 1 1.2 2];
% Coefficient of thrust look-up table CT = CT(J)
CT = [0.0492 0.0286 0.0266 0.0232 0.0343 0.034 0.0372 0.0314 0.0254 0.0117 -0.005 -0.0156 -0.0203 -0.0295 -0.04 -0.1115];
% Coefficient of power look-up table CP = CP(J)
CP = [0.0199 0.0207 0.0191 0.0169 0.0217 0.0223 0.0254 0.0235 0.0212 0.0146 0.0038 -0.005 -0.0097 -0.018 -0.0273 -0.0737];
% Propeller radius
Rprop = 1.88/2; % m
% Propeller moment of inertia
Jprop = 25.4*0.0254*0.4536; % kg*m^2


%%% ENGINE %%%
% Engine rpm vector
RPM = [2000 2200 2400 2600 2700]; % rot/min
% Manifold pressure vector
MAP = [57.6 64.35 71.12 77.89 84.66 91.44 98.21]; % kPa

% Sea-level fuel flow look-up table fflow = fflow(RPM, MAP)
% RPM -> rows, MAP -> columns
FuelFlow = [
    6 6.7 7.5 8.5 9.6 12 14.3
    6.5 7.3 8.2 9.4 10.6 12 14.3
    7.2 8 9 10 11.4 12.8 14.3
    7.8 8.6 9.6 10.9 12.3 14 15.6
    8.3 9.2 10.3 11.6 13.2 15 17
]*0.0037854*800*1000; 
% Sea-level power look-up table P = P(RPM, MAP)
% RPM -> rows, MAP -> columns
Power = [
    70 83 96 110 124 137 151
    77 90 105 120 134 150 164
    84 98 114 128 144 160 174
    88 104 118 134 150 166 180
    91 107 122 138 154 170 184
]*745.7; % W
% Sea-level pressure and temperature at which the data above is given
pSL = 102300; % Pa
TSL = 291.15; % deg K
% Engine shaft moment of inertia
Jeng = 0; % Neglected


%%% INERTIA %%%
% Empty aircraft mass (zero-fuel)
mempty = 1000; % kg
% Gross aircraft mass (full fuel tank)
mgross = 1247.392; % kg
% Empty CG location [x y z]
CGempty = [-0.04*MAC 0 -0.25]; % m
% Gross CG location [x y z]
CGgross = [-0.045*MAC 0 -0.2]; % m
rAC = CGgross; % m
% Empty moments of inertia [Jx Jy Jz Jxz]
Jempty = [1040 2900 3500 100]*14.594*0.3048^2; % kg*m^2
% Gross moments of inertia [Jx Jy Jz Jxz]
Jgross = [1048 3000 3530 110]*14.594*0.3048^2; % kg*m^2


%%% OTHER SIMULATION PARAMETERS %%%
% WMM-2000 date [day month year]
dmy = [13 05 2002];

% Save workspace variables to MAT file
save(cfgmatfile);

% Output a message to the screen
fprintf(strcat('\n Aircraft configuration saved as:\t', strcat(cfgmatfile),'.mat'));
fprintf('\n');