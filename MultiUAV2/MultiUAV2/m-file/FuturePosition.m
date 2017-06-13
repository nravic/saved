function [NewX,NewY,NewPsi,NewCounter]=FuturePosition(VehicleID,OldX,OldY,OldPsi,counter,TimeStep)

global g_WaypointCells
global g_WaypointDefinitions
global g_VehicleMemory


%load velocity from memory
Speed=g_VehicleMemory(VehicleID).Dynamics.VTrueFPSInit;
DistanceToGo=TimeStep*Speed;



%load waypoints
CurrentWaypoints=g_WaypointCells{VehicleID};

WX=CurrentWaypoints(:,g_WaypointDefinitions.PositionX);
WY=CurrentWaypoints(:,g_WaypointDefinitions.PositionY);
TurnDirection=CurrentWaypoints(:,g_WaypointDefinitions.TurnDirection);
Segment=CurrentWaypoints(:,g_WaypointDefinitions.SegmentLength);
TurnX=CurrentWaypoints(:,g_WaypointDefinitions.TurnCenterX);
TurnY=CurrentWaypoints(:,g_WaypointDefinitions.TurnCenterY);


%increment counter to go from 0-start indexed waypoints to a 1-start indexed array
counter=counter+1;

%estimate distance to next waypoint (assume vehicle is traveling on trajectory, hopefully that's not too big an assumption)
if TurnDirection(counter)==0
    ToNext=sqrt((OldX-WX(counter))^2+(OldY-WY(counter))^2);
    if ToNext>DistanceToGo
        Scale=DistanceToGo/ToNext;
        NewX=OldX+Scale*(WX(counter)-OldX);
        NewY=OldY+Scale*(WY(counter)-OldY);
        
        if counter>1
            LastTurn=find(TurnDirection(1:counter)~=0);
            if isempty(LastTurn)
                NewAngle=mod(atan2(WY(counter)-WY(counter-1),WX(counter)-WX(counter-1)),2*pi);
                NewPsi=mod(pi/2-NewAngle,2*pi);
            else
                LastTurn=LastTurn(end);
                NewAngle=mod(atan2(WY(LastTurn)-TurnY(LastTurn),WX(LastTurn)-TurnX(LastTurn)),2*pi);
                NewPsi=mod(pi/2-(NewAngle+pi/2*TurnDirection(LastTurn)),2*pi);
            end
        else 
            NewPsi=OldPsi;
        end
        NewCounter=counter-1;   
        return;
    else
        DistanceToGo=DistanceToGo-ToNext;
        counter=counter+1;
    end
else
    TurnRadius=sqrt((WY(counter)-TurnY(counter))^2+(WX(counter)-TurnX(counter))^2);
    WAngle=mod(atan2(WY(counter)-TurnY(counter),WX(counter)-TurnX(counter)),2*pi);
    VAngle=mod(atan2(OldY-TurnY(counter),OldX-TurnX(counter)),2*pi);
    DiffAngle=(WAngle-VAngle)*TurnDirection(counter);
    %fudge of 5 degrees over
    if DiffAngle<0 & abs(DiffAngle)<5*(pi/180)
        DiffAngle=0;
    else
        DiffAngle=mod(DiffAngle,2*pi);
    end
    
    ToNext=TurnRadius*DiffAngle;
    
    if ToNext>DistanceToGo
        Scale=DistanceToGo/ToNext;
        NewAngle=VAngle+DiffAngle*Scale*TurnDirection(counter);
        NewX=TurnX(counter)+TurnRadius*cos(NewAngle);
        NewY=TurnY(counter)+TurnRadius*sin(NewAngle);
        NewPsi=mod(pi/2-(NewAngle+pi/2*TurnDirection(counter)),2*pi);
        
        NewCounter=counter-1; 
        return;
    else
        DistanceToGo=DistanceToGo-ToNext;
        counter=counter+1;
    end
end


%find next waypoint vehicle won't reach
while(DistanceToGo>Segment(counter))
    DistanceToGo=DistanceToGo-Segment(counter);
    counter=counter+1;
end


%find final x,y, & psi
DistanceBack=Segment(counter)-DistanceToGo;
if TurnDirection(counter)==0
    Scale=DistanceBack/Segment(counter);
    NewX=WX(counter)+Scale*(WX(counter-1)-WX(counter));
    NewY=WY(counter)+Scale*(WY(counter-1)-WY(counter));
        
    LastTurn=find(TurnDirection(1:counter)~=0);
    if isempty(LastTurn)
        NewAngle=mod(atan2(WY(counter)-WY(counter-1),WX(counter)-WX(counter-1)),2*pi);
        NewPsi=mod(pi/2-NewAngle,2*pi);
    else
        LastTurn=LastTurn(end);
        NewAngle=mod(atan2(WY(LastTurn)-TurnY(LastTurn),WX(LastTurn)-TurnX(LastTurn)),2*pi);
        NewPsi=mod(pi/2-(NewAngle+pi/2*TurnDirection(LastTurn)),2*pi);
    end
    
else    
    TurnRadius=sqrt((WY(counter)-TurnY(counter))^2+(WX(counter)-TurnX(counter))^2);
    WAngle=mod(atan2(WY(counter)-TurnY(counter),WX(counter)-TurnX(counter)),2*pi);
    DiffAngle=DistanceBack/TurnRadius*TurnDirection(counter);
    NewAngle=mod(WAngle-DiffAngle,2*pi);
    
    NewX=TurnX(counter)+TurnRadius*cos(NewAngle);
    NewY=TurnY(counter)+TurnRadius*sin(NewAngle);
    NewPsi=mod(pi/2-(NewAngle+pi/2*TurnDirection(counter)),2*pi);
end

NewCounter=counter-1; 
return