function s = GetLibDir( top )

	Release = version('-release');
	ReleaseDir = 'R14';
	
	switch(Release),
	case {'14',},
		ReleaseDir = 'R14';
	case {'12.1','13'},
		ReleaseDir = 'R12';
	otherwise,
		ReleaseDir = 'R14';
	end;

	ostype = '';
	switch(computer),
	 case 'PCWIN',
		ostype = 'win32';
	 case 'SOL2',
		ostype = 'solaris';
	 case 'HPUX',
		ostype = 'hpux';
	 case 'IBM_RS',
		ostype = 'aix';
	 case 'SGI',
		ostype = 'sgi';
	 case 'GLNX86',
		ostype = 'linux';
	 case 'MACOSX',
		ostype = 'macosx';
	 otherwise,
		ostype = 'unknown_platform_specified';
		warning(ostype);
	end
	s = [top, 'src', filesep, 'lib', filesep, ostype , filesep, ReleaseDir ];

	return
