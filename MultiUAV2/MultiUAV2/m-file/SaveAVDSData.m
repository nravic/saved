function SaveAVDSData()
%SaveAVDSData - saves the AVDS playback from the global workspace to a file
%  and creates an AVDS playback configuration file.
%
%  Inputs:
%    (none) 
%
%  Outputs:
%    (none)
%

%  AFRL/VACA
%  December 2000 - Created and Debugged - RAS
%  October 2001 - added starting latitude and longitude to files - RAS
%  October 2001 - updated to take advantage of new AVDS capabilities - RAS



	global g_Debug; if(g_Debug==1),disp('SaveAVDSData.m');end; 

	global g_AVDSVehicleCells;
	global g_EnableVehicle;
	global g_EnableTarget;
	global g_AVDSTargetCells;
	global EnableThreat;

	disp('Saving AVDS data...');

	ScaleVehicles = 5.0;
	ScaleTargets = 5.0;

	tdir = ['..', filesep];
	cdir = ['.', filesep];
	avds_dir = ['AVDSData', filesep];
	obs_tmpl = 'Observer%i.dat';
	veh_tmpl = 'Vehicle%d.dat';
	tar_tmpl = 'Target%d.dat';
	mass_ply_ini = [tdir, avds_dir, 'MASS.ply.ini'];

	disp('  creating playback configuration...');

	% create a playback configuration file and write intial entries
	WritePlaybackInit(mass_ply_ini);

	[iNumberCells] = size(g_AVDSVehicleCells);
	iEntityNum = 1;

	%lat/long file
	ReferenceLatitude = 37.45;
	ReferenceLatitude = 37.43;
	ReferenceLongitude = -121.9496;
	ReferenceLongitude = -122.00;
	[fid, msg] = fopen('temp1','w+');
	if( fid == -1 )
		error(msg);
		return;
	end
	fprintf(fid,'%% LAT %5.4f\n',ReferenceLatitude);
	fprintf(fid,'%% LONG %5.4f\n',ReferenceLongitude);
	fclose(fid);

	AltitudeDefault = 200;
	OffsetDefault = -500;
	% add the postions of the first two targets as stationary observers
	NumberObservers = 0;
	ObserverPostions = zeros(NumberObservers,2);
	iCountTargets = 0;
	[iNumberTargetCells] = size(g_AVDSTargetCells); 
	if(iCountTargets < NumberObservers),
		for iCount = 1:iNumberTargetCells,
			if (g_EnableTarget(iCount) > 0 ),
        TempArray = g_AVDSTargetCells{iCount};
				ObserverPostions(iCount,1)= TempArray(1,2) + OffsetDefault;
				ObserverPostions(iCount,2)= TempArray(1,3) + OffsetDefault;
				iCountTargets = iCountTargets +1;
			end;
			if(iCountTargets >= NumberObservers),
				break;
			end;
		end;	%for iCount = 1:iNumberCells,
	end;	%if(iCountTargets < NumberObservers)

	disp('  saving observer data...');

	% add the stationary vehicle files to the configuration to act as an observation posts
	% default observer
	AddDefault = 1;
	if(AddDefault),
		FileName = [cdir, sprintf(obs_tmpl,1)];
		WritePlaybackInit(mass_ply_ini,'Vehicle',FileName);
		FileName = [tdir, avds_dir, sprintf(obs_tmpl,1)];
		%TempArray = [ 0.0 12500.0 -2000.0 AltitudeDefault 0.0 0.0 0.0 0.0 0.0 0.0 0.0 3.0 0.0 0.0];
		TempArray = [ 0.0 12500.0 -3000.0 AltitudeDefault 0.0 0.0 0.0 0.0 0.0 0.0 0.0 3.0 0.0 0.0];
		save ('temp2','TempArray','-ascii','-double');
		cat_files( 'temp1', 'temp2', FileName );
		iEntityNum = iEntityNum + 1;
	end;

	for iCount = 1:iCountTargets,
		FileName = [cdir, sprintf(obs_tmpl,iCount+1)];
		WritePlaybackInit(mass_ply_ini,'Vehicle',FileName);
		FileName = [tdir, avds_dir, sprintf(obs_tmpl,iCount+1)];
		TempArray = [  0.0  ObserverPostions(iCount,1) ObserverPostions(iCount,2) AltitudeDefault 0.0 0.0 0.0 0.0 0.0 0.0 0.0 3.0 0.0 0.0];
		save ('temp2','TempArray','-ascii','-double');
		cat_files( 'temp1', 'temp2', FileName );
		iEntityNum = iEntityNum + 1;
	end;	%for iCount = 1:iNumberCells,


	SaveStationary2 = 0;
	if(SaveStationary2),
		% add the stationary vehicle file to the configuration to act as an observation post
		FileName = [cdir, sprintf(obs_tmpl, 2)];
		WritePlaybackInit(mass_ply_ini,'Vehicle',FileName);
		FileName = [tdir, avds_dir, sprintf(obs_tmpl, 2)];
		TempArray = [  0.0  10000.0 -3500.0 2500.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 3.0 0.0 0.0];
   	save ('temp2','TempArray','-ascii','-double');
		cat_files( 'temp1', 'temp2', FileName );
		iEntityNum = iEntityNum + 1;
	end;	%if(SaveStationary2)


	iIndexScanAltitude = 16;
	iIndexScale = 31;

	disp('  saving vehicle data...');

	%save the vehicle data
	for iCount = 1:iNumberCells,
		if (g_EnableVehicle(iCount) > 0 ),
			TempArray = g_AVDSVehicleCells{iCount};
			if(isempty(TempArray)),
				ErrorString = sprintf('\tERROR:SaveAVDSData:Vehicle #%d did not save AVDS data. \n\t\tNOTE:This must be enabled in "InitializeGlobals" before the simulation run.',iCount);
				disp(ErrorString);
				continue;
			end;
			FileName = [tdir, avds_dir, sprintf(veh_tmpl,iCount)];
			[iRows,iCols]=size(TempArray);
			%		TempArray = [TempArray,(ScaleVehicles*ones(iRows,1))];
			TempArray(:,iIndexScale) = TempArray(:,iIndexScale)*ScaleVehicles;
			TempArray(:,iIndexScanAltitude) = TempArray(:,iIndexScanAltitude) + 50.0*ones(iRows,1);
			save ('temp2','TempArray','-ascii','-double');
			cat_files( 'temp1', 'temp2', FileName );
			FileName = [cdir, sprintf(veh_tmpl,iCount)];
			WritePlaybackInit(mass_ply_ini,'Vehicle',FileName);
			iEntityNum = iEntityNum + 1;
		end;
	end;	%for iCount = 1:iNumberCells,

	%save the sensor data
	for iCount = 1:iNumberCells,
   	if (g_EnableVehicle(iCount) > 0 ),
			FileName = [cdir, sprintf(veh_tmpl,iCount)];
      WritePlaybackInit(mass_ply_ini,'Sensor',FileName);
      iEntityNum = iEntityNum + 1;
		end;
	end;	%for iCount = 1:iNumberCells,

	ShowRabbit = 0;
	if (ShowRabbit),
		%save the rabbit data
		for iCount = 1:iNumberCells,
   		if (g_EnableVehicle(iCount) > 0 ),
				FileName = [cdir, sprintf(veh_tmpl,iCount)];
				WritePlaybackInit(mass_ply_ini,'Rabbit',FileName);
				iEntityNum = iEntityNum + 1;
   		end;
		end;	%for iCount = 1:iNumberCells,
	end;	%if (ShowRabbit),

	disp('  saving target data...');

	%save the target marker data
	for iCount = 1:iNumberCells,
   	if (g_EnableVehicle(iCount) > 0 ),
			FileName = [cdir, sprintf(veh_tmpl,iCount)];
			WritePlaybackInit(mass_ply_ini,'TargetMarker',FileName);
			iEntityNum = iEntityNum + 1;
		end;
	end;	%for iCount = 1:iNumberCells,

	%save the target data
	[iNumberCells] = size(g_AVDSTargetCells); 
	for iCount = 1:iNumberCells,
		if (g_EnableTarget(iCount) > 0 ),
			FileName = [tdir, avds_dir, sprintf(tar_tmpl,iCount)];
			TempArray = g_AVDSTargetCells{iCount};
			[iRows,iCols]=size(TempArray);
			TempArray = [TempArray,(ScaleTargets*ones(iRows,1))];
			save ('temp2','TempArray','-ascii','-double');
			cat_files( 'temp1', 'temp2', FileName );
			FileName = [cdir, sprintf(tar_tmpl,iCount)];
			WritePlaybackInit(mass_ply_ini,'Target',FileName);
			iEntityNum = iEntityNum + 1;
		end;
	end;

	cleanup_tmp_files('temp1 temp2');

	beep;
	disp('done.');

	return

%%=========================================================================
%% support function defs:
function cat_files( a, b, c )

	if( isunix )
		[s,r] = unix(['cat ', a, ' ', b, ' >', c]);
	else
		[s,r] = dos(['copy ', a, '+', b, ' ', c]);
	end

	if( s ~= 0 )
		error(['Unable to concatenate files ', a, ' and ', b, ' to ', c]);
	end

	return

function cleanup_tmp_files( str )

	if( isunix )
		[s,r] = unix(['rm ', str]);
	else
		[s,r] = dos(['del ', str]);
	end

	if( s ~= 0 )
		error(['Unable to cleanup files: ', str]);
	end

	return
