function Propulsion = xmlPropulsion(ACTree, PropulsionPath)

% Function name:
% Propulsion = xmlPropulsion(ACTree, PropulsionPath)
%
% Description:
% Load the propulsion data into a Matlab propulsion structure
%
% Inputs:
% ACTree = the aircraft tree structure, as provided by xml_parser
% PropulsionPath = the FlightGear engine directory '$FG_ROOT/Engine/'
%
% Outputs:
% Propulsion = the propulsion structure (empty if no propulsion data exists in the aircraft tree)
%
% Notes:
% The propulsion structure is defined as following:
% Propulsion -> Engine{i} = cell array of engine parameters (as defined in
% function xmlEngine)
% Propulsion -> Engine{i} -> Loc = the [X Y Z] location of the engine
% Propulsion -> Engine{i} -> Pitch = the pitch angle of the engine
% Propulsion -> Engine{i} -> Yaw = the yaw angle of the engine
% Propulsion -> Engine{i} -> Feed = [TankID0 TankID1 ...] IDs of the fuel
% tanks used by this engine
% Propulsion -> Thruster{i} = cell array of thruster parameters (as defined
% in function xmlThruster)
% Propulsion -> Thruster{i} -> Loc = the [X Y Z] location of the thruster
% Propulsion -> Thruster{i} -> Pitch = the pitch angle of the thruster
% Propulsion -> Thruster{i} -> Yaw = the yaw angle of the thruster
% Propulsion -> Thruster{i} -> PFactor = the p-factor of the thruster
% Propulsion -> Thruster{i} -> Sense = the rotation sense (for rotating
% thrusters)
% Propulsion -> Tank{i} = cell array of tank parameters (as defined in
% function xmlTank)
%
% Unmanned Dynamics, LLC
% 09/13/2002

% Initialize propulsion structure with empty array
Propulsion = [];

% Search for the propulsion tag
propidx = xmlSearchForTag(ACTree, 'PROPULSION');

% If no propulsion tags were found then 
if isempty(propidx)
    warning('No propulsion tag could be found in the xml tree. The aircraft is a glider.');
% If propulsion tags were found
else
    % If multiple propulsion tags were found
    if length(propidx) > 1
        warning('Multiple propulsion tags were found in the aircraft xml tree. We will use the last one.');
    end
    % Save the propulsion index
    Idx = propidx(end);
    % Save the propulsion children
    ContentUID = ACTree{Idx}.contents;
    % Reset the engine, thruster, and tank counters
    EngineIdx = 0; ThrusterIdx = 0; TankIdx = 0;
    % Process the propulsion model
    for i=ContentUID
        % Take into consideration only elements
        if strcmp(ACTree{i}.type, 'element')
            % We expect the following elements
            % 1. Engine
            if strcmp(ACTree{i}.name, 'AC_ENGINE')
                EngineIdx = EngineIdx + 1;
                EngFileName = strcat(PropulsionPath, ACTree{i}.attributes{1}.val, '.xml');
                Propulsion.Engine{EngineIdx} = xmlEngine(EngFileName);
                % Save the children UIDs
                EngineUID = ACTree{i}.contents;
                % Scan children elements for data
                if length(EngineUID) > 1
                    error('Comments not supported inside the engine tag.');
                else
                % Look only in strings (discard comments)
                    if strcmp(ACTree{EngineUID}.type, 'chardata')
                        % Save the data string
                        DataString = ACTree{EngineUID}.value;
                        % Search for the engine parameters:
                        % 1. X Location
                        temp = xmlParameter(DataString, 'XLOC', 1);
                        if ~isempty(temp)
                            Propulsion.Engine{EngineIdx}.Loc(1) = temp;
                        end
                        % 2. Y Location
                        temp = xmlParameter(DataString, 'YLOC', 1);
                        if ~isempty(temp)
                            Propulsion.Engine{EngineIdx}.Loc(2) = temp;
                        end
                        % 3. Z Location
                        temp = xmlParameter(DataString, 'ZLOC', 1);
                        if ~isempty(temp)
                            Propulsion.Engine{EngineIdx}.Loc(3) = temp;
                        end
                        % 4. Pitch
                        temp = xmlParameter(DataString, 'PITCH', 1);
                        if ~isempty(temp)
                            Propulsion.Engine{EngineIdx}.Pitch = temp;
                        end
                        % 5. Yaw
                        temp = xmlParameter(DataString, 'YAW', 1);
                        if ~isempty(temp)
                            Propulsion.Engine{EngineIdx}.Yaw = temp;
                        end
                        % 6. Feed
                        temp = xmlParameter(DataString, 'FEED', 1);
                        if ~isempty(temp)
                            Propulsion.Engine{EngineIdx}.Feed = temp;
                        end
                    end
                end
            end
            % 2. Thruster
            if strcmp(ACTree{i}.name, 'AC_THRUSTER')
                ThrusterIdx = ThrusterIdx + 1;
                ThrFileName = strcat(PropulsionPath, ACTree{i}.attributes{1}.val, '.xml');
                Propulsion.Thruster{ThrusterIdx} = xmlThruster(ThrFileName);
                % Save the children UIDs
                ThrusterUID = ACTree{i}.contents;
                % Scan children elements for data
                if length(ThrusterUID) > 1
                    error('Comments not supported inside the thruster tag.');
                else
                % Look only in strings (discard comments)
                    if strcmp(ACTree{ThrusterUID}.type, 'chardata')
                        % Save the data string
                        DataString = ACTree{ThrusterUID}.value;
                        % Search for the thruster parameters:
                        % 1. X Location
                        temp = xmlParameter(DataString, 'XLOC', 1);
                        if ~isempty(temp)
                            Propulsion.Thruster{ThrusterIdx}.Loc(1) = temp;
                        end
                        % 2. Y Location
                        temp = xmlParameter(DataString, 'YLOC', 1);
                        if ~isempty(temp)
                            Propulsion.Thruster{ThrusterIdx}.Loc(2) = temp;
                        end
                        % 3. Z Location
                        temp = xmlParameter(DataString, 'ZLOC', 1);
                        if ~isempty(temp)
                            Propulsion.Thruster{ThrusterIdx}.Loc(3) = temp;
                        end
                        % 4. Pitch
                        temp = xmlParameter(DataString, 'PITCH', 1);
                        if ~isempty(temp)
                            Propulsion.Thruster{ThrusterIdx}.Pitch = temp;
                        end
                        % 5. Yaw
                        temp = xmlParameter(DataString, 'YAW', 1);
                        if ~isempty(temp)
                            Propulsion.Thruster{ThrusterIdx}.Yaw = temp;
                        end
                        % 6. p-Factor
                        temp = xmlParameter(DataString, 'P_FACTOR', 1);
                        if ~isempty(temp)
                            Propulsion.Thruster{ThrusterIdx}.PFactor = temp;
                        end
                        % 7. Sense
                        temp = xmlParameter(DataString, 'SENSE', 1);
                        if ~isempty(temp)
                            Propulsion.Thruster{ThrusterIdx}.Sense = temp;
                        end
                    end
                end
            end
            % 3. Propellant tank
            temp = xmlTank(ACTree, i);
            if ~isempty(temp)
                TankIdx = TankIdx + 1;
                Propulsion.Tank{TankIdx} = temp;
            end
        end
    end
end
                