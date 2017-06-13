RTOP = ../../../..

include ${RTOP}/make.env
include ${RTOP}/make.opts

EXEC = EuminxdTest
SRCS = TestEuminxd.cpp

EUMINXD_DIR = ..

#DEFINES += -DAUSTINTEST

INCLUDES += -I${EUMINXD_DIR} -I${RTOP}/Includes

LIBS += -leuminxd -Wl,-rpath=${LIB_DIR_LONG} 

CXXFLAGS  = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}

LDFLAGS = ${LINK_FLAGS} ${LIBS} ${LD_ADD_LSTDCXX}

OBJS = ${SRCS:.cpp=.o}

default: all

all: EUMINXD_Lib ${EXEC}

${EXEC}: ${OBJS} 
	${CXX} ${LDFLAGS} -o $@ ${OBJS}

${OBJS}: Makefile .depend

EUMINXD_Lib: 
	${MAKE} -C ${EUMINXD_DIR} ${EUMINXD_SO}

clean:
	-rm -f ${OBJS} 

clean-exec:
	-rm -f ${EXEC}

clean-all: clean 

clobber: clean clean-exec

clobber-all: clobber

fresh: clobber-all default

include ${RTOP}/make.dep

