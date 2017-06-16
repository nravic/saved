function Thruster = xmlThruster(ThrusterFileName)

% Function name:
% Thruster = xmlThruster(ThrusterFileName)
%
% Description:
% Load a thruster configuration file into a thruster Matlab structure
%
% Inputs:
% ThrusterFileName = the path + filename of the thruster configuration file
% (xml)
%
% Outputs:
% Thruster = the thruster configuration structure, it is empty if no
% thruster definitions exist in the specified file
%
% Notes:
% The thruster structure is defined as following:
% Thruster -> Name = <name string>
% Thruster -> Type = 'PROPELLER' or 'NOZZLE'
% Thruster -> Param - depending on thruster type:
% For propellers we have:
% Thruster -> Param -> Inertia = the prop moment of inertia
% Thruster -> Param -> Diameter = the prop diameter
% Thruster -> Param -> NBlades = number of blades
% Thruster -> Param -> PitchRange = [min max] blade pitch angle range
% Thruster -> Param -> CoefThrust = the coefficient of thrust look-up-table
% (function of advance ratio CT=CT(J)
% Thruster -> Param -> CoefPower = the coefficient of power look-up-table
% (function of advance ratio CP=CP(J)
% For nozzles we have:
% Thruster -> Param -> ExitPress = nozzle exit pressure
% Thruster -> Param -> ExpRatio = expansion ratio
% Thruster -> Param -> Eff = nozzle efficiency
% Thruster -> Param -> Diameter = nozzle diameter
%
% Unmanned Dynamics, LLC
% 09/13/2002

% Initialize thruster structure with empty
Thruster = [];

% Parse the thruster configuration file
thrtree = xml_parser(ThrusterFileName);
% Search for a thruster definition tag
thridx = xmlSearchForTag(thrtree, 'FG_PROPELLER', 'FG_NOZZLE');

% If no thruster definitions were found then 
if isempty(thridx)
    error('No thruster definitions were found in the xml file %s.', ThrusterFileName);
% If thruster definitions were found
else
    % If multiple thruster definitions were found
    if length(thridx) > 1
        warning('Multiple thruster definitions were found in the xml file %s. We will use the last one.', ThrusterFileName);
    end
    % Save the thruster definition index
    Idx = thridx(end);
    % Save the thruster name
    Thruster.Name = thrtree{Idx}.attributes{1}.val;
    % Save the thruster type
    Thruster.Type = thrtree{Idx}.name(4:end);
    % Save children UIDs
    ThrParamUIDs = thrtree{Idx}.contents;
    if isempty(ThrParamUIDs)
        error('The thruster definition in xml file %s does not contain any data.', ThrusterFileName);
    else
        for j=ThrParamUIDs
            % If section is a string then:
            if strcmp(thrtree{j}.type, 'chardata')
                % Copy data string
                DataString = thrtree{j}.value;
                % Search for thruster parameters in the data string
                % 1. Propeller moment of inertia
                temp = xmlParameter(DataString, 'IXX', 1);
                if ~isempty(temp)
                    Thruster.Param.Inertia = temp;
                end
                % 2. Propeller diameter
                temp = xmlParameter(DataString, 'DIAMETER', 1);
                if ~isempty(temp)
                    Thruster.Param.Diameter = temp;
                end
                % 3. Propeller number of blades
                temp = xmlParameter(DataString, 'NUMBLADES', 1);
                if ~isempty(temp)
                    Thruster.Param.NBlades = temp;
                end
                % 4. Propeller minimum pitch
                temp = xmlParameter(DataString, 'MINPITCH', 1);
                if ~isempty(temp)
                    Thruster.Param.PitchRange(1) = temp;
                end
                % 5. Propeller maximum pitch
                temp = xmlParameter(DataString, 'MAXPITCH', 1);
                if ~isempty(temp)
                    Thruster.Param.PitchRange(2) = temp;
                end
                % 6. Propeller coefficient of thrust
                temp = xmlParameter(DataString, 'C_THRUST', 0);
                if ~isempty(temp)
                    Thruster.Param.CoefThrust = temp;
                end
                % 7. Propeller coefficient of power
                temp = xmlParameter(DataString, 'C_POWER', 0);
                if ~isempty(temp)
                    Thruster.Param.CoefPower = temp;
                end
                % 8. Nozzle exit pressure
                temp = xmlParameter(DataString, 'PE', 1);
                if ~isempty(temp)
                    Thruster.Param.ExitPress = temp;
                end
                % 9. Nozzle expansion ratio
                temp = xmlParameter(DataString, 'EXPR', 1);
                if ~isempty(temp)
                    Thruster.Param.ExpRatio = temp;
                end
                % 10. Nozzle efficiency
                temp = xmlParameter(DataString, 'NZL_EFF', 1);
                if ~isempty(temp)
                    Thruster.Param.Eff = temp;
                end
                % 11. Nozzle diameter
                temp = xmlParameter(DataString, 'DIAM', 1);
                if ~isempty(temp)
                    Thruster.Param.Diameter = temp;
                end
            end
        end
    end
end
