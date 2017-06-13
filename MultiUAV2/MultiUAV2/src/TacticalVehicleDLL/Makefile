# warning, the link TacticalVehicle.mexglx line uses globbing!

RTOP = ..

include ${RTOP}/make.env
include ${RTOP}/make.opts

LIB_NAME = ${TACT_GLX}

SRCS = SensorFootprint.cpp WaypointGuidance.cpp TacticalVehicle.cpp \
			 TacticalVehicleDLL.cpp

INCLUDES  += -I. -I${RTOP}/Includes -I${RTOP}/${VDYN_DIR_REL} \
             -I${RTOP}/${DATCOM_DIR_REL} \
             -I${RTOP}/${EUMINXD_DIR_REL} \
						 ${MAT_INCS}

#DEBUG_ADDS = -DJWM_DEBUG -DJWM_DEBUG_ETIME=(0.30)

DEFINES += ${MAT_DEFS} ${DEBUG_ADDS}

LIBS += -ldatcom -leuminxd -Wl,-rpath,${LIB_DIR_LONG} # ${LD_ADD_LSTDCXX} 

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
