# iRODS-Development-Bootstrapper

Builds all required packages to develop and run iRODS

```
Maker for iRODS software, by Harry Kodden

Will build into: ./build for distribution: ubuntu20

You can adjust distribution by setting environ variable 'DISTRIBUTION'

For example:

```bash
export DISTRIBUTION=centos7
```

You can build the iRODS software for specific branches like this:

```bash
export IRODS_SERVER_BRANCH=4-3-stable
export IRODS_CLIENT_BRANCH=4-3-stable
```

When not provided, the default branch will be **main**

Usage:
```bash
make help     shows this message
make builds   builds complete iRODS stack
make runners  build only the runners
make clean    cleans the environment, (might reguire sudo privileges)

echo Done !
Done !
```
