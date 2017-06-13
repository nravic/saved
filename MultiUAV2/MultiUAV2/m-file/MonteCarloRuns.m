function MonteCarloRuns 
%MonteCarloRuns - used to setup and run the simulation for monte carlo runs
%
%  Inputs:
%    (none) 
%
%  Outputs:
%    (none)
%
% Notes:
%   0. You can safely interrupt MonteCarloRuns while running by
%      creating a file named 'stopmonte' in the MultiUAV directory.
%      Don't forget to remove this file afterwards, if it lingers.
%  

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS
%  Fall 2001 - modified to do monte carlo runs - DUNKEL
%  2003/06/??  jwm  added few things like save all plot data, monte diary,
%                   and pack of mem every m runs to improve speed.
%============================================================================

s = who('global');
if( ~ismember( 'g_OneTimeInitialization', s ) )
	warning('Must run InitializeGlobals first!');
	error(mfilename);
end
clear s;

global g_isMonteCarloStop; g_isMonteCarloStop=0;
global g_isMonteCarloRun; g_isMonteCarloRun=1;
global g_Scenario;
global g_Seed;
global g_SimulationRunNumber;
global g_StopTime;
global g_StopTime;
global g_TypeAssignment;
global g_AssignmentAlgorithm; 
global g_SummaryFileName;
global g_MonteCarloMetrics;
global g_LengthenPaths;
global g_ActiveTargets;
global g_ActiveVehicles;
global g_CommunicationMemory;
global g_PlotAxesLimits;
global g_SearchSpace;
global g_TargetSpace;
global g_WaypointCells;
global g_MaxNumberVehicles;
global g_MaxNumberTargets;
global g_TargetTypes;
global g_TargetStates;
global g_EnableVehicle;
global g_VehicleColors;

%directory for saving results
tdir = ['..', filesep];
mdir = [tdir,'MonteCarloData'];
rtime = datestr(now,30); % avoid close time spawned different names
g_MonteCarloMetrics.DirectoryName = [mdir,filesep,'Run.',rtime];
g_MonteCarloMetrics.SaveMultipleTaskDataFlag = 0;
g_MonteCarloMetrics.RecalculateTrajectory = 1;	%force trajectory recalculation at every reassignment

% check that directories exists and make it if not
dirs = {mdir, g_MonteCarloMetrics.DirectoryName};
for k = 1:length(dirs),
	d = dirs{k};
	if( ~exist(d, 'dir') ),
%		warning([d, ' directory does not exist...making...']);
		[stat, msg] = mkdir(d);
		if( stat ~= 1 ),
			error(msg);
		end
	end
end
clear msg stat d k tdir mdir dirs;

%%===================== BEGIN DATA RECORD OPTIONS =============================
% g_OptionSaveDataPlot no longer necessary, see local SaveAllPlotData and
% Number

% set g_OptionSaveDataPlot to control saving of plot data. 
% (NOTE: Turning this off will increase simulation speed.).:
%     0 - OFF
%     1	- ON
global g_OptionSaveDataPlot; g_OptionSaveDataPlot=0;

% set g_OptionSaveDataAVDS to control saving of AVDS data. 
% (NOTE: Turning this OFF will increase simulation speed.).:
%     0	- OFF
%     1	- ON
global g_OptionSaveDataAVDS;	g_OptionSaveDataAVDS=0;

% set LOCAL option SaveWorkspace to control saving of workspace data for every
% run. This can get very big, and may not be 'easily' cullable.
% Also, SaveWorkspace OVERRIDES SaveAllPlotData, i.e. save workspace
% include plot data so it is not saved spearately.
% (NOTE: Turning this OFF will increase simulation speed.).
%     0	- OFF
%     1	- ON
SaveWorkspace = 1; 

% set LOCAL option SaveAllDataPlot to control saving of plot data for every
% run. This can get very big, and it may require hand mods to PlotOutput to
% view it.  It also OVERRIDES g_OptionSaveDataPlot above...so be careful.
% (NOTE: Turning this OFF will increase simulation speed.).
%     0	- OFF
%     1	- ON
SaveAllPlotData = 1; 

% set LOCAL option SaveAllCommData to control saving of comm data for every
% run. This can get VERY big, and it may require hand mods to the comm history
% viewer routines to see it.
% (NOTE: Turning this OFF will increase simulation speed.).
%     0	- OFF
%     1	- ON
SaveAllCommData = 1; 

% set LOCAL option SaveDiary to control saving of console output to
% tagged diary file.
% (NOTE: Turning this OFF will increase simulation speed.).
%     0	- OFF
%     1	- ON
SaveDiary = 1;

% set LOCAL option PackMemOn to control how often memory is 'pack'd
% during a monte sequence.  It works by looking at the remainder of
% g_SimulationRunNumber divided by the value of PackMemOn.  
% results as pack time is short.
%
% (NOTE: Turning this ON will increase simulation speed.).
%           0 - yields NaN, so don't do it! (Very slow in Pentium 4)
%           2	- pack every other run
%           3	- pack every third run, etc.
%           .
%           .
%     realmax	- OFF, i.e. no pack applied
PackMemOn = 2;
%%====================== END DATA RECORD OPTIONS =============================


%%====================== BEGIN ESSENTIAL OPTIONS =============================

SimTime = 200;
%SimTime = 220;  % jwm-cdc04
g_StopTime = SimTime;
NumberRuns = 50;
%SimOptions = simset('Trace','compile');

%%======================= END ESSENTIAL OPTIONS ==============================

g_Scenario = 1;
NumberAVDS      = []; % Allows specified run number(s) to save AVDS data.
NumberWorkspace = []; % Allows specified run number(s) to save Workspace data.
NumberPlots     = []; % Allows specified run number(s) to save plot data.
NumberComms     = []; % Allows specified run number(s) to save comm data.

%% if we want to save all the plot data, then turn on saves by run
if( SaveAllPlotData == 1 ) 
	g_OptionSaveDataPlot = 1; % turn on in simulation...
end

if( SaveWorkspace == 1 ) 
	OptionSaveAllPlotData = 1; % turn on in simulation...
end

CommData = {};
iCommSave = 1;  % index for # of comm data saves, can be different than g_Scenario

if( exist('stopmonte','file') )
	disp([mfilename, ' - aborting MonteCarloRuns; ''stopmonte'' file found!']);
	disp([mfilename, ' - remove the file ''stopmonte'' and re-run.']);
	return;
end;

GenSumName = [g_MonteCarloMetrics.DirectoryName,filesep,'NAME','.dat'];

StartTime = clock;
for iCount = 1:NumberRuns,

	%% if you want to capture all the output possible, this MUST be the
	%% first thing in this iCount loop!!!!!!!!!
	if( SaveDiary == 1 )
		% keep all the diaries in a single file, as opposed to individual
		% diary files specified in the commented line below.
    diary( strrep(strrep(GenSumName, 'NAME', 'diary'), 'dat', 'txt') );
	end
	
	% save multiple task assignments
	g_SimulationRunNumber = iCount;
	%Set the random number generator seed according to scenario number and run number.  Dunkel, 22 Oct 2001
	g_Seed = g_Scenario*20000 + g_SimulationRunNumber;
	
	disp(sprintf('\n%s::Run #%03d of %03d runs', mfilename, ...
							 g_SimulationRunNumber, NumberRuns));
	
	GenRunName = [g_MonteCarloMetrics.DirectoryName,filesep,'NAME','.', ...
								sprintf('%03d', g_SimulationRunNumber),'.mat'];

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%first assignment type run
	g_SummaryFileName = strrep(GenSumName, 'NAME', 'SummaryData');

	% the next two are for differentiating path-lengthing output data
	%g_SummaryFileName = strrep(GenSumName, 'NAME', 'SummaryData.Lengthen');
	%g_SummaryFileName = strrep(GenSumName, 'NAME', 'SummaryData.NoLengthen');

	if( ismember(iCount, NumberAVDS) ),
		g_OptionSaveDataAVDS = 1;
	else,
		g_OptionSaveDataAVDS = 0;
	end;

	% check of NumberPlots moved below

	rand('state',g_Seed);
	g_AssignmentAlgorithm = g_TypeAssignment.ItCapTransShip;
	g_LengthenPaths = 1;
	g_MonteCarloMetrics.MultipleTaskSaveFile = [sprintf('Save')];

	[t,x,y] = sim('MultiUAV',SimTime);
	clear t x y;
    
	g_MonteCarloMetrics.LastMultipleTaskSaveTime = 0;
    
  if( (SaveAllCommData == 1) | ismember(iCount, NumberComms) ),
		GenMatName = strrep(GenSumName,'dat', 'mat');
		f = strrep(GenMatName,'NAME', 'CommData');
		if( exist(f, 'file') )
			load(f);
		end
		CommData{ iCommSave } = struct('run', iCount, 'seed', g_Seed, ...
																	 'CommMem', g_CommunicationMemory, ...
																	 'CommMsgHist', CommMessageHistory );
		iCommSave = iCommSave + 1;
		save(f, 'CommData');
		clear GenMatName f CommData;
	end
    
  if( (SaveWorkspace == 1) | ismember(iCount, NumberWorkspace) ),
    WorkspaceOut = strrep(GenRunName,'NAME', 'workspace');
		XYPositions     = []; % explicitly declare...
		TargetPositions = []; % explicitly declare...
		load SimPositionsOut.mat; % XYPositions (used in PlotOutput)
		load SimTargetsOut.mat;   % TargetPositions (used in PlotOutput)
		global g_XYPositions g_TargetPositions;
		g_XYPositions = XYPositions;
		g_TargetPositions = TargetPositions;
		save(WorkspaceOut);
		clear XYPositions;
	end

  if( (SaveWorkspace == 0) & ...
		  ((SaveAllPlotData == 1) | ismember(iCount,NumberPlots)) ),
		XYPositions     = []; % explicitly declare...
		TargetPositions = []; % explicitly declare...
		load SimPositionsOut.mat; % XYPositions (used in PlotOutput)
		load SimTargetsOut.mat;   % TargetPositions (used in PlotOutput)
		global g_XYPositions g_TargetPositions;
		g_XYPositions = XYPositions;
		g_TargetPositions = TargetPositions;
		PlotDataName = strrep(GenRunName,'NAME', 'PlotData');
		save(PlotDataName,'g_WaypointCells','g_XYPositions','g_TargetPositions');
		clear XYPositions;

		% other things possibly needed for ploting data (global'd above)
		%PlotSupp = struct('g_PlotAxesLimits', g_PlotAxesLimits, ...
		%									 'g_SearchSpace', g_SearchSpace, ...
		%									 'g_TargetSpace', g_TargetSpace, ...
		%									 'g_MaxNumberVehicles', g_MaxNumberVehicles, ...
		%									 'g_MaxNumberTargets', g_MaxNumberTargets, ...
		%									 'TargetTypes', g_TargetTypes, ...
		%									 'g_TargetStates', g_TargetStates, ...
		%									 'g_EnableVehicle', g_EnableVehicle, ...
		%									 'g_VehicleColors', g_VehicleColors );
  end;

	% pack mem in tmp dir to improve performance for long or many runs.
	if( ~rem(g_SimulationRunNumber, PackMemOn))
		tic;
		disp( sprintf( '%s::message - packing memory...', mfilename) );
		cwd = pwd;
		cd(tempdir);
		pack
		cd(cwd);
		disp( sprintf( '%s::message - done.  (%.2f s)', mfilename, toc) );
	end
   
	s = whos;
	total_bytes = sum(cell2mat({s.bytes}));
	disp(sprintf('%s::TotalMemory = %d bytes == %d MB', mfilename, ...
							 total_bytes, total_bytes/1024^2));
	clear s total_bytes;

	% check for abort
	if(g_isMonteCarloStop | exist('stopmonte','file') )
		disp([mfilename, ' - aborting MonteCarloRuns!']);
		disp('                 GUI or stopmonte file found.');
		disp('');
		break;
	end;

	if( SaveDiary == 1 )
		diary off;
	end

end;	%for

if( exist('stopmonte','file') )
	disp([mfilename, ' - removing ''stopmonte'' file.']);
	delete('stopmonte');
end;

g_isMonteCarloRun = 0;

% variable clean up
clear iCommSave rtime;

% finish up above because the time metrics start below:
DeltaTime = etime(clock,StartTime);
RealTimeMetric = (0.5*DeltaTime)/SimTime/NumberRuns;
RateTimesRealTime = 1/RealTimeMetric;

disp(sprintf('%s::RealTimeMetric = %12.9e', mfilename, RealTimeMetric));
disp(sprintf('%s::RateTimesRealTime = %12.9e', mfilename, RateTimesRealTime));
disp(sprintf('%s::Total elapsed time: %.2f s == %.2f m == %.2f hr', ...
						 mfilename, DeltaTime, DeltaTime/60, DeltaTime/3600) );
disp(sprintf('%s::Avg run time: %.2f s == %.2f m', mfilename, ...
						 DeltaTime/NumberRuns, DeltaTime/NumberRuns/60));

return;
