# Project Neutron/LBaaS

Date: 10/28/2013

## Elevator Pitch
LBaaS (Load-balancer-as-a-Service) is Quantum extension (aka 'service') that introduces load
balancing feature set into the core.

The proposed service allows to manage multiple hardware and software based load
balancers in an OpenStack cloud environment using a RESTful API, and to provide
LB services to OpenStack tenants. It is designed specifically for OpenStack,
but can also be used as a standalone service to manage a set of load balancers
via a single unified API.

It became a sub-project of Quantum per decisions in "San Diego Oct-2012 Design
Summit".

## Project Maturity
* **OpenStack Program Status:** Integrated
* **Usability Timeframe:** Now
  * Current version is capable of running on top of Havana

## Dependencies
* Ubuntu 12.04
* Requires: Nova, Keystone, Neutron (Quantum), Glance, Horizon (optional)

## Example Use Cases
* Cloud Users can enable load balancers for their applications
* Cloud Admin adds several load balancers to the pool to manage their users
load of the virtual infrastructure
* Cloud Admin can provide a layer of protection against DoS attacks

## Misc Notes
* Dynamically adding/removing VMs to LB
    * LB service allows you to include/exclude VMs from the load balancing pool at
    any time. This allows to implement auto-scaling capabilities: a component could
    monitor the load, add more VMs when a certain load threshold is reached and
    remove VMs when the load decreases. Removal of VMs will be graceful, without
    impacting existing connections, as described in the next paragraph.
    Graceful Exclusion of a VM from LB
* Graceful Exclusion of a VM from LB
    * LB service exposes simple methods for activating and suspending traffic to VMs,
    so it’s possible to take VMs out of rotation by just making a simple REST API
    call.  If the underlying LB device supports graceful suspension, it will stop
    accepting new traffic to a VM instance but will let it finish processing the
    existing connections. This allows to remove VMs from the load balancing pool
    without interruptions in traffic processing.
    Health Monitoring and High Availability
* Health Monitoring and High Availability
    * LB service monitors the health of back-end servers and immediately stops
    directing traffic to a server that is found unresponsive to minimize its impact
    on the users. A variety of health checks are supported, such as simple ICMP
    ping, TCP connection or running a particular HTTP or HTTPS request.
* Some affiliations with Mirantis, Atlas, eBay/Paypal

## Community Information
* Use OpenStack infrastructure
  * gerrit code reviews
  * code base lives in github
  * weekly irc meetings
      * irc channel - #openstack-neutron

## Rackspace Involvement
None

## Links
* [Wiki](https://wiki.openstack.org/wiki/Neutron/LBaaS)
* [Architecture](https://wiki.openstack.org/wiki/Quantum/LBaaS/Architecture)
* [API Blueprint](https://wiki.openstack.org/wiki/Quantum/LBaaS/API_1.0)

## Code Repositories
* [Source](https://github.com/openstack/neutron/tree/17336c6540396984759cf5050cc7f731c4d84616/neutron/services/loadbalancer)
