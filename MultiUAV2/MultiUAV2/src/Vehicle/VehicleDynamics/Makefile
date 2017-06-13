# this guy is just for testing dummy instantiation in SimulationLib.cpp,
# otherwise he just passes through to the DATCOM stuff.

RTOP = ../..

include ${RTOP}/make.env
include ${RTOP}/make.opts

LIB_NAME=${VDYN_SO}

SRCS=

#DEFINES += -DNDEBUG 

#INCLUDES += 

LINK_FLAGS += -Wl,-soname,${LIB_NAME}

CXXFLAGS = ${COMPILE_FLAGS} ${DEFINES} ${INCLUDES}
LDFLAGS  = ${LINK_FLAGS} ${SO_FLAGS} 

OBJS = ${SRCS:.cpp=.o}

default: all

all:	msg
	(cd DATCOMTableLib && ${MAKE} all)
	(cd EuminxdLib && ${MAKE} all)

msg:
	@echo "  There is no library to make here, only headers w/ test code."
	@echo "    oh, and what lies beneath..."
	@echo "    ...and something <voice timbre=\"Kosh\">for the future</voice>."

clean:
	(cd DATCOMTableLib && ${MAKE} clean)
	(cd EuminxdLib && ${MAKE} clean)

clean-all:
	(cd DATCOMTableLib && ${MAKE} clean-all)
	(cd EuminxdLib && ${MAKE} clean-all)

clobber:
	(cd DATCOMTableLib && ${MAKE} clobber)
	(cd EuminxdLib && ${MAKE} clobber)

clobber-all:
	(cd DATCOMTableLib && ${MAKE} clobber-all)
	(cd EuminxdLib && ${MAKE} clobber-all)

fresh: clobber-all default

test: msg ${LIB_NAME}

${LIB_NAME}: ${OBJS}
	${CXX} ${LDFLAGS} -o $@ $^

test-clean:
	-rm -f ${OBJS}

test-clobber: clean
	-rm -f ${LIB_NAME}

depend dep::
	(cd DATCOMTableLib && ${MAKE} dep)
	(cd EuminxdLib && ${MAKE} dep)

include ${RTOP}/make.dep

