//=============================================================================================
// shows memory info via malloc mallinfo() interface.
// (you're outta luck if you're runnin' Winblows)
// $Id: mallinfo.cpp,v 2.0 2004/01/22 20:54:54 mitchejw Exp $
//=============================================================================================
#include <cstdlib>
#include <cstdio>

#include <mallinfo.h>

// these two FILE*s are decl'd in DATCOMTest.cpp above main()

void show_mallinfo( FILE* os, const char* label )
{
	static meminfo_t mem;

	mem = mallinfo();
	fprintf(os, " %s:\n   arena:%d, ordblks:%d, smblks:%d, hblks:%d, hblkhd:%d, usmblks:%d, "
					"fsmblks:%d,\n   uordblks:%d, fordblks:%d, keepcost:%d\n", label, mem.arena, 
					mem.ordblks, mem.smblks, mem.hblks, mem.hblkhd, mem.usmblks, mem.fsmblks, 
					mem.uordblks, mem.fordblks, mem.keepcost);
}

void compare_mallinfo( FILE* os, const meminfo_t mem[], const char* label )
{
	fprintf(os, 
					" ============================================================================\n"
					" %s\n"
					" ----------------------------------------------------------------------------\n"
					"     entry      before       after        diff\n"
					" ----------------------------------------------------------------------------\n"
					"     arena: %10d  %10d  %10d (total space allocated)\n"
					"   ordblks: %10d  %10d  %10d (number of non-inuse chunks)\n"
					"    smblks: %10d  %10d  %10d (unused - always zero)\n"
					"     hblks: %10d  %10d  %10d (number of mmaped regions)\n"
					"    hblkhd: %10d  %10d  %10d (total space in mmapped regions)\n"
					"   usmblks: %10d  %10d  %10d (unused - always zero)\n"
					"   fsmblks: %10d  %10d  %10d (unused - always zero)\n"
					"  uordblks: %10d  %10d  %10d (total allocated space)\n"
					"  fordblks: %10d  %10d  %10d (total non-inuse space)\n"
					"  keepcost: %10d  %10d  %10d (top-most, releasable space)\n"
					" ============================================================================\n"
					" (see malloc.h for struct mallinfo definition)\n", label,
					mem[0].arena,    mem[1].arena,    mem[1].arena-mem[0].arena, 
					mem[0].ordblks,  mem[1].ordblks,  mem[1].ordblks - mem[0].ordblks,
					mem[0].smblks,   mem[1].smblks,   mem[1].smblks - mem[0].smblks, 
					mem[0].hblks,    mem[1].hblks,    mem[1].hblks - mem[0].hblks,
					mem[0].hblkhd,   mem[1].hblkhd,   mem[1].hblkhd - mem[0].hblkhd, 
					mem[0].usmblks,  mem[1].usmblks,  mem[1].usmblks - mem[0].usmblks,
					mem[0].fsmblks,  mem[1].fsmblks,  mem[1].fsmblks - mem[0].fsmblks, 
					mem[0].uordblks, mem[1].uordblks, mem[1].uordblks - mem[0].uordblks,
					mem[0].fordblks, mem[1].fordblks, mem[1].fordblks - mem[0].fordblks, 
					mem[0].keepcost, mem[1].keepcost, mem[1].keepcost - mem[0].keepcost );
}
