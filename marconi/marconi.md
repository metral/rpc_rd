# Project Marconi 

Date: 10/9/2013

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
* **Usability Timeframe:** Beta
  * Current version is capable of running on top of Havana
* **Misc:**

## Dependencies
* Ubuntu 12.04
* Requires: 

## Persona Target
* Cloud End User (Short-Term Target)
  * Allows users to create queues to manage a set of tasks for an
  application. These tasks, called “messages”, can be anything- creating a
  backup, deleting a volume, sending an email, broadcasting a status
  update, etc.
* Cloud Architect (Long-Term Target)
  * Allows admins to replace the AMQP (RabbitMQ) messaging system of the
  OpenStack infrastructure
  
## Example Use Cases
* Distribute tasks among multiple workers (transactional job queues)
* Forward events to data collectors (transactional event queues)
* Publish events to any number of subscribers (pub-sub)
* Send commands to one or more agents (point-to-point or pub-sub)
* Request an action or get information from an agent (RPC)

## Community Information
* Use OpenStack infrastructure
  * gerrit code reviews
  * code base lives in github
  * weekly irc meetings
      * irc channel - #openstack-marconi

## Rackspace Involvement

## Links
* [Wiki](https://wiki.openstack.org/wiki/Marconi)


## Code Repositories
* [Source](https://github.com/stackforge/marconi)
* [Client Source](https://github.com/stackforge/python-marconiclient)
