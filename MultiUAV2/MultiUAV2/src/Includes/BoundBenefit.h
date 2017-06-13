//=========================================================================
// THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION IS RELEASED "AS IS."
// THE U.S.GOVERNMENT MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// CONCERNING THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION, INCLUDING,
// WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A
// PARTICULAR PURPOSE. IN NO EVENT WILL THE U.S. GOVERNMENT BE LIABLE FOR
// ANY DAMAGES, INCLUDING ANY LOST PROFITS, LOST SAVINGS OR OTHER
// INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE, OR
// INABILITY TO USE, THIS SOFTWARE OR ANY ACCOMPANYING DOCUMENTATION, EVEN
// IF INFORMED IN ADVANCE OF THE POSSIBILITY OF SUCH DAMAGES.
//=========================================================================
// 2003/12/10  jwm  To deal with matlab in bounding values in mex/s-funcs
//                    to avoid over/underflow.
//=========================================================================

//=========================================================================
// $Id: BoundBenefit.h,v 2.0 2004/01/22 20:54:52 mitchejw Exp $
// Notes: 
//   - None.
//=========================================================================

#ifndef MATLAB_MEX_INTEGER_BOUNDING_FUNCTIONS
#define MATLAB_MEX_INTEGER_BOUNDING_FUNCTIONS

# ifndef mex_h
#  error "These functions require MEX support!"
# endif

#include <rounding_cast>

int ibound_benefit( const double& dval )
{
#ifdef MATLAB_R12
	static const mxArray* ap_max_benefit = mexGetArrayPtr("g_MaxBenefit", "global");
#else	//#ifdef MATLAB_R12
	static const mxArray* ap_max_benefit = mexGetVariablePtr("global","g_MaxBenefit");
#endif	//#ifdef MATLAB_R12

	if( !ap_max_benefit )
		mexErrMsgTxt("Variable g_MaxBenefit not found!");

	static int max_benefit = rounding_cast<int>(mxGetPr(ap_max_benefit)[0]);

	return( (abs(dval) > max_benefit) ? max_benefit : rounding_cast<int>(dval) );
}

#endif

// Local Variables:
// mode:C++
// End:

