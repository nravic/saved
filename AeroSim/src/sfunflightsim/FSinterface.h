// FSinterface.h
// Microsoft Flight Simulator interface utilities
// Marius Niculescu
// 11/16/01

#include "Types.h"

// FS offsets
#define TAS_OFFSET			0x02B8
#define IAS_OFFSET			0x02BC
#define VS_OFFSET			0x0842
#define LAT_OFFSET			0x0560
#define LON_OFFSET			0x0568
#define ALT_OFFSET			0x0570
#define PITCH_OFFSET		0x0578
#define BANK_OFFSET			0x057C
#define HEAD_OFFSET			0x0580
#define SLEWFLAG_OFFSET		0x05DC
#define ROLLRATE_OFFSET		0x05E4
#define YAWRATE_OFFSET		0x05E6
#define SLEWMODE_OFFSET		0x05F4


// FS data structure types
typedef struct 
{
	SInt32 Lo;
	SInt32 Hi;
} SFSVarType;

typedef struct 
{
	UInt32 Lo;
	SInt32 Hi;
} UFSVarType;

typedef struct 
{
	UFSVarType Lat;
	UFSVarType Lon;
	UFSVarType Alt;
} FSPositionType;

typedef struct
{
	SInt32 Pitch;
	SInt32 Bank;
	SInt32 Heading;
} FSAttitudeType;


// Function prototypes

// Convert position from FS to simulation application
void PositionFSToSim(double *Pos, FSPositionType *FSPos);

// Convert position from simulation application to FS
void PositionSimToFS(FSPositionType *FSPos, double *Pos);

// Convert attitude from FS to simulation application
void AttitudeFSToSim(double *Att, FSAttitudeType *FSAtt);

// Convert attitude from simulation application to FS
void AttitudeSimToFS(FSAttitudeType* FSAtt, double *Att);

// Convert airspeed from FS to simulation application
void AirspeedFSToSim(double *Airsp, SInt32 FSAirsp);

// Convert airspeed from simulation application to FS
void AirspeedSimToFS(SInt32 *FSAirsp, double Airsp);

// Convert vertical speed from FS to simulation application
void VertSpeedFSToSim(double *VS, SInt16 FSVS);

// Convert vertical speed from simulation application to FS
void VertSpeedSimToFS(SInt16 *FSVS, double VS);

