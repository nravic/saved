RTOP = ../../..

include ${RTOP}/make.env
include ${RTOP}/make.opts

LIB_NAME = ${DATCOM_SO}

DEFINES += 

SO_FLAGS += -Wl,-soname,${LIB_NAME}
INCLUDES += -I.. -I${RTOP}/Includes

CXXFLAGS = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}
LDFLAGS  = ${SO_FLAGS} 

SRCS = DataTable.cpp DATCOMTable.cpp DeltaTable.cpp

OBJS = ${SRCS:.cpp=.o}

default: all
	
all:	${LIB_NAME}
	(cd DATCOMTableMex  && ${MAKE})
	(cd DATCOMTest      && ${MAKE})

${LIB_NAME}: ${OBJS} 
	${CXX} ${LDFLAGS} ${OBJS} -o $@ 

${OBJS}: Makefile

clean:
	-rm -f ${OBJS}

clean-all: clean
	(cd DATCOMTableMex  && ${MAKE} clean-all)
	(cd DATCOMTest      && ${MAKE} clean-all)

clobber: clean
	-rm -f ${LIB_NAME}

clobber-all: clobber
	(cd DATCOMTableMex  && ${MAKE} clobber-all)
	(cd DATCOMTest      && ${MAKE} clobber-all)

fresh: clobber-all default

#depend dep:
#	mkdep -f Makefile ${CXXFLAGS} ${SRCS}

depend dep::
	(cd DATCOMTableMex  && ${MAKE} dep)
	(cd DATCOMTest      && ${MAKE} dep)

include ${RTOP}/make.dep

