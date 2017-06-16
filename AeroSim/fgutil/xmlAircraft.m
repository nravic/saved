function Aircraft = xmlAircraft(AircraftName, FGRoot)

% Function name:
% Aircraft = xmlAircraft(AircraftName, FGRoot)
%
% Description:
% Parse a JSBSim aircraft model into a Matlab aircraft structure
%
% Inputs:
% AircraftName = a string containing the JSBSim aircraft name (for example,
% the Cessna-172 will use 'c172')
% FGRoot = a string containing the main FlightGear or JSBSim path (for
% example, 'C:\FlightGear-0.8')
%
% Outputs:
% Aircraft = a Matlab structure containing the aircraft model
%
% Notes:
% The aircraft structure is defined as following:
% Aircraft -> Name = the name of the aircraft
% Aircraft -> Version = the aircraft model version number
% Aircraft -> Metrics = the physical characteristics of the aircraft. It
% includes the following:
% Aircraft -> Metrics -> WingArea = wing area (ft^2)
% Aircraft -> Metrics -> WingSpan = wing span (ft)
% Aircraft -> Metrics -> WingChord = mean aerodynamic chord (ft)
% Aircraft -> Metrics -> HTailArea = horizontal tail area (ft^2)
% Aircraft -> Metrics -> HTailArm = distance from wing AC to horizontal tail AC (ft)
% Aircraft -> Metrics -> VTailArea = vertical tail area (ft^2)
% Aircraft -> Metrics -> VTailArm = distance from wing AC to vertical tail AC (ft)
% Aircraft -> Metrics -> InertiaX = moment of inertia about x-axis
% Aircraft -> Metrics -> InertiaY = moment of inertia about y-axis
% Aircraft -> Metrics -> InertiaZ = moment of inertia about z-axis
% Aircraft -> Metrics -> InertiaXZ = inertia coupling for x and z axes
% Aircraft -> Metrics -> EmptyWeight =  empty weight
% Aircraft -> Metrics -> ACLoc = aerodynamic reference point location
% Aircraft -> Metrics -> CGLoc = center of gravity location, empty weight, in aircraft's own structural coord
%   system. X, Y, Z, in inches
% Aircraft -> Metrics -> PilotLoc = pilot's eyepoint location, in aircraft's own coord system, FROM cg.
%  X, Y, Z, in inches
% Aircraft -> Metrics -> PointMass{i} = cell array of concetrated mass points
% (passangers, payloads, etc.)
% Aircraft -> Propulsion = the propulsion system characteristics of the
% aircraft. It includes the following:
% Aircraft -> Propulsion -> Engine{i} = cell array of engine parameters which include
% the following:
% Aircraft -> Propulsion -> Engine{i} -> Name = <name string>
% Aircraft -> Propulsion -> Engine{i} -> Type = 'PISTON' or 'ROCKET'
% Aircraft -> Propulsion -> Engine{i} -> Param - depending on engine type:
% For piston engine we have:
% Aircraft -> Propulsion -> Engine{i} -> Param -> ThrottleLim = [min max] values of throttle input
% Aircraft -> Propulsion -> Engine{i} -> Param -> MAPLim = [min max] values of manifold pressure
% Aircraft -> Propulsion -> Engine{i} -> Param -> Displacement = engine displacement
% Aircraft -> Propulsion -> Engine{i} -> Param -> MaxPower = maximum power produced
% Aircraft -> Propulsion -> Engine{i} -> Param -> NCycles = number of cycles / power stroke
% Aircraft -> Propulsion -> Engine{i} -> Param -> IdleRPM = minimum sustainable RPM
% For rocket engines we have:
% Aircraft -> Propulsion -> Engine{i} -> Param -> ThrottleLim = [min max] values of throttle input
% Aircraft -> Propulsion -> Engine{i} -> Param -> SpecHeatRatio = specific heat ratio
% Aircraft -> Propulsion -> Engine{i} -> Param -> MaxChPress = maximum chamber pressure
% Aircraft -> Propulsion -> Engine{i} -> Param -> Variance = random vibration parameter
% Aircraft -> Propulsion -> Engine{i} -> Param -> PropEff = propulsive efficiency
% Aircraft -> Propulsion -> Engine{i} -> Param -> MaxFuelFlowSL = maximum sea-level fuel flow
% Aircraft -> Propulsion -> Engine{i} -> Param -> MaxOxiFlowSL = maximum sea-level oxidizer flow
% Other engine parameters:
% Aircraft -> Propulsion -> Engine{i} -> Loc = the [X Y Z] location of the engine
% Aircraft -> Propulsion -> Engine{i} -> Pitch = the pitch angle of the engine
% Aircraft -> Propulsion -> Engine{i} -> Yaw = the yaw angle of the engine
% Aircraft -> Propulsion -> Engine{i} -> Feed = [TankID0 TankID1 ...] IDs of the fuel
% tanks used by this engine
% Aircraft -> Propulsion -> Thruster{i} = cell array of thruster parameters which
% include the following:
% Aircraft -> Propulsion -> Thruster{i} -> Name = <name string>
% Aircraft -> Propulsion -> Thruster{i} -> Type = 'PROPELLER' or 'NOZZLE'
% Aircraft -> Propulsion -> Thruster{i} -> Param - depending on thruster type:
% For propellers we have:
% Aircraft -> Propulsion -> Thruster{i} -> Param -> Inertia = the prop moment of inertia
% Aircraft -> Propulsion -> Thruster{i} -> Param -> Diameter = the prop diameter
% Aircraft -> Propulsion -> Thruster{i} -> Param -> NBlades = number of blades
% Aircraft -> Propulsion -> Thruster{i} -> Param -> PitchRange = [min max] blade pitch angle range
% Aircraft -> Propulsion -> Thruster{i} -> Param -> CoefThrust = the coefficient of thrust look-up-table
% (function of advance ratio CT=CT(J)
% Aircraft -> Propulsion -> Thruster{i} -> Param -> CoefPower = the coefficient of power look-up-table
% (function of advance ratio CP=CP(J)
% For nozzles we have:
% Aircraft -> Propulsion -> Thruster{i} -> Param -> ExitPress = nozzle exit pressure
% Aircraft -> Propulsion -> Thruster{i} -> Param -> ExpRatio = expansion ratio
% Aircraft -> Propulsion -> Thruster{i} -> Param -> Eff = nozzle efficiency
% Aircraft -> Propulsion -> Thruster{i} -> Param -> Diameter = nozzle diameter
% Other thruster parameters:
% Aircraft -> Propulsion -> Thruster{i} -> Loc = the [X Y Z] location of the thruster
% Aircraft -> Propulsion -> Thruster{i} -> Pitch = the pitch angle of the thruster
% Aircraft -> Propulsion -> Thruster{i} -> Yaw = the yaw angle of the thruster
% Aircraft -> Propulsion -> Thruster{i} -> PFactor = the p-factor of the thruster
% Aircraft -> Propulsion -> Thruster{i} -> Sense = the rotation sense (for rotating
% thrusters)
% Aircraft -> Propulsion -> Tank{i} = cell array of tank parameters which include the
% following:
% Aircraft -> Propulsion -> Tank{i} -> ID = the fuel tank index
% Aircraft -> Propulsion -> Tank{i} -> Type = the tank type can be 'FUEL' or 'OXIDIZER'
% Aircraft -> Propulsion -> Tank{i} -> Loc = the [X Y Z] tank location
% Aircraft -> Propulsion -> Tank{i} -> Radius = the approximate geometrical radius of the tank
% Aircraft -> Propulsion -> Tank{i} -> Capacity = the tank capacity (volume)
% Aircraft -> Propulsion -> Tank{i} -> Contents = the propellant tank contents (volume)
% Aircraft -> Aerodynamics = the aerodynamic model of the aircraft include
% the following:
% Aircraft -> Aerodynamics -> AlphaLim = [min max] angle-of-attack limits
% Aircraft -> Aerodynamics -> HystLim = [min max] alpha hysteresis limits
% Aircraft -> Aerodynamics -> Axis{i} = cell array of aerodynamic axes
% structures which include the following:
% Aircraft -> Aerodynamics -> Axis{i} -> Name = <name string>
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j} = cell array of factor
% groups, which include the following:
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j} -> Name = <name string>
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j} -> Description = <description string>
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j} -> Factor = The group
% factor structure which includes the following:
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j} -> Factor -> Name = <name string>
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j} -> Factor -> Type = 'VALUE', 'VECTOR' or 'TABLE'
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j} -> Factor -> Description = <description string>
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j} -> Factor -> RowIndex = the name of the row index
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j} -> Factor -> ColIndex = the name of the column index
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j} -> Factor -> RowArg = the row table argument x
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j} -> Factor -> ColArg = the column table argument y 
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j} -> Factor -> Data = the factor data,  data = data(x,y)
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j}.Coeff{k} = cell array of
% group coefficients, which include the following:
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j}.Coeff{k} -> Name = <name string>
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j}.Coeff{k} -> Type = 'VALUE', 'VECTOR' or 'TABLE'
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j}.Coeff{k} -> Description = <description string>
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j}.Coeff{k} -> RowIndex = the name of the row index
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j}.Coeff{k} -> ColIndex = the name of the column index
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j}.Coeff{k} -> RowArg = the row table argument x
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j}.Coeff{k} -> ColArg = the column table argument y 
% Aircraft -> Aerodynamics -> Axis{i} -> Group{j}.Coeff{k} -> Data = the coefficient data,  data = data(x,y)
% Aircraft -> Aerodynamics -> Axis{i} -> Coeff{j} = cell array of
% coefficients, which include the following:
% Aircraft -> Aerodynamics -> Axis{i} -> Coeff{j} -> Name = <name string>
% Aircraft -> Aerodynamics -> Axis{i} -> Coeff{j} -> Type = 'VALUE', 'VECTOR' or 'TABLE'
% Aircraft -> Aerodynamics -> Axis{i} -> Coeff{j} -> Description = <description string>
% Aircraft -> Aerodynamics -> Axis{i} -> Coeff{j} -> RowIndex = the name of the row index
% Aircraft -> Aerodynamics -> Axis{i} -> Coeff{j} -> ColIndex = the name of the column index
% Aircraft -> Aerodynamics -> Axis{i} -> Coeff{j} -> RowArg = the row table argument x
% Aircraft -> Aerodynamics -> Axis{i} -> Coeff{j} -> ColArg = the column table argument y 
% Aircraft -> Aerodynamics -> Axis{i} -> Coeff{j} -> Data = the coefficient data,  data = data(x,y)
%
% Unmanned Dynamics, LLC
% 09/13/2002

% Initialize aircraft structure with empty array
Aircraft = [];

% Build file paths
AircraftPath = strcat(FGRoot, '\Aircraft\', AircraftName, '\', AircraftName, '.xml');
PropulsionPath = strcat(FGRoot, '\Engine\');

% Parse the XML file
ACTree = xml_parser(AircraftPath);

% Search for the aircraft configuration tag
fdmidx = xmlSearchForTag(ACTree, 'FDM_CONFIG');

% If no aircraft model was found then 
if isempty(fdmidx)
    error('No aircraft model could be found in the xml file %s.', AircraftPath);
% If the aircraft model was found
else
    % If multiple aircraft were found
    if length(fdmidx) > 1
        error('Multiple aircraft models were found in the xml file %s.', AircraftPath);
    else
        % Save the aircraft model tag index
        Idx = fdmidx;
        % Save aircraft name
        Aircraft.Name = ACTree{Idx}.attributes{1}.val;
        Aircraft.Version = ACTree{Idx}.attributes{2}.val;
        % Process metrics
        Aircraft.Metrics = xmlMetrics(ACTree);
        % Process propulsion
        Aircraft.Propulsion = xmlPropulsion(ACTree, PropulsionPath);
        % Process aerodynamics
        Aircraft.Aerodynamics = xmlAerodynamics(ACTree);
    end
end