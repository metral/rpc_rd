# Project TripleO

Date: 11/26/2013
## Elevator Pitch
TripleO (OpenStack On OpenStack) is a program aimed at installing, upgrading and operating OpenStack
clouds using OpenStack's own cloud facilities as the foundations - building on
nova, neutron and heat to automate fleet management at datacentre scale (and
scaling down to as few as 2 machines).

## Project Maturity
* **OpenStack Program Status:** Integrated
* **Usability Timeframe:** Now
  * Current version is capable of running on top of Havana
  * Suggestion: Experimental 

## Dependencies
* Requires: Nova, Keystone, Neutron (Quantum), Glance, Heat, Ironic

## Example Use Cases
* Cloud Admin wants to deploy base undercloud running on infrastructure using
the community standard
* Cloud User wants to setup to independent, virtual clouds running on top of
openstack ie 1 for Production, 1 for Testing

## Misc Notes
   * Issues with Clouds Today
      * Bugs
         * In the software
      * Cruft / Entropy
         * As OpenStack grows it will become more complicated and cruft/entropy will accrue
      * Hardware Failure
   * Objectives
      * Continuous Integration / Delivery
      * Encapsulate installation & upgrade process
      * Common API and infrastructure above & below cloud
   * TripleO Addressing the Cloud Issues
      * Bugs -> CI/CD
      * Cruft/Entropy -> Golden Images
      * Hardware Failure -> HA Setup
   * TripleO tools + Existing tools
   <div><img src="https://raw.github.com/metral/rpc_images/master/setup_tools.png" height="400" width="800"></div>
   * If you don't like the TripleO approach (blue spheres) you can merge it with the tools you do like and use and they should work in concert
      * Therefore, TripleO's components are not prescribed nor should prevent you from using something else
      * There approach is just to keep each module encapsulated as they see it from a deployment perspective
   * TripleO Components
      * Nova bare metal / Ironic
         * Handles provisioning
      * Heat
         * OpenStack orchestration engine to describe & deal with interactions of several machines
      * Custom Tools
         * diskimage-builder
            * Builds disk images
         * os-apply-config
            * Apply configurations
         * os-refresh-config
            * Handle orchestration & refreshing
         * os-collect-config
            * Collecting metadata
      * Aim of components
         * To be able to integrate with the OpenStack CI environment
         * To avoid playing favorites of the existing config management space
            * ie Not specific to Chef, Puppet, Salt, Juju etc
   * Detailed Components
      * Nova bare metal / Ironic
         * Traditionally, boots a VM in a hypervisor
         * Now, you can have a virtualization layer to control a physical machine via PXE & IPMI and use the same API based controls to provision bare metal
         * Note: Virtually doing PXE boot to KVM instances is now allowed (for testing) but no support for IPMI
      * Heat
         * Orchestration Engine
         * Focused on describing cloud resources that you need and the interrelationships between them
         * Not focused what will go on inside the system aka the VM's or bare metal, but it can deliver config metadata
         * The config management inside said system can take the metadata and then do other commands
      * os-config utilities
         * Collect
            * Grabs new metadata from Heat
            * Spit metadata out in JSON (without having to do say interact metadata service in OpenStack)
            * Has configurable hook as to what to run next
               * ie Trigger Chef to run recipes for proceeding steps
               * Or if you're using the TripleO stack, it will trigger os-refresh-config
         * Refresh
            * Understand that before you do tasks such as install and update systems, there are some lifecycle management that need to happen
               * ie Upgrade packages, reboot system
         * Apply
            * Single purpose: take metadata from the collect service and turn it into config files
            * It doesn't know anything about the services, or installing software
         * Notify Heat that the deploy is complete on the machine and provide it with any necessary information/metadata to continue with the rest of the orchestration
            * ie Install MySQL server, notify Heat its installed and that the root password is XYZ for the consequent step to use
      * Golden Images
         * Encapsulate a known good set of software
            * Excludes configuration & persistent state
         * Each image can be tested & deployed as-is
            * Because the config is not part of the image
         * Reduces ability for things to go wrong because with this concept you're just copying bytes, not applying configs
      * Deployment
         * Heat stack defines the entire cluster
         * Heat then drives the Nova API to deliver images to machines
         * Deployment Environments for same stacks include:
            * Dev: Virtual machines
            * CI/CD & Production: Bare metal Nova
      * Performance
         * Installation code executes at Image Build time
         * Deployment is fast
            * ie 6 minutes from powered off to working machine
               * 1/3 to almost 1/2 of this time is due to power on self-test that most enterprise-class hardware performs
   * Running a Cloud
      * Nova cant reliably run 2 different hypervisors in 1 cloud today
      * So we run 2+ clouds
         * Under Cloud
            * Bare metal cloud that runs on and owns all the hardware
         * Over Cloud
            * A regular VM based cloud running as a tenant on the bare metal cloud
         * Additional VM clouds can run as parallel tenants on the undercloud (ie one for testing, another for production etc)
        <div><img
        src="https://raw.github.com/metral/rpc_images/master/under_over_cloud.png" height="300" width="500"></div>
      * Under Cloud
         * Fully HA config of OpenStack to operate your bare metal
         * Self hosted: nodes in the control plane are tenants within it
         * Aiming for as few as 2 machines for the control plane
            * ie Run entire control plane in 1 machine and the 2nd be its HA node, forming an HA pair
         * The rest of the machines, be that 100s or 1000s are just bare metal resources that the under cloud can provision and install stuff on
            * Minimizes operational overhead
      * Overclouds
         * Are each themselves tenants in the undercloud
         * Fully HA KVM based OpenStack hosted by the undercloud
         * Orchestrated by Heat running in the undercloud
            * Each overcloud deployed can itself have Heat to deploy services
         * Can (optionally) use the same disk images for most services ie same image on both undercloud & overcloud
      * Installation of Undercloud
         * Current: special case of a normal deployment 
         * Scenario
            * Walk into DC with your laptop
            * You build a single disk image cloud with Heat + Nova Bare metal in a VM on your laptop
            * Bridge the laptop to the new DC network
            * Enroll the machines in the DC
            * Tell Heat that we want an HA config
            * Wait while the undercloud scales out to the machines enrolled
            * Switch off the VM image on the laptop
            * Tell Heat to recover from the loss of the laptop VM node (by scaling out again)
            * Deploy the overcloud as a tenant

## Community Information
* Use OpenStack infrastructure
  * gerrit code reviews
  * code base lives in github
  * weekly irc meetings
      * irc channel - #tripleo

## Rackspace Involvement
Minimal to None

Primarily driven by HP & RedHat

## Links
* [Wiki](https://wiki.openstack.org/wiki/TripleO)
* [Deploying TripleO](http://docs.openstack.org/developer/tripleo-incubator/deploying.html)
* [Blueprints](https://blueprints.launchpad.net/openstack?searchtext=tripleo)
* [Reviews](http://bit.ly/17UN3yC)

## Code Repositories
* [Source - TripleO Incubator](https://github.com/openstack/tripleo-incubator)
* [Source - os-collect-config](https://github.com/openstack/os-collect-config)
* [Source - os-apply-config](https://github.com/openstack/os-apply-config)
* [Source - os-refresh-config](https://github.com/openstack/os-refresh-config)
* [Source - diskimage-builder](https://github.com/openstack/diskimage-builder)
