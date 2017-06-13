 % PrintSimulationSettings
% PrintSimulationSettings - prints out the values of the variables that set-up the simulation.

% use the folowing to format all of the globals
% Whos = whos;
% for(Count=1:size(Whos,1)),
% 	Name = Whos(Count).name;
% 	fprintf('fprintf(''%s = %%g'',%s);\n',Name,Name);
% end;


fprintf('########################################################################\n');
fprintf('########################################################################\n');
fprintf('########################################################################\n\n\n');

fprintf('############################# debug  ##################################\n');
fprintf('g_Debug = %g\n',g_Debug);
fprintf('\n');

fprintf('############################# simulation control  ##################################\n');
fprintf('g_SampleTime = %g\n',g_SampleTime);
fprintf('g_SimulationRunNumber = %g\n',g_SimulationRunNumber);
fprintf('g_StopTime = %g\n',g_StopTime);
fprintf('g_OptionSaveDataAVDS = %g\n',g_OptionSaveDataAVDS);
fprintf('g_OptionSaveDataPlot = %g\n',g_OptionSaveDataPlot);
fprintf('g_SummaryFileName = %s\n',g_SummaryFileName);
fprintf('g_Scenario = %g\n',g_Scenario);
fprintf('g_ASSERT_STATUS = %g\n',g_ASSERT_STATUS);
fprintf('g_PauseAfterEachTimeStep = %g\n',g_PauseAfterEachTimeStep);
fprintf('g_Seed = %d\n',g_Seed);
fprintf('g_SimulationTime = %g\n',g_SimulationTime);
fprintf('g_isMonteCarloRun = %g\n',g_isMonteCarloRun);
fprintf('g_isMonteCarloStop = %g\n',g_isMonteCarloStop);
fprintf('g_SearchSpace = '); disp(g_SearchSpace);
fprintf('g_PlotAxesLimits = '); disp(g_PlotAxesLimits);
fprintf('\n');

fprintf('############################# vehicle control  ##################################\n');
fprintf('g_MaxNumberVehicles = %g\n',g_MaxNumberVehicles);
fprintf('g_ActiveVehicles = %g\n',g_ActiveVehicles);
fprintf('g_EnableVehicle = '); disp(g_EnableVehicle');
fprintf('g_CommandTurnRadius = %g\n',g_CommandTurnRadius);
fprintf('g_DefaultMach = %g\n',g_DefaultMach);
fprintf('g_DefaultWaypointAltitude = %g\n',g_DefaultWaypointAltitude);
fprintf('g_SensorRollLimitDeg = %g\n',g_SensorRollLimitDeg);
fprintf('g_SensorLeadingEdge_ft = %g\n',g_SensorLeadingEdge_ft);
fprintf('g_SensorTrailingEdge_ft = %g\n',g_SensorTrailingEdge_ft);
fprintf('g_SensorWidth_ft = %g\n',g_SensorWidth_ft);
fprintf('g_SensorWidth_m = %g\n',g_SensorWidth_m);
fprintf('\n');

fprintf('############################# target control  ##################################\n');
fprintf('g_MaxNumberTargets = %g\n',g_MaxNumberTargets);
fprintf('g_ActiveTargets = %g\n',g_ActiveTargets);
fprintf('g_EnableTarget = '); disp(g_EnableTarget');
fprintf('g_TargetSpace = '); disp(g_TargetSpace);
fprintf('g_RandomTargetPosition = ''%s''\n', g_RandomTargetPosition);
fprintf('g_RandomTargetPose     = ''%s''\n', g_RandomTargetPose);
fprintf('g_RandomTargetType     = ''%s''\n', g_RandomTargetType);
fprintf('g_TargetPositions = \n'); disp(g_TargetPositions);
fprintf('\n');

fprintf('############################# assignment algorithm control  ##################################\n');
fprintf('g_AssignmentAlgorithm = %g (%s)\n',g_AssignmentAlgorithm, GetAssignmentAlgoName);
fprintf('g_MaxNumberDesiredHeadings = %g\n',g_MaxNumberDesiredHeadings);
fprintf('g_AssignmentTimeDelay = %g\n',g_AssignmentTimeDelay);
fprintf('g_LengthenPaths = %g\n',g_LengthenPaths);
fprintf('g_MaxReassignmentDeltaTime = %g\n',g_MaxReassignmentDeltaTime);
fprintf('g_OptionAssignmentWeight = %g\n',g_OptionAssignmentWeight);
fprintf('g_OptionBackToSearch = %g\n',g_OptionBackToSearch);
fprintf('g_OptionModifiedWaypoints = %g\n',g_OptionModifiedWaypoints);
fprintf('g_AssignToSearchMethod = %g\n',g_AssignToSearchMethod);
fprintf('g_AssignmentDelayEstimate = %g\n',g_AssignmentDelayEstimate);
fprintf('g_BiddingIncrement = %g\n',g_BiddingIncrement);
fprintf('g_CoordinationDelayDen = '); disp(g_CoordinationDelayDen);
fprintf('g_SaveAlgorithmTimeFlag = %g\n',g_SaveAlgorithmTimeFlag);
fprintf('g_VerificationOn = %g\n',g_VerificationOn);
fprintf('\n');

fprintf('############################# ATR algorithm control  ##################################\n');
fprintf('g_ATRThreshold = %g\n',g_ATRThreshold);
fprintf('g_BDAFalseReportPercentage = %g\n',g_BDAFalseReportPercentage);
fprintf('g_CooperativeATR = %g\n',g_CooperativeATR);
fprintf('g_ProbabilityID = \n'); disp(g_ProbabilityID);
fprintf('g_ProbabilityOfKill = %g\n',g_ProbabilityOfKill);
fprintf('\n');

fprintf('############################# communication control  ##################################\n');
fprintf('g_CommDelayDiscHoldOrder = %g\n',g_CommDelayDiscHoldOrder);
fprintf('g_CommDelayMajorStepsOther = %g\n',g_CommDelayMajorStepsOther);
fprintf('g_CommDelayMajorStepsSelf = %g\n',g_CommDelayMajorStepsSelf);
fprintf('\n');

fprintf('\n\n########################################################################\n');
fprintf('########################################################################\n');
fprintf('########################################################################\n\n\n');
