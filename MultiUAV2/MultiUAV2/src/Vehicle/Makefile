default:	all

all:	build-all

build build-all:
	(cd VehicleDynamics			&& ${MAKE} all)
	(cd VehicleDynamicsMex	&& ${MAKE} all)

clobber:
	(cd VehicleDynamics			&& ${MAKE} clobber)
	(cd VehicleDynamicsMex	&& ${MAKE} clobber)

clean-all:
	(cd VehicleDynamics			&& ${MAKE} clean-all)
	(cd VehicleDynamicsMex	&& ${MAKE} clean-all)

clobber-all:
	(cd VehicleDynamics			&& ${MAKE} clobber-all)
	(cd VehicleDynamicsMex	&& ${MAKE} clobber-all)

fresh:	clobber-all	default

depend dep::
	(cd VehicleDynamics      && ${MAKE} dep)
	(cd VehicleDynamicsMex   && ${MAKE} dep)
#	(cd VehicleDynamicsSFunc && ${MAKE} dep)
