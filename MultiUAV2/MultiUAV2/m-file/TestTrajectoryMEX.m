function [WayPoints,TotalDistanceAbsolute,FinalHeading] = TestTrajectoryMEX

global g_Tasks;


TestData = 3;

switch(TestData)
case 1,
	%VehicleState = [VehicleID;CurrentPos(1);CurrentPos(2);DefaultWaypointAltitude;CurrentPos(3);-1;CommandTurnRadius;VehicleType;CurrentETA];
	VehicleState =[ ...
			1.000000000000000e+000
		7.708947076991733e+003
		5.901574802886867e+004
		6.750000000000000e+002
		1.570796326167476e+000
		-1.000000000000000e+000
		2.000000000000000e+003
		1.000000000000000e+000
		0];
	%TargetState = [TargetID;TargetToTask(1,1);TargetToTask(1,2);0;TaskInput;TargetScheduleLength];
	TaskRequired = g_Tasks.Verify;
	TargetState = [ ...
			2.000000000000000e+000
		1.006585070034359e+004
		5.849769532374998e+004
		0
		TaskRequired
		1.736300000000000e+004];
	TargetHeadings = [ ...
			5.338710690886324e+000
		6.266005908887936e+000
		2.197118037296530e+000
		3.124413255298144e+000];
	LengthenPaths = 1;
	
case 2,
	VehicleState =[...
			1.000000000000000e+000
		7.708947076991733e+003
		5.901574802886867e+004
		6.750000000000000e+002
		1.570796326167476e+000
		-1.000000000000000e+000
		2.000000000000000e+003
		1.000000000000000e+000
		0];
	TaskRequired = g_Tasks.Classify;
	TargetState =[...
			2.000000000000000e+000
		1.006585070034359e+004
		5.849769532374998e+004
		0
		1.000000000000000e+000
		0];
	TargetHeadings =[...
			5.338710690886324e+000
		6.266005908887936e+000
		2.197118037296530e+000
		3.124413255298144e+000];
	LengthenPaths = 1;
case 3,
	VehicleState =[...
			1.000000000000000e+000
		1.681931508868353e+004
		-9.842519709158347e+002
		6.750000000000000e+002
		1.570796325902623e+000
		-1.000000000000000e+000
		2.000000000000000e+003
		1.000000000000000e+000
		0];
	
	TargetState =[...
			3.000000000000000e+000
		9.683535028904369e+003
		-6.648358093365687e+002
		0
		3.000000000000000e+000
		1.361600000000000e+004];
	
	TargetHeadings =[...
			8.363166149367487e-001
		3.977909268526542e+000
		4.905204486528154e+000
		0];
	LengthenPaths = 1;
	
end;

[WayPoints,TotalDistanceAbsolute,FinalHeading] = TrajectoryMEX(VehicleState,TargetState,TargetHeadings,LengthenPaths);

TestPlotWaypoints('SinglePlot',WayPoints);