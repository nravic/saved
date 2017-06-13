global g_MaxBenefit; g_MaxBenefit = 1.0e+07;

% setup path info
tdir = ['..', filesep, '..', filesep, '..', filesep];
mdir = [tdir, 'm-file'];

addpath(mdir);
addpath(GetLibDir(tdir));

load 'TestBenefits.mat';


Benefits = TestBenefits;
NumberVehicles = 8;
NumberTargets = 10;
NumberTasks = 1;
[TargetAssigned,TaskAssigned,TotalBenefit] = CapTranShipMex(Benefits,NumberVehicles,NumberTargets,NumberTasks)

return;

Benefits = [
1
1
1
1
1
1
1
1
47
56
51
55
0
0
0
0
0
0
52
52
45
48
0
0
0
0
0
0
53
47
49
44
0
0
0
0
0
0
60
1797693
314
53
0
0
0
0
0
0
456
70
170
62
0
0
0
0
0
0
103
60
162
78
0
0
0
0
0
0
91
77
83
73
0
0
0
0
0
0
77
74
70
64
0
0
0
0
0
0
];

NumberVehicles = 8;
NumberTargets = 10;
NumberTasks = 1;
[TargetAssigned,TaskAssigned,TotalBenefit] = CapTranShipMex(Benefits,NumberVehicles,NumberTargets,NumberTasks)


