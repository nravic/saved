RTOP = ../..

include ${RTOP}/make.env
include ${RTOP}/make.opts

LIB_NAME = ${CTP_SO}

DEFINES += 

LINK_FLAGS += -Wl,-soname,${CTP_SO}

CXXFLAGS = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}
CFLAGS   = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}
LDFLAGS  = ${SO_FLAGS} ${LINK_FLAGS} 

SRCS = CapTransShip.cpp ctp.c

OBJS = ${SRCS:.cpp=.o} 
OBJS := ${OBJS:.c=.o} 

default: all
	
all:	${LIB_NAME}

${LIB_NAME}: ${OBJS}
	${CXX} ${LDFLAGS} -o $@ ${OBJS}

${OBJS}: Makefile .depend

clean:
	-rm -f ${OBJS}

clobber: clean
	-rm -f ${LIB_NAME}

fresh: clobber default

include ${RTOP}/make.dep

