# $Id: Makefile,v 2.1 2004/01/27 16:11:08 mitchejw Exp $
#
# NOTE: the C version of the test program is not setup to build since the
#       library requires C++.

RTOP = ..

include ${RTOP}/make.env
include ${RTOP}/make.opts

CXX_MAIN = CapTranShipTest.cpp 
CC_MAIN  = ctpdriver.c

CTPD_DIR = ./CapTranShipDll 
CTPL_DIR = ./CapTranShipLib 
CTPM_DIR = ./CapTranShipMex 

DEFINES +=  # -DUSE_DEPRECATED_CC_HEADERS

INCLUDES +=  -I${CTPL_DIR} 

LIBS += -lctp -Wl,-rpath,${LIB_DIR_LONG}

CXXFLAGS = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}
CFLAGS   = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}

LDFLAGS += ${LINK_FLAGS} ${LIBS} 

CXX_EXEC = ${CXX_MAIN:.cpp=}
CC_EXEC = ${CC_MAIN:.c=}

SRCS = ${CXX_MAIN} ${CC_MAIN}

CXX_OBJS = ${CXX_MAIN:.cpp=.o}
CC_OBJS = ${CC_MAIN:.c=.o}

OBJS = ${CXX_OBJS} ${CC_OBJS}

default: all
	
all: 
	(cd CapTranShipLib && ${MAKE} all)
	(cd CapTranShipDll && ${MAKE} all)
	(cd CapTranShipMex && ${MAKE} all)
	${MAKE} CapTranShipTest 

exec: ${CXX_EXEC}

${CXX_EXEC}: ${CXX_OBJS}
	${CXX} ${LDFLAGS} ${LD_ADD_LSTDCXX} -o $@ ${CXX_OBJS}

${CC_EXEC}: ${CC_OBJS}
	${CC} ${LDFLAGS} -o $@ ${CC_OBJS}

clean:
	-rm -f ${OBJS}

clobber: clean
	-rm -f ${OBJS} ${CXX_EXEC} ${CC_EXEC}

clean-all: clean
	(cd ${CTPL_DIR} && ${MAKE} clean)
	(cd ${CTPD_DIR} && ${MAKE} clean)
	(cd ${CTPM_DIR} && ${MAKE} clean)

clobber-all: clobber
	(cd ${CTPL_DIR} && ${MAKE} clobber)
	(cd ${CTPD_DIR} && ${MAKE} clobber)
	(cd ${CTPM_DIR} && ${MAKE} clobber)

fresh: clobber-all default

depend dep::
	(cd ${CTPL_DIR} && ${MAKE} dep)
	(cd ${CTPD_DIR} && ${MAKE} dep)
	(cd ${CTPM_DIR} && ${MAKE} dep)
	
include ${RTOP}/make.dep
