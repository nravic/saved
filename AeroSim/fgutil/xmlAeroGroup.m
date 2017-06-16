function Group = xmlAeroGroup(ACTree, Idx)

% Function name:
% Group = xmlAeroGroup(ACTree, Idx)
%
% Description:
% Load an aerodynamic factor group into a Matlab factor group structure
%
% Inputs:
% ACTree = the aircraft tree structure, as provided by xml_parser
% Idx = the UID of the group element
%
% Outputs:
% Group = the factor group structure (empty if the element is not a factor group)
%
% Notes:
% The group structure is defined as following:
% Group -> Name = <name string>
% Group -> Description = <description string>
% Group -> Factor = The group factor structure (similar to coefficient
% structures)
% Group.Coeff{i} = cell array of group coefficients
%
% Unmanned Dynamics, LLC
% 09/13/2002

% Initialize group structure with empty
Group = [];

% If the structure type is element and the name is group then we have
% a valid group
if strcmp(ACTree{Idx}.type, 'element') & strcmp(ACTree{Idx}.name, 'GROUP')
    % Save name
    Group.Name = ACTree{Idx}.attributes{1}.val;
    % Save the children UIDs
    ContentUID = ACTree{Idx}.contents;
    % First element is the group description
    Group.Description = ACTree{ContentUID(1)}.value;
    % Second element is the group factor
    temp = []; i = 2;
    while isempty(temp)|(i==100)
        temp = xmlAeroFactor(ACTree, ContentUID(i));
        i = i + 1;
    end
    if i>=100
        error('Group %s does not have a factor.', Group.Name);
    else
        eval(strcat('Group.', temp.Name, ' = temp;'));
    end
    % The rest of the children are coefficients
    for j=i:length(ContentUID)
        temp = xmlAeroCoeff(ACTree, ContentUID(j));
        if ~isempty(temp)
            eval(strcat('Group.', temp.Name, ' = temp;'));
        end
    end
end
