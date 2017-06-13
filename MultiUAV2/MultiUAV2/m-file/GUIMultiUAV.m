function GUIMultiUAV(action,Input)
%GUIMultiUAV - function builds the GUI and contains the callback function for it
%
%  Inputs:
%    (none)

%  Outputs:
%    (none)
%

%  AFRL/VACA
%  September 2000 - Created and Debugged - RAS



global g_Debug; 
if(~exist('g_Debug')),g_Debug=0;end;
if(g_Debug==1),disp('GUIMultiUAV.m');end; 

global g_isMonteCarloStop;
global g_isMonteCarloRun;
global g_OneTimeInitialization;
global g_CommunicationMemory;

if nargin <1,
	action = 'DrawFigure';
end

% add button names, callback function names and button colors to the following cell array to add buttons to the GUI
ButtonsStrings = {
	{'Xtreme Reinitilization'},{['XtremeReinitialize;']},{['[1.0 1.0 0.0]']}
	{'Run Simulation'},{['GUIMultiUAV(''RunSimulation'');']},{['[0.4 0.6 0.4]']}
	{'Run MonteCarlo'},{['GUIMultiUAV(''RunMonteCarlo'');']},{['[0.4 0.6 0.4]']}
	{'Stop MonteCarlo'},{['GUIMultiUAV(''StopMonteCarlo'');']},{['[0.6 0.4 0.4]']}
	{'Plot Vehicle Trajectories'},{['GUIMultiUAV(''PlotResults'');']},{['[0.6 0.6 0.4]']}
	{'Print Simulation Settings'},{['PrintSimulationSettings']},{['[0.6 0.6 0.4]']}
	{'Plot Comm Avg Data Rate'},{['GUIMultiUAV(''CommPlot'');']},{['[0.6 0.6 0.4]']}
	{'Save AVDS Data'},{['GUIMultiUAV(''SaveAVDSData'')']},{['[0.6 0.6 0.4]']}
	{'Edit Globals'},{['GUIMultiUAV(''EditInitializeGlobals'');']},{['[0.4 0.6 0.6]']}
	{'Edit MonteCarlo'},{['GUIMultiUAV(''EditMonteCarlo'');']},{['[0.4 0.6 0.6]']}
	{'Edit Simulation Functions'},{['GUIMultiUAV(''EditSimulationFunctions'');']},{['[0.4 0.6 0.6]']}
	{'Edit Create Structure'},{['GUIMultiUAV(''EditCreateStructure'');']},{['[0.4 0.6 0.6]']}
	{'Edit GUI'},{['GUIMultiUAV(''EditGUI'');']},{['[0.4 0.6 0.6]']}
	{'Run VehicleTest'},{['GUIMultiUAV(''RunVehicleTest'');']},{['[0.4 0.6 0.4]']}
	{'Open MultiUAV Main (Simulink)'},{['GUIMultiUAV(''OpenMultiUAV'');']},{['[0.5 0.4 0.6]']}
	{'Open MultiUAV Library (Simulink)'},{['GUIMultiUAV(''OpenCooperativeLib'');']},{['[0.5 0.4 0.6]']}
};
for(CountMessages=1:g_CommunicationMemory.NumberMessages),
	ButtonsStrings{end+1,1} = {['Messages: ' g_CommunicationMemory.Messages{CountMessages}.Title]};
	MessageNumberString = num2str(CountMessages);
	ButtonsStrings{end,2} = {['GUIMultiUAV(''ShowMessage'',',MessageNumberString,');']};
	ButtonsStrings{end,3} = {['[0.8 0.7 0.5]']};
end;	%for(CountMessages=1:g_CommunicationMemory.NumberMessages)
%add some blank buttons for spacing
%ButtonsStrings{end+1,1} = {''}; ButtonsStrings{end,2} = {['']}; ButtonsStrings{end,3} = {['[0.7 0.7 0.7]']};

% moved def here for convenience with adding blank buttons
ButtonsPerColumn = 14;

switch action
	
case 'ShowMessage',
	if(~isempty(g_CommunicationMemory.Messages{Input}.Data)),
		fprintf(strcat(g_CommunicationMemory.Messages{Input}.Title,' = \n'));
		disp(g_CommunicationMemory.Messages{Input}.Data(:,find(g_CommunicationMemory.Messages{Input}.Data(1,:)~=0)));
	else,
		fprintf('****** No Messages ******\n');
	end;
	
case 'PlotResults',
	PlotOutput('PlotData',0);

case 'CommPlot',
	CommPlot(0);
	
case 'RunSimulation',
	g_isMonteCarloRun=0;
	[t,x,y] = sim('MultiUAV');
	
case 'RunVehicleTest',
	[t,x,y] = sim('VehicleTest');
	
case 'SaveAVDSData',
	SaveAVDSData;
	
case 'EditInitializeGlobals',
	local_edit('InitializeGlobals.m');
	
case 'EditCreateStructure',
	local_edit('CreateStructure.m');
	
case 'EditMonteCarlo',
	local_edit('MonteCarloRuns.m');
	
case 'RunMonteCarlo',
    disp(sprintf('\n'));
    disp('Luke:  All right, I''ll give it a try.');
    disp('Yoda:  No.  Try not.  Do, or do not.  *shakes head*  There is no ''try''.');
    disp('Luke:  I don''t believe it!');
    disp('Yoda:  That is why you fail.');
    disp(sprintf(['Robot Us(es):\n\tEnable by uncommenting ''MonteCarloRuns;''' ...
		  ' under ''case RunMonteCarlo''\n\tin GUIMultiUAV.m.']));

	%MonteCarloRuns;
	
case 'StopMonteCarlo',
	disp('**************************************************************************************************')
	disp('*********** Monte Carlo simulation will stop at the end of the current simulation run. ***********')
	disp('**************************************************************************************************')
	g_isMonteCarloStop = 1;
	
case 'EditSimulationFunctions',
	local_edit('SimulationFunctions.m');
	
case 'OpenMultiUAV',
	open 'MultiUAV.mdl';
	
case 'OpenCooperativeLib',
	open 'cooperative.mdl';

case 'EditGUI',
	local_edit('GUIMultiUAV.m');
	
case 'DrawFigure',
	
	[NumberButtons,dummy]=size(ButtonsStrings);
	
	NumberColumns = fix((NumberButtons-1)/ButtonsPerColumn) + 1;
	ButtonWidth = 1/NumberColumns;
	if(NumberButtons > ButtonsPerColumn),
		ButtonHeight = 1/ButtonsPerColumn;
	else,
		ButtonHeight = 1/NumberButtons;
	end;
	
	GUIHeightIncrement = 0.025;
	GUIWidthIncrement = 0.15;
	if(NumberButtons > ButtonsPerColumn),
		GUIHeight = GUIHeightIncrement * ButtonsPerColumn;
	else,
		GUIHeight = GUIHeightIncrement * NumberButtons;
	end;
	GUIWidth = GUIWidthIncrement * NumberColumns;
	GUIPositionX = 0;
	GUIPositionY = 1 - (GUIHeight + GUIHeightIncrement);
	
	h0 = figure(32);
	clf;
	set(h0,'Color',[0.8 0.8 0.8], ...
		'Name','MultiUAV Simulation', ...
		'Units','normalized', ...
		'Position', [GUIPositionX GUIPositionY GUIWidth GUIHeight], ...
		'Tag','MultiUAVFig', ...
		'NumberTitle','off', ...
		'MenuBar','none', ...
		'ToolBar','none', ...
		'DefaultaxesCreateFcn','plotedit(gcbf,''promoteoverlay''); ');
	
	ButtonPositionX = 0;
	ButtonPositionY = 1 - ButtonHeight;
	CountColumnButtons = 1;
	for(CountButtons = 1:NumberButtons),
		h=uicontrol('Style', 'pushbutton', ...
			'Units','normalized', ...
			'Position', [ButtonPositionX ButtonPositionY ButtonWidth ButtonHeight], ...
			'String', ButtonsStrings{CountButtons,1},...
			'Callback',char(ButtonsStrings{CountButtons,2}), ...
			'BackgroundColor',str2num(char(ButtonsStrings{CountButtons,3})) ...
			);
		if(CountColumnButtons >= ButtonsPerColumn),
			CountColumnButtons = 1;
			ButtonPositionY = 1 - ButtonHeight;
			ButtonPositionX = ButtonPositionX + ButtonWidth;
		else,
			ButtonPositionY = ButtonPositionY - ButtonHeight;
			CountColumnButtons = CountColumnButtons + 1;
		end;
	end;	%for(CountButtons = 1:NumberButtons),
end

%========================================================================
function local_edit( file )
%
% This function tries to account for MATLAB's insatiable desire to
% control even those things you set as a user...

  global g_UserDefinedEditor;

	if ~isempty( g_UserDefinedEditor )
		if exist(file,'file')
			if isunix
				eval(['!' g_UserDefinedEditor ' "' file '" &'])
			else
				% "" because windoze allows spaces, but doesn't know how to
				% handle them correctly---they r suck.
        eval(['!"' g_UserDefinedEditor '" "' file '" &']) 
			end
		else
      error(sprintf('File ''%s'' not found.', file));
		end
	else
		edit(file);
	end

	return
