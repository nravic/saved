//
//	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION IS RELEASED "AS IS." THE
//	U.S.GOVERNMENT MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, CONCERNING
//	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION, INCLUDING, WITHOUT LIMITATION,
//	ANY WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
//	WILL THE U.S. GOVERNMENT BE LIABLE FOR ANY DAMAGES, INCLUDING ANY LOST PROFITS,
//	LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE,
//	OR INABILITY TO USE, THIS SOFTWARE OR ANY ACCOMPANYING DOCUMENTATION, EVEN IF
//	INFORMED IN ADVANCE OF THE POSSIBILITY OF SUCH DAMAGES.
//
// Trajectory.cpp: implementation of the CTrajectory class.
//
////////////////////////////////////


#include "Trajectory.h"

ostream &operator << (ostream &os,const CWaypoint& wayRhs) 
{
        os	<< wayRhs.dGetPositionX() << "\t"
			<< wayRhs.dGetPositionY() << "\t"
			<< wayRhs.dGetPositionZ() << "\t"
			<< wayRhs.dGetMachCommand() << "\t"
			<< wayRhs.bGetMachCommandFlag() << "\t"
			<< wayRhs.dGetSegmentLength() << "\t"
			<< wayRhs.circleGetTurn().dGetPositionX() << "\t"
			<< wayRhs.circleGetTurn().dGetPositionY() << "\t"
			<< (int)wayRhs.circleGetTurn().turnGetTurnDirection() << "\t"
			<< (int)wayRhs.typeGetWaypoint() << "\t"
			<< wayRhs.iGetTargetHandle() << "\t"
			<< wayRhs.bGetResetVehiclePosition() << "\t";
        return os;
    }

////////////////////////////////////
// Construction/Destruction
////////////////////////////////////

CTrajectory::CTrajectory()
{

}

CTrajectory::~CTrajectory()
{

}

double CTrajectory::dMinimumDistance(CVehicle& rVehicle,CTarget& rTarget,BOOL bLengthenPath,enPathType_t pathType,BOOL bGenerateWaypoints)
{

	double dDistanceMinimum = DBL_MAX;
	switch(pathType)
	{
	case pathEuclidean:
		dDistanceMinimum = dMinimumDistanceEuclidean(rVehicle,rTarget,bGenerateWaypoints,bLengthenPath);
		break;
	case pathTurnStraightTurn:
		dDistanceMinimum = dMinimumDistanceTurnStraightTurn(rVehicle,rTarget,bGenerateWaypoints,bLengthenPath);
		break;
	default:
		break;
	};
	return(dDistanceMinimum);
}


double CTrajectory::dMinimumDistanceEuclidean(CVehicle& rVehicle,CTarget& rTarget,BOOL bGenerateWaypoints,BOOL bLengthenPath)
{

	n_enWaypointType_t waytypFinal = waytypeSearch;
	switch(rTarget.typeGetTaskRequired())
	{
	case taskSearch:
		waytypFinal = waytypeSearch;
		break;
	case taskClassify:
		waytypFinal = waytypeClassify;
		break;
	case taskAttack:
		waytypFinal = waytypeAttack;
		break;
	case taskVerify:
		waytypFinal = waytypeVerify;
		break;
	case taskFinished:
		return(0);	// nothing to do for this target
		break;
	default:
		// TODO:: ERROR!!
		return(DBL_MAX);
		break;
	}

	double dAngleRelative_rad;
	double dDistance_ft = rVehicle.dRelativeDistanceAngle2D(rTarget,dAngleRelative_rad);
	double dHeadingFinal_rad = _PI_O_2 - dAngleRelative_rad;

	//////////////////////////////////////////////////////////////////////////////////////
	// lengthen completion times (distance) if necessary
	////////////////////////////////////////////////////////////////////////////////////////
	double dDistanceTotal_ft = dDistance_ft + rVehicle.dGetTimeCurrent();
	if((bLengthenPath)&&(dDistanceTotal_ft < rTarget.dGetTimePrerequisite()))
	{
		dDistance_ft = rTarget.dGetTimePrerequisite() - rVehicle.dGetTimeCurrent() + 1.0; 
		// add an extra foot so all tasks do not happen at same time 
	}

	rVehicle.vwayGetWaypoints().push_back(CWaypoint(
									rTarget,
									n_dMachDefault,TRUE,dDistance_ft,DBL_MAX,DBL_MAX,DBL_MAX,turnNone,
									waytypFinal,rTarget.iGetID(),FALSE));
	rVehicle.vwayGetWaypoints().back().SetPositionZ(rVehicle.dGetPositionZ());
	rVehicle.SetNumberAssignments(rVehicle.iGetNumberAssignments()+1);
	rVehicle.SetHeadingFinal(dHeadingFinal_rad);	// this should only be used if non-Euclidean paths are subsequentially used
	return(dDistance_ft);
}


double CTrajectory::dMinimumDistanceTurnStraightTurn(CVehicle& rVehicle,CTarget& rTarget,BOOL bGenerateWaypoints,BOOL bLengthenPath)
{
	// - decide on desired heading to target based on target and vehicle state.
	// - decide on sensor stand off based on task
	// - decide on free to turn point based on target state and desired heading to the target.
	// = lengthen path to resolve any conflict with previous task execution time.
	//

	////////////////////////////////////////////////////////////////////////////////////////
	// calculate intial vehicle turn centers
	////////////////////////////////////////////////////////////////////////////////////////
	V_CIRCLE_t vcircleVehicle;
	//first center is the clockwise turn (alpha + Pi/2)
	double dCenter1X_ft = rVehicle.posGetPositionAssignedLast().dGetPositionX() + rVehicle.dGetCommandTurnRadius()*cos(rVehicle.dGetHeadingFinal());
	double dCenter1Y_ft = rVehicle.posGetPositionAssignedLast().dGetPositionY() - rVehicle.dGetCommandTurnRadius()*sin(rVehicle.dGetHeadingFinal());
	vcircleVehicle.push_back(CCircle(dCenter1X_ft,dCenter1Y_ft,rVehicle.dGetCommandTurnRadius(),turnClockwise));
	//second center is the counterclockwise turn (alpha - Pi/2)
	dCenter1X_ft = rVehicle.posGetPositionAssignedLast().dGetPositionX() - rVehicle.dGetCommandTurnRadius()*cos(rVehicle.dGetHeadingFinal());
	dCenter1Y_ft = rVehicle.posGetPositionAssignedLast().dGetPositionY() + rVehicle.dGetCommandTurnRadius()*sin(rVehicle.dGetHeadingFinal());
	vcircleVehicle.push_back(CCircle(dCenter1X_ft,dCenter1Y_ft,rVehicle.dGetCommandTurnRadius(),turnCounterclockwise));


	////////////////////////////////////////////////////////////////////////////////////////
	// initalize parameters
	////////////////////////////////////////////////////////////////////////////////////////
	double dFreeToTurn_ft = 0.0;	// distance from the final point
	double dSensorStandoff_ft = rVehicle.dGetCommandSensorStandOff();
	n_enWaypointType_t waytypFinal = waytypeSearch;
	switch(rTarget.typeGetTaskRequired())
	{
	case taskSearch:
		waytypFinal = waytypeSearch;
		dSensorStandoff_ft = n_dSensorStandOffSearch_ft;
		dFreeToTurn_ft = n_dFreeToTurnSearch_ft;
		break;
	case taskClassify:
		waytypFinal = waytypeClassify;
		dSensorStandoff_ft = (dSensorStandoff_ft>=0)?(dSensorStandoff_ft):(n_dSensorStandOffClassify_ft);
		dFreeToTurn_ft = n_dFreeToTurnClassify_ft;
		break;
	case taskAttack:
		waytypFinal = waytypeAttack;
		dSensorStandoff_ft = (dSensorStandoff_ft>=0)?(dSensorStandoff_ft):(n_dSensorStandOffAttack_ft);
		dFreeToTurn_ft = n_dFreeToTurnAttack_ft;
		CalculateTaskHeading(rVehicle,rTarget,vcircleVehicle);
		break;
	case taskVerify:
		waytypFinal = waytypeVerify;
		dSensorStandoff_ft = (dSensorStandoff_ft>=0)?(dSensorStandoff_ft):(n_dSensorStandOffVerify_ft);
		dFreeToTurn_ft = n_dFreeToTurnVerify_ft;
		CalculateTaskHeading(rVehicle,rTarget,vcircleVehicle);
		break;
	case taskFinished:
		return(0);	// nothing to do for this target
		break;
	default:
		// TODO:: ERROR!!
		return(DBL_MAX);
		break;
	}
	dFreeToTurn_ft = (dFreeToTurn_ft<dSensorStandoff_ft)?(dFreeToTurn_ft):(0.0);

	////////////////////////////////////////////////////////////////////////////////////////
	// find minimum distance path
	////////////////////////////////////////////////////////////////////////////////////////

	if(rTarget.rvdGetHeadingsTo().empty())
	{
		//TODO:: error
		return(DBL_MAX);
	}
	CAssignment assignMinimum;
	double dDistanceTotalMinimum_ft = DBL_MAX;	// defaults to error
	double dDistanceFinalLeg_ft = dSensorStandoff_ft - dFreeToTurn_ft;
	for(V_DOUBLE_CONST_IT_t itHeadingTo=rTarget.rvdGetHeadingsTo().begin();itHeadingTo!=rTarget.rvdGetHeadingsTo().end();itHeadingTo++)
	{
		// - use desired headings from the targets for trajectory generation
		double dHeadingFrom_rad = dNormalizeAngleRad((*itHeadingTo) + _PI,0.0);

		CPosition posStandoff(dSensorStandoff_ft*sin(dHeadingFrom_rad),dSensorStandoff_ft*cos(dHeadingFrom_rad));
		posStandoff += rTarget;
		posStandoff.SetPositionZ(rVehicle.dGetPositionZ());
		for(V_CIRCLE_IT_t itVehicleTurn=vcircleVehicle.begin();itVehicleTurn!=vcircleVehicle.end();itVehicleTurn++)
		{
			for(int iCountSecondTurn=0;iCountSecondTurn<2;iCountSecondTurn++)
			{
				double dMultiplier2X = (iCountSecondTurn==0)?(1.0):(-1.0);
				double dMultiplier2Y = (iCountSecondTurn==0)?(-1.0):(1.0);
				enTurnDirection_t turnDirection2 = (iCountSecondTurn==0)?(turnClockwise):(turnCounterclockwise);
				double dCenter2X_ft = posStandoff.dGetPositionX() + dMultiplier2X*rVehicle.dGetCommandTurnRadius()*cos(*itHeadingTo);
				double dCenter2Y_ft = posStandoff.dGetPositionY() + dMultiplier2Y*rVehicle.dGetCommandTurnRadius()*sin(*itHeadingTo);
				CCircle circleSecond(dCenter2X_ft,dCenter2Y_ft,rVehicle.dGetCommandTurnRadius(),turnDirection2);
				if((itVehicleTurn->turnGetTurnDirection() == circleSecond.turnGetTurnDirection())||
					bCompareDouble(itVehicleTurn->posGetPosition().dRelativeDistance2D(circleSecond.posGetPosition()),
																itVehicleTurn->dGetRadius() + circleSecond.dGetRadius(),enGreaterEqual),1.0e-8)
				{
					CAssignment assignTemp;
					if(szMinimumDistanceCircle(rVehicle.posGetPositionAssignedLast(),posStandoff,*itVehicleTurn,circleSecond,assignTemp))
					{
						//TODO:: ERROR!!!
					} 
					else
					{
						// compare to find minimum distance
						if((assignTemp.dGetDistanceTotal() + dDistanceFinalLeg_ft) < dDistanceTotalMinimum_ft)
						{
							CPosition posTemp(dFreeToTurn_ft*sin(dHeadingFrom_rad),dFreeToTurn_ft*cos(dHeadingFrom_rad),rVehicle.dGetPositionZ());
							posTemp += rTarget;
							assignTemp.vwayGetWaypoints().push_back(CWaypoint(
															posTemp,
															n_dMachDefault,TRUE,dDistanceFinalLeg_ft,DBL_MAX,DBL_MAX,DBL_MAX,turnNone,
															waytypFinal,rTarget.iGetID(),FALSE));
							assignTemp.SetHeadingFinal(*itHeadingTo);
							assignMinimum = assignTemp;
							dDistanceTotalMinimum_ft = assignTemp.dGetDistanceTotal();
						}
					}	//if(szMinimumDistanceCircle(rVehicle.posGetPositionAssignedLast(),posStandoff,*itVehicleTurn,circleSecond,assignTemp);)
				}	//if((itVehicleTurn->turnGetTurnDirection() == circleSecond.turnGetTurnDirection())|| ....
				//check to see if "turn-turn-turn" is possible
				if(itVehicleTurn->turnGetTurnDirection() == circleSecond.turnGetTurnDirection())
				{
					double dXSquared = pow((posStandoff.dGetPositionX() - rVehicle.posGetPositionAssignedLast().dGetPositionX()),2.0);
					double dY = posStandoff.dGetPositionY() - rVehicle.posGetPositionAssignedLast().dGetPositionY();
					double bTurnTurnTurnCheck1 = pow(dXSquared + pow((dY - itVehicleTurn->dGetRadius()),2.0),0.5);
					double bTurnTurnTurnCheck2 = pow(dXSquared + pow(dY + itVehicleTurn->dGetRadius(),2.0),0.5);
					double dDistanceCenters = itVehicleTurn->dRelativeDistance2D(circleSecond);

					if(bCompareDouble(dDistanceCenters,(4.0*itVehicleTurn->dGetRadius()),enLessEqual)&&
						((bTurnTurnTurnCheck1<3.0*itVehicleTurn->dGetRadius())||(bTurnTurnTurnCheck2<3.0*itVehicleTurn->dGetRadius())))
					{
						CAssignment assignTemp;
						if(szMinimumDistanceTurnTurnTurn(rVehicle.posGetPositionAssignedLast(),posStandoff,*itVehicleTurn,circleSecond,assignTemp))
						{
							//TODO:: ERROR!!!
						}
						else
						{
							// compare to find minimum distance
							if(bCompareDouble((assignTemp.dGetDistanceTotal() + dDistanceFinalLeg_ft),dDistanceTotalMinimum_ft,enLess))
							{
								CPosition posTemp(dFreeToTurn_ft*sin(dHeadingFrom_rad),dFreeToTurn_ft*cos(dHeadingFrom_rad),rVehicle.dGetPositionZ());
								posTemp += rTarget;
								assignTemp.vwayGetWaypoints().push_back(CWaypoint(
																posTemp,
																n_dMachDefault,TRUE,dDistanceFinalLeg_ft,DBL_MAX,DBL_MAX,DBL_MAX,turnNone,
																waytypFinal,rTarget.iGetID(),FALSE));
								assignTemp.SetHeadingFinal(*itHeadingTo);
								assignMinimum = assignTemp;
								dDistanceTotalMinimum_ft = assignTemp.dGetDistanceTotal();
							}
						}	//if(szMinimumDistanceTurnTurnTurn(rVehicle.posGetPositionAssignedLast(),posStandoff,*itVehicleTurn,circleSecond,assignTemp))
					}		//if((bTurnTurnTurnCheck1<3.0*itVehicleTurn->dGetRadius())||(bTurnTurnTurnCheck2<3.0*itVehicleTurn->dGetRadius()))
				}	//if(itVehicleTurn->turnGetTurnDirection() == circleSecond.turnGetTurnDirection())
			}	//for(int iCountSecondTurn=0;iCountSecondTurn<2;iCountSecondTurn++)
		}	//for(int iCountFirstTurn=0;iCountFirstTurn<2;iCountFirstTurn++)
	}

	double dCurrentTimeNew_ft = assignMinimum.dGetDistanceTotal();
	if(dCurrentTimeNew_ft == DBL_MAX)
	{
		//TODO:: error
		return(DBL_MAX);
	}

	////////////////////////////////////////////////////////////////////////////////////////
	// resolve any conflicts in task completion times (distances)
	////////////////////////////////////////////////////////////////////////////////////////
	double dCompletionTimeAdjustment= 0.0;	// need to adjust the task completion time based on the task 
	switch(rTarget.typeGetTaskRequired())
	{
	case taskVerify:
		dCompletionTimeAdjustment = dFreeToTurn_ft - dSensorStandoff_ft;
		break;
	case taskClassify:
	case taskAttack:
	case taskFinished:
	default:
		break;
	}
	dCurrentTimeNew_ft += rVehicle.dGetTimeCurrent() + dCompletionTimeAdjustment;
	if(dCurrentTimeNew_ft < rTarget.dGetTimePrerequisite())
	{
		if(bLengthenPath)
		{
#ifdef STEVETEST
			double dDesiredDistance = rTarget.dGetTimePrerequisite() - rVehicle.dGetTimeCurrent();
#else	//#ifndef STEVETEST
			double dDesiredDistance = rTarget.dGetTimePrerequisite() - (rVehicle.dGetTimeCurrent() + dCompletionTimeAdjustment);
#endif	//#ifndef STEVETEST
			dCurrentTimeNew_ft = dLengthenPath(rVehicle,rTarget,dDesiredDistance,assignMinimum);
		}
		else
		{
			//TODO:: need to do something when path is not being lengthened
			return(DBL_MAX);	// don't want to update the assignment
		}
	}
	// update vehicle assignment
	rVehicle += assignMinimum;
	return(rVehicle.dGetTimeCurrent());
}

size_t CTrajectory::szMinimumDistanceCircle(CPosition posBegin,CPosition posEnd,
										CCircle& circleFirst,CCircle& circleSecond,CAssignment& rassignAssignment)
{

	//%  Probably ought to set these tolerances in the global defaults m-file
	double dAngleTol = 0.005;	//% If tangent point within angular tolerance to given point, use given point instead
	double dPositionTol = 0.01;	//% if turn circles centers are close together then consider them the same

	double dMinDistance = DBL_MAX;	//%defaults to error condition

	double dTheta_rad;
	double dDistCircleCenters = iRound(circleSecond.posGetPosition().dRelativeDistanceAngle2D(circleFirst.posGetPosition(),dTheta_rad));
	
	if(fabs(dDistCircleCenters) <= dPositionTol)
	{
		circleFirst.posGetPosition() = circleSecond.posGetPosition();
		dDistCircleCenters = 0.0;
		dTheta_rad = 0.0;
	}
	posBegin.TransformPoint2D(circleFirst.posGetPosition(),dTheta_rad);
	CPosition posEndSave = posEnd;
	posEnd.TransformPoint2D(circleFirst.posGetPosition(),dTheta_rad);
	CPosition posSecondCenter = circleSecond.posGetPosition();
	posSecondCenter.TransformPoint2D(circleFirst.posGetPosition(),dTheta_rad);

	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//% find out if this should be a direct tangent or a transverse tanget
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	BOOL bOnlyDirectTangents = FALSE;
	if(dDistCircleCenters < iRound(circleFirst.dGetRadius() + circleSecond.dGetRadius()))
	{
	   bOnlyDirectTangents = TRUE;	//%only direct tangents are possible
	   if((circleFirst.turnGetTurnDirection() != circleSecond.turnGetTurnDirection())||
			((circleFirst.turnGetTurnDirection() == turnNone) || (circleSecond.turnGetTurnDirection() == turnNone))
			)
	   {
		   //TODO::ERROR (also do i need to check for 0 directions????
		  return(errorWrongDirectionsForTangent);
	   }
	}
	//%vehicle orienintation with initial circle
	double dAlpha = dNormalizeAngleRad(atan2(posBegin.dGetPositionY(),posBegin.dGetPositionX()),0.0);

	//%desired final orientation angle
	double dBeta = dNormalizeAngleRad(atan2((posEnd.dGetPositionY()-posSecondCenter.dGetPositionY()),(posEnd.dGetPositionX()-posSecondCenter.dGetPositionX())),0.0);

	CPosition posTranversePoint1(0.0,0.0);
	CPosition posTranversePoint2(0.0,0.0);
	double dAlphaStar = 0.0;
	double dBetaStar = 0.0;

	//% AlphaStar is the angle of the tangent point on the initial turn circle
	if (circleFirst.turnGetTurnDirection() == circleSecond.turnGetTurnDirection())
	{
	   //%use direct tangets
   		if (circleSecond.turnGetTurnDirection() == turnCounterclockwise)
		{
			//%bottom direct
			dAlphaStar = 1.5*_PI;
			dBetaStar = 1.5*_PI;
			posTranversePoint1.SetPosition(0.0, -circleFirst.dGetRadius());
			posTranversePoint2.SetPosition(dDistCircleCenters, -circleSecond.dGetRadius());
		}
   		else
		{
			//%top direct
			posTranversePoint1.SetPosition(0.0,circleFirst.dGetRadius());
			posTranversePoint2.SetPosition(dDistCircleCenters,circleSecond.dGetRadius());
			dAlphaStar = 0.5*_PI;
			dBetaStar = 0.5*_PI;
		}
	}
	else	//if (circleFirst.turnGetTurnDirection() == circleSecond.turnGetTurnDirection())
	{
		//%use indirect tangets
		dAlphaStar = dNormalizeAngleRad(acos(2.0*circleFirst.dGetRadius()/dDistCircleCenters),0.0);

#ifdef STEVETEST	//I don't think this is needed here
		//%Prevent going around too much of a circle
		double dAlphaDist = fabs(dAlphaStar - dAlpha);
		if ((dAlphaDist < dAngleTol) || (fabs(dAlphaDist - _2PI) < dAngleTol))
		{
			dAlphaStar = dAlpha;
		}
#endif	//STEVETEST

		double dTangetX = circleFirst.dGetRadius() * cos(dAlphaStar);
		double dTangetY = circleFirst.dGetRadius() * sin(dAlphaStar);

		if (circleSecond.turnGetTurnDirection() == turnCounterclockwise)
		{
		  //%top (negative slope) transverse
			posTranversePoint1.SetPosition(dTangetX,dTangetY);
			posTranversePoint2.SetPosition(dDistCircleCenters-dTangetX,-dTangetY);
		}
		else
		{
		  //%bottom (positive slope) transverse
			posTranversePoint1.SetPosition(dTangetX,-dTangetY);
			posTranversePoint2.SetPosition(dDistCircleCenters-dTangetX,dTangetY);
			dAlphaStar = dNormalizeAngleRad(_2PI - dAlphaStar,0.0);
		}
		dBetaStar = dNormalizeAngleRad(dAlphaStar + _PI,0.0);
	}	//if (circleFirst.turnGetTurnDirection() == circleSecond.turnGetTurnDirection())


	//%Prevent going around too much of a circle
	double dAlphaDist = fabs(dAlphaStar - dAlpha);
	if ((dAlphaDist < dAngleTol) || (fabs(dAlphaDist - _2PI) < dAngleTol))
	{
		dAlphaStar = dAlpha;
	}
	double dBetaDist = fabs(dBetaStar - dBeta);
	if ((dBetaDist < dAngleTol) || (fabs(dBetaDist - _2PI) < dAngleTol))
	{
		dBetaStar = dBeta;
	}


	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//%% Distance calculation
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	// first turn
	double dDistance1 = 0.0;
	double dTurnRadius = circleFirst.dGetRadius();
	double dAngle01 = 0.0;
	if (circleFirst.turnGetTurnDirection() == turnClockwise)
	{
		if(dAlpha >= dAlphaStar)
		{
			dAngle01 = dAlpha - dAlphaStar;
		}
		else
		{
			dAngle01 = dAlpha +(_2PI - dAlphaStar);
		}
	}
	else	//(circleFirst.turnGetTurnDirection() == turnCounterclockwise)
	{
		if(dAlpha <= dAlphaStar)
		{
			dAngle01 = dAlphaStar - dAlpha;
		}
		else
		{
			dAngle01 = (_2PI - dAlpha) + dAlphaStar;
		}
	}	//(circleFirst.turnGetTurnDirection() == turnCounterclockwise)
	dDistance1 = dAngle01*dTurnRadius;

	// straight segement
	double dDistance2 = posTranversePoint2.dRelativeDistance2D(posTranversePoint1);

	// second turn
	double dDistance3 = 0.0;
	double dAngle02 = 0.0;
	dTurnRadius = circleSecond.dGetRadius();
	if (circleSecond.turnGetTurnDirection() == turnClockwise)
	{
		if(dBetaStar >= dBeta)
		{
			dAngle02 = dBetaStar - dBeta;
		}
		else
		{
			dAngle02 = dBetaStar + (_2PI - dBeta);
		}
	}
	else		//if (circleSecond.turnGetTurnDirection() == turnCounterclockwise)
	{
		if(dBetaStar <= dBeta)
		{
			dAngle02 =  dBeta - dBetaStar;
		}
		else
		{
			dAngle02 = (_2PI - dBetaStar) + dBeta;
		}
	}	//if (circleSecond.turnGetTurnDirection() == turnCounterclockwise)
	dDistance3 = dAngle02*dTurnRadius;

	dMinDistance = dDistance1 + dDistance2 + dDistance3; 


	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//%% transform waypoints back to original coordinate frame
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	posTranversePoint1.ReTransformPoint2D(circleFirst.posGetPosition(),dTheta_rad);
	posTranversePoint2.ReTransformPoint2D(circleFirst.posGetPosition(),dTheta_rad);

	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//%% add final waypoints to the vector for return
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	V_WAYPOINT_t& rvwayWaypoint = rassignAssignment.vwayGetWaypoints();
	rvwayWaypoint.push_back
		(
				CWaypoint
				(
					posTranversePoint1.dGetPositionX(),posTranversePoint1.dGetPositionY(),posBegin.dGetPositionZ(),
					n_dMachDefault,TRUE,
					dDistance1,
					circleFirst.dGetPositionX(),circleFirst.dGetPositionY(),dTurnRadius,circleFirst.turnGetTurnDirection()
				)
		);
	rvwayWaypoint.push_back
		(
				CWaypoint
				(
					posTranversePoint2.dGetPositionX(),posTranversePoint2.dGetPositionY(),posBegin.dGetPositionZ(),
					n_dMachDefault,TRUE,
					dDistance2,
					DBL_MAX,DBL_MAX,DBL_MAX,turnNone
				)
		);
	rvwayWaypoint.push_back
		(
				CWaypoint
				(
					posEndSave,
					n_dMachDefault,TRUE,
					dDistance3,
					circleSecond.dGetPositionX(),circleSecond.dGetPositionY(),dTurnRadius,circleSecond.turnGetTurnDirection()
				)
		);
	rassignAssignment.SetNumberAssignments(1);
	return(errorNone);
}


size_t CTrajectory::szMinimumDistanceTurnTurnTurn(CPosition posBegin,CPosition posEnd,
						CCircle& circleFirst,CCircle& circleSecond,CAssignment& rassignAssignment)
{

	double dTurnRadius = circleFirst.dGetRadius();
	double dDistanceCenters = circleFirst.dRelativeDistance2D(circleSecond);

	double dGama = acos(dDistanceCenters/(4.0*dTurnRadius));

	double dDistanceA = DBL_MAX;	//%defaults to error condition
	double dDistanceB = (_PI + (2.0*dGama))*dTurnRadius;
	double dDistanceC = DBL_MAX;	//%defaults to error condition


	//%  Probably ought to set these tolerances in the global defaults m-file
	double dAngleTol = 0.005;	//% If tangent point within angular tolerance to given point, use given point instead
	double dPositionTol = 0.01;	//% if turn circles centers are close together then consider them the same

	double dTheta_rad = 0.0;
	double dDistCircleCenters = circleSecond.posGetPosition().dRelativeDistanceAngle2D(circleFirst.posGetPosition(),dTheta_rad);
	
	if(fabs(dDistCircleCenters) <= dPositionTol)
	{
		circleFirst.posGetPosition() = circleSecond.posGetPosition();
		dDistCircleCenters = 0.0;
		dTheta_rad = 0.0;
	}
	posBegin.TransformPoint2D(circleFirst.posGetPosition(),dTheta_rad);
	CPosition posEndSave = posEnd;
	posEnd.TransformPoint2D(circleFirst.posGetPosition(),dTheta_rad);
	CPosition posSecondCenter = circleSecond.posGetPosition();
	posSecondCenter.TransformPoint2D(circleFirst.posGetPosition(),dTheta_rad);


	//%vehicle orienintation with initial circle
	double dAlpha = dNormalizeAngleRad(atan2(posBegin.dGetPositionY(),posBegin.dGetPositionX()),0.0);
	//%desired final orientation angle
	double dBeta = dNormalizeAngleRad(atan2((posEnd.dGetPositionY()-posSecondCenter.dGetPositionY()),(posEnd.dGetPositionX()-posSecondCenter.dGetPositionX())),0.0);

	// calculate waypoint positions
	CPosition posTangentPoint1(cos(dGama),sin(dGama));
	posTangentPoint1 *= dTurnRadius;

	CPosition posTangentPoint2(-cos(dGama),sin(dGama));
	posTangentPoint2 *= dTurnRadius;
	posTangentPoint2 += posSecondCenter;

	CPosition posTurnCenter(cos(dGama),sin(dGama));
	posTurnCenter *= 2.0*dTurnRadius;

	// move center of second turn down if clockwize
	if (circleFirst.turnGetTurnDirection() == turnClockwise)
	{
		posTangentPoint1.dGetPositionY() *= -1;
		posTangentPoint2.dGetPositionY() *= -1;
		posTurnCenter.dGetPositionY() *= -1;
	}


	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//%% Distance calculation
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if (circleFirst.turnGetTurnDirection() == turnCounterclockwise)
	{
		dDistanceA = (dAlpha<=dGama)?((dGama-dAlpha)*dTurnRadius):
											((_2PI+dGama-dAlpha)*dTurnRadius);
		dDistanceC = (dBeta<=(_PI-dGama))?((_PI+dBeta+dGama)*dTurnRadius):
											((dBeta+dGama-_PI)*dTurnRadius);
	}
	else	//(circleFirst.turnGetTurnDirection() == turnCounterclockwise)
	{
		dDistanceA = (dAlpha<=(_2PI-dGama))?((dGama+dAlpha)*dTurnRadius):
											((dGama+dAlpha-_2PI)*dTurnRadius);
		dDistanceC = (dBeta<=(_PI+dGama))?((_PI+dGama-dBeta)*dTurnRadius):
											((3.0*_PI+dGama-dBeta)*dTurnRadius);
	}	//(circleFirst.turnGetTurnDirection() == turnCounterclockwise)

	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//%% transform waypoints back to original coordinate frame
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	posTangentPoint1.ReTransformPoint2D(circleFirst.posGetPosition(),dTheta_rad);
	posTangentPoint2.ReTransformPoint2D(circleFirst.posGetPosition(),dTheta_rad);
	posTurnCenter.ReTransformPoint2D(circleFirst.posGetPosition(),dTheta_rad);
	enTurnDirection_t turnDirection = (circleFirst.turnGetTurnDirection()==turnCounterclockwise)?(turnClockwise):(turnCounterclockwise);

	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//%% add final waypoints to the vector for return
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	V_WAYPOINT_t& rvwayWaypoint = rassignAssignment.vwayGetWaypoints();
	rvwayWaypoint.push_back
		(
				CWaypoint
				(
					posTangentPoint1.dGetPositionX(),posTangentPoint1.dGetPositionY(),posBegin.dGetPositionZ(),
					n_dMachDefault,TRUE,
					dDistanceA,
					circleFirst.dGetPositionX(),circleFirst.dGetPositionY(),dTurnRadius,circleFirst.turnGetTurnDirection()
				)
		);
	rvwayWaypoint.push_back
		(
				CWaypoint
				(
					posTangentPoint2.dGetPositionX(),posTangentPoint2.dGetPositionY(),posBegin.dGetPositionZ(),
					n_dMachDefault,TRUE,
					dDistanceB,
					posTurnCenter.dGetPositionX(),posTurnCenter.dGetPositionY(),dTurnRadius,turnDirection
				)
		);
	rvwayWaypoint.push_back
		(
				CWaypoint
				(
					posEndSave,
					n_dMachDefault,TRUE,
					dDistanceC,
					circleSecond.dGetPositionX(),circleSecond.dGetPositionY(),dTurnRadius,circleSecond.turnGetTurnDirection()
				)
		);
	rassignAssignment.SetNumberAssignments(1);
	return(errorNone);
}


///////////////////////////////////////////////////
//CalculateTaskHeading
///////////////////////////////////////////////////
void
CTrajectory::CalculateTaskHeading(CVehicle& rVehicle,CTarget& rTarget,V_CIRCLE_t& rvcircleVehicle)
{
	//ASSERT(rvcircleVehicle.size()==2;);
	double dDesiredHeadingTo = 0.0;
	rTarget.rvdGetHeadingsTo().clear();	// ASSUME: that we are calculating all of the angles needed in this function

	//% Get the necessary distances to be used in the heading calculations
	//%  Get the distance from the vehicle to the target
	double dAngleToTarget = 0.0;
	double dDotoF = rVehicle.posGetPositionAssignedLast().dRelativeDistanceAngle2D(rTarget.posGetPosition(),dAngleToTarget);
	vRound(dDotoF,1.0e-9);
	if(bCompareDouble(dDotoF,0.0,enEqual))	//vehicle is on top of the target, return current vehicle heading
	{
		rTarget.rvdGetHeadingsTo().push_back(rVehicle.dGetHeadingFinal());
		return;
	}

	//%  Get the distances from the target to the initial turn circle centers
	double dHc1=0.0;
	double dDc1toF = rvcircleVehicle[0].posGetPosition().dRelativeDistanceAngle2D(rTarget.posGetPosition(),dHc1);
	vRound(dDc1toF,1.0e-9);

	double dHc2=0.0;
	double dDc2toF = rvcircleVehicle[1].posGetPosition().dRelativeDistanceAngle2D(rTarget.posGetPosition(),dHc2);
	vRound(dDc2toF,1.0e-9);

	double dTurnRadius = rVehicle.dGetCommandTurnRadius();
	double dSensorStandoff_ft = rVehicle.dGetCommandSensorStandOff();
	switch(rTarget.typeGetTaskRequired())
	{
	case taskClassify:
		dSensorStandoff_ft = (dSensorStandoff_ft>=0)?(dSensorStandoff_ft):(n_dSensorStandOffClassify_ft);
		break;
	case taskAttack:
		dSensorStandoff_ft = (dSensorStandoff_ft>=0)?(dSensorStandoff_ft):(n_dSensorStandOffAttack_ft);
		break;
	case taskVerify:
		dSensorStandoff_ft = (dSensorStandoff_ft>=0)?(dSensorStandoff_ft):(n_dSensorStandOffVerify_ft);
		break;
	case taskFinished:
		return;	// nothing to do for this target
		break;
	default:
		// TODO:: ERROR!!
		return;
		break;
	}

	//% Calculate the minimum distance between the target and the final turn circle center to ensure the needed standoff distance
	double dRs = pow((pow(dTurnRadius,2.0) + pow(dSensorStandoff_ft,2.0)),0.5);
	vRound(dRs,1.0e-9);
	if(dRs==0.0)
	{
		//TODO::ERROR
		return;
	}
	//% Calculate the headings from the target to the initial turn circle centers - used in heading constructions
	dHc1 = _PI_O_2 - dHc1;
	dHc2 = _PI_O_2 - dHc2;
	//% Calculate the angle between the final vehicle position (at sensor standoff distance) and
	//%  the position of final turn circle's center
	double dSliver = atan2(dTurnRadius,dSensorStandoff_ft);

	//%  Do the geometric constructions of the final vehicle heading depending on the initial position and heading
	//%   of the vehicle with respect to the target (final position)
	if ((dDc1toF < dRs) && (dDc2toF < dRs))
	{
		if ((dDc2toF!=0.0)&&((((dDc1toF+2*dTurnRadius) <= dRs) && (dDc1toF < dTurnRadius)) || (dDc1toF <= dDc2toF)))
		{
			dDesiredHeadingTo = dHc2 - asin(dTurnRadius/dDc2toF) + 2.0*dSliver;
		}
		else if((dDc1toF!=0.0)&&((((dDc2toF + 2.0*dTurnRadius) <= dRs) && (dDc2toF<dTurnRadius)) || (dDc2toF < dDc1toF)))
		{
			dDesiredHeadingTo = dHc1 + asin(dTurnRadius/dDc1toF) + 2*dSliver;
		}
		else
		{
			//TODO::error
		}
	}
	else
	{
		double dAngleDifference = dNormalizeAngleRad((_PI_O_2 - rVehicle.dGetHeadingFinal()) - dAngleToTarget,0.0);
		double dCase = ((dAngleDifference>_PI_O_2)&&(dAngleDifference<_3PI_O_2))?(1.0):(-1.0);
		if (((dDc2toF >= dRs) && (dDc1toF > dDc2toF)) || ((dDc2toF >= dRs) && (dDc1toF < dRs)))
		{
			double dFactor = (dTurnRadius/dDc2toF);
			vRound(dFactor,1.0e-9);
			double dBeta = -asin(dFactor);

			dFactor = (-pow(dTurnRadius,2.0) + pow(dDc2toF,2.0) + pow(dDotoF,2.0))/(2*dDc2toF*dDotoF);
			vRound(dFactor,1.0e-9);
			double dDelta = acos(dFactor);

			//double dDelta = acos((-pow(dTurnRadius,2.0) + pow(dDc2toF,2.0) + pow(dDotoF,2.0))/(2*dDc2toF*dDotoF));
			double dPhi = dBeta + dCase*dDelta;
			dDesiredHeadingTo = _PI_O_2 - (dAngleToTarget - dPhi);
		}
		else
		{
			double dFactor = (dTurnRadius/dDc1toF);
			vRound(dFactor,1.0e-9);
			double dBeta = asin(dFactor);

			dFactor = (-pow(dTurnRadius,2.0) + pow(dDc1toF,2.0) + pow(dDotoF,2.0))/(2*dDc1toF*dDotoF);
			vRound(dFactor,1.0e-9);
			double dDelta = acos(dFactor);

			double dPhi = dBeta - dCase*dDelta;
			dDesiredHeadingTo = _PI_O_2 - (dAngleToTarget - dPhi);
		}
	}

	dDesiredHeadingTo += _PI;
	dNormalizeAngleRad(dDesiredHeadingTo,0.0);

	rTarget.rvdGetHeadingsTo().push_back(dDesiredHeadingTo);
}
///////////////////////////////////////////////////
///////////////////////////////////////////////////




double CTrajectory::dLengthenPath(CVehicle& rVehicle,CTarget& rTarget,double dDesiredDistance,CAssignment& assignMinimum)
{
	// ASSUMES::
	// "assignMinimum" contains the following waypoints:
	// The first waypoint is at the end of the first turn/beginning of the straight segment
	// The second waypoint is at the end of the straight segment/beginning of the second turn
	// The third waypoint is at the end of the second turn/beginning of the final segment
	// The forth, and final waypoint, is at the end of the final segment
	// 
	enum enAssignedWaypoints_t {assignwayEndFirstTurn,assignwayEndStraight,assignwayEndSecondTurn,assignwayEndFinal};

	//////////////////////////////////////////////////////////////////////////////////
	// ?) find standoff and free to turn distances
	//////////////////////////////////////////////////////////////////////////////////
	double dSensorStandoff_ft = rVehicle.dGetCommandSensorStandOff();
	double dFreeToTurn_ft = n_dFreeToTurnDefault_ft;

	n_enWaypointType_t waytypFinal = waytypeSearch;
	switch(rTarget.typeGetTaskRequired())
	{
	case taskAttack:
		waytypFinal = waytypeAttack;
		dSensorStandoff_ft = (dSensorStandoff_ft>=0)?(dSensorStandoff_ft):(n_dSensorStandOffAttack_ft);
		dFreeToTurn_ft = n_dFreeToTurnAttack_ft;
		break;
	case taskVerify:
		waytypFinal = waytypeVerify;
		dSensorStandoff_ft = (dSensorStandoff_ft>=0)?(dSensorStandoff_ft):(n_dSensorStandOffVerify_ft);
		dFreeToTurn_ft = n_dFreeToTurnVerify_ft;
		break;
	case taskFinished:
		return(0);	// nothing to do for this target
		break;
	case taskClassify:
	default:
		// TODO:: ERROR!!
		//disp('ERROR - The LengthenPath function is being called for a task other than verify or attack');
		return(DBL_MAX);
		break;
	}
	dFreeToTurn_ft = (dFreeToTurn_ft<dSensorStandoff_ft)?(dFreeToTurn_ft):(0.0);

	//////////////////////////////////////////////////////////////////////////////////
	// ?) calculate radius, center, and direction of loiter path (circle)
	//////////////////////////////////////////////////////////////////////////////////
	double dRadiusTurnCenter_ft = sqrt((pow(dSensorStandoff_ft,2.0) + pow(rVehicle.dGetCommandTurnRadius(),2.0)));
	double dRadiusLoiter_ft = dRadiusTurnCenter_ft + rVehicle.dGetCommandTurnRadius();
	double dRadiusTurnOnToLoiterMin_ft = dRadiusLoiter_ft + rVehicle.dGetCommandTurnRadius();

	//////////////////////////////////////////////////////////////////////////////////
	// ?) calculate final leg distance
	//////////////////////////////////////////////////////////////////////////////////
	double dAngleStandOffRelative_rad = atan(rVehicle.dGetCommandTurnRadius()/dSensorStandoff_ft);
	double dDistanceFinalLeg_ft = rVehicle.dGetCommandTurnRadius()*(_PI - (_PI_O_2 - dAngleStandOffRelative_rad)) + dSensorStandoff_ft - dFreeToTurn_ft;

	//////////////////////////////////////////////////////////////////////////////////
	// ?) determine case 
	//////////////////////////////////////////////////////////////////////////////////
	enTurnDirection_t turndirLoiterDirection = turnNone;
	double dAngleLoiterEntryToTarget_rad = DBL_MAX;
	double dDistanceInitialLeg_ft = 0.0;
	double dDistanceFirstTangetToTarget = assignMinimum.wayGetWaypoint(assignwayEndFirstTurn).dRelativeDistance2D(rTarget);
	if(dDistanceFirstTangetToTarget >= dRadiusTurnOnToLoiterMin_ft)	//????????????
	{
		//caseOne;
		// case1: outside the required radius. find circle to turn on to loiter circle
		//1. find tangent point to loiter circle
		//2. calculate distance from vehicle to tangent point, first waypoint distance + distance from end of first turn to loiter entry point
		//3. calculate loiter distance required: LoiterDistance = DistanceRequired - (DistanceVehicleToLoiter + DistanceLoiterToFinal)
		//4. remove unused waypoints from the "assignMinimum" waypoints
		//5. calculate new waypoints and pop them onto the "assignMinimum" waypoints
		//6. update final heading, i.e. assignMinimum.SetHeadingFinal(??)

		turndirLoiterDirection = turnCounterclockwise;
		
		double dAngleEndFirstTurnToTarget = assignMinimum.wayGetWaypoint(assignwayEndFirstTurn).dRelativeAngle2D(rTarget);
		// the following angle calculation assumes a clockwise turn onto the loiter circle
		dAngleLoiterEntryToTarget_rad = dAngleEndFirstTurnToTarget + asin(rVehicle.dGetCommandTurnRadius()/dRadiusTurnOnToLoiterMin_ft);
		double dRadiusLoiterTurnPoint = sqrt(pow(dRadiusTurnOnToLoiterMin_ft,2.0) - pow(rVehicle.dGetCommandTurnRadius(),2.0));

		assignMinimum.EraseWaypoints(assignwayEndStraight);

		CPosition posTemp(dRadiusLoiterTurnPoint*cos(dAngleEndFirstTurnToTarget),
									dRadiusLoiterTurnPoint*sin(dAngleEndFirstTurnToTarget),rVehicle.dGetPositionZ());
		posTemp += rTarget;
		double dDistanceEndFirstTurnToTurnLoiter = assignMinimum.wayGetWaypoint(assignwayEndFirstTurn).
																					dRelativeDistance2D(posTemp);
		assignMinimum.vwayGetWaypoints().push_back(CWaypoint(posTemp,n_dMachDefault,TRUE,
																dDistanceEndFirstTurnToTurnLoiter)
																);

		double dDistanceTurnToLoiter = rVehicle.dGetCommandTurnRadius()*acos(rVehicle.dGetCommandTurnRadius()/dRadiusTurnOnToLoiterMin_ft);
		posTemp.SetPosition(dRadiusLoiter_ft*cos(dAngleLoiterEntryToTarget_rad),
							dRadiusLoiter_ft*sin(dAngleLoiterEntryToTarget_rad),rVehicle.dGetPositionZ());
		posTemp += rTarget;
		assignMinimum.vwayGetWaypoints().push_back(CWaypoint(posTemp,n_dMachDefault,TRUE,
																dDistanceTurnToLoiter,
																dRadiusTurnOnToLoiterMin_ft*cos(dAngleLoiterEntryToTarget_rad) + rTarget.dGetPositionX(),
																dRadiusTurnOnToLoiterMin_ft*sin(dAngleLoiterEntryToTarget_rad) + rTarget.dGetPositionY(),
																rVehicle.dGetCommandTurnRadius(),
																(turndirLoiterDirection==turnClockwise)?(turnCounterclockwise):(turnClockwise))
																);


		dDistanceInitialLeg_ft = assignMinimum.wayGetWaypoint(assignwayEndFirstTurn).dGetSegmentLength() + 
														dDistanceEndFirstTurnToTurnLoiter + dDistanceTurnToLoiter;
	}
	else
	{
		//caseTwo;
		// case2: path has a tangent to the loiter circle, find it 
		//1. find tangent point to loiter circle
		//2. calculate distance from vehicle to tangent point, first waypoint distance + distance from end of first turn to loiter entry point
		//3. calculate loiter distance required: LoiterDistance = DistanceRequired - (DistanceVehicleToLoiter + DistanceLoiterToFinal)
		//4. remove unused waypoints from the "assignMinimum" waypoints
		//5. calculate new waypoints and pop them onto the "assignMinimum" waypoints
		//6. update final heading, i.e. assignMinimum.SetHeadingFinal(??)

		dAngleLoiterEntryToTarget_rad = assignMinimum.wayGetWaypoint(assignwayEndSecondTurn).circleGetTurn().dRelativeAngle2D(rTarget);


		CPosition posTemp(dRadiusLoiter_ft*cos(dAngleLoiterEntryToTarget_rad),
									dRadiusLoiter_ft*sin(dAngleLoiterEntryToTarget_rad),rVehicle.dGetPositionZ());
		posTemp += rTarget;
		assignMinimum.wayGetWaypoint(assignwayEndSecondTurn).SetPosition(posTemp);
		double dAngleToLoiter = assignMinimum.wayGetWaypoint(assignwayEndSecondTurn).circleGetTurn().dGetRelativeAngle(
													assignMinimum.wayGetWaypoint(assignwayEndStraight).posGetPosition(),posTemp);
		dAngleToLoiter = dNormalizeAngleRad(dAngleToLoiter,0.0);
		double dDistanceTurnToLoiter = rVehicle.dGetCommandTurnRadius()*dAngleToLoiter;
		assignMinimum.wayGetWaypoint(assignwayEndSecondTurn).SetSegmentLength(dDistanceTurnToLoiter);
		assignMinimum.EraseWaypoints(assignwayEndFinal);

		dDistanceInitialLeg_ft = assignMinimum.wayGetWaypoint(assignwayEndFirstTurn).dGetSegmentLength() +
									assignMinimum.wayGetWaypoint(assignwayEndStraight).dGetSegmentLength() +
									dDistanceTurnToLoiter;

		turndirLoiterDirection = assignMinimum.wayGetWaypoint(assignwayEndSecondTurn).circleGetTurn().turnGetTurnDirection();
	}

	double dDistanceLoiter = dDesiredDistance - (dDistanceInitialLeg_ft + dDistanceFinalLeg_ft);
	dDistanceLoiter = (dDistanceLoiter>0.0)?(dDistanceLoiter):(0.0);

	double dAngleLoiter = turndirLoiterDirection*dDistanceLoiter/dRadiusLoiter_ft;
	double dAngleLoiterIncrement = turndirLoiterDirection*n_dAngleLoiterIncrement_rad;
	
	// add a waypoint evey "n_dAngleLoiterIncrement_rad" radians along the loiter circle
	double dDistanceLoiterSegment = n_dAngleLoiterIncrement_rad*dRadiusLoiter_ft;
	double dAngleLoiterTemp = dAngleLoiterIncrement;
	double dAnglePointIncrement_rad = 0.0;
	while((turndirLoiterDirection!=turnNone)&&(fabs(dAngleLoiterTemp) <= fabs(dAngleLoiter)))
	{
		dAnglePointIncrement_rad = dAngleLoiterTemp + dAngleLoiterEntryToTarget_rad;
		CPosition posTemp(dRadiusLoiter_ft*cos(dAnglePointIncrement_rad),
									dRadiusLoiter_ft*sin(dAnglePointIncrement_rad),
									rVehicle.dGetPositionZ());
		posTemp += rTarget;
		assignMinimum.vwayGetWaypoints().push_back(CWaypoint(posTemp,n_dMachDefault,TRUE,
																dDistanceLoiterSegment,
																rTarget.dGetPositionX(),rTarget.dGetPositionY(),dRadiusLoiter_ft,turndirLoiterDirection)
																);
		dAngleLoiterTemp += dAngleLoiterIncrement;
	}
	// add last waypoint on the loiter trajectory
	double dAnglePointLoiterFinal_rad = dAngleLoiter + dAngleLoiterEntryToTarget_rad;

	CPosition posTemp(dRadiusLoiter_ft*cos(dAnglePointLoiterFinal_rad),
								dRadiusLoiter_ft*sin(dAnglePointLoiterFinal_rad),
								rVehicle.dGetPositionZ());
	posTemp += rTarget;
	assignMinimum.vwayGetWaypoints().push_back(CWaypoint(posTemp,n_dMachDefault,TRUE,
															dRadiusLoiter_ft*fabs(dAngleLoiter-(dAngleLoiterTemp - dAngleLoiterIncrement)),
															rTarget.dGetPositionX(),rTarget.dGetPositionY(),dRadiusLoiter_ft,turndirLoiterDirection)
															);

	double dAngleStandOff_rad = dAnglePointLoiterFinal_rad + (turndirLoiterDirection*dAngleStandOffRelative_rad);

	posTemp.SetPosition(dSensorStandoff_ft*cos(dAngleStandOff_rad),
						dSensorStandoff_ft*sin(dAngleStandOff_rad),
						rVehicle.dGetPositionZ());
	posTemp += rTarget;
	assignMinimum.vwayGetWaypoints().push_back(CWaypoint(posTemp,n_dMachDefault,TRUE,
															rVehicle.dGetCommandTurnRadius()*(_PI - (_PI_O_2 - dAngleStandOffRelative_rad)),
															(dRadiusLoiter_ft - rVehicle.dGetCommandTurnRadius())*cos(dAnglePointLoiterFinal_rad) + rTarget.dGetPositionX(),
															(dRadiusLoiter_ft - rVehicle.dGetCommandTurnRadius())*sin(dAnglePointLoiterFinal_rad) + rTarget.dGetPositionY(),
															rVehicle.dGetCommandTurnRadius(),turndirLoiterDirection)
															);

	posTemp.SetPosition(dFreeToTurn_ft*cos(dAngleStandOff_rad),
						dFreeToTurn_ft*sin(dAngleStandOff_rad),
						rVehicle.dGetPositionZ());
	posTemp += rTarget;
	assignMinimum.vwayGetWaypoints().push_back(CWaypoint(posTemp,n_dMachDefault,TRUE,
										(dSensorStandoff_ft - dFreeToTurn_ft),DBL_MAX,DBL_MAX,DBL_MAX,turnNone,
										waytypFinal,rTarget.iGetID(),FALSE)
										);
	
	assignMinimum.SetHeadingFinal(_PI_O_2 - dAngleStandOff_rad + _PI);

	return(dDistanceInitialLeg_ft + dDistanceLoiter + dDistanceFinalLeg_ft);
	return(dDistanceInitialLeg_ft + dDistanceLoiter + dDistanceFinalLeg_ft);
}


