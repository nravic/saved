function	InitializeTargets();
%InitializeTargets - sets the position, orientation and type of the targets.
%
%  Inputs:
%    (none) 
%
%  Outputs:
%    (none)
%

%   NOTE: g_TargetMemory.Alive settings:
%         g_TargetMemory.Alive = -1 for a target that is not used
%         g_TargetMemory.Alive = 0 for a dead target
%         g_TargetMemory.Alive = ID number for a target that is alive
%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS
%  May 2001 - removed the target cell array - RAS



global g_Debug; if(g_Debug==1),disp('InitializeTargets.m');end; 

global g_TargetMemory;
global g_TargetMainMemory;
global g_MaxNumberTargets;
global g_EnableTarget;
global g_EnableTargetDefault;
global g_RandomTargetPosition;
global g_RandomTargetPose;
global g_RandomTargetType;
global g_TargetPositions;
global g_TargetPositionDefinitions;
global g_isMonteCarloRun;	
global g_MonteCarloMetrics;

%disp('*** InitializeTargets:: Initializing Target Memory and States ***');

g_EnableTarget = g_EnableTargetDefault;

[NumberPositions Dummy] = size(g_TargetPositions); % why not use g_MaxNumberTargets?

g_TargetMainMemory = CreateStructure('TargetMainMemory');
g_TargetMemory = [];

for(CountTargets= 1:g_MaxNumberTargets),
	TempTarget = CreateStructure('TargetMemory');
	TempTarget.ID = length(g_TargetMemory)+1 ;
	ThisTargetAlive = g_EnableTarget(TempTarget.ID);
	if(ThisTargetAlive > 0),

		TargetPositionDistribution = g_RandomTargetPosition;
		if( strcmp(TargetPositionDistribution, 'PredefinedFixed') | strcmp(TargetPositionDistribution, 'TimeBasedDistribution') ),
			%% just pull off the defined set
			TempTarget.PositionX=g_TargetPositions(CountTargets,g_TargetPositionDefinitions.PositionX);
			TempTarget.PositionY=g_TargetPositions(CountTargets,g_TargetPositionDefinitions.PositionY);
			TempTarget.PositionZ=g_TargetPositions(CountTargets,g_TargetPositionDefinitions.PositionZ);
			TempTarget.Psi  = g_TargetPositions(CountTargets,g_TargetPositionDefinitions.PositionPsi);
			TempTarget.Type = g_TargetPositions(CountTargets,g_TargetPositionDefinitions.PositionType);
		else,
			%% otherwise, we look at local config functions
			TargetPoseDistribution = g_RandomTargetPose;
			TargetTypeDistribution = g_RandomTargetType;

			%% check to see if we're setting up more than we expect
			if( CountTargets > NumberPositions )
				warning('Number of targets exceeds number of available positions!');
				warning('...additional target positions will be uniformly random.');
				TargetPositionDistribution = 'UniformDistribution';
				TargetPoseDistribution = 'UniformDistribution';
				TargetTypeDistribution = 'PredefinedFixed';
			end

			[TempTarget.PositionX, TempTarget.PositionY, TempTarget.PositionZ] = ...
					TargetPosition( TargetPositionDistribution );
			TempTarget.Psi = TargetPoseAnglePsi( TargetPoseDistribution );
			TempTarget.Type = TargetType( TargetTypeDistribution );
		end
		
		TempTarget.Alive = TempTarget.ID;
	else,	%if(ThisTargetAlive > 0),
		TempTarget.PositionX = 1.0e7;
		TempTarget.PositionY = 1.0e7;
		TempTarget.PositionZ = 0.0;
		TempTarget.Psi = 0.0;
		TempTarget.Type = 1;
		TempTarget.Alive = -1;
	end;	%if(ThisTargetAlive > 0),

	g_TargetMemory = [g_TargetMemory;TempTarget];

	% commented 20040301 by jwm; reduce growth induced slow downs
	%if( g_isMonteCarloRun )
	%	g_MonteCarloMetrics.Target1PostionHeading = [g_MonteCarloMetrics.Target1PostionHeading;TempTarget];
	%end

end;	%for(CountTargets= 1:g_MaxNumberTargets),

return;	%InitializeTargets

function [X,Y,Z] = TargetPosition( DistributionType )

	global g_TargetDistributionData

	su = g_TargetDistributionData.UniformDist;

	switch(  DistributionType  )
		
	 case 'UniformDistribution',
		X = su.MinX + rand*(su.MaxX - su.MinX);
		Y = su.MinY + rand*(su.MaxY - su.MinY);
		Z = 0.0;
		
	 case 'BivariateNormalDistribution',
		s = g_TargetDistributionData.BivariateNormalDist;
		TooManyIterations = s.MaxDraws;
		
		%% reject out of bounds values (truncate full distribution)
		for k = 1:TooManyIterations,
			[X,Y] = DistBivariateNormal(s);
			if( (X < su.MaxX & X > su.MinX) & ...
			    (Y < su.MaxY & Y > su.MinY) )
					break;
			end
		end
		Z = 0.0;
		if( k >= TooManyIterations )
			error('Maximum Number of iterations exceded!');
		end
		
	 otherwise,
		error(['Unknown target position distribution type specified: ', DistributionType]);
	end
	
	return;
	
function psi = TargetPoseAnglePsi(  DistributionType  )
%%
%% Psi is a heading that is treated as 0 rad North, and positive clockwise.
%%
	global g_TargetDistributionData

	switch(  DistributionType  )
		
	 case 'PredefinedFixed',
		psi = -pi/2;

	 case 'UniformDistribution',
		psi = rand*2.0*pi;

	 case 'NormalDistribution',
		s = g_TargetDistributionData.NormalDist;

		if( s.mean ~= 0 & s.sig ~= 1 )
			error('Data does not match assumption of mean:0, sig:1 here!');
		end

		TooManyIterations = s.MaxDraws;
		for k = 1:TooManyIterations,
			psi = randn; % mostly in (-2pi,2pi) for zero mean, one var, one sigma
			if( (psi < 2*pi  & psi > -2*pi) )
				break;
			end
		end
		
	 otherwise,
		error(['Unknown target pose angle distribution type specified: ', DistributionType]);
	end

	return;

function type = TargetType(  DistributionType  )
	global g_TargetDistributionData

	switch(  DistributionType  )
		
	 case 'PredefinedFixed',
		type = 1;

	 otherwise,
		error(['Unknown target type distribution type specified: ', DistributionType]);
	end

	return;
