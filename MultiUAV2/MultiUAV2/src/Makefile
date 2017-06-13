# $Id: Makefile,v 2.1 2004/01/27 16:10:57 mitchejw Exp $

include make.env

default: all

all: build 

build:
	@echo "Making build... (root:build)"
	[ `find . -name .depend | wc -l` -eq 15 ]
	(cd CapTranShip        && ${MAKE} all)
	(cd CommunicationsDLL  && ${MAKE} all)
	(cd Vehicle            && ${MAKE} all)
	(cd Trajectory         && ${MAKE} all)
	(cd TacticalVehicleDLL && ${MAKE} all)
	@echo "done. (root:build)"

clean:
	@echo "There is no 'clean' target, only clean-all."

clean-libs:
	@echo "Cleaning mex libs...(root:clean-libs)"
	@for l in ${LIB_ALL}; do \
	   CMD="rm -f $$l"; \
		 echo $${CMD}; \
		 eval $${CMD}; \
	 done
	@echo "done. (root:clean-libs)"

clean-all:
	@echo "Cleaning all...(root:clean-all)"
	(cd CapTranShip        && ${MAKE} clean-all)
	(cd CommunicationsDLL  && ${MAKE} clean-all)
	(cd Vehicle            && ${MAKE} clean-all)
	(cd Trajectory         && ${MAKE} clean-all)
	(cd TacticalVehicleDLL && ${MAKE} clean-all)
	@echo "done. (root:clean-all)"

clobber:
	@echo "There is no 'clobber' target, only clobber-all."

clobber-all: clean-libs
	@echo "Clobbering all...(root:clobber-all)"
	(cd CapTranShip        && ${MAKE} clobber-all)
	(cd CommunicationsDLL  && ${MAKE} clobber-all)
	(cd Vehicle            && ${MAKE} clobber-all)
	(cd Trajectory         && ${MAKE} clobber-all)
	(cd TacticalVehicleDLL && ${MAKE} clobber-all)
	@echo "done, except for root libs... (root:clobber-all)"
	${MAKE} clean-libs

fresh: 
	@echo "Making fresh...(root:fresh)"
	${MAKE} clean-libs
	(cd CapTranShip        && ${MAKE} fresh)
	(cd CommunicationsDLL  && ${MAKE} fresh)
	(cd Vehicle            && ${MAKE} fresh)
	(cd Trajectory         && ${MAKE} fresh)
	(cd TacticalVehicleDLL && ${MAKE} fresh)
	@echo "done. (root:fresh)"

depend dep: 
	@echo "Making depend...(root:depend)"
	(cd CapTranShip        && ${MAKE} depend)
	(cd CommunicationsDLL  && ${MAKE} depend)
	(cd Vehicle            && ${MAKE} depend)
	(cd Trajectory         && ${MAKE} depend)
	(cd TacticalVehicleDLL && ${MAKE} depend)
	@echo "done. (root:depend)"
