/*
//	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION IS RELEASED "AS IS." THE
//	U.S.GOVERNMENT MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, CONCERNING
//	THIS SOFTWARE AND ANY ACCOMPANYING DOCUMENTATION, INCLUDING, WITHOUT LIMITATION,
//	ANY WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
//	WILL THE U.S. GOVERNMENT BE LIABLE FOR ANY DAMAGES, INCLUDING ANY LOST PROFITS,
//	LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE,
//	OR INABILITY TO USE, THIS SOFTWARE OR ANY ACCOMPANYING DOCUMENTATION, EVEN IF
//	INFORMED IN ADVANCE OF THE POSSIBILITY OF SUCH DAMAGES.
*/
/****************************************************
 *
 * FILE     : $RCSfile: badvaluec.h,v $
 * AUTHOR   : hennebry
 * DATE     : $Date: 2004/05/06 13:05:28 $
 * REVISION : $Revision: 2.0.8.3 $
 *
 * MODIFICATION HISTORY:-
 *   $Log: badvaluec.h,v $
 *   Revision 2.0.8.3  2004/05/06 13:05:28  rasmussj
 *   Merge corrections from stable that happened after merging RAS-02 into STABLE.
 *
 *   Revision 2.0.18.1  2004/05/06 12:47:32  rasmussj
 *   Merged in Development for inital releaase of 2.0
 *
 *   Revision 2.0.20.1  2004/05/06 12:26:49  rasmussj
 *   Merged RAS-02
 *
 *   Revision 2.0.8.2  2004/05/03 20:38:42  rasmussj
 *   Fixed comments, i.e. C->C++
 *
 *   Revision 2.0.8.1  2004/04/30 16:40:11  rasmussj
 *   Added disclaimer to top of all source files. Removed the Vehicle S-Function directory, it was not working.
 *
 *   Revision 2.0  2004/01/22 20:54:51  mitchejw
 *   Initial checkin of v2-pre0
 *
 *   Revision 1.2  2003/10/23 18:37:58  rasmussj
 *   LINUX/Windows version merged into the head.
 *
 *   Revision 1.1.4.1  2003/10/23 16:51:44  rasmussj
 *   Initial LINUX port. Windows compiled and tested also.
 *
 *   Revision 1.1  2003/09/18 15:47:48  mitchejw
 *   Initial revision
 *
 *   Revision 1.1  2003/07/30 15:30:24  rasmussj
 *   Initial Revision
 *
 *   Revision 1.1  2000/12/29 22:50:45  hennebry
 *   Initial revision
 *
 *
 ****************************************************/

#ifndef BADVALUEC_HH
#define BADVALUEC_HH 1


class BadValueBase {
public:
   BadValueBase(const char *t1, const char *t2) : text1(t1), text2(t2) {}

   const char *text1;
   const char *text2;
} ;
// BadValueBase


template<class T> class BadValueC : public BadValueBase {
public:
   BadValueC(T v, const char *t1, const char *t2=0)
                                 : BadValueBase(t1, t2), value(v) {}

   T value;
} ;
// BadValueC


#endif
