%XtremeReinitialize.m - this script sets up the MultiUAVglobal simulation parameters/memory and opens the GUI figure 
%       which calls other intialization functions
%
%  Inputs:
%    (none) 
%
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  June 2003 - Created and Debugged - RAS

clc;
disp('*** XtremeReinitialize:: Reinitializing Global Variables ***');
clear all;
% intialize global variables
InitializeGlobals;

