#include <cstdio>
#include <malloc.h>
typedef struct mallinfo meminfo_t;

void show_mallinfo( std::FILE* os, const char* label );
void compare_mallinfo( std::FILE* os, const meminfo_t mem[], const char* label );
