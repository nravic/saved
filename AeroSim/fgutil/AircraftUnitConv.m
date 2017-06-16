function ACOut = AircraftUnitConv(ACIn)

% Function name:
% ACOut = AircraftUnitConv(ACIn)
%
% Description:
% Convert an aircraft structure from English to Metric units
%
% Inputs:
% ACIn = the Matlab aircraft structure in English units
%
% Outputs:
% ACOut = the Matlab aircraft structure in metric units
%
% Unmanned Dynamics, LLC
% 09/13/2002

% Initialize output structure
ACOut = ACIn;

% Conversion factors
% Length
ft2m = 0.3048;
in2m = 0.0254;
% Area
ft2m2 = ft2m^2;
% Speed
fts2ms = ft2m;
mph2ms = 0.44704;
kts2ms = 0.51479027;
% Weight
lb2kg = 0.45359702;
lb2N = 4.44820070;
slug2kg = 14.59406605;
% Inertia
slugft2kgm = slug2kg*ft2m2;
% Pressure
inHg2Pa = 3386.53074866;
psi2Pa = 6894.55468071;
psf2Pa = 47.87896198;
% Power
hp2W = 745.7;

% I. Metrics section
ACOut.Metrics.WingArea = ACOut.Metrics.WingArea * ft2m2;
ACOut.Metrics.WingSpan = ACOut.Metrics.WingSpan * ft2m;
ACOut.Metrics.WingChord = ACOut.Metrics.WingChord * ft2m;
ACOut.Metrics.HTailArea = ACOut.Metrics.HTailArea * ft2m2;
ACOut.Metrics.HTailArm = ACOut.Metrics.HTailArm * ft2m;
ACOut.Metrics.VTailArea = ACOut.Metrics.VTailArea * ft2m2;
ACOut.Metrics.VTailArm = ACOut.Metrics.VTailArm * ft2m;
ACOut.Metrics.InertiaX = ACOut.Metrics.InertiaX * slugft2kgm;
ACOut.Metrics.InertiaY = ACOut.Metrics.InertiaY * slugft2kgm;
ACOut.Metrics.InertiaZ = ACOut.Metrics.InertiaZ * slugft2kgm;
ACOut.Metrics.InertiaXZ = ACOut.Metrics.InertiaXZ * slugft2kgm;
ACOut.Metrics.EmptyWeight = ACOut.Metrics.EmptyWeight * lb2kg;
ACOut.Metrics.ACLoc = ACOut.Metrics.ACLoc * in2m;
ACOut.Metrics.CGLoc = ACOut.Metrics.CGLoc * in2m;
ACOut.Metrics.PilotLoc = ACOut.Metrics.PilotLoc * in2m;
if isfield(ACOut.Metrics, 'PointMass')
    for i=1:length(ACOut.Metrics.PointMass)
        ACOut.Metrics.PointMass{i}(1) = ACOut.Metrics.PointMass{i}(1) * lb2kg;
        ACOut.Metrics.PointMass{i}(2) = ACOut.Metrics.PointMass{i}(2) * in2m;
        ACOut.Metrics.PointMass{i}(3) = ACOut.Metrics.PointMass{i}(3) * in2m;
        ACOut.Metrics.PointMass{i}(4) = ACOut.Metrics.PointMass{i}(4) * in2m;
    end
end

% II. Propulsion section
if ~isempty(ACOut.Propulsion)
    for i=1:length(ACOut.Propulsion.Engine)
        ACOut.Propulsion.Engine{i}.Loc = ACOut.Propulsion.Engine{i}.Loc * in2m;
        if strcmp(ACOut.Propulsion.Engine{i}.Type, 'PISTON')
            ACOut.Propulsion.Engine{i}.Param.MAPLim = ACOut.Propulsion.Engine{i}.Param.MAPLim * inHg2Pa;
            ACOut.Propulsion.Engine{i}.Param.Displacement = ACOut.Propulsion.Engine{i}.Param.Displacement * (in2m*100)^3;
            ACOut.Propulsion.Engine{i}.Param.MaxPower = ACOut.Propulsion.Engine{i}.Param.MaxPower * hp2W;
        else
            if strcmp(ACOut.Propulsion.Engine{i}.Type, 'ROCKET')
                ACOut.Propulsion.Engine{i}.Param.MaxChPress = ACOut.Propulsion.Engine{i}.Param.MaxChPress * psf2Pa;
                ACOut.Propulsion.Engine{i}.Param.MaxFuelFlowSL = ACOut.Propulsion.Engine{i}.Param.MaxFuelFlowSL * lb2kg;
                ACOut.Propulsion.Engine{i}.Param.MaxOxiFlowSL = ACOut.Propulsion.Engine{i}.Param.MaxOxiFlowSL * lb2kg;
            end
        end
    end
    for i=1:length(ACOut.Propulsion.Thruster)
        ACOut.Propulsion.Thruster{i}.Loc = ACOut.Propulsion.Thruster{i}.Loc * in2m;
        if strcmp(ACOut.Propulsion.Thruster{i}.Type, 'PROPELLER')
            ACOut.Propulsion.Thruster{i}.Param.Inertia = ACOut.Propulsion.Thruster{i}.Param.Inertia * slugft2kgm;
            ACOut.Propulsion.Thruster{i}.Param.Diameter = ACOut.Propulsion.Thruster{i}.Param.Diameter *in2m;
        else
            if strcmp(ACOut.Propulsion.Thruster{i}.Type, 'NOZZLE')
                ACOut.Propulsion.Thruster{i}.Param.ExitPress = ACOut.Propulsion.Thruster{i}.Param.ExitPress * psf2Pa;
                ACOut.Propulsion.Thruster{i}.Param.Diameter = ACOut.Propulsion.Thruster{i}.Param.Diameter * ft2m;
            end
        end
    end
    for i=1:length(ACOut.Propulsion.Tank)
        ACOut.Propulsion.Tank{i}.Loc = ACOut.Propulsion.Tank{i}.Loc * in2m;
        ACOut.Propulsion.Tank{i}.Radius = ACOut.Propulsion.Tank{i}.Radius * in2m;
        ACOut.Propulsion.Tank{i}.Capacity = ACOut.Propulsion.Tank{i}.Capacity * lb2kg;
        ACOut.Propulsion.Tank{i}.Contents = ACOut.Propulsion.Tank{i}.Contents * lb2kg;
    end
end

% III. Aerodynamics
% Aerodynamic coefficients are non-dimensional - no unit conversion
% required.
        
        
    