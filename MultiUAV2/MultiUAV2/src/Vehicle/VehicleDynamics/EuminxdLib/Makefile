# this guy is just for testing dummy instantiation in SimulationLib.cpp,
# otherwise he just passes through to the DATCOM stuff.

RTOP = ../../..

include ${RTOP}/make.env
include ${RTOP}/make.opts

LIB_NAME=${EUMINXD_SO}

SRCS = Euminxd.cpp

DEFINES += 

INCLUDES += 

LINK_FLAGS += -Wl,-soname,${LIB_NAME}

CXXFLAGS = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}
LDFLAGS  = ${LINK_FLAGS} ${SO_FLAGS} 

OBJS = ${SRCS:.cpp=.o}

default: all

all:	lib
	(cd TestEuminxd && ${MAKE} all)

lib: ${LIB_NAME}

${LIB_NAME}: ${OBJS}
	${CXX} ${LDFLAGS} -o $@ $^

${OBJS}: Makefile .depend

clean:
	-rm -f ${OBJS}

clobber: clean
	-rm -f ${LIB_NAME}

clean-all: clean
	(cd TestEuminxd && ${MAKE} clean-all)

clobber-all: clobber
	(cd TestEuminxd && ${MAKE} clobber-all)

fresh: clobber-all default

depend dep::
	(cd TestEuminxd && ${MAKE} dep)

include ${RTOP}/make.dep

