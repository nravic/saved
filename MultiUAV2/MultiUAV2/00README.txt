Welcome to MultiUAV version 2.0!

Here are some general notes about the file layout and usage, in no
particular order:

Top Level:

	00README				- (*this);
	AVDSData        - data directory for AVDS visualization of sim results.
	Documents       - highest level documentation, i.e. manual, etc.
	InputFiles      - various input files needed by the simulation;
	                  typically used only by s-function files.
	m-file          - where all of the m-file scripts/functions live.
	MonteCarloData  - data directory for Monte-Carlo simulation data.
	s-model         - directory where the Simulink portions live.
	src             - compiled C++ material for mex-/s-func, and additional
	                  libraries; makefile(s) and MSVC++ project files
										reside here.
	startup.m       - hook to get you into MATLAB and setup the sim environ.
	tool            - directory to hold little tools/scripts mostly useful for
	                  development, rather than simulation use.

Usage:

	0. Startup MATLAB in this top level directory.  It will initialize the
	   needed paths, and change you automatically to the m-file directory
		 and bring up the sim GUI.

	1. Many (but not all) simulation parameters are specified in the file:
	   m-file/InitializeGlobals.m.  There is a GUI button to open this file
		 for editing if you are using the _BIG_ MATLAB front-end.

	2. More specific details can be found in the documentation at
	   Documents/MultiUAV2.pdf.
