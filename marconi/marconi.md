# Project Marconi 

Date: 10/11/2013

## Elevator Pitch

Marconi is a new messaging and notifications service for the OpenStack product
portfolio, supporting both producer-consumer and publish-subscribe modes.

Marconi is designed to perform and scale in a multi-tenant environment to fill
the need of applications that require a robust, web-scale message queuing
service to support the distributed nature of large web applications.

The aim is to create an open alternative to SQS (producer-consumer) and SNS
(pub-sub), for use in applications that run on OpenStack clouds.

## Project Maturity
* **OpenStack Program Status:** Incubation
* **Usability Timeframe:**
  * Rackspace Cloud Queues: Beta
  * Current version is capable of running on top of Havana

## Dependencies
* Ubuntu 12.04
* Requires: 

## Persona Target
* Cloud End User (Short-Term Goal)
  * Allows users to create queues to manage a set of tasks for an
  application. These tasks, called “messages”, can be anything- creating a
  backup, deleting a volume, sending an email, broadcasting a status
  update, etc.
* Cloud Architect (Very Long-Term Thought - Not A Goal ATM)
  * Allows admins to replace the AMQP (RabbitMQ) messaging system of the
  OpenStack infrastructure
  
## Example Use Cases
* Distribute tasks among multiple workers (transactional job queues)
* Forward events to data collectors (transactional event queues)
* Publish events to any number of subscribers (pub-sub)
* Send commands to one or more agents (point-to-point or pub-sub)
* Request an action or get information from an agent (RPC)

## Out of Scope Use Cases
Marconi may be used as the foundation for other services to support the
following use cases, but will not support them directly within its code base.

* Forwarding notifications to email, SMS, Twitter, etc.
* Forwarding notifications to web hooks
* Forwarding notifications to APNS, GCM, etc.
* Scheduling-as-a-service
* Metering usage

## Misc Notes
* Not looking to replace existing queuing systems, main focus is for the OpenStack user and for apps built on top of OpenStack
* Described as a macro version of the intracluster messaging buses (ie. RabbitMQ & ZeroMQ)
* A large system would use a hybrid of several different queuing solutions
* Targeting Mongo as the backend storage system since it gives, HA, durability, sharding - but you could use RabbitMQ if you wanted
* python-marconiclient - client to use against marconi-server is still in dev
* Main method of interaction ATM is via API
* Pyrax will have support for Cloud Queues / Marconi in a couple of weeks (as of 10/11/13)

## Community Information
* Use OpenStack infrastructure
  * gerrit code reviews
  * code base lives in github
  * weekly irc meetings
      * irc channel - #openstack-marconi

## Rackspace Involvement
* Co-developed by Rackspace
    * Kurt Griffiths (Racker) is PTL

## Links
* [Wiki](https://wiki.openstack.org/wiki/Marconi)
* [API Blueprint](https://wiki.openstack.org/wiki/Marconi/specs/api/v1)
* [python-marconiclient dev](https://review.openstack.org/#/q/status:open+project:openstack/python-marconiclient,n,z)
* [DevStack Integration Blueprint](https://blueprints.launchpad.net/devstack/+spec/marconi-devstack-integration)

## Code Repositories
* [Source](https://github.com/openstack/marconi)
* [Client Source](https://github.com/openstack/python-marconiclient)
