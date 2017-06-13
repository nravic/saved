# Microsoft Developer Studio Project File - Name="VehicleDynamicsMex" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=VehicleDynamicsMex - Win32 Debug R14
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "VehicleDynamicsMex.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "VehicleDynamicsMex.mak" CFG="VehicleDynamicsMex - Win32 Debug R14"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "VehicleDynamicsMex - Win32 Debug R12" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "VehicleDynamicsMex - Win32 Release R12" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "VehicleDynamicsMex - Win32 Debug R14" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "VehicleDynamicsMex - Win32 Release R14" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName "VehicleDynamicsMex"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "VehicleDynamicsMex - Win32 Debug R12"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "VehicleDynamicsMex___Win32_Debug_R12"
# PROP BASE Intermediate_Dir "VehicleDynamicsMex___Win32_Debug_R12"
# PROP BASE Ignore_Export_Lib 1
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "VehicleDynamicsMex___Win32_Debug_R12"
# PROP Intermediate_Dir "VehicleDynamicsMex___Win32_Debug_R12"
# PROP Ignore_Export_Lib 1
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\VehicleDynamics\EuminxdLib" /I "..\..\Includes" /I "..\VehicleDynamics\DATCOMTableLib" /I "..\VehicleDynamics" /D "MATLAB_R12" /D "MATLAB_MEX_FILE" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "VehicleDynamicsMex_EXPORTS" /FR /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\VehicleDynamics\EuminxdLib" /I "..\..\Includes" /I "..\VehicleDynamics\DATCOMTableLib" /I "..\VehicleDynamics" /D "MATLAB_R12" /D "MATLAB_MEX_FILE" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "VehicleDynamicsMex_EXPORTS" /FR /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 ..\VehicleDynamics\EuminxdLib\debug\EuminxdLib.lib ..\VehicleDynamics\DATCOMTableLib\Debug\DATCOMTableLib.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /incremental:no /map /debug /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\..\lib\win32\R12\VehicleDynamicsMex.dll" /pdbtype:sept /export:mexFunction
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 ..\VehicleDynamics\EuminxdLib\debug\EuminxdLib.lib ..\VehicleDynamics\DATCOMTableLib\Debug\DATCOMTableLib.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /incremental:no /map /debug /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\..\lib\win32\R12\VehicleDynamicsMex.dll" /pdbtype:sept /export:mexFunction
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "VehicleDynamicsMex - Win32 Release R12"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "VehicleDynamicsMex___Win32_Release_R12"
# PROP BASE Intermediate_Dir "VehicleDynamicsMex___Win32_Release_R12"
# PROP BASE Ignore_Export_Lib 1
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "VehicleDynamicsMex___Win32_Release_R12"
# PROP Intermediate_Dir "VehicleDynamicsMex___Win32_Release_R12"
# PROP Ignore_Export_Lib 1
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /I "..\VehicleDynamics\EuminxdLib" /I "..\..\Includes" /I "..\VehicleDynamics\DATCOMTableLib" /I "..\VehicleDynamics" /D "MATLAB_R12" /D "MATLAB_MEX_FILE" /D "VehicleDynamicsMex_EXPORTS" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /I "..\VehicleDynamics\EuminxdLib" /I "..\..\Includes" /I "..\VehicleDynamics\DATCOMTableLib" /I "..\VehicleDynamics" /D "MATLAB_R12" /D "MATLAB_MEX_FILE" /D "VehicleDynamicsMex_EXPORTS" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 ..\VehicleDynamics\EuminxdLib\release\EuminxdLib.lib ..\VehicleDynamics\DATCOMTableLib\Release\DATCOMTableLib.lib libcpmt.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\..\lib\win32\R12\VehicleDynamicsMex.dll" /export:mexFunction
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 ..\VehicleDynamics\EuminxdLib\release\EuminxdLib.lib ..\VehicleDynamics\DATCOMTableLib\Release\DATCOMTableLib.lib libcpmt.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\..\lib\win32\R12\VehicleDynamicsMex.dll" /export:mexFunction
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "VehicleDynamicsMex - Win32 Debug R14"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "VehicleDynamicsMex___Win32_Debug_R14"
# PROP BASE Intermediate_Dir "VehicleDynamicsMex___Win32_Debug_R14"
# PROP BASE Ignore_Export_Lib 1
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "VehicleDynamicsMex___Win32_Debug_R14"
# PROP Intermediate_Dir "VehicleDynamicsMex___Win32_Debug_R14"
# PROP Ignore_Export_Lib 1
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\VehicleDynamics\EuminxdLib" /I "..\..\Includes" /I "..\VehicleDynamics\DATCOMTableLib" /I "..\VehicleDynamics" /D "MATLAB_MEX_FILE" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "VehicleDynamicsMex_EXPORTS" /U "MATLAB_R12" /FR /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\VehicleDynamics\EuminxdLib" /I "..\..\Includes" /I "..\VehicleDynamics\DATCOMTableLib" /I "..\VehicleDynamics" /D "MATLAB_MEX_FILE" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "VehicleDynamicsMex_EXPORTS" /U "MATLAB_R12" /FR /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 ..\VehicleDynamics\EuminxdLib\debug\EuminxdLib.lib ..\VehicleDynamics\DATCOMTableLib\Debug\DATCOMTableLib.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /incremental:no /map /debug /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\..\lib\win32\R14\VehicleDynamicsMex.dll" /pdbtype:sept /export:mexFunction
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 ..\VehicleDynamics\EuminxdLib\debug\EuminxdLib.lib ..\VehicleDynamics\DATCOMTableLib\Debug\DATCOMTableLib.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /incremental:no /map /debug /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\..\lib\win32\R14\VehicleDynamicsMex.dll" /pdbtype:sept /export:mexFunction
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "VehicleDynamicsMex - Win32 Release R14"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "VehicleDynamicsMex___Win32_Release_R14"
# PROP BASE Intermediate_Dir "VehicleDynamicsMex___Win32_Release_R14"
# PROP BASE Ignore_Export_Lib 1
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "VehicleDynamicsMex___Win32_Release_R14"
# PROP Intermediate_Dir "VehicleDynamicsMex___Win32_Release_R14"
# PROP Ignore_Export_Lib 1
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /I "..\VehicleDynamics\EuminxdLib" /I "..\..\Includes" /I "..\VehicleDynamics\DATCOMTableLib" /I "..\VehicleDynamics" /D "MATLAB_MEX_FILE" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "VehicleDynamicsMex_EXPORTS" /U "MATLAB_R12" /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /I "..\VehicleDynamics\EuminxdLib" /I "..\..\Includes" /I "..\VehicleDynamics\DATCOMTableLib" /I "..\VehicleDynamics" /D "MATLAB_MEX_FILE" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "VehicleDynamicsMex_EXPORTS" /U "MATLAB_R12" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 ..\VehicleDynamics\EuminxdLib\release\EuminxdLib.lib ..\VehicleDynamics\DATCOMTableLib\Release\DATCOMTableLib.lib libcpmt.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\..\lib\win32\R14\VehicleDynamicsMex.dll" /export:mexFunction
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 ..\VehicleDynamics\EuminxdLib\release\EuminxdLib.lib ..\VehicleDynamics\DATCOMTableLib\Release\DATCOMTableLib.lib libcpmt.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\..\lib\win32\R14\VehicleDynamicsMex.dll" /export:mexFunction
# SUBTRACT LINK32 /pdb:none

!ENDIF 

# Begin Target

# Name "VehicleDynamicsMex - Win32 Debug R12"
# Name "VehicleDynamicsMex - Win32 Release R12"
# Name "VehicleDynamicsMex - Win32 Debug R14"
# Name "VehicleDynamicsMex - Win32 Release R14"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\VehicleDynamicsMex.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
