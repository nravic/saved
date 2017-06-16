%%% AIRCRAFT CONFIGURATION SCRIPT %%%
%%% TEMPLATE %%%

%   Copyright 2002 Unmanned Dynamics, LLC
%   Revision: 1.0   Date: 08/07/2002

%%% IMPORTANT %%%
% Airframe origin (reference point) can be arbitrarily chosen
% Body axes convention is as follows:
%       x - forward towards the nose
%       y - spanwise, towards the right wing tip
%       z - vertical, pointing down
% All data should be specified in metric units, unless otherwise noted

% Clear workspace
clear all;

%%% Begin editing here %%%

% Insert the name of the MAT-file that will be generated (without .mat extension)
cfgmatfile = 'template_cfg';

%%% SECTION 1 %%%
%%% AERODYNAMICS %%%
% Aerodynamic force application point [x y z]
%(Location of the aerodynamic center with respect to the origin, in meters
rAC = [0 0 0]; % m

%%% Aerodynamic parameter bounds %%%
% (the model will limit the parameters below to these intervals, to keep aerodynamics within linear region)
% Airspeed bounds
VaBnd = [0 0]; % m/s
% Sideslip angle bounds
BetaBnd = [0 0]; % rad
% Angle of attack bounds
AlphaBnd = [0 0]; % rad

%%% Aerodynamic reference parameters %%%
% Mean aerodynamic chord
MAC = 0; % m
% Wind span
b = 0; % m
% Wing area
S = 0; % m^2

% ALL aerodynamics derivatives are per radian:
%%% Lift coefficient %%%
% Zero-alpha lift
CL0 = 0;
% alpha derivative
CLa = 0;
% Lift control (flap) derivative
CLdf = 0;
% Pitch control (elevator) derivative
CLde = 0;
% alpha-dot derivative
CLalphadot = 0;
% Pitch rate derivative
CLq = 0;
% Mach number derivative
CLM = 0;

%%% Drag coefficient %%%
% Lift at minimum drag
CLmind = 0;
% Minimum drag
CDmin = 0;
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
osw = 0;

%%% Side force coefficient %%%
% Sideslip derivative
CYbeta = 0;
% Roll control derivative
CYda = 0;
% Yaw control derivative
CYdr = 0;
% Roll rate derivative
CYp = 0;
% Yaw rate derivative
CYr = 0;

%%% Pitch moment coefficient %%%
% Zero-alpha pitch
Cm0 = 0;
% alpha derivative
Cma = 0;
% Lift control derivative
Cmdf = 0;
% Pitch control derivative
Cmde = 0;
% alpha_dot derivative
Cmalphadot = 0;
% Pitch rate derivative
Cmq = 0;
% Mach number derivative
CmM = 0;

%%% Roll moment coefficient %%%
% Sideslip derivative
Clbeta = 0;
% Roll control derivative
Clda = 0;
% Yaw control derivative
Cldr = 0;
% Roll rate derivative
Clp = 0;
% Yaw rate derivative
Clr = 0;

%%% Yaw moment coefficient %%%
% Sideslip derivative
Cnbeta = 0;
% Roll control derivative
Cnda = 0;
% Yaw control derivative
Cndr = 0;
% Roll rate derivative
Cnp = 0;
% Yaw rate derivative
Cnr = 0;


%%% SECTION 2 %%%
%%% PROPELLER %%%
%Propulsion force application point [x y z]
% (location of propeller hub with respect to the origin
rHub = [0 0 0]; % m
% Advance ratio vector
% (arbitrary size, but sizes for J, CT, and CP must match)
J = [0 0];
% Coefficient of thrust look-up table CT = CT(J)
CT = [0 0];
% Coefficient of power look-up table CP = CP(J)
CP = [0 0];
% Propeller radius
Rprop = 0; % m
% Propeller moment of inertia
Jprop = 0; % kg*m^2


%%% SECTION 3 %%%
%%% ENGINE %%%
% Engine rpm vector
% (arbitrary size)
RPM = [0 0]; % rot/min
% Manifold pressure vector
% (arbitrary size)
MAP = [0 0 0 0]; % kPa
% Sea-level fuel flow look-up table fflow = fflow(RPM, MAP)
% (Number of rows must match size of RPM vector, number of columns must match size of MAP vector)
FuelFlow = [
    0 0 0 0
    0 0 0 0
]; 
% Sea-level power look-up table P = P(RPM, MAP)
% (Number of rows must match size of RPM vector, number of columns must match size of MAP vector)
Power = [
    0 0 0 0
    0 0 0 0
]; % W
% Sea-level pressure and temperature at which the data above is given
pSL = 0; % Pa
TSL = 0; % deg K
% Engine shaft moment of inertia
% (generally can be neglected)
Jeng = 0;

%%% SECTION 4 %%%
%%% INERTIA %%%
% Empty aircraft mass (zero-fuel)
mempty = 0; % kg
% Gross aircraft mass (full fuel tank)
mgross = 0; % kg
% Empty CG location [x y z]
% (with respect to the origin)
CGempty = [0 0 0]; % m
% Gross CG location [x y z]
% (with respect to the origin)
CGgross = [0 0 0]; % m
% Empty moments of inertia [Jx Jy Jz Jxz]
Jempty = [0 0 0 0]; % kg*m^2
% Gross moments of inertia [Jx Jy Jz Jxz]
Jgross = [0 0 0 0]; % kg*m^2

%%% SECTION 5 %%%
%%% OTHER SIMULATION PARAMETERS %%%
% WMM-2000 date [day month year]
dmy = [00 00 0000];

%%% FINISHED ALL SECTIONS %%%
%%% Do not edit below this line %%%

% Save workspace variables to MAT file
save(cfgmatfile);

% Output a message to the screen
fprintf(strcat('\n Aircraft configuration saved as:\t', strcat(cfgmatfile),'.mat'));
fprintf('\n');