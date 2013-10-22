# Project Designate 

Date: 10/23/2013

## Elevator Pitch
Designate is a DNS as-a-service project. It is intended to be used to provide
DNS service from the entry point of creating, updating, maintaining and
deleting DNS data using the Designate API, to providing DNS resolution for
users. It is a very modular project, allowing for the use of whatever DNS
server and organization demands, or the database where DNS data is stored. It
is also intended to work in conjunction with other components such as Nova.

The purpose of the project is provide managed DNS for the Openstack Ecosystem
using a REST API or Designate Sink which consumes events from Nova or Neutron
(formerly Quantum),
or any other service that has events that would necessitate DNS changes. It
also will replace Nova DNS bindings and provide much more robust and
full-featured DNS functionality. Also, advanced DNS record support will be
added such as DNSSEC.

Designate is relevant to the mission by adding a missing piece of data-center
functionality, namely, one of the most ubiquitous services, DNS. It is relevant
to other OpenStack projects by automating the name resolution changes required
for the creation and deletion of Nova instances or other components.

## Project Maturity
* **OpenStack Program Status:** Applied for Incubation
* **Usability Timeframe:** Beta
  * Current version (2013.2.a261.gfde4d7e) is capable of running on top of Havana

## Dependencies
* Ubuntu 12.04
* Requires: Nova & Neutron EventQ, Keystone, RabbitMQ

## Persona Target
* Cloud Admin wants to setup domain for all of the users VMs
* Cloud User wants to manage domains for different projects
  
## Community Information
* Use OpenStack infrastructure
  * gerrit code reviews
  * code base lives in github
  * weekly irc meetings
      * irc channel - #openstack-dns

## Rackspace Involvement
* Kiall Mac Innes (HP Cloud) is PTL & HP primarily composes all
contributors
* Rackspace has minimal involvment
    * Rackers
        * Tim Simmons

## Links
* [Wiki](https://wiki.openstack.org/wiki/Designate)
* [Python Docs](http://designate.readthedocs.org/en/latest/#)
* [Architecture](http://designate.readthedocs.org/en/latest/architecture.html)

## Code Repositories
* [Source - StackForge](https://github.com/stackforge/designate)
