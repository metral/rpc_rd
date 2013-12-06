# Project Docker Nova Driver

Date: 12/5/2013

## Elevator Pitch
Docker is an open-source engine which automates the deployment of applications
as highly portable, self-sufficient containers which are independent of
hardware, language, framework, packaging system and hosting provider.

Containers don't aim to be a replacement for VMs, they are just complementary
in the sense that they are better for specific use cases. Nova support for VMs
is currently advanced thanks to the variety of hypervisors running VMs. However
it's not the case for containers even though libvirt/LXC is a good starting
point. Docker aims to go the second level of integration.

Specifically, this project revolves around the Docker driver, which is a hypervisor 
driver for Nova Compute to manage containers

## Project Maturity
* **OpenStack Program Status:** Incubation
* **Usability Timeframe:** Wait - Experimental - Networking & VM State are
shaky
  * Current version is capable of running on top of Havana

## Dependencies
* Ubuntu 12.04
* Requires: Nova, Glance

## Example Use Cases
* Cloud Admin wants to setup a PaaS offering for their users via containers
instead of VMs
* Cloud User wants to be able to transport an existing application from their
dev environment to a container on an OpenStack cloud with ease and no friction

## Misc Notes ##
* **Docker:**
   * Docker is a tool that can encapsulate an application and its dependencies in a virtual container that can theoretically run on any Linux server.
      * It helps enable flexibility and portability on where the application can run, whether on premise, public cloud, private cloud, bare metal, etc
      * In short, some state Docker can be seen as an open-source, stand-alone PaaS, but with extra features
   * Started at dotCloud, who has since renamed themselves to Docker Inc. due to the success of the project
   * Docker extends Linux Containers (LXC), with a high level API providing a lightweight virtualization solution that runs processes in isolation, providing a way to automate software deployment in a secure and repeatable environment
   * Integrations have been made with tools such as Chef, Puppet & OpenStack Nova
   * Officially runs on Debian, Ubuntu and recently just added support for RedHat, Suse & Gentoo that doesnt require a modded Linux kernel
   * The beauty of Docker is that it lets developers keep using the languages and frameworks of their choosing but then deploy their application widely & seamlessly on the infrastructure of their choice
   * A standard container in Docker contains a software component along with all of its dependencies - binaries, libraries, configuration files, scripts, virtualenvs, jars, gems, tarballs, etc. Docker can be run on any x64 Linux kernel that supports cgroups and aufs
      * cgroups
         * A Linux kernel feature to limit, account and isolate resource usage (CPU, memory, disk I/O, etc.) of process groups
      * aufs
         * An union filesystem takes an existing filesystem and transparently overlays it on a newer filesystem
         * aufs allows files and directories of separate filesystem to co-exist under a single roof
         * It can merge several directories and provide a single merged view

* **OpenStack Integration:**
   * The Docker driver is a hypervisor driver for Openstack Nova Compute
      * It has been introduced with the Havana release
   * Docker is a way of managing LXC containers on a single machine
      * However used behind Nova makes it much more powerful since its then possible to manage several hosts which will then manage hundreds of containers
   * Containers don't aim to be a replacement for VMs, they are just complementary in the sense that they are better for specific use cases
      * Nova support for VMs is currently advanced thanks to the variety of hypervisors running VMs
      * However it's not the case for containers even though libvirt/LXC is a good starting point. Docker aims to go the second level of integration
   * Docker benefits to libvirt/LXC support
      * Docker takes advantage of LXC and the AUFS file system to offer specific capabilities which are definitely not generic enough to be provided by libvirt
      * Process-level API: For example docker can collect the standard outputs and inputs of the process running in each container for logging or direct interaction, it allows blocking on a container until it exits, setting its environment, and other process-oriented primitives which don't fit well in libvirt's abstraction.
      * Advanced change control at the filesystem level: Every change made on the filesystem is managed through a set of layers which can be snapshotted, rolled back, diff-ed etc.
      * Image portability: The state of any docker container can be optionally committed as an image and shared through a central image registry (ie Glance).
         * Docker images are designed to be portable across infrastructures, so they are a great building block for hybrid cloud scenarios.
      * Build facility: docker can automate the assembly of a container from an application's source code. This gives developers an easy way to deploy payloads to an Openstack cluster as part of their development workflow.
   * Under the Hood
      * The Nova driver embeds a tiny HTTP client which talks with the Docker internal Rest API through a unix socket. It uses the HTTP API to control containers and fetch information about them.
      * By using an embedded docker-registry, Docker can push and pull images from Glance. The registry usually lives in a container, but it can be deployed outside a container as well.
         * Requires that Glance be configured to support the "docker" container format

## Community Information
* Somewhat uses OpenStack infrastructure
  * code base lives in github
  * irc channel - #docker
* Docker
* Nebula (previously at Rackspace - Dean Troyer)
* CoreOS (previously at Rackspace - Brian Waldon)

## Rackspace Involvement
None

## Links
* [Wiki](https://wiki.openstack.org/wiki/Docker)
* [Blueprint](https://blueprints.launchpad.net/nova/+spec/new-hypervisor-docker)

## Code Repositories
* [Source](https://github.com/dotcloud/openstack-docker)
* [Docker Image Registry](https://github.com/dotcloud/docker-registry)
