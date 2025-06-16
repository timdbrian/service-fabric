# Running a test using Cluster Deployer in an LXD container

## Prerequisites

You will need to have LXD installed. See the README for instructions on setting up LXD on Linux or macOS.

### Linux Setup

Initialize LXD after installation:

```bash
lxd init --auto
```
## Running the test

Build Service Fabric
```
  $ ./runbuild.sh
```
Run the test
```
  $ cd out/build.prod/ClusterDeployerTest/
  $ ./runtest.sh
```
## Details

This test first builds an LXD image (service-cluster-run-ubuntu) locally, which contains the necessary packages to run Service Fabric. The test then runs LXD, mounting the FabricDrop folder in your output directory. Then a [sample application](https://github.com/Azure-Samples/service-fabric-dotnet-core-getting-started) is downloaded and built inside the container. The application is installed, and if the http endpoint can be hit then the test passes.
