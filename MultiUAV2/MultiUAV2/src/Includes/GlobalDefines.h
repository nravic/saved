//
//	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION IS RELEASED "AS IS." THE
//	U.S.GOVERNMENT MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, CONCERNING
//	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION, INCLUDING, WITHOUT LIMITATION,
//	ANY WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
//	WILL THE U.S. GOVERNMENT BE LIABLE FOR ANY DAMAGES, INCLUDING ANY LOST PROFITS,
//	LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE,
//	OR INABILITY TO USE, THIS SOFTWARE OR ANY ACCOMPANYING DOCUMENTATION, EVEN IF
//	INFORMED IN ADVANCE OF THE POSSIBILITY OF SUCH DAMAGES.
//
//

#ifndef GLOBALDEFINES_H
#define GLOBALDEFINES_H

//////////////////////////////////////////////////////////////////////////////
///   This header is for constants that are used globally in the program   ///
//////////////////////////////////////////////////////////////////////////////

#ifndef _PI_O_4
#define _PI_O_4 0.78539816339745
#endif

#ifndef _PI_O_2
#define _PI_O_2 1.57079632679490
#endif

#ifndef _3PI_O_4
#define _3PI_O_4 2.35619449019234
#endif

#ifndef _PI
#define _PI 3.14159265358979
#endif

#ifndef _3PI_O_2
#define _3PI_O_2 4.71238898038469
#endif

#ifndef _2PI
#define _2PI 6.28318530717959
#endif

#ifndef _TWO_THIRDS
#define _TWO_THIRDS (0.66666666666666666666666666666667)
#endif

#ifndef _DEG_TO_RAD
#define _DEG_TO_RAD 0.01745329251994
#endif

#ifndef _RAD_TO_DEG
#define _RAD_TO_DEG 57.29577951308232
#endif

#ifndef _FEET_TO_FEET
#define _FEET_TO_FEET (1.0)
#endif

#ifndef _FEET_TO_METERS
#define _FEET_TO_METERS (0.3048)
#endif

#ifndef _METERS_TO_FEET
#define _METERS_TO_FEET (3.280839895)
#endif

#ifndef _FEET_TO_KMETERS
#define _FEET_TO_KMETERS (0.0003048)
#endif

#ifndef _KMETERS_TO_FEET
#define _KMETERS_TO_FEET (3280.839895)
#endif

#ifndef _FEET_TO_MILES
#define _FEET_TO_MILES (1.893939393e-4)
#endif

#ifndef _MILES_TO_FEET
#define _MILES_TO_FEET (5280.0)
#endif

#ifndef _KNOTS_TO_FPS
#define _KNOTS_TO_FPS (1.687777777777778)
#endif

#ifndef _FPS_TO_KNOTS
#define _FPS_TO_KNOTS (5.924950625411455e-001)
#endif

#ifndef _OUPUT_CONVERSION
#define _OUPUT_CONVERSION _FEET_TO_MILES
#endif

#ifndef _OUPUT_CONVERSION_TEXT
//#define _OUPUT_CONVERSION_TEXT "Feet"
#define _OUPUT_CONVERSION_TEXT "Miles"
//#define _OUPUT_CONVERSION_TEXT "Meters"
//#define _OUPUT_CONVERSION_TEXT "Kilometers"
#endif

#ifndef _GRAVITY_DEFAULT
#define _GRAVITY_DEFAULT 32.17	// ft/sec^2
#endif

#ifndef _MAXTIME
#ifndef MATLAB_MEX_FILE
#define _MAXTIME 3600   // 1 hour in seconds
#else	//MATLAB_MEX_FILE
#define _MAXTIME 600
#endif	//MATLAB_MEX_FILE
#endif	//_MAXTIME

#ifndef TIME_INCREMENT
#define TIME_INCREMENT 0.01
#endif

#ifndef NUMBER_THREATS
#define NUMBER_THREATS 40
#endif

#ifndef NUMBER_TARGETS
//#define NUMBER_TARGETS 8
#define NUMBER_TARGETS 50
#endif

#ifndef NUMBER_LUVS
#define NUMBER_LUVS 6
#endif

#ifndef NUMBER_REMOTE_COMMANDS
#define NUMBER_REMOTE_COMMANDS 5
#endif

#ifndef MAX_WAYPOINTS
#ifndef MATLAB_MEX_FILE
#define MAX_WAYPOINTS 1000		//this is the maximum number of waypoints (not yet set up in original waypoint code)
#else	//MATLAB_MEX_FILE
#define MAX_WAYPOINTS 100		//this is the maximum number of waypoints (not yet set up in original waypoint code)
#endif	//MATLAB_MEX_FILE
#endif	//MAX_WAYPOINTS

// define the BOOL values (this should be set to the bool type, but is it ANSI?)
#ifndef BOOL
typedef int BOOL;
#define Bool BOOL
#endif

#ifndef DWORD
typedef int DWORD;
#endif

#ifndef ULONG
typedef unsigned int ULONG;
#endif

#ifndef LONG
typedef int LONG;
#endif

#ifndef WORD
typedef short WORD;
#endif

#ifndef MAKELONG
#define MAKELONG(a, b) ((LONG) (((WORD) (a)) | ((DWORD) ((WORD) (b))) << 16)) 
#endif


#ifndef NULL
#define NULL 0
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef _PLOTS_PATH
#define	_PLOTS_PATH ".\\Plots\\"
#endif
#ifndef _AVDS_DATA_PATH
#define	_AVDS_DATA_PATH ".\\AVDSData\\"
#endif

#ifndef GLOBAL_FUNCTIONS
#define GLOBAL_FUNCTIONS
#include <cassert>
#include <climits>
#include <cfloat>
#include <limits>
#include <cmath>

// MSVC++/Linux differences
#ifdef _MSC_VER
# define isinf _isinf
# define isnan _isnan
# define finite _finite
#endif

// MSVC++/Linux differences for min/max
#include <algorithm>
#ifdef _MSC_VER
#undef min
#undef max
  template <typename T> T max( const T& a, const T& b) { return( (a > b) ? a : b ); }
  template <typename T> T min( const T& a, const T& b) { return( (a < b) ? a : b ); }
#else
  using std::min;
  using std::max;
#endif


namespace
{
	enum enRelationalOperators
	{
		enGreater,
		enGreaterEqual,
		enLess,
		enLessEqual,
		enEqual,
		enTotalRelationalOperators
	};

	inline BOOL bCompareDouble(double dArgument1, double dArgument2,enRelationalOperators relOperator,double dEpsilon=1.0e-9)
	{
		switch(relOperator)
		{
		case enGreater:
			return((dArgument1 - dArgument2)>dEpsilon);
			break;
		case enGreaterEqual:
			return((dArgument1 - dArgument2)>=dEpsilon);
			break;
		case enLess:
			return((dArgument1 - dArgument2)<dEpsilon);
			break;
		case enLessEqual:
			return((dArgument1 - dArgument2)<=dEpsilon);
			break;
		default:
		case enEqual:
			return((dArgument1 - dArgument2)==dEpsilon);
			break;
		};
		return(FALSE);
	};

	inline double RAS_FIX(double arg)
	{
		return((arg>0)?(floor(arg)):(ceil(arg)));
	}

	inline double RAS_SIGN(double arg)
	{
		return((arg==0)?(0.0):(arg/fabs(arg)));
	}

	inline int C_INDEX(int arg)
	{
		return(arg-1);
	}

	inline double dNormalizeAngleRad(double dAngleRad,double dAngleReference=(-_PI))
	{
		assert( dAngleReference <= 0.0 && dAngleReference >= -_2PI );

		double dModAngle = fmod(dAngleRad,_2PI);
		if( bCompareDouble(dModAngle, dAngleReference, enLess) )
		{
			dModAngle += _2PI;
		}
		else if( bCompareDouble(dModAngle, (dAngleReference+_2PI), enGreaterEqual) )
		{
			dModAngle -= _2PI;
		}
		return(dModAngle);
	}
	inline double dNormalizeAngleDeg(double dAngleDeg,double dAngleReference=(-180.0))
	{
		const double deg360 = 360.0;
		
		assert( dAngleReference <= 0.0 && dAngleReference >= -deg360 );

		double dModAngle = fmod(dAngleDeg,deg360);
		if( bCompareDouble(dModAngle, dAngleReference, enLess) )
		{
			dModAngle += deg360;
		}
		else if( bCompareDouble(dModAngle, (dAngleReference+deg360), enGreaterEqual) )
		{
			dModAngle -= deg360;
		}
		return(dModAngle);
	}
	inline int iRound(double dNumber)
	{
		// rounds rdNumber to the nearest integer.
		return(int(dNumber + 0.5));
	};
	inline double dRound(double dNumber,const double dDecimalPlace)
	{
		// rounds rdNumber to the dDecimalPlace decimal place.
		// i.e. vRound(123456.123456,1e-2) => 123456.12 and vRound(123456.123456,1e2) => 123500.00
		dNumber = floor(dNumber/dDecimalPlace + 0.5)*dDecimalPlace;
		return(dNumber);
	};
	inline void vRound(double& rdNumber,const double dDecimalPlace)
	{
		// rounds rdNumber to the dDecimalPlace decimal place.
		// i.e. vRound(123456.123456,1e-2) => 123456.12 and vRound(123456.123456,1e2) => 123500.00
		rdNumber = floor(rdNumber/dDecimalPlace + 0.5)*dDecimalPlace;
	};
	inline double dSign(double dNumber)
	{
		// returns +1.0, -1.0, or 0.0 indicating the sign of the argument.
		return((dNumber==0.0)?(0.0):(dNumber/fabs(dNumber)));
	};
	inline double dNorm(double dNumber1,double dNumber2)
	{
		// 
		return(pow((pow(dNumber1,2.0) + pow(dNumber2,2.0)),0.5));
	};
	inline double dRAS_Limit(double dVariable,double dLimitUpper,double dLimitLower)
	{
		return((dVariable>dLimitUpper)?(dLimitUpper):((dVariable<dLimitLower)?(dLimitLower):(dVariable)));
	}
	inline double dRAS_Blank(double dVariable,double dLimitUpper,double dLimitLower)
	{
		return((dVariable>dLimitUpper)?(dVariable-dLimitUpper):((dVariable<dLimitLower)?(dVariable-dLimitLower):(0.0)));
	}
}
#endif	//#ifndef GLOBAL_FUNCTIONS



#endif	//#ifndef GLOBALDEFINES_H
