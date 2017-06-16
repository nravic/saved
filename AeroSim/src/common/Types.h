///////////////////////////////////////////////////////////////////////////////
// This file is used to define new types that are accessible by all files in
//   the system.  Most of these types are familiar contractions that simply
//   save typing

///////////////////////////////////
// This file provided by:        //
// Cloud Cap Technology, Inc.    //
// PO Box 1500                   //
// No. 8 Fourth St.              //
// Hood River, OR, 97031         //
// +1-541-387-2120    (voice)    //
// +1-541-387-2030    (fax)      //
// vaglient@gorge.net (e-mail)   //
// http://www.gorge.net/cloudcap //
///////////////////////////////////
#ifndef _TYPES_H
#define _TYPES_H

// These definitions used for systems where chars are 8bits, shorts are
//   16bits, longs are 32bits, and long long are 64 bits.

typedef char				   Char;  // 8 bits signed
typedef unsigned char		  UChar;  // 8 bits unsigned
typedef volatile Char		  VChar;  // 8 bits volatile signed
typedef volatile UChar		 VUChar;  // 8 bits volatile unsigned
typedef const Char			  CChar;  // 8 bits const signed
typedef const UChar			 CUChar;  // 8 bits const unsigned
typedef const VChar			 CVChar;  // 8 bits const volatile signed
typedef const VUChar		CVUChar;  // 8 bits const volatile unsigned

typedef signed short		   Short; // 16 bits signed
typedef unsigned short		  UShort; // 16 bits unsigned
typedef volatile Short		  VShort; // 16 bits volatile signed
typedef volatile UShort		 VUShort; // 16 bits volatile unsigned
typedef const Short			  CShort; // 16 bits const signed
typedef const UShort		 CUShort; // 16 bits const unsigned
typedef const VShort		 CVShort; // 16 bits const volatile signed
typedef const VUShort		CVUShort; // 16 bits const volatile unsigned

typedef signed long			   Long;  // 32 bits signed
typedef unsigned long		  ULong;  // 32 bits unsigned
typedef volatile Long		  VLong;  // 32 bits volatile
typedef volatile ULong		 VULong;  // 32 bits volatile unsigned
typedef const Long			  CLong;  // 32 bits const signed
typedef const ULong		 	 CULong;  // 32 bits const unsigned
typedef const VLong			 CVLong;  // 32 bits const volatile
typedef const VULong 		CVULong;  // 32 bits const volatile unsigned

#ifdef WIN32
#include <windows.h>
typedef LONGLONG			  LLong; // 64 bits signed
typedef ULONGLONG			 ULLong; // 64 bits unsigned
#else
typedef signed long long	  LLong; // 64 bits signed
typedef unsigned long long	 ULLong; // 64 bits unsigned
#endif

typedef volatile LLong		 VLLong; // 64 bits volatile signed
typedef volatile ULLong		VULLong; // 64 bits volatile unsigned
typedef const LLong			 CLLong; // 64 bits constant signed
typedef const ULLong		CULLong; // 64 bits constant unsigned
typedef const VLLong		CVLLong; // 64 bits constant volatile signed
typedef const VULLong	   CVULLong; // 64 bits constatn volatile unsigned

typedef Char				  SInt8;
typedef UChar				  UInt8;
typedef VChar				 VSInt8;
typedef VUChar				 VUInt8;
typedef CChar				 CSInt8;
typedef CUChar				 CUInt8;
typedef CVChar				CVSInt8;
typedef CVUChar				CVUInt8;

typedef Short				  SInt16;
typedef UShort				  UInt16;
typedef VShort				 VSInt16;
typedef VUShort				 VUInt16;
typedef CShort				 CSInt16;
typedef CUShort				 CUInt16;
typedef CVShort				CVSInt16;
typedef CVUShort			CVUInt16;

typedef Long				  SInt32;
typedef ULong				  UInt32;
typedef VLong				 VSInt32;
typedef VULong				 VUInt32;
typedef CLong				 CSInt32;
typedef CULong				 CUInt32;
typedef CVLong				CVSInt32;
typedef CVULong				CVUInt32;

typedef LLong				  SInt64;
typedef ULLong				  UInt64;
typedef VLLong				 VSInt64;
typedef VULLong				 VUInt64;
typedef CLLong				 CSInt64;
typedef CULLong				 CUInt64;
typedef CVLLong				CVSInt64;
typedef CVULLong			CVUInt64;

#ifndef WIN32
typedef UInt32					BOOL;
#endif	// WIN32

// Mask constants
#define BIT0  0x80000000
#define BIT1  0x40000000
#define BIT2  0x20000000
#define BIT3  0x10000000
#define BIT4  0x08000000
#define BIT5  0x04000000
#define BIT6  0x02000000
#define BIT7  0x01000000
#define BIT8  0x00800000
#define BIT9  0x00400000
#define BIT10 0x00200000
#define BIT11 0x00100000
#define BIT12 0x00080000
#define BIT13 0x00040000
#define BIT14 0x00020000
#define BIT15 0x00010000
//#define BIT16 0x00008000
#define BIT17 0x00004000
#define BIT18 0x00002000
#define BIT19 0x00001000
#define BIT20 0x00000800
#define BIT21 0x00000400
#define BIT22 0x00000200
#define BIT23 0x00000100
#define BIT24 0x00000080
#define BIT25 0x00000040
#define BIT26 0x00000020
#define BIT27 0x00000010
#define BIT28 0x00000008
#define BIT29 0x00000004
#define BIT30 0x00000002
#define BIT31 0x00000001

#ifndef TRUE
    #define TRUE 1
#endif

#ifndef FALSE
    #define FALSE 0
#endif

#ifndef NULL
    #define NULL 0x00000000
#endif

#endif //!_TYPES_H