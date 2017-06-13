if exist('regress.mat', 'file')
  load regress
else
	error('regress.mat not found! (did you uncompress it?)');
end

d = zeros(1,3);
e = [];
for k = 1:length(data.Waypoints)
  e(1) = max(max(data.Waypoints{k} - regress.Waypoints{k}));
end
d(1) = max(e);
d(2) = max(data.TotalDistance - regress.TotalDistance);
d(3) = max(data.FinalHeading - regress.FinalHeading);

d
if( d == zeros(1,3) )
	disp('good match. (all zero)')
else
	disp('mis-match!');
end
