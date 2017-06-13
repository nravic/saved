# warning, the link TacticalVehicle.mexglx line uses globbing!

RTOP = ../..

include ${RTOP}/make.env
include ${RTOP}/make.opts

LIB_NAME = ${VDYN_GLX}

SRCS = VehicleDynamicsMex.cpp

VEHDYN_DIR = ${RTOP}/${VDYN_DIR_REL}
EUMINXD_DIR = ${RTOP}/${EUMINXD_DIR_REL}
DATCOM_DIR = ${RTOP}/${DATCOM_DIR_REL}

INCLUDES += -I${RTOP}/Includes -I${EUMINXD_DIR} -I${VEHDYN_DIR} -I${DATCOM_DIR} ${MAT_INCS}

LRPATH = -Wl,-rpath=${LIB_DIR_LONG}
LIBS += -L${LIB_DIR_LONG} -ldatcom -leuminxd ${LRPATH} # ${LD_ADD_LSTDCXX}

CXXFLAGS  = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}

LDFLAGS = ${SO_FLAGS} ${LINK_FLAGS} ${LIBS} ${MAT_LIBS} ${MAT_MEX_VER} ${MAT_RPATH}

OBJS = ${SRCS:.cpp=.o} 

default: all

all: ${LIB_NAME}

include ${RTOP}/make.mexver

${OBJS}: Makefile .depend

${LIB_NAME}: ${OBJS} 
	${CXX} ${LDFLAGS} -o $@ ${OBJS} 

clean:
	-rm -f ${OBJS}

clean-mex:
	-rm -f ${LIB_NAME}

clean-all: clean

clobber: clean clean-mex

clobber-all: clobber

fresh: clobber-all default

include ${RTOP}/make.dep

