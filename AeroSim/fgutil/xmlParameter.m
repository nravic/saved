function ParamVal = xmlParameter(DataString, ParamName, VecSize)

% Function name:
% ParamVal = xmlParameter(DataString, ParamName, VecSize)
%
% Description:
% Search for a parameter in a string array and return its value
%
% Inputs:
% DataString = the character string to be processed
% ParamName = a string containing the name of the desired parameter
% VecSize = the size of the parameter vector
% (if VecSize = 0 then it parameter is assumed a look-up table and the size
% is read from the data string)
%
% Outputs:
% ParamVal = the parameter values, empty if the parameter could not be
% found
%
% Unmanned Dynamics, LLC
% 09/13/2002

% Initialize parmeter value to empty
ParamVal = [];

% Append a space char at the end of the name string
ParamName2 = [ParamName, ' '];

% Find the parameter name in the data string
Occurence = findstr(DataString, ParamName2);

% If the parameter was found
if ~isempty(Occurence)
    % If there are multiple occurences then use only the first one
    if length(Occurence)>1
        % FEED parameter is an exception
        if ~strcmp(ParamName, 'FEED')
            warning('Multiple occurences of the parameter %s were found. We will use the last one.', ParamName);
        end
    end
    % FEED parameter is an exception
    if strcmp(ParamName, 'FEED')
        for i=Occurence
            % Create a sub-string which starts after the parameter name
            SmallString = DataString((i+length(ParamName)):end);
            % Scan string for parameter value
            temp = sscanf(SmallString, '%d', 1);
            ParamVal = [ParamVal temp];
        end
    else
        % Save the occurence index
        Idx = Occurence(end);
        % Create a sub-string which starts after the parameter name
        SmallString = DataString((Idx+length(ParamName)):end);
        % If size is known
        if VecSize > 0
            % Scan string for parameter value
            ParamVal = sscanf(SmallString, '%f', VecSize);
        % If size is not known
        else
            % Scan string for parameter size
            [temp,count,errmsg,nextidx] = sscanf(SmallString, '%d', 2);
            ColSize = temp(1);
            RowSize = temp(2) + 1;
            if temp(2)>1
                % We have a table. Read row argument
                [temp,count,errmsg,nextidx2] = sscanf(SmallString(nextidx:end), '%f', temp(2));
                ParamArg = [0 temp'];
                nextidx = nextidx + nextidx2;
            end
            % Scan string for parameter value
            ParamVal = sscanf(SmallString(nextidx:end), '%f', [RowSize, ColSize]);
            ParamVal = ParamVal';
            if exist('ParamArg')
                ParamVal = [ParamArg; ParamVal];
            end
        end
    end
end
    