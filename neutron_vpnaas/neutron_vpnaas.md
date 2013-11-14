# Project Neutron/VPNaaS

Date: 11/13/2013

## Elevator Pitch
The VPNaaS extension provides OpenStack tenants with the ability to extend
private networks across the public telecommunication infrastructure. The
capabilities provided by this initial implementation of the VPNaaS extension
are:

    * Site-to-site Virtual Private Network connecting two private networks.

    * Multiple VPN connections per tenant.

    * Supporting IKEv1 policy with 3des, aes-128, aes-256, or aes-192 encryption.

    * Supporting IPSec policy with 3des, aes-128, aes-256, or aes-192 encryption,
    sha1 authentication, ESP, AH, or AH-ESP transform protocol, and tunnel or
    transport mode encapsulation.

    * Dead Peer Detection (DPD) allowing hold, clear, restart, disabled, or
    restart-by-peer actions.

## Project Maturity
* **OpenStack Program Status:** Integrated
* **Usability Timeframe:** Now
  * Current version is capable of running on top of Havana
  * Suggestion: Experimental 

## Dependencies
* Ubuntu 12.04
* Requires: Nova, Keystone, Neutron (Quantum), Glance, Horizon (optional)

## Example Use Cases
* Cloud Admin wants to connect multiple seperate OpenStack deployments to each
other
* Cloud User wants to connect their workloads from different deployments

## Misc Notes
* This extension introduces new resources:
    * service: a high level object that associates VPN with a specific subnet and
router.
    * ikepolicy: the Internet Key Exchange policy identifying the authentication and
encryption algorithm used during phase one and phase two negotiation of a VPN
connection.
    * ipsecpolicy: the IP security policy specifying the authentication and
encryption algorithm, and encapsulation mode used for the established VPN
connection.
    * ipsec-site-connection: has details for the site-to-site IPsec connection,
including the peer CIDRs, MTU, authentication mode, peer address, DPD settings,
and status.
* Concepts
    * A VPN service relates the Virtual Private Network with a specific subnet
    and router for a tenant.

    * An IKE Policy is used for phase one and phase two negotiation of the VPN
    connection. Configuration selects the authentication and encryption
    algorithm used to establish a connection.

    * An IPsec Policy is used to specify the encryption algorithm, transform
    protocol, and mode (tunnel/transport) for the VPN connection.

    * A VPN connection represents the IPsec tunnel established between two sites
    for the tenant. This contains configuration settings specifying the
        policies used, peer information, MTU, and the DPD actions to take.
* High-level Setup flow

    * The high-level task flow for using VPNaaS API to configure a site-to-site
    Virtual Private Network is as follows:

        * The tenant creates a VPN service specifying the router and subnet.

        * The tenant creates an IKE Policy.

        * The tenant creates an IPsec Policy.

        * The tenant creates a VPN connection, specifying the VPN service, peer
        information, and IKE and IPsec policies.
* VPN Types
    * IPSec
    * SSL
    * BGP/MPLS

## Community Information
* Use OpenStack infrastructure
  * gerrit code reviews
  * code base lives in github
  * weekly irc meetings
      * irc channel - #openstack-neutron

## Rackspace Involvement
None

## Links
* [Wiki](https://wiki.openstack.org/wiki/Neutron/VPNaaS)
* [Architecture](http://www.slideshare.net/KazunoriTakeuchi/neutron-vpnaas-20130628/9)
* [IPSec Blueprint](https://docs.google.com/document/d/1Jphcvnn7PKxqFEFFZQ1_PYkEx5J4aO5J5Q74R_PwgV8/edit#%7C)
* [Operations](http://docs.openstack.org/api/openstack-network/2.0/content/vpnaas_ext_ops_service.html)

## Code Repositories
* [Source](https://github.com/openstack/neutron/tree/17336c6540396984759cf5050cc7f731c4d84616/neutron/services/vpn)
