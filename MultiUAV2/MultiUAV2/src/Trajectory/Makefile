# $Id: Makefile,v 2.1 2004/01/27 16:11:08 mitchejw Exp $

default:	all

all:	build-all

build build-all:
	(cd TrajectoryLib	&& ${MAKE} all)
	(cd TrajectoryMEX	&& ${MAKE} all)

clean:
	(cd TrajectoryLib	&& ${MAKE} clean)
	(cd TrajectoryMEX	&& ${MAKE} clean)

clean-all: clean

clobber:
	(cd TrajectoryLib	&& ${MAKE} clobber)
	(cd TrajectoryMEX	&& ${MAKE} clobber)

clobber-all:
	(cd TrajectoryLib	&& ${MAKE} clobber-all)
	(cd TrajectoryMEX	&& ${MAKE} clobber-all)

fresh:	clobber-all	default

depend dep::
	(cd TrajectoryLib && ${MAKE} dep)
	(cd TrajectoryMEX && ${MAKE} dep)
