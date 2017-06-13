RTOP = ../../../..

include ${RTOP}/make.env
include ${RTOP}/make.opts

LIB_NAME = ${DATCOM_GLX}

SRCS = DATCOMTableMex.cpp 

DATCOM_LIB = ${DATCOM_SO}

VEHDYN_DIR = ../..
DATCOM_DIR = ..

INCLUDES += ${MAT_INCS} -I${DATCOM_DIR} -I${VEHDYN_DIR} -I${RTOP}/Includes
DEFINES += ${MAT_DEFS} -DJWM_DEBUG

LIBS += -ldatcom -Wl,-rpath=${LIB_DIR_LONG} 

CXXFLAGS  = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}

LDFLAGS = ${SO_FLAGS} ${LINK_FLAGS} ${LIBS} ${MAT_LIBS} \
					${MAT_MEX_VER} ${MAT_RPATH} ${LD_ADD_LSTDCXX}

OBJS = ${SRCS:.cpp=.o}

default: all

all: ${LIB_NAME}

include ${RTOP}/make.mexver

${LIB_NAME}: ${OBJS} Makefile 
	${MAKE} DATCOMLib
	${CXX} ${LDFLAGS} -o $@ ${OBJS} 

DATCOMLib: 
	${MAKE} -C ${DATCOM_DIR} ${DATCOM_LIB}

clean:
	-rm -f ${OBJS} 

clean-mex:
	-rm -f ${LIB_NAME}

clean-all: clean

clobber: clean clean-mex

clobber-all: clobber

fresh: clobber default

include ${RTOP}/make.dep

