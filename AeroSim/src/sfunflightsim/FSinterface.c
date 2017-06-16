// FSinterface.c
// Microsoft Flight Simulator interface utilities
// Marius Niculescu
// 11/16/01

// Include own header
#include "FSinterface.h"

// Universal data
#include "universal.h"

//Include standard headers
#include <math.h>

// Function definitions

// Convert position from FS to simulation application
void PositionFSToSim(double *Pos, FSPositionType *FSPos)
{
	double LatLo, LatHi, LonLo, LonHi, AltLo, AltHi;

	LatLo = (double)FSPos->Lat.Lo*90.0/10001750.0/(65536.0*65536.0);
	LatHi = (double)FSPos->Lat.Hi*90.0/10001750.0;
	Pos[LAT] = LatHi + LatLo;

	LonLo = (double)FSPos->Lon.Lo*360.0/(65536.0*65536.0)/(65536.0*65536.0);
	LonHi = (double)FSPos->Lon.Hi*360.0/(65536.0*65536.0);
	Pos[LON] = LonHi + LonLo;

	AltLo = (double)FSPos->Alt.Lo/10000000000.0;
	AltHi = (double)FSPos->Alt.Hi;
	Pos[ALT] = AltHi + AltLo;
} // PositionFSToSim

// Convert position from simulation application to FS
void PositionSimToFS(FSPositionType *FSPos, double *Pos)
{
	double LatScaled, LonScaled;
	SInt64 Temp;

	LatScaled = Pos[LAT]*10001750.0/90.0;
	Temp = (SInt64)(LatScaled*65536*65536);
	FSPos->Lat.Hi = (SInt32)(Temp>>32);
	FSPos->Lat.Lo = (UInt32)(Temp);
	
	LonScaled = Pos[LON]*65536*65536/360.0;
	Temp = (SInt64)(LonScaled*65536*65536);	
	FSPos->Lon.Hi = (SInt32)(Temp>>32);
	FSPos->Lon.Lo = (UInt32)(Temp);


	FSPos->Alt.Hi = (SInt32)floor(Pos[ALT]);
	FSPos->Alt.Lo = (SInt32)((Pos[ALT]-(double)FSPos->Alt.Hi)*10000000000.0);
} // PositionSimToFS

// Convert attitude from FS to simulation application
void AttitudeFSToSim(double *Att, FSAttitudeType *FSAtt)
{
	Att[PITCH] = -(double)FSAtt->Pitch*360.0/(65536.0*65536.0);
	Att[ROLL] = -(double)FSAtt->Bank*360.0/(65536.0*65536.0);
	Att[YAW] = (double)FSAtt->Heading*360.0/(65536.0*65536.0);
} // AttitudeFSToSim

// Convert attitude from simulation application to FS
void AttitudeSimToFS(FSAttitudeType* FSAtt, double *Att)
{
	FSAtt->Pitch = (SInt32)(-Att[PITCH]*65536.0*65536.0/360.0);
	FSAtt->Bank = (SInt32)(-Att[ROLL]*65536.0*65536.0/360.0);
	FSAtt->Heading = (SInt32)(Att[YAW]*65536.0*65536.0/360.0);
} // AttitudeSimToFS

// Convert airspeed from FS to simulation application
void AirspeedFSToSim(double *Airsp, SInt32 FSAirsp)
{
	*Airsp = (double)FSAirsp*0.51479/128.0;
} // AirspeedFSToSim

// Convert airspeed from simulation application to FS
void AirspeedSimToFS(SInt32 *FSAirsp, double Airsp)
{
	*FSAirsp = (SInt32)(Airsp/0.51479*128.0);
} // AirspeedSimToFS

// Convert vertical speed from FS to simulation application
void VertSpeedFSToSim(double *VS, SInt16 FSVS)
{
	*VS = -(double)FSVS/60.0;
} // VertSpeedFSToSim

// Convert vertical speed from simulation application to FS
void VertSpeedSimToFS(SInt16 *FSVS, double VS)
{
	*FSVS = -(SInt16)(VS*60.0);
} // VertSpeedSimToFS
