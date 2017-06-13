RTOP = ../..

include ${RTOP}/make.env
include ${RTOP}/make.opts

LIB_NAME = ${CTPMEX_GLX}

SRCS = CapTranShipMex.cpp

OBJS = ${SRCS:.cpp=.o}

CTPL_DIR = ../CapTranShipLib

INCLUDES += -I${RTOP}/Includes -I${CTPL_DIR} ${MAT_INCS}

DEFINES += ${MAT_DEFS}

LINK_FLAGS += -lctp -Wl,-rpath,${LIB_DIR_LONG} # ${LD_ADD_LSTDCXX}

CXXFLAGS = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}
LDFLAGS  = ${SO_FLAGS} ${LINK_FLAGS} ${MAT_LIBS} ${MAT_MEX_VER} ${MAT_RPATH}

default: all

all: ${LIB_NAME}

include ${RTOP}/make.mexver

${LIB_NAME}: ${OBJS} 
	${MAKE} CapTranShipLib
	${CXX} ${LDFLAGS} -o $@ ${OBJS}

${OBJS}: Makefile .depend

CapTranShipLib:
	@echo "Forcing check of CapTranShipLib..."
	(cd ${CTPL_DIR} && ${MAKE})

CapTranShipLibFresh:
	@echo "Forcing fresh remake of CapTranShipLib..."
	(cd ${CTPL_DIR} && ${MAKE} fresh)

clean:
	-rm -f ${OBJS}

clobber: clean
	-rm -f ${LIB_NAME}

fresh: CapTranShipLibFresh clobber default

include ${RTOP}/make.dep

