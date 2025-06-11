# Service Fabric

Service Fabric is a distributed systems platform for packaging, deploying, and managing stateless and stateful distributed applications and containers at large scale. Service Fabric runs on Windows and Linux, on any cloud, any datacenter, across geographic regions, or on your laptop.Service Fabric represents the next-generation platform for building and managing these enterprise-class, tier-1, cloud-scale applications running in containers.

## Architecture and Subsystem Explorer
[Learn about Service Fabric's Core Subsystems](docs/architecture/README.md), mapped to this repo's folder structure.

## Service Fabric release schedule 
Here is the upcoming release schedule for Service Fabric runtime versions that we will be supporting starting with version 8.0.

| Version 	| Release date 	   |
|---------	|----------------- |
| 8.0     	| 2021 Mar     	   |
| 8.1     	| 2021 Jul     	   |
| 8.2     	| 2021 Oct     	   |
| 9.0     	| 2022 Apr         |
| 9.1     	| 2022 Oct     	   |
| 10.0     	| 2023 Apr     	   |
| 10.1      | 2023 Nov         |

Please note that these dates are advanced estimates and might be subject to change or minor adjustments closer to each release.

We will be publishing upcoming features and roadmap items on [Azure Updates for Service Fabric](https://azure.microsoft.com/en-us/updates/?product=service-fabric).

## Repo status
We are in the process to move our development to GitHub. Until then, the Service Fabric team will continue regular feature development internally. We'll be providing frequent updates here and on our [team blog](https://blogs.msdn.microsoft.com/azureservicefabric/) as we make progress.  

### Quick look at our current status
 - [x] Service Fabric build tools for Linux
 - [x] Basic tests for Linux builds available
 - [x] Container image with build tools available to run builds


## Providing feedback and filing issues
We have multiple repositories (in addition to this one) that constitute the Service Fabric product. For more information on how to provide feedback and file issues across the different components (and associated repositories), please see [Contributing.md](CONTRIBUTING.md).


## Build Requirements
The requirements below are based off running clean builds using ninja, with the command

```sh
runbuild.sh –c –n
```

The builds were run on [Azure Linux VMs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes-general) with added disk capacity. If you want to to build on an Azure machine you need to add approximately 70GB for the source+build outputs. 

These times should be taken as estimates of how long a build will take.

|Machine SKU|Cores|Memory|Build Time|
|-----------|-----|-----------|----------|
|Standard_D8s_v3|8|32GB|~4 hours|
|Standard_D16s_v3|16|64GB|~2 hours|
|Standard_D32s_v3|32|128GB|~1 hour|

On a smaller VM (Standard_D4s_V3 / 4 cores / 16GB) the build may fail. You may be able to build on a machine with less RAM if you limit the parallelism using the `-j` switch.

The build also requires approximately 70GB of disk space.

## Setting up for build
### Get a Linux machine
This is the Linux version of Service Fabric. You need a Linux machine to build this project.  If you already have a Linux machine, great! You can get started below.  If not, you can get a [Linux machine on Azure](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/Canonical.UbuntuServer?tab=Overview).

### Installing LXD
Our build environment now depends on LXD. Install LXD using your package manager and initialize it:

```sh
sudo apt-get install -y lxd
newgrp lxd
lxd init --auto
```

## Optional: Enable executing LXD without sudo
By default LXD requires root privileges to run. To manage containers as a regular user add yourself to the `lxd` group:

```sh
sudo usermod -aG lxd ${USER}
su - ${USER}
```

You do not need to do this, but note that if you skip this step, you must run all `lxc` commands with sudo.

## Build Service Fabric
To start the build inside of an LXD container you can clone the repository and run this command from the root directory:

```sh

./runbuild.sh
```

This will do a full build of the project with the output being placed into the `out` directory.  For more options see `runbuild.sh -h`.

Additionally in order to build and create the installer packages you can pass in the `-createinstaller` option to the script:

```sh
./runbuild.sh -createinstaller
```

#### Optional: Build the container locally
If you would prefer to build the container locally, you can run the following script:

```sh
sudo ./tools/builddocker.sh
```

Currently, the build container is based off a base image that includes a few Service Fabric dependencies that have either not yet been open sourced, or must be included due to technical constraints (for example, some .NET files currently only build on Windows, but are required for a Linux build).

This will pull all of the required packages, add Service Fabric internal dependencies, and apply patches.

#### Troubleshooting: Internet connectivity when installing local LXD images behind a firewall
When working behind a firewall you may need to configure proxy or DNS settings for LXD before building the image.
## Testing a local cluster  
For more details please refer to [Testing using ClusterDeployer](docs/cluster_deployer_test.md).

## Running a local cluster  
For more details please refer [Deploying local cluster from build](docs/install_packages_and_deploy_cluster.md)

## Documentation 
Service Fabric conceptual and reference documentation is available at [docs.microsoft.com/azure/service-fabric](https://docs.microsoft.com/azure/service-fabric/). Documentation is also open to your contribution on GitHub at [github.com/Microsoft/azure-docs](https://github.com/Microsoft/azure-docs).
## Samples 
For Service Fabric sample code, check out the [Azure Code Sample gallery](https://azure.microsoft.com/resources/samples/?service=service-fabric) or go straight to [Azure-Samples on GitHub](https://github.com/Azure-Samples?q=service-fabric).
## Channel 9: Inside Azure Service Fabric  
<a href="https://www.youtube.com/playlist?list=PLlrxD0HtieHh73JryJJ-GWcUtrqpcg2Pb&disable_polymer=true"><strong>Take a virtual tour with us</strong></a> and meet some of the folks who design and implement service fabric. This Channel 9 YouTube playlist will continue to grow over time with content describing the inner workings of Service Fabric. We have covered most of the [subsystems](docs/architecture/README.md) already.  
## License 
All Service Fabric open source projects are licensed under the [MIT License](LICENSE).
## Code of Conduct 
All Service Fabric open source projects adopt the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
