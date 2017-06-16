function Engine = xmlEngine(EngineFileName)

% Function name:
% Engine = xmlEngine(EngineFileName)
%
% Description:
% Load an engine configuration file into an engine Matlab structure
%
% Inputs:
% EngineFileName = the path + filename of the engine configuration file
% (xml)
%
% Outputs:
% Engine = the engine configuration structure, it is empty if no engine
% definitions exist in the specified file
%
% Notes:
% The engine structure is defined as following:
% Engine -> Name = <name string>
% Engine -> Type = 'PISTON' or 'ROCKET'
% Engine -> Param - depending on engine type:
% For piston engine we have:
% Engine -> Param -> ThrottleLim = [min max] values of throttle input
% Engine -> Param -> MAPLim = [min max] values of manifold pressure
% Engine -> Param -> Displacement = engine displacement
% Engine -> Param -> MaxPower = maximum power produced
% Engine -> Param -> NCycles = number of cycles / power stroke
% Engine -> Param -> IdleRPM = minimum sustainable RPM
% For rocket engines we have:
% Engine -> Param -> ThrottleLim = [min max] values of throttle input
% Engine -> Param -> SpecHeatRatio = specific heat ratio
% Engine -> Param -> MaxChPress = maximum chamber pressure
% Engine -> Param -> Variance = random vibration parameter
% Engine -> Param -> PropEff = propulsive efficiency
% Engine -> Param -> MaxFuelFlowSL = maximum sea-level fuel flow
% Engine -> Param -> MaxOxiFlowSL = maximum sea-level oxidizer flow
%
% Unmanned Dynamics, LLC
% 09/13/2002

% Initialize engine structure with empty
Engine = [];

% Parse the engine configuration file
engtree = xml_parser(EngineFileName);
% Search for an engine definition tag
engidx = xmlSearchForTag(engtree, 'FG_PISTON', 'FG_ROCKET');

% If no engine definitions were found then 
if isempty(engidx)
    error('No engine definitions were found in the xml file %s.', EngineFileName);
% If engine definitions were found
else
    % If multiple engine definitions were found
    if length(engidx) > 1
        warning('Multiple engine definitions were found in the xml file %s. We will use the last one.', EngineFileName);
    end
    % Save the engine definition index
    Idx = engidx(end);
    % Save the engine name
    Engine.Name = engtree{Idx}.attributes{1}.val;
    % Save the engine type
    Engine.Type = engtree{Idx}.name(4:end);
    % Save children UIDs
    EngParamUIDs = engtree{Idx}.contents;
    if isempty(EngParamUIDs)
        error('The engine definition in xml file %s does not contain any data.', EngineFileName);
    else
        for j=EngParamUIDs
            % If section is a string then:
            if strcmp(engtree{j}.type, 'chardata')
                % Copy data string
                DataString = engtree{j}.value;
                % Search for engine parameters in the data string
                % 1. Minimum manifold pressure
                temp = xmlParameter(DataString, 'MINMP', 1);
                if ~isempty(temp)
                    Engine.Param.MAPLim(1) = temp;
                end
                % 2. Maximum manifold pressure
                temp = xmlParameter(DataString, 'MAXMP', 1);
                if ~isempty(temp)
                    Engine.Param.MAPLim(2) = temp;
                end
                % 3. Displacement
                temp = xmlParameter(DataString, 'DISPLACEMENT', 1);
                if ~isempty(temp)
                    Engine.Param.Displacement = temp;
                end
                % 4. Maximum power
                temp = xmlParameter(DataString, 'MAXHP', 1);
                if ~isempty(temp)
                    Engine.Param.MaxPower = temp;
                end
                % 5. Cycles
                temp = xmlParameter(DataString, 'CYCLES', 1);
                if ~isempty(temp)
                    Engine.Param.NCycles = temp;
                end
                % 6. Idle RPM
                temp = xmlParameter(DataString, 'IDLERPM', 1);
                if ~isempty(temp)
                    Engine.Param.IdleRPM = temp;
                end
                % 7. Maximum throttle
                temp = xmlParameter(DataString, 'MAXTHROTTLE', 1);
                if ~isempty(temp)
                    Engine.Param.ThrottleLim(2) = temp;
                end
                % 8. Minimum throttle
                temp = xmlParameter(DataString, 'MINTHROTTLE', 1);
                if ~isempty(temp)
                    Engine.Param.ThrottleLim(1) = temp;
                end
                % 9. Specific heat ratio
                temp = xmlParameter(DataString, 'SHR', 1);
                if ~isempty(temp)
                    Engine.Param.SpecHeatRatio = temp;
                end
                % 10. Maximum chamber pressure
                temp = xmlParameter(DataString, 'MAX_PC', 1);
                if ~isempty(temp)
                    Engine.Param.MaxChPress = temp;
                end
                % 11. Variance
                temp = xmlParameter(DataString, 'VARIANCE', 1);
                if ~isempty(temp)
                    Engine.Param.Variance = temp;
                end
                % 12. Propulsive efficiency
                temp = xmlParameter(DataString, 'PROP_EFF', 1);
                if ~isempty(temp)
                    Engine.Param.PropEff = temp;
                end
                % 13. Maximum sea-level fuel flow
                temp = xmlParameter(DataString, 'SLFUELFLOWMAX', 1);
                if ~isempty(temp)
                    Engine.Param.MaxFuelFlowSL = temp;
                end
                % 14. Maximum sea-level oxidizer flow
                temp = xmlParameter(DataString, 'SLOXIFLOWMAX', 1);
                if ~isempty(temp)
                    Engine.Param.MaxOxiFlowSL = temp;
                end
            end
        end
    end
end
        
