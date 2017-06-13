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
// 2003/12/15  jwm  maximum path length different 'tween Winblows/*NIX
//=========================================================================

#ifndef MAXIMUM_PATH_LENGTH_DISAMBIGULATOR_HEADER
#define MAXIMUM_PATH_LENGTH_DISAMBIGULATOR_HEADER

// take two---they're small.
#include <cstdlib> // for Win32
#include <climits> // for *NIX

namespace 
{
# if defined( _WIN32 )
  const size_t max_path_len = _MAX_PATH;
# else
  const size_t max_path_len = PATH_MAX;
# endif
}

#endif

