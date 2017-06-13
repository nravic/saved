function [VehicleAssignment,VehicleAssigned] = RunJacobi(Task,Benefits,Index,VehicleSchedule,NumberOfVehicles,NumberOfTargets,BenefitsContinueToSearch)    %Mod by Schumacher 4/22/02
    
    global g_Debug; if(g_Debug==1),disp('RunJacobi.m');end; 
    
global g_Tasks;

Assignment = zeros(1,NumberOfVehicles);
    LeaveOuts = setdiff(1:1:NumberOfTargets,Index);
    Benefits(:,LeaveOuts) = 0;
    
 DeadVehicles = find(VehicleSchedule(4,2,:) == g_Tasks.Attack);
    LowValueVehicles = [];
 if (Task == g_Tasks.Attack)|(Task == g_Tasks.Verify)
       BestBenefits = max(Benefits,[],2);
       MaxBenefit = max(BestBenefits);
       for i = 1:NumberOfVehicles
          if BestBenefits(i) < .25*MaxBenefit
             LowValueVehicles = [LowValueVehicles i];
          end
       end
    end
    
%  Additions for search task:

Benefits = [Benefits,BenefitsContinueToSearch];           %Mod by Schumacher 4/22/02

if ((NumberOfTargets+NumberOfVehicles) < NumberOfVehicles),
       % The case where there are more vehicles than tasks. Transposes the benefit
       % matrix to assign tasks to vehicles. the jacobi can't handle more rows than columns.
       Benefits =Benefits';
       % Call the auction algorithim to maximize benefit
       if ~isempty(Benefits) 
          [TaskToVehicleAssignment] = JacobiMax(Benefits,NumberOfTargets,NumberOfVehicles);
       end 
       % Decode the task-to-vehicle assignment to vehicle-to-task assignment
       for i = 1:length(TaskToVehicleAssignment)
          Assignment(TaskToVehicleAssignment(i)) = i;
       end 
    else %if length(Index) < NumberOfVehicles
       if ~isempty(Benefits) 
       [Assignment] = JacobiMax(Benefits,NumberOfVehicles,NumberOfTargets+NumberOfVehicles);   %Mod by Schumacher 4/22/02
       end 
    end %if length(Index) < NumberOfVehicles
    
    for i = 1:length(LeaveOuts)
    	Assignment(find(Assignment == LeaveOuts(i))) = 0;
    end

    SearchVehicles = [];     %Mod by Schumacher 4/22/02
  
  for i = 1:NumberOfVehicles               %Mod by Schumacher 4/22/02
      if Assignment(i) > NumberOfTargets       %Mod by Schumacher 4/22/02
          SearchVehicles = [SearchVehicles,i];     %Mod by Schumacher 4/22/02
          Assignment(i) = 0;                       %Mod by Schumacher 4/22/02
      end %if                                      %Mod by Schumacher 4/22/02
  end %for                                         %Mod by Schumacher 4/22/02
  
  
    Assignment(LowValueVehicles) = 0;
    Assignment(DeadVehicles) = 0;
    
    % Decode the Assignment
    VehicleAssigned = find(Assignment);
    VehicleAssignment = Assignment; %(VehicleAssigned) = Index(Assignment(VehicleAssigned));
    
    return
