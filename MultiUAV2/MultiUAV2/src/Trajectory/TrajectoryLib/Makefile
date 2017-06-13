RTOP = ../..

include ${RTOP}/make.env
include ${RTOP}/make.opts

LIB_NAME = ${TRAJ_SO}

SRCS = Trajectory.cpp

#DEFINES += 

INCLUDES += -I${RTOP}/Includes

LINK_FLAGS += -Wl,-soname,${LIB_NAME}

CXXFLAGS = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}
LDFLAGS  = ${LINK_FLAGS} ${SO_FLAGS} 

OBJS = ${SRCS:.cpp=.o} 

default: all
	
all:	${LIB_NAME}

${LIB_NAME}: ${OBJS}
	${CXX} ${LDFLAGS} -o $@ ${OBJS}

${OBJS}: Makefile .depend

clean:
	-rm -f ${OBJS}

clobber: clean
	-rm -f ${LIB_NAME}

clobber-all:	clobber

fresh: clobber default

include ${RTOP}/make.dep
