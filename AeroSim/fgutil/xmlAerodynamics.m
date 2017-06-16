function Aero = xmlAerodynamics(ACTree)

% Function name:
% Aerodynamics = xmlAerodynamics(ACTree)
%
% Description:
% Load the aerodynamics into a Matlab aerodynamics structure
%
% Inputs:
% ACTree = the aircraft tree structure, as provided by xml_parser
%
% Outputs:
% Aero = the aerodynamics structure (empty if no aerodynamics exist in the aircraft tree)
%
% Notes:
% The aerodynamics structure is defined as following:
% Aero -> AlphaLim = [min max] angle-of-attack limits
% Aero -> HystLim = [min max] alpha hysteresis limits
% Aero -> Axis{i} = cell array of aerodynamic axes structures
%
% Unmanned Dynamics, LLC
% 09/13/2002

% Initialize aerodynamics with empty
Aero = [];

% Search for the aerodynamics definition tag
aeroidx = xmlSearchForTag(ACTree, 'AERODYNAMICS');

% If no aerodynamics were found then 
if isempty(aeroidx)
    error('No aerodynamics were found in the aircraft xml tree.');
% If aerodynamics were found
else
    % If multiple aerodynamics were found
    if length(aeroidx) > 1
        warning('Multiple aerodynamic models were found in the aircraft xml tree. We will use the last one.');
    end
    % Save the aerodynamics index
    Idx = aeroidx(end);
    % Save the aerodynamics children
    ContentUID = ACTree{Idx}.contents;
    % Process the aerodynamics
    for i=ContentUID
        if strcmp(ACTree{i}.type, 'chardata')
            % Copy data string
            DataString = ACTree{i}.value;
            % Search for aerodynamics parameters in the data string
            % 1. Alpha limits
            temp = xmlParameter(DataString, 'AC_ALPHALIMITS', 2);
            if ~isempty(temp)
                Aero.AlphaLim = temp;
            end
            % 2. Hysteresis limits
            temp = xmlParameter(DataString, 'AC_HYSTLIMITS', 2);
            if ~isempty(temp)
                Aero.HystLim = temp;
            end
        else
            if strcmp(ACTree{i}.type, 'element')
                % If it is an element then we expect an aerodynamic axis
                temp = xmlAeroAxis(ACTree, i);
                if ~isempty(temp)
                    switch temp.Name
                        case 'LIFT'
                            Aero.Lift = temp;
                        case 'DRAG'
                            Aero.Drag = temp;
                        case 'SIDE'
                            Aero.Side = temp;
                        case 'ROLL'
                            Aero.Roll = temp;
                        case 'PITCH'
                            Aero.Pitch = temp;
                        case 'YAW'
                            Aero.Yaw = temp;
                    end
                end
            end
        end
    end
end
                
                
    