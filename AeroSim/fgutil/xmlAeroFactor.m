function Coeff = xmlAeroFactor(ACTree, Idx)

% Function name:
% Coeff = xmlAeroFactor(ACTree, Idx)
%
% Description:
% Load an aerodynamic factor into a Matlab coefficient structure
%
% Inputs:
% ACTree = the aircraft tree structure, as provided by xml_parser
% Idx = the UID of the factor element
%
% Outputs:
% Coeff = the coefficient structure (empty if the element is not an
% aerodynamic factor)
%
% Notes:
% The coefficient structure is defined as following:
% Coeff -> Name = <name string>
% Coeff -> Type = 'VALUE', 'VECTOR' or 'TABLE'
% Coeff -> Description = <description string>
% Coeff -> RowIndex = the name of the row index
% Coeff -> ColIndex = the name of the column index
% Coeff -> RowArg = the row table argument x
% Coeff -> ColArg = the column table argument y 
% Coeff -> Data = the coefficient data,  data = data(x,y)
%
% Unmanned Dynamics, LLC
% 09/13/2002

% Initialize coefficient structure with empty
Coeff = [];

% If the structure type is element and the name is factor then we have
% a valid coefficient
if strcmp(ACTree{Idx}.type, 'element') & strcmp(ACTree{Idx}.name, 'FACTOR')
    % Save name
    Coeff.Name = ACTree{Idx}.attributes{1}.val;
    % Save type
    Coeff.Type = ACTree{Idx}.attributes{2}.val;
    ColSize = 1; RowSize = 1;
    % Save the children UIDs
    ContentUID = ACTree{Idx}.contents;
    % Scan children elements for data
    if length(ContentUID) > 1
        error('Comments not supported inside an aerodynamic factor tag.');
    else
        % Look only in strings (discard comments)
        if strcmp(ACTree{ContentUID}.type, 'chardata')
            % Save the data string
            DataString = ACTree{ContentUID}.value;
            % First string is the description
            [Coeff.Description,count,errmsg,nextidx] = sscanf(DataString, '%s', 1);
            % If coefficient is vector or table, next string is the column
            % size
            if strcmp(Coeff.Type, 'VECTOR') | strcmp(Coeff.Type, 'TABLE')
                [ColSize,count,errmsg,newidx] = sscanf(DataString(nextidx:end), '%d', 1);
                nextidx = nextidx + newidx;
            end
            % If coefficient is a table, next string is the row size
            if strcmp(Coeff.Type, 'TABLE')
                [RowSize,count,errmsg,newidx] = sscanf(DataString(nextidx:end), '%d', 1);
                nextidx = nextidx + newidx;
            end
            % If coefficient is vector or table, next string is the row
            % index
            if strcmp(Coeff.Type, 'VECTOR') | strcmp(Coeff.Type, 'TABLE')
                [Coeff.RowIndex,count,errmsg,newidx] = sscanf(DataString(nextidx:end), '%s', 1);
                nextidx = nextidx + newidx;
            end
            % If coefficient is a table, next string is the column index
            if strcmp(Coeff.Type, 'TABLE')
                [Coeff.ColIndex,count,errmsg,newidx] = sscanf(DataString(nextidx:end), '%s', 1);
                nextidx = nextidx + newidx;
            end
            % Next string is the set of non-dimensionamizing parameters
            [NonDimParams,count,errmsg,newidx] = sscanf(DataString(nextidx:end), '%s', 1);
            nextidx = nextidx + newidx;
            % If the coefficient is a table, the next string is the column
            % argument data
            if strcmp(Coeff.Type, 'TABLE')
                [Coeff.ColArg,count,errmsg,newidx] = sscanf(DataString(nextidx:end), '%f', RowSize);
                nextidx = nextidx + newidx;
            end
            % Finally read the coefficient data
            if strcmp(Coeff.Type, 'VECTOR') | strcmp(Coeff.Type, 'TABLE')
                temp = sscanf(DataString(nextidx:end), '%f', [RowSize+1, ColSize]);
                temp = temp';
                Coeff.RowArg = temp(:,1);
                Coeff.Data = temp(:,2:end);
            else
                Coeff.Data = sscanf(DataString(nextidx:end), '%f', 1);
            end
        end
    end
end
            
              
    
    
    

