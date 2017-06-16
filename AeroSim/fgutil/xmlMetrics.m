function Metrics = xmlMetrics(ACTree)

% Function name:
% Metrics = xmlMetrics(ACTree)
%
% Description:
% Load the metrics into a Matlab metrics structure
%
% Inputs:
% ACTree = the aircraft tree structure, as provided by xml_parser
%
% Outputs:
% Metrics = the metrics structure (empty if no metrics exist in the aircraft tree)
%
% Notes:
% The metrics structure is defined as following:
% Metrics -> WingArea = wing area (ft^2)
% Metrics -> WingSpan = wing span (ft)
% Metrics -> WingChord = mean aerodynamic chord (ft)
% Metrics -> HTailArea = horizontal tail area (ft^2)
% Metrics -> HTailArm = distance from wing AC to horizontal tail AC (ft)
% Metrics -> VTailArea = vertical tail area (ft^2)
% Metrics -> VTailArm = distance from wing AC to vertical tail AC (ft)
% Metrics -> InertiaX = moment of inertia about x-axis
% Metrics -> InertiaY = moment of inertia about y-axis
% Metrics -> InertiaZ = moment of inertia about z-axis
% Metrics -> InertiaXZ = inertia coupling for x and z axes
% Metrics -> EmptyWeight =  empty weight
% Metrics -> ACLoc = aerodynamic reference point location
% Metrics -> CGLoc = center of gravity location, empty weight, in aircraft's own structural coord
%   system. X, Y, Z, in inches
% Metrics -> PilotLoc = pilot's eyepoint location, in aircraft's own coord system, FROM cg.
%  X, Y, Z, in inches
% Metrics -> PointMass{i} = cell array of concetrated mass points
% (passangers, payloads, etc.)
%
% Unmanned Dynamics, LLC
% 09/13/2002

% Initialize metrics with empty
Metrics = [];

% Search for the metrics tag
metidx = xmlSearchForTag(ACTree, 'METRICS');

% If no metrics were found then 
if isempty(metidx)
    error('No metrics were found in the aircraft xml tree.');
% If metrics were found
else
    % If multiple metrics were found
    if length(metidx) > 1
        warning('Multiple metric models were found in the aircraft xml tree. We will use the last one.');
    end
    % Save the metrics index
    Idx = metidx(end);
    % Save the metrics children
    ContentUID = ACTree{Idx}.contents;
    % Reset the point mass counter
    PointMassIdx = 0;
    % Process the metrics
    for i=ContentUID
        if strcmp(ACTree{i}.type, 'chardata')
            % Copy data string
            DataString = ACTree{i}.value;
            % Search for metrics parameters in the data string
            % 1. Wing area
            temp = xmlParameter(DataString, 'AC_WINGAREA', 1);
            if ~isempty(temp)
                Metrics.WingArea = temp;
            end
            % 2. Wing span
            temp = xmlParameter(DataString, 'AC_WINGSPAN', 1);
            if ~isempty(temp)
                Metrics.WingSpan = temp;
            end
            % 3. Mean aerodynamic chord
            temp = xmlParameter(DataString, 'AC_CHORD', 1);
            if ~isempty(temp)
                Metrics.WingChord = temp;
            end
            % 4. Horizontal tail area
            temp = xmlParameter(DataString, 'AC_HTAILAREA', 1);
            if ~isempty(temp)
                Metrics.HTailArea = temp;
            end
            % 5. Horizontal tail arm
            temp = xmlParameter(DataString, 'AC_HTAILARM', 1);
            if ~isempty(temp)
                Metrics.HTailArm = temp;
            end
            % 6. Vertical tail area
            temp = xmlParameter(DataString, 'AC_VTAILAREA', 1);
            if ~isempty(temp)
                Metrics.VTailArea = temp;
            end
            % 7. Vertical tail arm
            temp = xmlParameter(DataString, 'AC_LV', 1);
            if ~isempty(temp)
                Metrics.VTailArm = temp;
            end
            % 8. Moment of inertia Jx
            temp = xmlParameter(DataString, 'AC_IXX', 1);
            if ~isempty(temp)
                Metrics.InertiaX = temp;
            end
            % 9. Moment of inertia Jy
            temp = xmlParameter(DataString, 'AC_IYY', 1);
            if ~isempty(temp)
                Metrics.InertiaY = temp;
            end
            % 10. Moment of inertia Jz
            temp = xmlParameter(DataString, 'AC_IZZ', 1);
            if ~isempty(temp)
                Metrics.InertiaZ = temp;
            end
            % 11. Moment of inertia Jxz
            temp = xmlParameter(DataString, 'AC_IXZ', 1);
            if ~isempty(temp)
                Metrics.InertiaXZ = temp;
            end
            % 12. Empty weight
            temp = xmlParameter(DataString, 'AC_EMPTYWT', 1);
            if ~isempty(temp)
                Metrics.EmptyWeight = temp;
            end
            % 13. Aerodynamic reference point
            temp = xmlParameter(DataString, 'AC_AERORP', 3);
            if ~isempty(temp)
                Metrics.ACLoc = temp;
            end
            % 14. CG location
            temp = xmlParameter(DataString, 'AC_CGLOC', 3);
            if ~isempty(temp)
                Metrics.CGLoc = temp;
            end
            % 15. Pilot eye point location
            temp = xmlParameter(DataString, 'AC_EYEPTLOC', 3);
            if ~isempty(temp)
                Metrics.PilotLoc = temp;
            end
            % 16. Point masses
            temp = xmlParameter(DataString, 'AC_POINTMASS', 4);
            if ~isempty(temp)
                PointMassIdx = PointMassIdx + 1;
                Metrics.PointMass{PointMassIdx} = temp;
            end
        end
    end
end