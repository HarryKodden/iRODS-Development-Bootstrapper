# iRODS-Development-Bootstrapper

Builds all required packages to develop and run iRODS

```bash
Maker for iRODS software, by Harry Kodden
Maker for iRODS software, by Harry Kodden

Will build into: ./build for distribution: ubuntu20

You can adjust distribution by setting environ variable 'DISTRIBUTION'

For example:
export DISTRIBUTION=centos7

You can build the iRODS software for specific branches other origin/main like this:
export IRODS_SERVER_BRANCH=4-3-stable
export IRODS_CLIENT_BRANCH=4-3-stable

Usage:
make help     shows this message
make builds   builds complete iRODS stack
make runners  build only the runners
make clean    cleans the environment, (might reguire sudo privileges)

echo Done !
Done !
```
