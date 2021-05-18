all: icinga-collection.pp

icinga-collection.pp: icinga-collection.te
	checkmodule -M -m -o icinga-collection.mod icinga-collection.te
	semodule_package -o icinga-collection.pp -m icinga-collection.mod

install:
	semodule -r icinga-collection
	semodule -i icinga-collection.pp
