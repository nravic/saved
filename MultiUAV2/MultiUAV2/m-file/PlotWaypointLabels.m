function PlotWaypointLabels( XY, maxPts, szWP )
%
% function PlotWaypointLabels( XY )
%
%   Purpose:  plot numbered labels on waypoints based on their order in
%             the waypoint list, where points that are too close have a
%             common label enclosed in curly braces, e.g. {4 5}.
%
%   Input:
%     1. XY:      2-D vector of (X,Y or Y,X for LVLH coords) planar waypoint
%                 positions.
%     2. maxPts:  maximum number of waypoints to label.
%     3. szWP:    specified size of waypoint.
%
%   Output:
%     <None>
%
%   Notes:
%     1.  All labels added to current figure.
%     0.  To change the definition of 'close', you must change the value of
%         dstar.
%
%   Author:   Jason Wm. Mitchell
%   Created:  2004/21/04
%   $Id: PlotWaypointLabels.m,v 1.1.10.3 2004/05/06 12:47:26 rasmussj Exp $
%==========================================================================

	global g_Debug; if(g_Debug==1),disp(mfilename);end; 

	dstar = 100; % ft; value that defines close.
	fontweight = 'bold';
	fontsize = 12;
	offset = szWP;

	s = getWaypointLabelInfo(XY,dstar);

	%% next block adds the labels to the plot
	for k = 1:maxPts
		pts =  s{k}.pts;
		if( ~isempty(pts) )
			wptxt = num2str(pts);
			if( length(pts) > 1 )
				wptxt = ['\{ ' wptxt ' \}']; % add braces
			end
			text(XY(k,1)-offset, XY(k,2)-offset, wptxt, ...
					 'FontWeight',fontweight,'FontSize',fontsize);
		end
	end

	return;

%%=========================================================================
function s = getWaypointLabelInfo( v, dstar )

	global g_Debug; if(g_Debug==1),disp([mfilename,':getWaypointLabelInfo']);end; 

	s = {};
	b = [];
	kmax = length(v);
	for k = 1:kmax
		s{k}.pos = []; % empty by default.
		s{k}.pts = [];
		s{k}.dist = [];
		if( ~ismember(k,b) )
			for l = 1:kmax
				p(l,:) = v(k,:); % pickup a vector of each kth (x,y) point
			end
			m = v - p;
			d = sqrt(m(:,1).^2 + m(:,2).^2);
			g = find(d<dstar)';
			if( length(g) > 1 ),
				b = [b setdiff(g,k)]; % remove waypoints that are included in
                              % this label; accept default value.
			end
			s{k}.pos = v(k,:); % location of the waypoint label.
			s{k}.pts = g;      % vector of waypoint indices in label.
			s{k}.dist = d(g)'; % distance from common waypoint.
		end
	end

	return
