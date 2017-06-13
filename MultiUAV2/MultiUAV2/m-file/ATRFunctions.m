function [OutputVector] = ATRFunctions(action,InputVector)
%ATRFunctions - calculates single and multiple ATR values and BDA values.
%
%  Inputs:
%    action - The type of function call. Implemented values are:
%      'Combined' - Find the highest combined ATR value for each known target.
%      'Single' - Calculate an ATR value for each target that has been sensed
%         by the current vehicle.
%      'BDA' - Calculate a BDA value for the known targets.
%    InputVector - the data in the InputVector changes based on the value of "action"  
%      action-> 'Combined'
%        InputVector(1) - "VehicleID", identification index of the current vehicle.
%        InputVector(...) - "InputATRTimes", a vector containing the times that the 
%          vehicles calculated the ATR values. size = (g_MaxNumberVehicles)
%        InputVector(...) - "InputATRValues", a matrix containing the ATR values for
%          each vehicle to each target.  size = (g_MaxNumberVehicles,g_MaxNumberTargets)
%        InputVector(...) - "InputATRHeadings", a matrix containing the headings that
%          the vhehicles used to calculate the ATR values.  size = (g_MaxNumberVehicles,g_MaxNumberTargets)
%        InputVector(...) - "InputEstPoseAngles", a matrix containing the target pose
%          angles that were estimated by each vehicle for each target.   size = (g_MaxNumberVehicles,g_MaxNumberTargets)
%      action-> 'Single'
%        InputVector(1) - "ATRSingleTime", time the target was sensed.
%        InputVector(2) - "VehicleID", identification index of the current vehicle.
%        InputVector(3) - "VehicleHeading", the heading the target was sensed from (deg) 
%        InputVector(...) - "SensedTargetVectorNew", a vector of target IDs that are currently in the 
%          sensor footprint, size = (g_MaxNumberTargets)
%        InputVector(...) - "SensedTargetVectorLast", the SensedTargetVectorNew vector from the last 
%          update, size = (g_MaxNumberTargets)
%      action-> 'BDA'
%        InputVector(1) - "VehicleID", identification index of the current vehicle.
%        InputVector(...) - "TargetStatus", is a vector containing the locally maintained status for each of 
%          the targets, size = (g_MaxNumberTargets)
%        InputVector(...) - "SensedTargetVectorNew", a vector of target IDs that are currently in the 
%          sensor footprint, size = (g_MaxNumberTargets)
%        InputVector(...) - "SensedTargetVectorLast", the SensedTargetVectorNew vector from the last 
%          update, size = (g_MaxNumberTargets)
%  Outputs:
%    OutputVector - the data contained in OutputVector changes based on the value of "action"  
%      action-> 'Combined'
%        OutputVector(...) - Combined ATR values for each target (size = g_MaxNumberTargets)
%        OutputVector(...) - vectors of desired headings for subsequent ATR of the targets. Note values 
%          of realmax are used to indicated angles not used. (size = g_MaxNumberDesiredHeadings*(g_MaxNumberTargets))
%        OutputVector(...) - number of valid desired headings for each target
%      action-> 'Single'
%        OutputVector(...) - vector contining single ATR values for all of the targets. (size = g_MaxNumberTargets) 
%        OutputVector(...) - vector contining the sensed heading for all of the targets. (size = g_MaxNumberTargets) 
%        OutputVector(...) - vector contining estimated pose angle for all of the targets. (size = g_MaxNumberTargets) 
%      action-> 'BDA'
%        OutputVector(...) - A BDA value for each target. 0-Not verified, 1-Verified. (size = g_MaxNumberTargets)

%  AFRL/VACA
%  May 2001 - Created and Debugged - RAS
%  Feb 2003 - changed minimum between angles from +/-45 degrees to +/-15 degrees - RAS
%$Id: ATRFunctions.m,v 2.0.10.1.4.2 2004/05/06 12:47:22 rasmussj Exp $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Global Variables  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

global g_Debug; if(g_Debug==1),disp('ATRFunctions.m');end; 

global g_MaxNumberTargets;
global g_MaxNumberVehicles;
global g_MaxNumberDesiredHeadings;
global g_TargetMemory	%truth information
global g_TargetStates;
global g_TargetTypes;
global g_VehicleMemory;
global g_BDAFalseReportPercentage;
global g_ProbabilityID;
global g_CooperativeATR; % addd by Orhan 21 Nov 2002


if (nargin < 1),
	action = 'Undefined';
end;	%if (narg <= 0),


switch (action),
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
	%%%%%%%%%%%%%%%%%%%%%% Calculate Combine ATR Values       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
	
case 'Combined',
	
	NumberOutputs = g_MaxNumberTargets*(1+g_MaxNumberDesiredHeadings);
	OutputVector = zeros(NumberOutputs,1); %defaults all values to 0.0, i.e. new estimates will be positive
	NumberValidDesiredHeadings = -ones(g_MaxNumberTargets,1);
	
	
	[iRow,iCols]=size(InputVector);
	
	iCurrentRow = 1;
	iCurrentVectorSize = 1;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	VehicleID = InputVector(iCurrentRow:iLastRow);
	
	iCurrentRow = iLastRow + 1;
	iLastRow = iRow;
	NumberRows = 1 + g_MaxNumberTargets*4;		% ATRTime, ATRValues, ATRHeadings, EstPoseAngles EstTargetType
	InputMatrix = reshape(InputVector(iCurrentRow:iLastRow),NumberRows,g_MaxNumberVehicles);
	
	iCurrentRow = 1;
	iCurrentVectorSize = 1;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	InputATRTimes = InputMatrix([iCurrentRow:iLastRow],:);
	
	iCurrentRow = iLastRow+1;
	iCurrentVectorSize = g_MaxNumberTargets;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	InputATRValues = InputMatrix([iCurrentRow:iLastRow],:);
	
	iCurrentRow = iLastRow+1;
	iCurrentVectorSize = g_MaxNumberTargets;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	InputATRHeadings = InputMatrix([iCurrentRow:iLastRow],:);
	
	iCurrentRow = iLastRow+1;
	iCurrentVectorSize = g_MaxNumberTargets;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	InputEstPoseAngles = InputMatrix([iCurrentRow:iLastRow],:);
	
	iCurrentRow = iLastRow+1;
	iCurrentVectorSize = g_MaxNumberTargets;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	InputEstTargetTypes = InputMatrix([iCurrentRow:iLastRow],:);
	
	for (CountTargets = 1:g_MaxNumberTargets),
		for (CountVehicles = 1:g_MaxNumberVehicles),
			ATRSingleTime = InputATRTimes(CountVehicles);
			ATRSingleMetric = InputATRValues(CountTargets,CountVehicles);
			ATRSingleViewingAngle = InputATRHeadings(CountTargets,CountVehicles);
			ATRSingleEstPose = InputEstPoseAngles(CountTargets,CountVehicles);
			ATREstTargetType = InputEstTargetTypes(CountTargets,CountVehicles);
			
			NumberSightings = g_VehicleMemory(VehicleID).SensorManager.NumberSightings(CountTargets,CountVehicles);
			if((ATRSingleMetric > 0)&((NumberSightings == 0)|((NumberSightings > 0)&(NumberSightings < g_MaxNumberDesiredHeadings)&...
					(ATRSingleTime ~= g_VehicleMemory(VehicleID).SensorManager.ATRSingleTime(CountTargets,CountVehicles,NumberSightings))))),
				NumberSightings = NumberSightings + 1;
				g_VehicleMemory(VehicleID).SensorManager.NumberSightings(CountTargets,VehicleID) = NumberSightings;
				g_VehicleMemory(VehicleID).SensorManager.ATRSingleTime(CountTargets,CountVehicles,NumberSightings) = ATRSingleTime;
				g_VehicleMemory(VehicleID).SensorManager.ATRSingleMetric(CountTargets,CountVehicles,NumberSightings) = ATRSingleMetric;
				g_VehicleMemory(VehicleID).SensorManager.ATRSingleViewingAngle(CountTargets,CountVehicles,NumberSightings) = ATRSingleViewingAngle;
				g_VehicleMemory(VehicleID).SensorManager.ATRSingleEstPose(CountTargets,CountVehicles,NumberSightings) = ATRSingleEstPose;
				g_VehicleMemory(VehicleID).SensorManager.ATREstTargetType(CountTargets,CountVehicles,NumberSightings) = ATREstTargetType;
				g_VehicleMemory(VehicleID).SensorManager.NumberSightings(CountTargets,CountVehicles) = NumberSightings;
			end;
		end;	%for (CountVehicles = 1:g_MaxNumberVehicles),
	end;	%for (CountTargets = 1:g_MaxNumberTargets),
	
	if(g_CooperativeATR == 1),
		[IndexTarget,IndexVehicle,IndexSighting]=ind2sub([g_MaxNumberTargets,g_MaxNumberVehicles,g_MaxNumberDesiredHeadings], ...
			find(g_VehicleMemory(VehicleID).SensorManager.ATRSingleMetric));
		GoodATRIndicies = [IndexTarget,IndexVehicle,IndexSighting];
		NumberATRs = length(IndexTarget);
	else,	%if(g_CooperativeATR ~= 1),
		[IndexTarget,IndexVehicle,IndexSighting]=ind2sub([g_MaxNumberTargets,g_MaxNumberVehicles,g_MaxNumberDesiredHeadings], ...
			find(g_VehicleMemory(VehicleID).SensorManager.ATRSingleMetric(:,VehicleID,:)));
		GoodATRIndicies = [IndexTarget,IndexVehicle,IndexSighting];
		NumberATRs = size(GoodATRIndicies,1);
	end;	%if(g_CooperativeATR == 1),
	
	if ~isempty(GoodATRIndicies),
		for (CountTarget = 1:g_MaxNumberTargets),
			%find good ATR values for this target
			GoodTargetATRIndicies = ind2sub(NumberATRs,find(GoodATRIndicies(:,1)==CountTarget));
			NumberTargetATRs = size(GoodTargetATRIndicies,1);
			
			if (NumberTargetATRs > 0),
				ProbabilityVector = [];
				PastATRHeadings = [];
				EstTgtTypeVector = [];
				EstPoseVector = [];
				TargetType = 0;
				for (iCount=1:NumberTargetATRs),            %Each ATR in the rows
					for (jCount=1:NumberTargetATRs),        %All the other ATRs in the columns
						iIndexTarget = GoodATRIndicies(GoodTargetATRIndicies(iCount),1);
						iIndexVehicle =  GoodATRIndicies(GoodTargetATRIndicies(iCount),2);
						iIndexSighting =  GoodATRIndicies(GoodTargetATRIndicies(iCount),3);
						ATR1 = g_VehicleMemory(VehicleID).SensorManager.ATRSingleMetric(iIndexTarget,iIndexVehicle,iIndexSighting);
						Heading1 = g_VehicleMemory(VehicleID).SensorManager.ATRSingleViewingAngle(iIndexTarget,iIndexVehicle,iIndexSighting);
						EstTgtType1 = g_VehicleMemory(VehicleID).SensorManager.ATREstTargetType(iIndexTarget,iIndexVehicle,iIndexSighting);
						EstPose1 = g_VehicleMemory(VehicleID).SensorManager.ATRSingleEstPose(iIndexTarget,iIndexVehicle,iIndexSighting);
						
						SameType = 0;        %Flag to indicate if multiple classifications are of the same target type.  Dunkel, 3 Dec 2001
						if(iCount ~= jCount),
							jIndexTarget = GoodATRIndicies(GoodTargetATRIndicies(jCount),1);
							jIndexVehicle =  GoodATRIndicies(GoodTargetATRIndicies(jCount),2);
							jIndexSighting =  GoodATRIndicies(GoodTargetATRIndicies(jCount),3);
							ATR2 = g_VehicleMemory(VehicleID).SensorManager.ATRSingleMetric(jIndexTarget,jIndexVehicle,jIndexSighting);
							Heading2 = g_VehicleMemory(VehicleID).SensorManager.ATRSingleViewingAngle(jIndexTarget,jIndexVehicle,jIndexSighting);
							EstTgtType2 = g_VehicleMemory(VehicleID).SensorManager.ATREstTargetType(jIndexTarget,jIndexVehicle,jIndexSighting);
							EstPose2 = g_VehicleMemory(VehicleID).SensorManager.ATRSingleEstPose(jIndexTarget,jIndexVehicle,jIndexSighting);
							%**** Determine if multiple classifications are of the same target type.  Dunkel, 3 Dec 2001 ************
							if (g_VehicleMemory(VehicleID).SensorManager.ATREstTargetType(iIndexTarget,iIndexVehicle,iIndexSighting) == ...
									g_VehicleMemory(VehicleID).SensorManager.ATREstTargetType(jIndexTarget,jIndexVehicle,jIndexSighting))
								SameType = 1;
							end		
							%*****************************************************************************************************
							%*** If the classifications are of the same type, combine them.  If they are not the same type,    ***
							%*** use the classification with the highest ATR value.  Dunkel, 3 Dec 2001.                       ***
							if SameType == 1
								DeltaThetaRad = Heading1 - Heading2;
								ProbabilityVector = [ProbabilityVector;CalculateCombinedProbability(ATR1, ATR2, DeltaThetaRad)];
								PastATRHeadings = [PastATRHeadings;Heading1];
								PastATRHeadings = [PastATRHeadings;Heading2];
								EstTgtTypeVector = [EstTgtTypeVector;EstTgtType1];
								EstPoseVector = [EstPoseVector;EstPose1];
							else,	%if SameType == 1
								if (ATR1 > ATR2),
									ProbabilityVector = [ProbabilityVector;ATR1];
									PastATRHeadings = [PastATRHeadings;Heading1];
									EstTgtTypeVector = [EstTgtTypeVector;EstTgtType1];
									EstPoseVector = [EstPoseVector;EstPose1];
								else
									ProbabilityVector = [ProbabilityVector;ATR2];
									PastATRHeadings = [PastATRHeadings;Heading2];
									EstTgtTypeVector = [EstTgtTypeVector;EstTgtType2];
									EstPoseVector = [EstPoseVector;EstPose2];
								end
							end %SameType ==1  Dunkel 29 Nov 2001
						else %if (iCount ~= jCount)
							ProbabilityVector = [ProbabilityVector;ATR1];
							PastATRHeadings = [PastATRHeadings;Heading1];
							EstTgtTypeVector = [EstTgtTypeVector;EstTgtType1];
							EstPoseVector = [EstPoseVector;EstPose1];
						end; %if (iCount ~= jCount)
					end;      %for (jCount=1:NumberTargetATRs),
				end;	%for (iCount=1:NumberTargetATRs),
				
				[Probability,Index] = max(ProbabilityVector);
				EstTargetType = EstTgtTypeVector(Index);
				EstTargetPose =  EstPoseVector(Index);
				
				OutputVector(CountTarget) = Probability;
				
				DesiredHeadings = realmax * ones(g_MaxNumberDesiredHeadings,1);
				NumberPastHeadings = length(PastATRHeadings);
				NumberValidDesiredHeadings(CountTarget) = 0;
				if (Probability ~= 0.0),
					AllDesiredHeadings = g_TargetTypes(EstTargetType).BestViewingHeadingsRad + EstTargetPose;
					NumberDesiredHeadings = length(AllDesiredHeadings);
					if(NumberDesiredHeadings > g_MaxNumberDesiredHeadings),
						NumberDesiredHeadings = g_MaxNumberDesiredHeadings;
					end;
					CountDesiredHeadings = 0;
					for(iCountHeadings=1:NumberDesiredHeadings),
						CandidateDesiredHeading = AllDesiredHeadings(iCountHeadings);
						while(CandidateDesiredHeading <=0)
							CandidateDesiredHeading = CandidateDesiredHeading + 2*pi;
						end;
						while(CandidateDesiredHeading >= 2*pi)
							CandidateDesiredHeading = CandidateDesiredHeading - 2*pi;
						end;
						%MinimumDeltaAngleRad = 7.853981633974483e-001;	%exclude angles that are +/-45.0 from previous angles 
						MinimumDeltaAngleRad = 2.617993877991494e-001;	%exclude angles that are +/-15.0 from previous angles 
						GoodHeading = 1;
						for (CountPastHeadings = 1:NumberPastHeadings),
							if(abs(PastATRHeadings(CountPastHeadings) - CandidateDesiredHeading) < MinimumDeltaAngleRad),
								GoodHeading = 0;
								break;
							end;
						end;	%for (CountPastHeadings = 1:NumberPastHeadings),
						if(GoodHeading),
							CountDesiredHeadings = CountDesiredHeadings + 1;
							NumberValidDesiredHeadings(CountTarget) = NumberValidDesiredHeadings(CountTarget) + 1;
							OutputVector(CountTarget+(CountDesiredHeadings*g_MaxNumberTargets)) = CandidateDesiredHeading;
						end;
					end;	%for(iCountHeadings=1:NumberDesiredHeadings),
				end;	%if (Probability ~= 0.0),
			end;	%if (NumberTargetATRs > 0),
		end;	%for (CountTarget = 1:g_MaxNumberTargets),
	end %end isempty(GoodATRIndicies)
	
	OutputVector = [OutputVector;NumberValidDesiredHeadings];
	
	
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
	%%%%%%%%%%%%%%%%%%%%%% Calculate Single ATR Values              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'Single',
	NumberOutputs = g_MaxNumberTargets*4;	% ATRValues(10), ViewAngle, EstPoseAngle, EstTargetType
	OutputVector = zeros(NumberOutputs,1); %defaults all values to 0.0, i.e. new estimates will be positive
	[iRow,iCols]=size(InputVector);
	
	iCurrentRow = 1;
	iCurrentVectorSize = 1;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	ATRSingleTime = InputVector(iCurrentRow:iLastRow);
	
	iCurrentRow = iLastRow + 1;
	iCurrentVectorSize = 1;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	VehicleID = InputVector(iCurrentRow:iLastRow);
	
	iCurrentRow = iLastRow + 1;
	iCurrentVectorSize = 1;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	VehicleHeadingAngleRad = HeadingToAngle(InputVector(iCurrentRow:iLastRow))*pi/180.0;
	
	iCurrentRow = iLastRow + 1;
	iCurrentVectorSize = g_MaxNumberTargets;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	SensedTargetVectorNew = InputVector(iCurrentRow:iLastRow);
	
	iCurrentRow = iLastRow+1;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	SensedTargetVectorLast = InputVector(iCurrentRow:iLastRow);
	
	for (CountTarget = 1:g_MaxNumberTargets),
		ATRMetric = 0.0;
		VehicleHeadingRadOut = realmax;
		EstPoseAngle = realmax;
		EstTgtType = 0;	
		SensedTargetIDNew = SensedTargetVectorNew(CountTarget);
		NumberSightings = g_VehicleMemory(VehicleID).SensorManager.NumberSightings(CountTarget,VehicleID);
		% target must have been in scan last time, and not in scan this time
		% the ATR isn't valid until the sensor footprint leaves the target.
		if((SensedTargetVectorLast(CountTarget) > 0.0)&(SensedTargetIDNew == 0.0)), 
			VehicleHeadingRadOut = VehicleHeadingAngleRad;
			TargetTruth = g_TargetMemory(CountTarget);
			EstPoseAngle = TargetTruth.Psi;
			EstTgtType = ClassifyTarget(TargetTruth.Type,g_ProbabilityID);
			TargetTypestruct = g_TargetTypes(EstTgtType);
			%NOTE: not calculating exact aspect angle to target, leaving out the angle that is defined by the line
			%      between the vehicle and the target, and the vehicle's heading.
			TargetAspectRad = VehicleHeadingAngleRad - TargetTruth.Psi;	%% TODO:: is this suppose to be EstPoseAngle;
			ThetaAspectRad = pi/2.0 - TargetAspectRad;
			while ThetaAspectRad >= 2*pi
				ThetaAspectRad  = ThetaAspectRad  - 2*pi;
			end
			while ThetaAspectRad  < 0
				ThetaAspectRad  = ThetaAspectRad  + 2*pi;
			end
 			ATRMetric = ProbabilityCorrectTarget(ThetaAspectRad,TargetTypestruct.Length,TargetTypestruct.Width);
%			ATRMetric = 1.0;
		elseif (NumberSightings > 0),	%if((SensedTargetVectorLast(CountTarget) > 0.0)&(SensedTargetIDNew == 0.0)),
% 			VehicleHeadingRadOut = VehicleHeadingAngleRad;
% 			ATRMetric = g_VehicleMemory(VehicleID).SensorManager.ATRSingleMetric(CountTarget,VehicleID,NumberSightings);
% 			VehicleHeadingAngleRad = g_VehicleMemory(VehicleID).SensorManager.ATRSingleViewingAngle(CountTarget,VehicleID,NumberSightings);
% 			EstPoseAngle = g_VehicleMemory(VehicleID).SensorManager.ATRSingleEstPose(CountTarget,VehicleID,NumberSightings);
% 			EstTgtType = g_VehicleMemory(VehicleID).SensorManager.ATREstTargetType(CountTarget,VehicleID,NumberSightings);	
		end;	%if((SensedTargetVectorLast(CountTarget) > 0.0)&(SensedTargetIDNew == 0.0)),
		OutputVector(CountTarget) = ATRMetric;
		OutputVector(CountTarget+g_MaxNumberTargets) = VehicleHeadingRadOut;
		OutputVector(CountTarget+g_MaxNumberTargets*2) = EstPoseAngle;
		OutputVector(CountTarget+g_MaxNumberTargets*3) = EstTgtType;
	end;   	%for (CountTarget = 1:g_MaxNumberTargets),
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
	%%%%%%%%%%%%%%%%%%%%%% Calculate BDA Values              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'BDA',
	
	iColumnX = 1;
	iColumnY = 2;
	iColumnZ = 3;
	iColumnType = 4;
	iColumnPsi = 5;
	iColumnAlive = 6;
	SizeTargetVector = 6;
	
	iCurrentRow = 1;
	iCurrentVectorSize = 1;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	VehicleID = InputVector(iCurrentRow:iLastRow);
	if(VehicleID<=0),
		return;
	end;
	
	iCurrentRow = iLastRow+1;
	iCurrentVectorSize = g_MaxNumberTargets;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	TargetStatus = InputVector(iCurrentRow:iLastRow);
	
	iCurrentRow = iLastRow + 1;
	iCurrentVectorSize = g_MaxNumberTargets;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	SensedTargetVectorNew = InputVector(iCurrentRow:iLastRow);
	
	iCurrentRow = iLastRow+1;
	iCurrentVectorSize = g_MaxNumberTargets;
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	SensedTargetVectorLast = InputVector(iCurrentRow:iLastRow);
	
	iCurrentRow = iCurrentRow + iCurrentVectorSize;
	iCurrentVectorSize = g_MaxNumberTargets * SizeTargetVector;	% 6 columns: x y z type alive psi
	iLastRow = iCurrentRow + iCurrentVectorSize - 1;
	TargetVector = InputVector(iCurrentRow:iLastRow);
	TargetMatrix = reshape(TargetVector,SizeTargetVector,g_MaxNumberTargets)';
	
	OutputVector = zeros(g_MaxNumberTargets,1);
	for (CountTarget = 1:g_MaxNumberTargets),
		if(rem(TargetStatus(CountTarget),g_TargetStates.IncAttack) == g_TargetStates.StateKilledNotConfirmed),
			if((SensedTargetVectorLast(CountTarget) ~= 0.0)&(SensedTargetVectorNew(CountTarget) == 0.0)),
				% if a sensor has crossed this target and it was waiting for BDA then run the BDA sensor model.
				if((TargetMatrix(CountTarget,iColumnAlive)==0)),
					%BDA Sensor model
					if(rand > g_BDAFalseReportPercentage),
						OutputVector(CountTarget) = 1;	% report the "truth" state of the target
					else,
						OutputVector(CountTarget) = -1;	% report the "truth" state of the target
					end;
				end;
			end;	%if((SensedTargetVectorLast(CountTarget) ~= 0.0)&(SensedTargetIDNew == 0.0)),
		end;	%if(TargetStatus(CountTarget) == g_TargetStates.StateKilledNotConfirmed),
	end;   	%for (CountTarget = 1:g_MaxNumberTargets),
	
otherwise,
	
end;		%switch (action),   

return;




function [Probability] = CalculateCombinedProbability(ATR1, ATR2, DeltaThetaRad)
%CalculateCombinedProbability - calculates the combined probability of two ATR estimates
%
%  Inputs:
%    ATR1, ATR2 - ATR estimates
%    DeltaTheta - difference between the two viewing angles
%  Outputs:
%    Probability - combined probability of the two ATR estimates
%
DeltaThetaDeg = DeltaThetaRad * 180.0/pi;
Rho = 1 - exp(-0.03*abs(DeltaThetaDeg));
%Pci = ATR1 + ATR2 - (ATR1*ATR2);
%Probability = Pci + (1.0 - Rho)*((ATR1*ATR2)-((ATR1+ATR2)/2.0));
Probability = (ATR1 + ATR2*Rho) - ATR1*ATR2*Rho;
return;

