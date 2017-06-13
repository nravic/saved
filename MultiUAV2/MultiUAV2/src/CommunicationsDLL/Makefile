# warning, the link TacticalVehicle.mexglx line uses globbing!

RTOP = ..

include ${RTOP}/make.env
include ${RTOP}/make.opts

LIB_NAME = ${COMMEX_GLX}

SRCS = CommunicationsDLL.cpp

INCLUDES  += -I${RTOP}/Includes ${MAT_INCS}

DEFINES += ${MAT_DEFS}

#LINK_FLAGS += ${LD_ADD_LSTDCXX}

CXXFLAGS  = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}
LDFLAGS = ${SO_FLAGS} ${LINK_FLAGS} ${MAT_LIBS} ${MAT_MEX_VER} ${MAT_RPATH} 

OBJS = ${SRCS:.cpp=.o}

default: all

all: ${LIB_NAME}

include ${RTOP}/make.mexver

${LIB_NAME}: ${OBJS} 
	${CXX} ${LDFLAGS} -o $@ ${OBJS}

${OBJS}: Makefile .depend

clean:
	-rm -f ${OBJS}

clean-mex:
	-rm -f ${LIB_NAME}

clean-all: clean

clobber: clean clean-mex

clobber-all: clobber

fresh: clobber-all default

include ${RTOP}/make.dep
