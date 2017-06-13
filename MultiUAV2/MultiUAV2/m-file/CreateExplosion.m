function [AddtionalTimeVector,VectorAVDSCraftType,VectorAVDSColors, VectorAVDSXYZSize] = CreateExplosion(TimeStart,CraftType)
%CreateExplosion - this functions calculates the vectors necessary to display an explosion in AVDS
%
%  Inputs:
%    TimeStart - time to start the explosion, appears in the output AddtionalTimeVector vector
%    CraftType - craft type to use for the explosion. For instance a sperical object will produce a symetric explosion.
%
%  Outputs:
%    AddtionalTimeVector - a vector of times representing the elapsed time of the the explosion, starting at TimeStart.
%    VectorAVDSCraftType - a vector containg the craft type to use during the explosion
%    VectorAVDSColors - a vector containg the color definitions for the explosion
%    VectorAVDSXYZSize - a vector containg the scale multipliers for the explsion.
%    
%

%  AFRL/VACA
%  October 2001 - Created and Debugged - RAS


global g_Debug; if(g_Debug==1),disp('CreateExplosion.m');end; 

global g_SampleTime;
global g_Colors;

TimeExplosionTotal = 2.0; 	%total time for explosion (seconds)

ScaleMaximum = 0.5;
ScaleStep = ScaleMaximum*(g_SampleTime/TimeExplosionTotal);

TransparencyMaximum = 255;
TransparencyStep = -TransparencyMaximum*(g_SampleTime/TimeExplosionTotal);


PercentRed = 0.25;
PercentLightGray = 0.50;
PercentDarkGray = 0.25;

DeltaTimeRed = PercentRed * TimeExplosionTotal;
DeltaTimeLightGray = PercentLightGray * TimeExplosionTotal;
DeltaTimeDarkGray = PercentDarkGray * TimeExplosionTotal;


TimeRed = 0.0;	% start with red
TimeLightGray = DeltaTimeLightGray + DeltaTimeRed;
TimeDarkGray = DeltaTimeLightGray + DeltaTimeRed;

ColorTransparentYellow = (200*g_Colors.AVDSRed1) + (175*g_Colors.AVDSGreen1) + (100*g_Colors.AVDSBlue1);
ColorTransparentRed = (200*g_Colors.AVDSRed1) + (50*g_Colors.AVDSGreen1) + (50*g_Colors.AVDSBlue1);
ColorTransparentLightGray = (200*g_Colors.AVDSRed1) + (200*g_Colors.AVDSGreen1) + (200*g_Colors.AVDSBlue1);
ColorTransparentDarkGray = (100*g_Colors.AVDSRed1) + (100*g_Colors.AVDSGreen1) + (100*g_Colors.AVDSBlue1);


AddtionalTimeVector = [];
VectorAVDSCraftType = [];
VectorAVDSXYZSize = [];
VectorAVDSColors = [];

TransparentValue = TransparencyMaximum;
ScaleValue = 0.0;
TimeStep = 0;
while(TimeStep < TimeExplosionTotal),
	AddtionalTimeVector = [AddtionalTimeVector;TimeStart];
	VectorAVDSCraftType = [VectorAVDSCraftType;CraftType];
	VectorAVDSXYZSize = [VectorAVDSXYZSize;ScaleValue];
	% calculate colors
	if(TimeStep >= TimeDarkGray),
		VectorAVDSColors = [VectorAVDSColors;((TransparentValue*g_Colors.AVDSTransparent1) + ColorTransparentDarkGray)];
	elseif(TimeStep >= TimeLightGray),
		VectorAVDSColors = [VectorAVDSColors;((TransparentValue*g_Colors.AVDSTransparent1) + ColorTransparentLightGray)];
	else,
		WhichColor = rand;
		if(WhichColor > 0.5),
			VectorAVDSColors = [VectorAVDSColors;((TransparentValue*g_Colors.AVDSTransparent1) + ColorTransparentRed)];
		else,
			VectorAVDSColors = [VectorAVDSColors;((TransparentValue*g_Colors.AVDSTransparent1) + ColorTransparentYellow)];
		end;
	end;
	TransparentValue = TransparentValue + TransparencyStep;
	ScaleValue = ScaleValue + ScaleStep;
	TimeStart = TimeStart + g_SampleTime;
	TimeStep = TimeStep + g_SampleTime;
end;
