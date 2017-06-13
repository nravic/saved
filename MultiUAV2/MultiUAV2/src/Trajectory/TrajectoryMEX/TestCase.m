% setup path info
tdir = ['..', filesep, '..', filesep, '..', filesep];
mdir = [tdir, 'm-file'];

addpath(mdir);
addpath(GetLibDir(tdir));



VehicleState = [1.000000000000000e+000
    4.000000000000000e+003
    1.000000000000000e+003
    8.000000000000000e+002
    7.853981633974483e-001
                         0
    1.700000000000000e+003
    1.000000000000000e+000
    1.000000000000000e+004];

TargetState = [1
        5000
           0
           0
           2
       10000];
   
   
TargetHeadings = [ 0
    1.570796326794897e+000
    3.141592653589793e+000
    4.712388980384690e+000];


LengthenPaths  = 1;

load 'DebugTemp'

[Waypoints,TotalDistance,FinalHeading] = TrajectoryMEX(VehicleState,TargetState,TargetHeadings,LengthenPaths);
