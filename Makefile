TOP ?= $(shell echo $$PWD)

OS_ID := $(shell cat /etc/os-release | grep \^ID=| cut -d "=" -f 2) 
OS_VERSION := $(shell cat /etc/os-release | grep \^VERSION_ID=| cut -d "=" -f 2) 

DISTRIBUTION ?= "$(strip ${OS_ID})$(strip ${OS_VERSION})"

BUILDERS = ${DISTRIBUTION}
RUNNERS = ${DISTRIBUTION}

SOURCE = ${TOP}/source
BUILD = ${TOP}/build

DEVELOPMENT = ${SOURCE}/development
IRODS_SERVER = ${SOURCE}/irods_server
IRODS_CLIENT = ${SOURCE}/irods_client

all: help
	echo Done !

help:
	@echo "Maker for iRODS software, by Harry Kodden"
	@echo
	@echo "Will build into: ${BUILD} for distribution: ${DISTRIBUTION}"
	@echo
	@echo "Output will be produced into: ${BUILD}/${DISTRIBUTION}"
	@echo
	@echo "You can adjust distribution by setting environ variable 'DISTRIBUTION'"
	@echo
	@echo "For example:"
	@echo "export DISTRIBUTION=centos7"
	@echo
	@echo "Usage:"
	@echo "make help     shows this message"
	@echo "make builds   builds complete iRODS stack"
	@echo "make runners  build only the runners"
	@echo "make clean    cleans the environment, (might reguire sudo privileges)"
	@echo

${DEVELOPMENT}:
	mkdir -p ${DEVELOPMENT}
	@git clone https://github.com/irods/irods_development_environment ${DEVELOPMENT}

${IRODS_SERVER}:
	mkdir -p ${IRODS_SERVER}
	@git clone --recursive https://github.com/irods/irods ${IRODS_SERVER}

${IRODS_CLIENT}:
	mkdir -p ${IRODS_CLIENT}
	@git clone https://github.com/irods/irods_client_icommands ${IRODS_CLIENT}

# Build builders & runners...

builds: ${DEVELOPMENT} ${IRODS_SERVER} ${IRODS_CLIENT}
	for os in ${BUILDERS}; \
	do \
		cd ${DEVELOPMENT} && docker build -f irods_core_builder.$$os.Dockerfile -t irods-core-builder-$$os .; \
		ocker run --rm \
             		-v ${IRODS_SERVER}:/irods_source:ro \
             		-v ${IRODS_CLIENT}:/icommands_source:ro \
             		-v ${BUILD}/$$os/server:/irods_build \
             		-v ${BUILD}/$$os/client:/icommands_build \
             		-v ${BUILD}/$$os/packages:/irods_packages \
             		irods-core-builder-$$os -N -j 10 --exclude-unit-tests; \
	done;

runners: ${DEVELOPMENT}
	for os in ${RUNNERS}; \
	do \
		cd ${DEVELOPMENT} && docker build -f irods_runner.$$os.Dockerfile -t irods-runner-$$os .; \
	done;

clean:
	rm -rf ${SOURCE}
	rm -rf ${TOP}/build


#pam_interactive:
#	https://github.com/stefan-wolfsheimer/irods_client_icommands.git
#	git checkout https://github.com/stefan-wolfsheimer/irods_client_icommands/tree/4-3_pam_interactive
