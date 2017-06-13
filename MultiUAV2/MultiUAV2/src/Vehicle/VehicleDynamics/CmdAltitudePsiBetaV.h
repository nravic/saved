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
// CmdAltitudePsiBetaV.h: interface for the CCmdAltitudePsiBetaV class.
//
//
///////////////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_CCMDALTITUDEPSIBETAV_H__0974B701_07D4_49CA_8B9D_B4F0679DEC94__INCLUDED_)
#define AFX_CCMDALTITUDEPSIBETAV_H__0974B701_07D4_49CA_8B9D_B4F0679DEC94__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <GlobalDefines.h>	//_PI

#include "Dynamic.h"
#include "InputOutput.h"

namespace
{
	static const double dKGammaPerAltErr = 0.05 *_PI/180.0;//1 degree per 100 ft (Orr)
	static const double dKThetaDotperGammaErr = 5.0;//5 deg per sec per deg (or (rad/sec)/rad) (Orr)
	static const double dKPsiDotperPsiErr = 1.1; //1.1 deg per sec per deg (or (rad/sec)/rad) (Orr)
	static const double dKCosPhiForQGain = 6.5;
	static const double dKPLoop = 2.0;
	static const double dKBetaLoop = -10.0;
	static const double dKVLoop = 1.0;
	static const double dLimitUpperGama_rad = 8.0*_PI/180.0;
	static const double dLimitLowerGama_rad = -15.0*_PI/180.0;
	static const double dLimitUpperTheta_rad = 40.0*_PI/180.0;
	static const double dLimitLowerTheta_rad = -40.0*_PI/180.0;
	static const double dLimitUpperPhi_rad = 120.0*_PI/180.0;
	static const double dLimitLowerPhi_rad = -120.0*_PI/180.0;
	static const double dLimitUpperThrottle_pct = 1.0;
	static const double dLimitLowerThrottle_pct = 0.0;
	static const double dLimitUpperP_radpersec = 40.0*_PI/180.0;
	static const double dLimitLowerP_radpersec = -40.0*_PI/180.0;
	static const double dLimitUpperQ_radpersec = 15.0*_PI/180.0;
	static const double dLimitLowerQ_radpersec = -5.0*_PI/180.0;
	static const double dLimitUpperR_radpersec = 20.0*_PI/180.0;
	static const double dLimitLowerR_radpersec = -20.0*_PI/180.0;
}

template<class STATE_t,class CONTAINER_INPUT_t,class CONTAINER_OUTPUT_t,class VARIABLE_t>
class CCmdAltitudePsiBetaV :
	public CDynamic<CONTAINER_INPUT_t,CONTAINER_OUTPUT_t,VARIABLE_t>   
{
public:
	CCmdAltitudePsiBetaV()	
	{
		vstrGetLabelsInput().clear();
		vstrGetLabelsInput().push_back(string("inCmdPsi_rad"));
		vstrGetLabelsInput().push_back(string("inCmdAltitude_ft"));
		vstrGetLabelsInput().push_back(string("inCmdBeta_rad"));
		vstrGetLabelsInput().push_back(string("inCmdV_ftpersec"));
		vstrGetLabelsInput().push_back(string("inAltitude_ft"));
		vstrGetLabelsInput().push_back(string("inPhi_rad"));
		vstrGetLabelsInput().push_back(string("inTheta_rad"));
		vstrGetLabelsInput().push_back(string("inPsi_rad"));
		vstrGetLabelsInput().push_back(string("inQ_radpersec"));
		vstrGetLabelsInput().push_back(string("inR_radpersec"));
		vstrGetLabelsInput().push_back(string("inAlpha_rad"));
		vstrGetLabelsInput().push_back(string("inBeta_rad"));
		vstrGetLabelsInput().push_back(string("inV_ftpersec"));
		vstrGetLabelsInput().push_back(string("inGama_rad"));
		vstrGetLabelsInput().push_back(string("inZdot_ftpersec"));
		ResizeInputs(vstrGetLabelsInput().size());

		vstrGetLabelsOutput().clear();
		vstrGetLabelsOutput().push_back(string("outCmdP_radpersec"));
		vstrGetLabelsOutput().push_back(string("outCmdQ_radpersec"));
		vstrGetLabelsOutput().push_back(string("outCmdR_radpersec"));
		vstrGetLabelsOutput().push_back(string("outCmdThrottle_pct"));
		vdGetOutputs().resize(vstrGetLabelsOutput().size(),0.0);

		vstrGetLabelsState().clear();
		szGetXSize() = vstrGetLabelsState().size();

		vGetKPLoop() = dKPLoop;
		vGetKBetaLoop() = dKBetaLoop;
		vGetKVLoop() = dKVLoop;
		vGetKGammaPerAltErr() = dKGammaPerAltErr;
		vGetKThetaDotperGammaErr() = dKThetaDotperGammaErr;
		vGetKPsiDotperPsiErr() = dKPsiDotperPsiErr;
		vGetKCosPhiForQGain() = dKCosPhiForQGain;
		
	}


	virtual ~CCmdAltitudePsiBetaV(){};

public:
	enum enInputs 
	{
		inCmdPsi_rad,
		inCmdAltitude_ft,
		inCmdBeta_rad,
		inCmdV_ftpersec,
		inAltitude_ft,
		inPhi_rad,
		inTheta_rad,
		inPsi_rad,
		inQ_radpersec,
		inR_radpersec,
		inAlpha_rad,
		inBeta_rad,
		inV_ftpersec,
		inGama_rad,
		inZdot_ftpersec,
		inputTotal 
	};
	enum enOutputs 
	{
		outCmdP_radpersec,
		outCmdQ_radpersec,
		outCmdR_radpersec,
		outCmdThrottle_pct,
		outputTotal 
	};

public:
	// virtual overrides
	virtual void CalculateXdot(VARIABLE_t* avState, const VARIABLE_t vDeltaTime, VARIABLE_t* avStateDot,BOOL bUpdateOutputs=TRUE){};
	virtual void UpdateOutputs(VARIABLE_t* avState, const VARIABLE_t& vDeltaTime,BOOL bIntermediateStep=FALSE)
	{

		//altitude command loop
		VARIABLE_t vDeltaAltitude = dGetInput(inCmdAltitude_ft) - dGetInput(inAltitude_ft);
		VARIABLE_t MomentaryGammaCmd = vGetKGammaPerAltErr() * vDeltaAltitude;
		vGetSmoothGammaCmd() = ((MomentaryGammaCmd - vGetSmoothGammaCmd())<(-2.5*_DEG_TO_RAD*vDeltaTime)?(vGetSmoothGammaCmd()-(2.5*_DEG_TO_RAD*vDeltaTime)):
							   ((MomentaryGammaCmd - vGetSmoothGammaCmd())>(2.5*_DEG_TO_RAD*vDeltaTime)?(vGetSmoothGammaCmd()+(2.5*_DEG_TO_RAD*vDeltaTime)):MomentaryGammaCmd));
		VARIABLE_t vGamaCmd = vGetSmoothGammaCmd();
		vGamaCmd = dRAS_Limit(vGamaCmd,dLimitUpperGama_rad,dLimitLowerGama_rad);
		VARIABLE_t ThetaDotCmd = vGetKThetaDotperGammaErr()*(vGamaCmd - dGetInput(inGama_rad));
		ThetaDotCmd = (dGetInput(inTheta_rad)>dLimitUpperTheta_rad)?(0.0):
					  ((dGetInput(inTheta_rad)<dLimitLowerTheta_rad)?(0.0):ThetaDotCmd);
		ThetaDotCmd = dRAS_Limit(ThetaDotCmd, 8.0*_DEG_TO_RAD, -8.0*_DEG_TO_RAD);										
										
		//psi command loop
		VARIABLE_t vPsiCmd = dNormalizeAngleRad(dGetInput(inCmdPsi_rad),0.0);
		VARIABLE_t vPsi = dNormalizeAngleRad(dGetInput(inPsi_rad),0.0);
		VARIABLE_t vDifference = vPsiCmd - vPsi;
		vDifference = (fabs(vDifference)<=_PI)?(vDifference):((vDifference>0)?-(_2PI-vPsiCmd+vPsi):(_2PI+vPsiCmd-vPsi));
		VARIABLE_t vPsiDotCmd = vGetKPsiDotperPsiErr() * vDifference;
		vPsiDotCmd = dRAS_Limit(vPsiDotCmd,20.0*_DEG_TO_RAD,-20.0*_DEG_TO_RAD);	
		VARIABLE_t Atan2Arg = (ThetaDotCmd*dGetInput(inV_ftpersec) >= -_GRAVITY_DEFAULT*cos(dGetInput(inTheta_rad)))?1.0:-1.0;
		VARIABLE_t vPhiCmd = atan2(Atan2Arg*(dGetInput(inV_ftpersec)*vPsiDotCmd/(_GRAVITY_DEFAULT*cos(dGetInput(inTheta_rad))+dGetInput(inV_ftpersec)*ThetaDotCmd)),Atan2Arg);
		vPhiCmd = dRAS_Limit(vPhiCmd,dLimitUpperPhi_rad,dLimitLowerPhi_rad);
		vdGetOutputs()[outCmdP_radpersec] = vGetKPLoop()*(vPhiCmd - dGetInput(inPhi_rad));
		
//		vPhiCmd = (fabs(vPhiCmd)<0.1)?(0.0):(vPhiCmd);
//		VARIABLE_t vCurrentPsiDot = (dGetInput(inQ_radpersec)*sin(dGetInput(inPhi_rad)) + dGetInput(inR_radpersec)*cos(dGetInput(inPhi_rad)))/cos(dGetInput(inTheta_rad));
//		VARIABLE_t vCurrentThetaDot = dGetInput(inQ_radpersec)*cos(dGetInput(inPhi_rad)) - dGetInput(inR_radpersec)*sin(dGetInput(inPhi_rad));
		VARIABLE_t vCosPhiForQ = cos(dGetInput(inPhi_rad));
		vCosPhiForQ = (fabs(vCosPhiForQ) > 0.001? vCosPhiForQ: (vCosPhiForQ < 0.0? -0.001:0.001));
		VARIABLE_t vNdesV = dGetInput(inV_ftpersec)*ThetaDotCmd/_GRAVITY_DEFAULT + cos(dGetInput(inTheta_rad)); 
		VARIABLE_t vNdes = vNdesV / vCosPhiForQ;
		vdGetOutputs()[outCmdQ_radpersec] = _GRAVITY_DEFAULT/dGetInput(inV_ftpersec)*(vNdes - cos(dGetInput(inTheta_rad))*cos(dGetInput(inPhi_rad)));
		
		// beta loop
		vdGetOutputs()[outCmdR_radpersec] = vGetKBetaLoop()*(dGetInput(inCmdBeta_rad) - dGetInput(inBeta_rad));

		//throttle command loop
		vdGetOutputs()[outCmdThrottle_pct] = vGetKVLoop()*(dGetInput(inCmdV_ftpersec) - dGetInput(inV_ftpersec));

		// apply limits
		//theta limiter
//		vdGetOutputs()[outCmdQ_radpersec] = (dGetInput(inAlpha_rad)>dLimitUpperAlpha_rad)?(0.0):
//												((dGetInput(inAlpha_rad)<dLimitLowerAlpha_rad)?(0.0):(vdGetOutputs()[outCmdQ_radpersec]));		
		vdGetOutputs()[outCmdQ_radpersec] = (dGetInput(inAlpha_rad)>dLimitUpperAlpha_rad)?(vdGetOutputs()[outCmdQ_radpersec]-1.0*_DEG_TO_RAD):
												((dGetInput(inAlpha_rad)<dLimitLowerAlpha_rad)?(vdGetOutputs()[outCmdQ_radpersec]+1.0*_DEG_TO_RAD):(vdGetOutputs()[outCmdQ_radpersec]));		
		//Pcmd limiter
		vdGetOutputs()[outCmdP_radpersec] = dRAS_Limit(vdGetOutputs()[outCmdP_radpersec],dLimitUpperP_radpersec,dLimitLowerP_radpersec);
		//Qcmd limiter
//		vdGetOutputs()[outCmdQ_radpersec] = dRAS_Limit(vdGetOutputs()[outCmdQ_radpersec],dLimitUpperQ_radpersec,(dLimitLowerQ_radpersec*cos(dGetInput(inPhi_rad))));
		vdGetOutputs()[outCmdQ_radpersec] = dRAS_Limit(vdGetOutputs()[outCmdQ_radpersec],dLimitUpperQ_radpersec,dLimitLowerQ_radpersec);
		//Rcmd limiter
		vdGetOutputs()[outCmdR_radpersec] = dRAS_Limit(vdGetOutputs()[outCmdR_radpersec],dLimitUpperR_radpersec,dLimitLowerR_radpersec);
		//Throttlecmd limiter
		vdGetOutputs()[outCmdThrottle_pct] = dRAS_Limit(vdGetOutputs()[outCmdThrottle_pct],dLimitUpperThrottle_pct,dLimitLowerThrottle_pct);

	};

	virtual BOOL bInitialize(stringstream& sstrErrorMessage)
	{
		ResetOutputs();

		vGetSmoothGammaCmd() = 0.0;

		return(TRUE);	//TODO!!
	};
	virtual void DefaultState(VARIABLE_t* avState){};

public:

	VARIABLE_t& vGetKPLoop(){return(m_dKPLoop);};
	const VARIABLE_t& vGetKPLoop()const{return(m_dKPLoop);};

	VARIABLE_t& vGetKBetaLoop(){return(m_dKBetaLoop);};
	const VARIABLE_t& vGetKBetaLoop()const{return(m_dKBetaLoop);};

	VARIABLE_t& vGetKVLoop(){return(m_dKVLoop);};
	const VARIABLE_t& vGetKVLoop()const{return(m_dKVLoop);};

	VARIABLE_t& vGetKGammaPerAltErr(){return(m_dKGammaPerAltErr);};
	const VARIABLE_t& vGetKGammaPerAltErr()const{return(m_dKGammaPerAltErr);};

	VARIABLE_t& vGetKThetaDotperGammaErr(){return(m_dKThetaDotperGammaErr);};
	const VARIABLE_t& vGetKThetaDotperGammaErr()const{return(m_dKThetaDotperGammaErr);};

	VARIABLE_t& vGetKPsiDotperPsiErr(){return(m_dKPsiDotperPsiErr);};
	const VARIABLE_t& vGetKPsiDotperPsiErr()const{return(m_dKPsiDotperPsiErr);};

	VARIABLE_t& vGetKCosPhiForQGain(){return(m_dKCosPhiForQGain);};
	const VARIABLE_t& vGetKCosPhiForQGain()const{return(m_dKCosPhiForQGain);};

	VARIABLE_t& vGetSmoothGammaCmd(){return(m_dSmoothGammaCmd);};
	const VARIABLE_t& vGetSmoothGammaCmd()const{return(m_dSmoothGammaCmd);};

protected:

	VARIABLE_t m_dKPLoop;
	VARIABLE_t m_dKBetaLoop;
	VARIABLE_t m_dKVLoop;
	VARIABLE_t m_dKGammaPerAltErr;
	VARIABLE_t m_dKThetaDotperGammaErr;
	VARIABLE_t m_dKPsiDotperPsiErr;
	VARIABLE_t m_dKCosPhiForQGain;
	VARIABLE_t m_dSmoothGammaCmd;

};
#endif // !defined(AFX_CCMDALTITUDEPSIBETAV_H__0974B701_07D4_49CA_8B9D_B4F0679DEC94__INCLUDED_)
