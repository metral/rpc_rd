# Project Trove 

Date: 10/3/2013

## Elevator Pitch

To provide scalable and reliable Cloud Database as a Service provisioning
functionality for both relational and non-relational database engines in
OpenStack

## Project Maturity
* **OpenStack Program Status:** Incubation
* **Usability Timeframe:** Now
  * Current version is capable of running on top of Havana
* **Misc:**
    * There are wiki pages, design docs & diagrams and API docs
    * Trove needs more usage documentation
        * troveclient is currently being rewritten and 
            the docs that go along with it are also in flux.
            *  Refactoring: [https://review.openstack.org/#/c/48576/](https://review.openstack.org/#/c/48576/)
                *  May be ready by Havana release but is currently a work in progress.
  * Formerly known as 'Red Dwarf'

## Dependencies
* Ubuntu 12.04
* Requires: Nova, Glance, Keystone
* Optional: Swift (backups), Cinder (if you decided to enable volumes)


## Persona Target
* Cloud End User
  * Allows users to spin up databases as needed
* Cloud Database Administrator
  * Allows admins to spin up and manage databases
  
## Example Use Cases
* End User can deploy a MySQL database
* End User wants to utilize a data service via IP such as MongoDB, Memcached, Redis (and in principle Ceph or Swift)
* Admin can create & manage a database for users

## Community Information
* Use OpenStack infrastructure
  * gerrit code reviews
  * code base lives in github
  * weekly irc meetings
      * irc channel - #openstack-trove

## Rackspace Involvement
* Co-developed by Rackspace
    * Michael Basnight (Racker) is PTL

## Links
* [Wiki](https://wiki.openstack.org/wiki/Trove)
* [Install Trove on Devstack](https://wiki.openstack.org/wiki/Trove/installation)
* [Kickstart Build Image](https://github.com/openstack/trove-integration/blob/master/README.md#kick-start-the-buildtest-initbuild-image-commands)
* [Developer Docs](http://docs.openstack.org/developer/trove/)
* [RAX / OpenStack API Docs](http://docs.rackspace.com/cdb/api/v1.0/cdb-devguide/content/overview.html)
* [Example of Devstack localrc created by Trove](https://gist.github.com/metral/6813412)

## Code Repositories
* [https://github.com/openstack/trove](https://wiki.openstack.org/wiki/Trove)
* [https://github.com/openstack/trove-integration](https://github.com/openstack/trove-integration)
* [https://github.com/openstack/python-troveclient](https://github.com/openstack/python-troveclient)
