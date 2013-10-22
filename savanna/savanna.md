# Project Savanna 

Date: 10/18/2013

## Elevator Pitch

The Savanna project provides a simple means to provision a Hadoop cluster on
top of OpenStack.

By specifying several parameters like Hadoop version, cluster topology, nodes
hardware details and a few more, Savanna deploys the cluster in a few minutes.

Also Savanna provides means to scale already provisioned cluster 
by adding/removing worker nodes on demand.

Savanna is known as Data Processing as a Service

## Project Maturity
* **OpenStack Program Status:** Incubation
* **Usability Timeframe:** Beta
  * Current version (0.3) is capable of running on top of Havana

## Dependencies
* Ubuntu 12.04
* Requires: Nova, Keystone, Glance, Swift, & Horizon
* Future Requirements: Ceilometer for metrics, Heat for orchestration, and
potentially Ironic for provisioning bare metal or hybrid Hadoop clusters

## Persona Target
* Cloud User wants to analyze big data aka map/reduce type jobs
* Cloud Provider wants to offer Hadoop Data Processing as a Service
  
## Example Use Cases
* Fast provisioning of Hadoop clusters on OpenStack for Dev and QA;
* Utilization of unused compute power from general purpose OpenStack IaaS
  cloud;
* "Analytics as a Service" for ad-hoc or bursty analytic workloads (similar to
  AWS EMR).

## Misc Notes
* Managed through REST API with UI available as part of OpenStack Dashboard
* Support for different Hadoop distributions:
    * Pluggable system of Hadoop installation engines;
    * Integration with vendor specific management tools, such as Apache Ambari or
    Cloudera Management Console;
* Predefined templates of Hadoop configurations with ability to modify
parameters
* Use latest tarball (0.3+) with pip install 

## Community Information
* Use OpenStack infrastructure
  * gerrit code reviews
  * code base lives in github
  * weekly irc meetings
      * irc channel - #savanna

## Rackspace Involvement
* Sergey Lukjanov (Mirantis) is PTL & Mirantis primarily composes all
contributors
* Rackspace has minimal to no involvement
    * Rackers
        * Nirmal Ranganathan

## Links
* [Wiki](https://wiki.openstack.org/wiki/Savanna)
* [Docs](https://savanna.readthedocs.org/en/latest/)
* [Workflow / Architecture](https://savanna.readthedocs.org/en/latest/overview.html#general-workflow)
* [Incubation Acceptance Blog](https://www.mirantis.com/blog/savanna-accepted-into-openstack-incubation/)
* [Savana 'pip' tarballs](http://tarballs.openstack.org/savanna/)

## Code Repositories
* [Source](https://github.com/search?q=%40openstack+savanna)
