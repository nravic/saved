function [SearchValue] = SearchBenefit(iCountVehicles,Tf)
%SearchBenefit - calculates value of searching relative to other tasks
%
%  Inputs:
%    iCountVehicles -  
%    Tf - Time of flight remaining
%  Outputs:
%    SearchValue - Value of Continued Search
%

%  AFRL/VACA
%  Summer 2001 - Created and Debugged - COREY

% more information will need to be passed in about vehicle state.
% for starting purposes this information will be hard-coded here. 



global g_Debug; if(g_Debug==1),disp('SearchBenefit.m');end; 

% Maximum flight time: (seconds)
T_limit = 30*60;

% Time of flight remaining:
%Tf = 5*60; 	% will vary for each calculation, this is just a starting value

Val_max = 10;							% must be equal to maximum target value

%Compute Value of Continued Search:

Vsearch = Val_max*(Tf/T_limit);

SearchValue = Vsearch;

return;	%SearchBenefit