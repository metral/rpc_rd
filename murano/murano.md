# Project Murano 

## Elevator Pitch

Murano allows non-experienced users to deploy reliable Windows based environments in a "push-the-button" manner. Using native windows features for HA solutions, Murano automates deployments of common Windows infrastructures on top of an OpenStack cloud.

## Project Maturity
* **Current Version:** 0.2.1
  * Would consider as **BETA**
* **OpenStack Program Status:** Pre-Incubation
  * Has not yet applied for Incubation
* **Usability Timeframe:** Near Term
  * Current version is capable of running on top of Grizzly code base (few bugs related to quantum/neutron rename)


## Dependencies
* Requires Heat
* Requires Neutron
  * Does not appear to work with Nova-Network
* Extends Horizon
  * Provides custom dashboard plugins
* Requires a custom Windows Image
  * Windows Image builder provided by Murano
  	* Installs VirtIO drivers
  	* Installs cloudbase-init
  	* Installs heat agent
  	* Installs murano agent

## Persona Target
* Cloud End User
  * Allows users to spin up complex Windows infrastructures with the push of a button
  
## Example Use Cases
* End User can deploy a Single Domain Active Directory infrastructure with multiple controllers
* End User can deploy an IIS Web Farm
  * loadbalancing provided by Neutron LBaaS
* End User can deploy an ASP.NET Web Farm
  * loadbalancing provided by Neutron LBaaS
* End User can deploy a Windows Instance connected to External Active Directory Infrastructure
* End User can deploy a MS SQL Server AlwaysOn Cluster


## Community Information
* Started and Maintained by Mirantis
  * Most contributors are Mirantis employees
  * Very few external to Mirantis contributors
* Use OpenStack infrastructure
  * gerrit code reviews
  * code base lives in Stackforge
  * weekly irc meetings on openstack channels

## Rackspace Involvement
* There are no known rackspace engineers currently contributing to this project

## Links
* [OpenStack Wiki Overview](https://wiki.openstack.org/wiki/Murano)
* [Roadmap](https://wiki.openstack.org/wiki/Murano/Roadmap)
* [Architecture](https://wiki.openstack.org/wiki/Murano/ProjectOverview#Architecture_Details)
* [v0.2 Release Notes](https://wiki.openstack.org/wiki/Murano/ReleaseNotes_v0.2)
* [v0.2 Announcement - Mirantis Blog Post](http://www.mirantis.com/blog/murano-0-2-is-here/)
* [Getting Started Guide](http://murano-docs.github.io/latest/getting-started/content/ch01.html)

## Code Repositories
* https://github.com/stackforge/murano-common
* https://github.com/stackforge/murano-agent
* https://github.com/stackforge/murano-api
* https://github.com/stackforge/murano-conductor
* https://github.com/stackforge/murano-dashboard
* https://github.com/stackforge/python-muranoclient
* https://github.com/stackforge/murano-deployment