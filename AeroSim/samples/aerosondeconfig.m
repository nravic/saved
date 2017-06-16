% AIRCRAFT CONFIGURATION SCRIPT
%   Aerosonde UAV - sample model from AeroSim Library

%   Copyright 2002 Unmanned Dynamics, LLC
%   Revision: 1.0   Date: 05/13/2002

% Clear workspace
clear all;

% Name of the MAT-file that will be generated
cfgmatfile = 'aerosondecfg';

%%% AERODYNAMICS %%%
% Aerodynamic force application point (usually the aerodynamic center)[x y z]
rAC = [0.1425 0 0]; % m

%%% Aerodynamic parameter bounds %%%
% Airspeed bounds
VaBnd = [15 50]; % m/s
% Sideslip angle bounds
BetaBnd = [-0.5 0.5]; % rad
% Angle of attack bounds
AlphaBnd = [-0.1 0.3]; % rad

%%% Aerodynamic reference parameters %%%
% Mean aerodynamic chord
MAC = 0.189941; % m
% Wind span
b = 2.8956; % m
% Wing area
S = 0.55; % m^2

% ALL aerodynamics derivatives are per radian:
%%% Lift coefficient %%%
% Zero-alpha lift
CL0 = 0.23;
% alpha derivative
CLa = 5.6106;
% Lift control (flap) derivative
CLdf = 0.74;
% Pitch control (elevator) derivative
CLde = 0.13;
% alpha-dot derivative
CLalphadot = 1.9724;
% Pitch rate derivative
CLq = 7.9543;
% Mach number derivative
CLM = 0;

%%% Drag coefficient %%%
% Lift at minimum drag
CLmind = 0.23;
% Minimum drag
CDmin = 0.0434;
% Lift control (flap) derivative
CDdf = 0.1467;
% Pitch control (elevator) derivative
CDde = 0.0135;
% Roll control (aileron) derivative
CDda = 0.0302;
% Yaw control (rudder) derivative
CDdr = 0.0303;
% Mach number derivative
CDM = 0;
% Oswald's coefficient
osw = 0.75;

%%% Side force coefficient %%%
% Sideslip derivative
CYbeta = -0.83;
% Roll control derivative
CYda = -0.075;
% Yaw control derivative
CYdr = 0.1914;
% Roll rate derivative
CYp = 0;
% Yaw rate derivative
CYr = 0;

%%% Pitch moment coefficient %%%
% Zero-alpha pitch
Cm0 = 0.135;
% alpha derivative
Cma = -2.7397;
% Lift control derivative
Cmdf = 0.0467;
% Pitch control derivative
Cmde = -0.9918;
% alpha_dot derivative
Cmalphadot = -10.3796;
% Pitch rate derivative
Cmq = -38.2067;
% Mach number derivative
CmM = 0;

%%% Roll moment coefficient %%%
% Sideslip derivative
Clbeta = -0.13;
% Roll control derivative
Clda = -0.1695;
% Yaw control derivative
Cldr = 0.0024;
% Roll rate derivative
Clp = -0.5051;
% Yaw rate derivative
Clr = 0.2519;

%%% Yaw moment coefficient %%%
% Sideslip derivative
Cnbeta = 0.0726;
% Roll control derivative
Cnda = 0.0108;
% Yaw control derivative
Cndr = -0.0693;
% Roll rate derivative
Cnp = -0.069;
% Yaw rate derivative
Cnr = -0.0946;


%%% PROPELLER %%%
%Propulsion force application point (usually propeller hub) [x y z]
rHub = [0 0 0]; % m
% Advance ratio vector
J = [-1 0 0.1 0.2 0.3 0.35 0.4 0.45 0.5 0.6 0.7 0.8 0.9 1 1.2 2];
% Coefficient of thrust look-up table CT = CT(J)
CT = [0.0492 0.0286 0.0266 0.0232 0.0343 0.034 0.0372 0.0314 0.0254 0.0117 -0.005 -0.0156 -0.0203 -0.0295 -0.04 -0.1115];
% Coefficient of power look-up table CP = CP(J)
CP = [0.0199 0.0207 0.0191 0.0169 0.0217 0.0223 0.0254 0.0235 0.0212 0.0146 0.0038 -0.005 -0.0097 -0.018 -0.0273 -0.0737];
% Propeller radius
Rprop = 0.254; % m
% Propeller moment of inertia
Jprop = 0.002; % kg*m^2


%%% ENGINE %%%
% Engine rpm vector
RPM = [1500 2100 2800 3500 4500 5100 5500 6000 7000]; % rot per min
% Manifold pressure vector
MAP = [60 70 80 90 92 94 96 98 100]; % kPa

% Sea-level fuel flow look-up table fflow = fflow(RPM, MAP)
% RPM -> rows, MAP -> columns
FuelFlow = [
    31 32 46 53 55 57 65 73 82
    40 44 54 69 74 80 92 103 111
    50 63 69 92 95 98 126 145 153
    66 75 87 110 117 127 150 175 190
    83 98 115 143 148 162 191 232 246
    93 102 130 159 167 182 208 260 310
    100 118 137 169 178 190 232 287 313
    104 126 151 184 191 206 253 326 337
    123 144 174 210 217 244 321 400 408
]; % g/hr
% Sea-level power look-up table P = P(RPM, MAP)
% RPM -> rows, MAP -> columns
Power = [
    18.85 47.12 65.97 67.54 69.12 67.54 67.54 69.12 86.39
    59.38 98.96 127.55 149.54 151.74 160.54 178.13 200.12 224.31
    93.83 149.54 187.66 237.5 249.23 255.1 307.88 366.52 398.77
    109.96 161.27 245.57 307.88 326.2 351.86 421.5 491.14 531.45
    164.93 245.04 339.29 438.25 447.68 494.8 565.49 673.87 772.83
    181.58 245.67 389.87 496.69 528.73 571.46 662.25 822.47 993.37
    184.31 293.74 403.17 535.64 570.2 622.04 748.75 956.09 1059.76
    163.36 276.46 420.97 565.49 609.47 691.15 860.8 1130.97 1193.81
    124.62 249.23 417.83 586.43 645.07 762.36 996.93 1246.17 1429.42
]; % W
% Sea-level pressure and temperature at which the data above is given
pSL = 102300; % Pa
TSL = 291.15; % deg K
% Engine shaft moment of inertia
Jeng = 0.0001; % kg*m^2


%%% INERTIA %%%
% Empty aircraft mass (zero-fuel)
mempty = 8.5; % kg
% Gross aircraft mass (full fuel tank)
mgross = 13.5; % kg
% Empty CG location [x y z]
CGempty = [0.156 0 0.079]; % m
% Gross CG location [x y z]
CGgross = [0.159 0 0.090]; % m
% Empty moments of inertia [Jx Jy Jz Jxz]
Jempty = [0.7795 1.122 1.752 0.1211]; % kg*m^2
% Gross moments of inertia [Jx Jy Jz Jxz]
Jgross = [0.8244 1.135 1.759 0.1204]; % kg*m^2


%%% OTHER SIMULATION PARAMETERS %%%
% WMM-2000 date [day month year]
dmy = [13 05 2002];

% Save workspace variables to MAT file
save(cfgmatfile);

% Output a message to the screen
fprintf(strcat('\n Aircraft configuration saved as:\t', strcat(cfgmatfile),'.mat'));
fprintf('\n');