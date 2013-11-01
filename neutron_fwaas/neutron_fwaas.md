# Project Neutron/FWaaS

Date: 11/1/2013

## Elevator Pitch
FWaaS (FireWall-as-a-Service) is Neutron (Quantum) extension that introduces firewall
feature set.

Using FwaasDriver Class, an instance of L3 perimeter Firewall
can be created. The firewall co-exists with the L3 agent.

## Project Maturity
* **OpenStack Program Status:** Integrated
* **Usability Timeframe:** Beta
  * Current version is capable of running on top of Havana
  * Suggestion: Hold off due to lack of support & docs

## Dependencies
* Ubuntu 12.04
* Requires: Nova, Keystone, Neutron (Quantum), Glance, Horizon (optional)

## Example Use Cases
* Cloud Users can enable application specific firewall policies for their VMs
* Cloud User can control firewall settings on the whole tenant instead of
iptable settings in each & every individual VMs
* Cloud Admin can provide a layer of protection against attacks for their tenants

## Notes
* Difference between FWaas and Security Groups:
    * FWaaS only manages what is allowed in and out on Neutron router ports on
    a per tenant basis. 
    * Security Groups on the other hand are applied to instances ports directly. 
    * Currently, the FWaaS API is somewhat experimental and policy applies 
globally to all the routers a tenant owns (i.e: no zone concept yet). 
* The FWaaS extension provides OpenStack users with the ability to deploy
    firewalls to protect their networks. The current features provided by the FWaaS
    extension are:

    * Apply firewall rules on traffic entering and leaving tenant networks.

    * Support for applying tcp, udp, icmp, or protocol agnostic rules.

    * Creation and sharing of firewall policies which hold an ordered collection of
    the firewall rules.

    * Ability to audit firewall rules and policies.

    * This extension introduces new resources:

        * firewall: represents a logical firewall resource that a tenant can instantiate
        and manage. A firewall is associated with one firewall_policy.

        * firewall\_policy: is an ordered collection of firewall\_rules. A firewall\_policy
        can be shared across tenants. Thus it can also be made part of an audit
        workflow wherein the firewall\_policy can be audited by the relevant entity that
        is authorized (and can be different from the tenants which create or use the
        firewall\_policy).

        * firewall\_rule: represents a collection of attributes like ports, ip addresses
        which define match criteria and action (allow, or deny) that needs to be taken
        on the matched data traffic.

* One instance is created for each tenant. One firewall policy
    is associated with each tenant (in the Havana release).

    * The Firewall can be visualized as having two zones (in Havana
    release), trusted and untrusted.

    * All the 'internal' interfaces of Neutron Router are treated as trusted. The
    interface connected to 'external network' is treated as untrusted.

    * The policy is applied on traffic ingressing/egressing interfaces on
    the trusted zone. This implies that policy will be applied for traffic
    passing from
        * trusted to untrusted zones
        * untrusted to trusted zones
        * trusted to trusted zones

    * Policy WILL NOT be applied for traffic from untrusted to untrusted zones.
    This is not a problem in Havana release as there is only one interface
    connected to external network.

    * Since the policy is applied on the internal interfaces, the traffic
    will be not be NATed to floating IP. For incoming traffic, the
    traffic will get NATed to internal IP address before it hits
    the firewall rules. So, while writing the rules, care should be
    taken if using rules based on floating IP.

    * The firewall rule addition/deletion/insertion/update are done by the
    management console. When the policy is sent to the driver, the complete
    policy is sent and the whole policy has to be applied atomically. The
    firewall rules will not get updated individually. This is to avoid problems
    related to out-of-order notifications or inconsistent behaviour by partial
    application of rules.

## Misc Notes
* Support for the vArmour & Nicira NVP drivers are now available in addition to
linux / iptables but there doesnt seem to be any docs or support in getting
them set up
* Setting up a firewall before launching VMs proves to be more reliable than
creating the VM first and the firewall after
    * i.e Creating a firewall as admin user & in the admin tenant produced odd
networking issues such as the firewall settings still being in effect even
after it was deleted. However, once a new VM was started up in the same network &
security groups (with the firewall still not being present), things normalized
* Documentation & support could be much better

## Community Information
* Use OpenStack infrastructure
  * gerrit code reviews
  * code base lives in github
  * weekly irc meetings
      * irc channel - #openstack-neutron

## Rackspace Involvement
None

## Links
* [Wiki](https://wiki.openstack.org/wiki/Neutron/FWaaS)
* [CLI Walkthrough](https://wiki.openstack.org/wiki/Quantum/FWaaS/HowToInstall#CLI.2FREST_Walkthrough)
* [REST Walkthrough](https://wiki.openstack.org/wiki/Quantum/FWaaS/HowToInstall#REST_calls_using_curl:)
* [Vendor Blueprints](https://wiki.openstack.org/wiki/Quantum/FWaaS/HavanaPlan#Vendor_Blueprints)
* [API Spec](https://docs.google.com/document/d/1PJaKvsX2MzMRlLGfR0fBkrMraHYF0flvl0sqyZ704tA)

## Code Repositories
* [Source](https://github.com/openstack/neutron/tree/17336c6540396984759cf5050cc7f731c4d84616/neutron/services/firewall)
