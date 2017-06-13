%startup - this script sets up the MultiUAV global simulation parameters/memory and opens the GUI figure 
%       which calls other intialization functions
%
%  Inputs:
%    (none) 
%
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS
%  May 2001 - moved globals to separate script - RAS

%debug_mex_files = 0;
%if(isunix & debug_mex_files)
%  dbmex on;
%end
%clear debug_mex_files;

% hop to m-file dir and intialize global variables
cd('m-file');
InitializeGlobals;
