RTOP = ../../../..

include ${RTOP}/make.env
include ${RTOP}/make.opts

EXEC = datcomtest
SRCS = DATCOMTest.cpp mallinfo.cpp

DATCOM_LIB = ${DATCOM_SO}

VEHDYN_DIR = ../..
DATCOM_DIR = ..

INCLUDES += -I. -I${DATCOM_DIR} -I${VEHDYN_DIR} -I${RTOP}/Includes
DEFINES += 

#LIBS += -ldatcom -Wl,-rpath=${DATCOM_DIR_LONG} ${LD_ADD_LSTDCXX}
LIBS += -ldatcom -Wl,-rpath=${LIB_DIR_LONG} ${LD_ADD_LSTDCXX}

CXXFLAGS  = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}
LDFLAGS = ${LINK_FLAGS} ${LIBS} 

OBJS = ${SRCS:.cpp=.o}

default: all

all: DATCOM_Lib ${EXEC}

${EXEC}: ${OBJS} 
	${CXX} ${LDFLAGS} -o $@ ${OBJS}

${OBJS}: Makefile

DATCOM_Lib: 
	${MAKE} -C ${DATCOM_DIR} ${DATCOM_LIB}

clean:
	-rm -f ${OBJS} 

clean-exec:
	-rm -f ${EXEC}

clean-all: clean 

clobber: clean clean-exec

clobber-all: clobber

fresh: clobber-all default

include ${RTOP}/make.dep

