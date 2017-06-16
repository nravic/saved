function Axis = xmlAeroAxis(ACTree, Idx)

% Function name:
% Axis = xmlAeroAxis(ACTree, Idx)
%
% Description:
% Load an aerodynamic axis into a Matlab axis structure
%
% Inputs:
% ACTree = the aircraft tree structure, as provided by xml_parser
% Idx = the UID of the axis element
%
% Outputs:
% Axis = the axis structure (empty if the element is not an axis)
%
% Notes:
% The axis structure is defined as following:
% Axis -> Name = <name string>
% Axis -> Group{i} = cell array of factor groups
% Axis -> Coeff{i} = cell array of coefficients
%
% Unmanned Dynamics, LLC
% 09/13/2002

% Initialize axis with empty
Axis = [];

% If the structure type is element and the name is group then we have
% a valid group
if strcmp(ACTree{Idx}.type, 'element') & strcmp(ACTree{Idx}.name, 'AXIS')
    % Save name
    Axis.Name = ACTree{Idx}.attributes{1}.val;
    % Save the children UIDs
    ContentUID = ACTree{Idx}.contents;
    % Scan the contents of the axis tag
    for i=ContentUID
        % If the child is a group then check for the basic group (ground
        % effect
        temp = xmlAeroGroup(ACTree, i);
        if ~isempty(temp)
            switch findstr(temp.Description, 'Basic')
                case 1
                    Axis.Basic = temp;
            end
        % If the child is a coefficient then save it as a coefficient
        else
            temp = xmlAeroCoeff(ACTree, i);
            if ~isempty(temp)
                eval(strcat('Axis.', temp.Name, ' = temp;'));
            end
        end        
    end
end
