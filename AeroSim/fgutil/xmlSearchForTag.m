function idx = xmlSearchForTag(varargin)

% Function name:
% IndexArray = xmlSearchForTag(XMLTree, Tag1, Tag2, ... TagN)
%
% Description:
% Searches for the tags specified as arguments and returns their UIDs
%
% Inputs:
% XMLTree = an XML tree structure, as provided by xml_parser
%
% Outputs:
% Array of UIDs for the tags that were found (empty if none could be found)
%
% Unmanned Dynamics, LLC
% 09/13/2002

% Initialize output array
idx = [];

% The total number of tag arguments
Nstrings = nargin - 1;

% First argument is always the xml tree
xmltree = varargin{1};

% If at least one tag argument was provided then start the search
if Nstrings > 0
    % Search each tag
    for i=1:Nstrings
        % Save tag name string
        TagName = varargin{1+i};
        % Search in all of the xml tree
        for j=1:length(xmltree)
            % Look for elements (discard comments)
            if strcmp(xmltree{j}.type, 'element')
                % If found a match
                if strcmp(xmltree{j}.name, TagName)
                    % Add UID to index array
                    idx = [idx xmltree{j}.uid];
                end
            end
        end
    end
end
        
    