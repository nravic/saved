function WritePlaybackInit(InitFileName,Section,DataFileName)
%WritePlaybackInit - creates and adds to an AVDS Playback configuration file
%	InitFileName - The name of the intitaliztion file to which the information 
%						is written.
%	Section - Section of the intitaliztion file to write. Valid choices are: 
%		'Default'	-	The Default section opens the file erases the contents, if any, and
%							writes the general intialization information to the file. 
%		'Vehicle01'	-	The Vehicle01 section opens the file and appends the initialization
%							information for one entity based on the default AVDS playback data 
%							file format
%							writes the general intialization information to the file.
%		UserDefined	- 	The user can define custom section definitions based on one's own data 
%							file formats. New Sections can be defined by adding new cases to the 
%							switch statement below.
%	DataFileName -	This is the name of the file that AVDS will use to load the data for 
%						this entity
%	USAGE - To use this function first call it with the desired intialization file name:
%					WritePlaybackInit('Configuration1.ply.ini');
%						note: the extension '.ply.ini' is the defult used by AVDS.
%				Next call the function for each entity that there is data for, e.g. if there
%				is data for 3 vehicles:
%					WritePlaybackInit('Configuration1.ply.ini','Vehicle01','Data01.dat');
%					WritePlaybackInit('Configuration1.ply.ini','Vehicle01','Data01.dat');
%					WritePlaybackInit('Configuration1.ply.ini','Vehicle01','Data03.dat');
%

%   Steve Rasmussen, December 2000
%   Copyright (c) 2000 by RasSimTech Ltd
%   $Revision: 2.0.18.2 $  $Date: 2004/05/06 12:47:28 $

%  September 2001 - modified to take advantage of neew AVDS capabilities - RAS


global g_Debug; if(g_Debug==1),disp('WritePlaybackInit.m');end; 

persistent EntityNumber;

if (nargin <= 1),
   Section = 'Default';
	if (nargin <= 0),
   	InitFileName = 'MATLAB.ply.ini';
   end;
elseif ((nargin < 3) & (Section ~= 'Initial')),
       error('Wrong number of arguments passed to a call to ''WritePlaybackInit'', expected three.');
end;	%if (nargin <= 1),

switch Section
case 'Default'	% this section writes the default intitialization information 
   [fid, msg] = fopen(InitFileName,'w');
	 if( fid == -1 )
		 error(msg);
		 return;
	 end
	 fprintf(fid,'[Block 1]\r\r\n\r\n');
   fprintf(fid,'Block Label=Network Block\r\n');
	 fprintf(fid,'[Block 2]\r\n\r\n');
	 fprintf(fid,'Block Label=Display Charts\r\n');
	 fprintf(fid,'Gallery:1=9109505\r\n');
	 fprintf(fid,'Line Width:1=2\r\n');
	 fprintf(fid,'Line Style:1=38469632\r\n');
	 fprintf(fid,'Marker Shape:1=9109504\r\n');
	 fprintf(fid,'Marker Size:1=3\r\n');
	 fprintf(fid,'Marker Step:1=1\r\n');
	 fprintf(fid,'Grid:1=9109505\r\n');
	 fprintf(fid,'Title:1=(Right-Click in Chart Area for Menu)\r\n');
	 fprintf(fid,'Chart3D:1=0\r\n');
	 fprintf(fid,'Legend Visible:1=-1\r\n');
	 fprintf(fid,'Legend Docked:1=256\r\n');
	 fprintf(fid,'Y Axis Autoscale:1=0\r\n');
	 fprintf(fid,'Y Axis Maximum:1=800\r\n');
	 fprintf(fid,'Y Axis Minimum:1=-150\r\n');
	 fprintf(fid,'Chart Refresh Rate=5\r\n');
	 fprintf(fid,'X Increment=5\r\n');
   fprintf(fid,'Number of Charts=1\r\n\r\n');
	 fprintf(fid,'[Block 3]\r\n');
   fprintf(fid,'Block Label=AVDS Playback Block\r\n');
   fclose(fid);
   
   EntityNumber = 0;		% start at zero because it is incremented at the end of the file
   
case 'Vehicle01'	% this is the initialization section for a vehicle with the AVDS default data file configuration
   fid = fopen(InitFileName,'a');
   fprintf(fid,'Entity:%d:DataFile=%s\r\n',EntityNumber,DataFileName);
   fprintf(fid,'Entity:%d:Time Type=Elapsed\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:time=1:1\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:x=1:2\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:y=1:3\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:z=1:4\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:xrot=1:5\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:yrot=1:6\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:zrot=1:7\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:craftmask=1:8\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:crafttype=1:9\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:1:Dyn:eng=1:10\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:alpha=1:11\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:beta=1:12\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:G=1:13\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:V=1:14\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:M=1:15\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc01=1:16\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc02=1:17\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc03=1:18\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc04=1:19\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc05=1:20\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc06=1:21\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc07=1:22\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc08=1:23\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc09=1:24\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc10=1:25\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc11=1:26\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc12=1:27\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc13=1:28\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc14=1:29\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:sfc15=1:30\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:select=1:31\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:launch=1:32\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:explode=1:33\r\n',EntityNumber);   
   fclose(fid);
case 'Vehicle'
   fid = fopen(InitFileName,'a');
   fprintf(fid,'Entity:%d:DataFile=%s\r\n',EntityNumber,DataFileName);
	fprintf(fid,'Entity:%d:Time Type=Elapsed\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:time=1:1\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:x=1:3\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:y=1:2\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:z=-1:4\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:xrot=-1:5\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:yrot=1:6\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:zrot=1:7\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:alpha=1:8\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:beta=1:9\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:V=1:10\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:M=1:11\r\n',EntityNumber);
   	fprintf(fid,'Entity:%d:Dyn:crafttype=1:12\r\n',EntityNumber);
   	fprintf(fid,'Entity:%d:Dyn:ColorOffsetVehicle=1:13\r\n',EntityNumber);
   	fprintf(fid,'Entity:%d:Dyn:ColorFlightPath=1:13\r\n',EntityNumber);
   	fprintf(fid,'Entity:%d:Dyn:ScaleX=1:31\r\n',EntityNumber);
   	fprintf(fid,'Entity:%d:Dyn:ScaleY=1:31\r\n',EntityNumber);
   	fprintf(fid,'Entity:%d:Dyn:ScaleZ=1:31\r\n',EntityNumber);
   fclose(fid);
case 'Sensor'
   fid = fopen(InitFileName,'a');
   fprintf(fid,'Entity:%d:DataFile=%s\r\n',EntityNumber,DataFileName);
	fprintf(fid,'Entity:%d:Time Type=Elapsed\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:time=1:1\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:x=1:15\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:y=1:14\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:z=-1:16\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:zrot=1:7\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:crafttype=1:17\r\n',EntityNumber);
   	fprintf(fid,'Entity:%d:Dyn:ScaleX=1:18\r\n',EntityNumber);
   	fprintf(fid,'Entity:%d:Dyn:ScaleY=1:19\r\n',EntityNumber);
   	fprintf(fid,'Entity:%d:Dyn:ColorOffsetVehicle=1:20\r\n',EntityNumber);
   fclose(fid);
case 'TargetMarker'
   fid = fopen(InitFileName,'a');
   fprintf(fid,'Entity:%d:DataFile=%s\r\n',EntityNumber,DataFileName);
	fprintf(fid,'Entity:%d:Time Type=Elapsed\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:time=1:1\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:x=1:22\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:y=1:21\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:z=-1:23\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:crafttype=1:24\r\n',EntityNumber);
   	fprintf(fid,'Entity:%d:Dyn:ColorOffsetVehicle=1:25\r\n',EntityNumber);
   fclose(fid);
case 'Rabbit'
   fid = fopen(InitFileName,'a');
   fprintf(fid,'Entity:%d:DataFile=%s\r\n',EntityNumber,DataFileName);
	fprintf(fid,'Entity:%d:Time Type=Elapsed\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:time=1:1\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:x=1:26\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:y=1:27\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:z=-1:28\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:zrot=1:29\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:crafttype=1:31\r\n',EntityNumber);
   fclose(fid);
case 'Target'
   fid = fopen(InitFileName,'a');
   fprintf(fid,'Entity:%d:DataFile=%s\r\n',EntityNumber,DataFileName);
	fprintf(fid,'Entity:%d:Time Type=Elapsed\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:time=1:1\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:x=1:3\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:y=1:2\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:z=-1:4\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:crafttype=1:5\r\n',EntityNumber);
	fprintf(fid,'Entity:%d:Dyn:zrot=1:6\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:explode=1:8\r\n',EntityNumber);
   fprintf(fid,'Entity:%d:Dyn:ColorOffsetVehicle=1:9\r\n',EntityNumber);
   	fprintf(fid,'Entity:%d:Dyn:ScaleX=1:10\r\n',EntityNumber);
   	fprintf(fid,'Entity:%d:Dyn:ScaleY=1:10\r\n',EntityNumber);
   	fprintf(fid,'Entity:%d:Dyn:ScaleZ=1:10\r\n',EntityNumber);
   fclose(fid);
end;	%switch Section

EntityNumber = EntityNumber + 1;	%increment the entity number, begins at 1 and is pesistent

