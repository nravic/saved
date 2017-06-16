function Tank = xmlTank(ACTree, Idx)

% Function name:
% Tank = xmlTank(ACTree, Idx)
%
% Description:
% Load propellant tank data into a Matlab tank structure
%
% Inputs:
% ACTree = the aircraft tree structure, as provided by xml_parser
% Idx = the UID of the propellant tank element
%
% Outputs:
% Tank = the propellant tank structure (empty if the element is not a tank)
%
% Notes:
% The tank structure is defined as following:
% Tank -> ID = the fuel tank index
% Tank -> Type = the tank type can be 'FUEL' or 'OXIDIZER'
% Tank -> Loc = the [X Y Z] tank location
% Tank -> Radius = the approximate geometrical radius of the tank
% Tank -> Capacity = the tank capacity (volume)
% Tank -> Contents = the propellant tank contents (volume)
%
% Unmanned Dynamics, LLC
% 09/13/2002

% Initialize tank structure with empty
Tank = [];

% If the structure type is element and the name is tank then we have
% a valid tank structure
if strcmp(ACTree{Idx}.type, 'element') & strcmp(ACTree{Idx}.name, 'AC_TANK')
    % Save tank ID
    Tank.ID = ACTree{Idx}.attributes{2}.val;
    % Save tank type
    Tank.Type = ACTree{Idx}.attributes{1}.val;
    % Save the children UIDs
    ContentUID = ACTree{Idx}.contents;
    % Scan children elements for data
    if length(ContentUID) > 1
        error('Comments not supported inside a propellant tank tag.');
    else
        % Look only in strings (discard comments)
        if strcmp(ACTree{ContentUID}.type, 'chardata')
            % Save the data string
            DataString = ACTree{ContentUID}.value;
            % Search for the tank parameters:
            % 1. X Location
            temp = xmlParameter(DataString, 'XLOC', 1);
            if ~isempty(temp)
                Tank.Loc(1) = temp;
            end
            % 2. Y Location
            temp = xmlParameter(DataString, 'YLOC', 1);
            if ~isempty(temp)
                Tank.Loc(2) = temp;
            end
            % 3. Z Location
            temp = xmlParameter(DataString, 'ZLOC', 1);
            if ~isempty(temp)
                Tank.Loc(3) = temp;
            end
            % 4. Radius
            temp = xmlParameter(DataString, 'RADIUS', 1);
            if ~isempty(temp)
                Tank.Radius = temp;
            end
            % 5. Capacity
            temp = xmlParameter(DataString, 'CAPACITY', 1);
            if ~isempty(temp)
                Tank.Capacity = temp;
            end
            % 6. Contents
            temp = xmlParameter(DataString, 'CONTENTS', 1);
            if ~isempty(temp)
                Tank.Contents = temp;
            end
        end
    end
end