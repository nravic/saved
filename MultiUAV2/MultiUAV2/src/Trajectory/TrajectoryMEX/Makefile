RTOP = ../..

include ${RTOP}/make.env
include ${RTOP}/make.opts

LIB_NAME = ${TRAJ_GLX}

SRCS = TrajectoryMex.cpp

TRAJ_LIB_DIR = ../TrajectoryLib
TRAJ_LIB = ${TRAJ_LIB_DIR}/${TRAJ_SO}

DEFINES += -DNDEBUG
INCLUDES += -I${RTOP}/Includes -I${TRAJ_LIB_DIR} ${MAT_INCS}

LINK_FLAGS += -ltraj -Wl,-rpath,${LIB_DIR_LONG} ${LD_ADD_LSTDCXX}

CXXFLAGS = ${DEFINES} ${INCLUDES}
LDFLAGS  = ${LINK_FLAGS} ${SO_FLAGS} ${MAT_LIBS} ${MAT_MEX_VER} ${MAT_RPATH}

OBJS = ${SRCS:.cpp=.o}

default: all

all: ${LIB_NAME}

include ${RTOP}/make.mexver

${LIB_NAME}: ${OBJS} ${TRAJ_SO}
	${CXX} ${LDFLAGS} -o $@ ${OBJS}

${OBJS}: Makefile .depend

${TRAJ_SO}:
	(cd ${TRAJ_LIB_DIR} && ${MAKE})

TrajectoryLibFresh:
	@echo "Forcing fresh remake of TrajectoryLib..."
	(cd ${TRAJ_LIB_DIR} && ${MAKE} fresh)

clean:
	-rm -f ${OBJS}

clobber: clean
	-rm -f ${LIB_NAME}

clobber-all:	clobber

fresh: TrajectoryLibFresh clobber default

include ${RTOP}/make.dep
