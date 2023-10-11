TOP ?= $(shell echo $$PWD)

OS_ID := $(shell cat /etc/os-release | grep \^ID=| cut -d "=" -f 2) 
OS_VERSION := $(shell cat /etc/os-release | grep \^VERSION_ID=| cut -d "=" -f 2) 

DISTRIBUTION ?= "$(strip ${OS_ID})$(strip ${OS_VERSION})"

BUILDERS = ${DISTRIBUTION}
RUNNERS = ${DISTRIBUTION}

SOURCE = ${TOP}/source
BUILD = ${TOP}/build
RELEASE = ${TOP}

DEVELOPMENT = ${SOURCE}/development
IRODS_SERVER = ${SOURCE}/irods_server
IRODS_CLIENT = ${SOURCE}/irods_client

DEVELOPMENT_BRANCH ?= "main"
IRODS_SERVER_BRANCH ?= "4-3-stable"
IRODS_CLIENT_BRANCH ?= "4-3-stable"

all: help
	echo Done !

help:
	@echo "Maker for iRODS software, by Harry Kodden"
	@echo
	@echo "Will build into: ${BUILD} for distribution: ${DISTRIBUTION}"
	@echo
	@echo "You can adjust distribution by setting environ variable 'DISTRIBUTION'"
	@echo
	@echo "For example:"
	@echo "export DISTRIBUTION=centos7"
	@echo
	@echo You can build the iRODS software for specific branches other "origin/main" like this:
	@echo "export IRODS_SERVER_BRANCH=4-3-stable"
	@echo "export IRODS_CLIENT_BRANCH=4-3-stable"
	@echo
	@echo "Usage:"
	@echo "make help     shows this message"
	@echo "make builds   builds complete iRODS stack"
	@echo "make runners  build only the runners"
	@echo "make clean    cleans the environment, (might reguire sudo privileges)"
	@echo


${DEVELOPMENT}:
	mkdir -p ${DEVELOPMENT}
	@git clone -b ${DEVELOPMENT_BRANCH} https://github.com/irods/irods_development_environment ${DEVELOPMENT}

${IRODS_SERVER}:
	mkdir -p ${IRODS_SERVER}
	@git clone -b ${IRODS_SERVER_BRANCH} --recursive https://github.com/irods/irods ${IRODS_SERVER}

${IRODS_CLIENT}:
	mkdir -p ${IRODS_CLIENT}
	@git clone -b ${IRODS_CLIENT_BRANCH} https://github.com/irods/irods_client_icommands ${IRODS_CLIENT}

# Build builders & runners...
	
builds: ${DEVELOPMENT} ${IRODS_SERVER} ${IRODS_CLIENT}
	for os in ${BUILDERS}; \
	do \
		cd ${DEVELOPMENT} && docker buildx build -f irods_core_builder.$$os.Dockerfile -t irods-core-builder-$$os .; \
		cd ${DEVELOPMENT} && docker run --rm \
             		-v ${IRODS_SERVER}:/irods_source:ro \
             		-v ${IRODS_CLIENT}:/icommands_source:ro \
             		-v ${BUILD}/$$os:/irods_packages \
             		irods-core-builder-$$os -N -j 10 --exclude-unit-tests; \
	done;

publish:
	for os in ${BUILDERS}; \
	do \
		rclone sync ${BUILD}/$$os gitpod:/$$os/packages; \
		rclone copy ${DEVELOPMENT}/ICAT.sql gitpod:/$$os/; \
		rclone copy ${DEVELOPMENT}/irods.logrotate gitpod:/$$os/; \
		rclone copy ${DEVELOPMENT}/irods.rsyslog gitpod:/$$os/; \
		rclone copy ${DEVELOPMENT}/keep_alive.sh gitpod:/$$os/; \
		cp ${DEVELOPMENT}/irods_runner.$$os.Dockerfile /tmp/Dockerfile; \
		rclone copy /tmp/Dockerfile gitpod:/$$os/; \
		rm /tmp/Dockerfile; \
	done;

runners: ${DEVELOPMENT}
	for os in ${RUNNERS}; \
	do \
		cd ${DEVELOPMENT} && docker buildx build -f irods_runner.$$os.Dockerfile -t irods-runner-$$os .; \
	done;

clean:
	rm -rf ${TOP}/source
	rm -rf ${TOP}/build
