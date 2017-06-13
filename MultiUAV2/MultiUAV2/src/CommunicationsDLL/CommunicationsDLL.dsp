# Microsoft Developer Studio Project File - Name="CommunicationsDLL" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=CommunicationsDLL - Win32 DebugDLL R12
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "CommunicationsDLL.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "CommunicationsDLL.mak" CFG="CommunicationsDLL - Win32 DebugDLL R12"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "CommunicationsDLL - Win32 DebugDLL R14" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "CommunicationsDLL - Win32 ReleaseDLL R12" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "CommunicationsDLL - Win32 DebugDLL R12" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "CommunicationsDLL - Win32 ReleaseDLL R14" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName "CommunicationsDLL"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "CommunicationsDLL - Win32 DebugDLL R14"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "CommunicationsDLL___Win32_DebugDLL_R14"
# PROP BASE Intermediate_Dir "CommunicationsDLL___Win32_DebugDLL_R14"
# PROP BASE Ignore_Export_Lib 1
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "CommunicationsDLL___Win32_DebugDLL_R14"
# PROP Intermediate_Dir "CommunicationsDLL___Win32_DebugDLL_R14"
# PROP Ignore_Export_Lib 1
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\Includes" /I "..\Vehicle\VehicleDynamics" /I "..\Vehicle\VehicleDynamics\DATCOMTableLib" /D "_DEBUG" /D "EXTERNAL_VEHICLE" /D "MATLAB_MEX_FILE" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CommunicationsDLL_EXPORTS" /U "MATLAB_R12" /FR /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\Includes" /I "..\Vehicle\VehicleDynamics" /I "..\Vehicle\VehicleDynamics\DATCOMTableLib" /D "_DEBUG" /D "EXTERNAL_VEHICLE" /D "MATLAB_MEX_FILE" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CommunicationsDLL_EXPORTS" /U "MATLAB_R12" /FR /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 ..\Vehicle\VehicleDynamics\DATCOMTableLib\debug\DATCOMTableLib.lib comdlg32.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /incremental:no /map /debug /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\lib\win32\R14\CommunicationsDLL.dll" /pdbtype:sept /export:mexFunction
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 ..\Vehicle\VehicleDynamics\DATCOMTableLib\debug\DATCOMTableLib.lib comdlg32.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /incremental:no /map /debug /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\lib\win32\R14\CommunicationsDLL.dll" /pdbtype:sept /export:mexFunction
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "CommunicationsDLL - Win32 ReleaseDLL R12"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "CommunicationsDLL___Win32_ReleaseDLL_R12"
# PROP BASE Intermediate_Dir "CommunicationsDLL___Win32_ReleaseDLL_R12"
# PROP BASE Ignore_Export_Lib 1
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "CommunicationsDLL___Win32_ReleaseDLL_R12"
# PROP Intermediate_Dir "CommunicationsDLL___Win32_ReleaseDLL_R12"
# PROP Ignore_Export_Lib 1
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /I "..\Includes" /I "..\Vehicle\VehicleDynamics" /I "..\Vehicle\VehicleDynamics\DATCOMTableLib" /D "MATLAB_R12" /D "NDEBUG" /D "EXTERNAL_VEHICLE" /D "MATLAB_MEX_FILE" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CommunicationsDLL_EXPORTS" /FD /c
# SUBTRACT BASE CPP /Fr /YX /Yc /Yu
# ADD CPP /nologo /MT /W3 /GX /O2 /I "..\Includes" /I "..\Vehicle\VehicleDynamics" /I "..\Vehicle\VehicleDynamics\DATCOMTableLib" /D "MATLAB_R12" /D "NDEBUG" /D "EXTERNAL_VEHICLE" /D "MATLAB_MEX_FILE" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CommunicationsDLL_EXPORTS" /FD /c
# SUBTRACT CPP /Fr /YX /Yc /Yu
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 ..\Vehicle\VehicleDynamics\DATCOMTableLib\release\DATCOMTableLib.lib libcpmt.lib libmex.lib libmx.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\lib\win32\R12\CommunicationsDLL.dll" /export:mexFunction
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 ..\Vehicle\VehicleDynamics\DATCOMTableLib\release\DATCOMTableLib.lib libcpmt.lib libmex.lib libmx.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\lib\win32\R12\CommunicationsDLL.dll" /export:mexFunction
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "CommunicationsDLL - Win32 DebugDLL R12"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "CommunicationsDLL___Win32_DebugDLL_R12"
# PROP BASE Intermediate_Dir "CommunicationsDLL___Win32_DebugDLL_R12"
# PROP BASE Ignore_Export_Lib 1
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "CommunicationsDLL___Win32_DebugDLL_R12"
# PROP Intermediate_Dir "CommunicationsDLL___Win32_DebugDLL_R12"
# PROP Ignore_Export_Lib 1
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\Includes" /I "..\Vehicle\VehicleDynamics" /I "..\Vehicle\VehicleDynamics\DATCOMTableLib" /D "MATLAB_R12" /D "_DEBUG" /D "EXTERNAL_VEHICLE" /D "MATLAB_MEX_FILE" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CommunicationsDLL_EXPORTS" /FR /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\Includes" /I "..\Vehicle\VehicleDynamics" /I "..\Vehicle\VehicleDynamics\DATCOMTableLib" /D "MATLAB_R12" /D "_DEBUG" /D "EXTERNAL_VEHICLE" /D "MATLAB_MEX_FILE" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CommunicationsDLL_EXPORTS" /FR /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 ..\Vehicle\VehicleDynamics\DATCOMTableLib\debug\DATCOMTableLib.lib comdlg32.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /incremental:no /map /debug /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\lib\win32\R12\CommunicationsDLL.dll" /pdbtype:sept /export:mexFunction
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 ..\Vehicle\VehicleDynamics\DATCOMTableLib\debug\DATCOMTableLib.lib comdlg32.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /incremental:no /map /debug /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\lib\win32\R12\CommunicationsDLL.dll" /pdbtype:sept /export:mexFunction
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "CommunicationsDLL - Win32 ReleaseDLL R14"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "CommunicationsDLL___Win32_ReleaseDLL_R14"
# PROP BASE Intermediate_Dir "CommunicationsDLL___Win32_ReleaseDLL_R14"
# PROP BASE Ignore_Export_Lib 1
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "CommunicationsDLL___Win32_ReleaseDLL_R14"
# PROP Intermediate_Dir "CommunicationsDLL___Win32_ReleaseDLL_R14"
# PROP Ignore_Export_Lib 1
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /I "..\Includes" /I "..\Vehicle\VehicleDynamics" /I "..\Vehicle\VehicleDynamics\DATCOMTableLib" /D "NDEBUG" /D "EXTERNAL_VEHICLE" /D "MATLAB_MEX_FILE" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CommunicationsDLL_EXPORTS" /U "MATLAB_R12" /FD /c
# SUBTRACT BASE CPP /Fr /YX /Yc /Yu
# ADD CPP /nologo /MT /W3 /GX /O2 /I "..\Includes" /I "..\Vehicle\VehicleDynamics" /I "..\Vehicle\VehicleDynamics\DATCOMTableLib" /D "NDEBUG" /D "EXTERNAL_VEHICLE" /D "MATLAB_MEX_FILE" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "CommunicationsDLL_EXPORTS" /U "MATLAB_R12" /FD /c
# SUBTRACT CPP /Fr /YX /Yc /Yu
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 ..\Vehicle\VehicleDynamics\DATCOMTableLib\release\DATCOMTableLib.lib libcpmt.lib libmex.lib libmx.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\lib\win32\R14\CommunicationsDLL.dll" /export:mexFunction
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 ..\Vehicle\VehicleDynamics\DATCOMTableLib\release\DATCOMTableLib.lib libcpmt.lib libmex.lib libmx.lib libmex.lib libmx.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386 /nodefaultlib:"libcpmt.lib" /out:"..\lib\win32\R14\CommunicationsDLL.dll" /export:mexFunction
# SUBTRACT LINK32 /pdb:none

!ENDIF 

# Begin Target

# Name "CommunicationsDLL - Win32 DebugDLL R14"
# Name "CommunicationsDLL - Win32 ReleaseDLL R12"
# Name "CommunicationsDLL - Win32 DebugDLL R12"
# Name "CommunicationsDLL - Win32 ReleaseDLL R14"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\CommunicationsDLL.cpp
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
