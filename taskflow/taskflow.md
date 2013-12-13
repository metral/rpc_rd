# Project TaskFlow

Date: 12/13/2013
## Elevator Pitch
TaskFlow is Python library for OpenStack that helps make task execution easy, consistent,
and reliable. TaskFlow allows the creation of lightweight task objects and/or
functions that are combined together into flows (aka: workflows).

It includes components for running these flows in a manner that can be stopped, resumed,
and safely reverted. Projects implemented using the Taskflow library enjoy
added state resiliency, and fault tolerance. The library also simplifies crash
recovery for resumption of tasks, flows, and jobs. With Taskflow, interrupted
actions may be resumed or rolled back automatically when a manager process is
resumed.

## Project Maturity
* **OpenStack Program Status:** Library
* **Usability Timeframe:**
  * Suggestion: Experimental 

## Dependencies
* Requires: Nova, Cinder (depending on project being used with)

## Example Use Cases
* Cloud Admin wants help when upgrading or performing maitenance to track the actions,
tasks, and there associated states so that when the services are restarted
(even after the services software is upgraded) the service can easily resume
(or rollback) the tasks that were interrupted when the stop command was
triggered
* Cloud User wants progress/status tracking of the actions a project is doing
via TaskFlows notification system

## Misc Notes
* Currently are in active integration with Nova & Cinder
* Planned integration with Heat & Glance
* Why TaskFlow?

    * OpenStack code has grown organically, and does not have a standard and
    consistent way to perform sequences of code in a way that can be safely resumed
    or rolled back if the calling process is unexpectedly terminated while the code
    is busy doing something. Most projects don't even attempt to make tasks
    restartable, or revertible. There are numerous failure scenarios that are
    simply skipped and/or recovery scenarios which are not possible in today's
    code. Taskflow makes it easy to address these concerns.
* Structure

    * Tasks
        * A task is the smallest possible unit of work that can have a rollback sequence
    associated with it. It could be as simple as a single API call, or a block of
    code (although the later is not always preferable since a block of code usually
    is hard to resume or revert, especially if it contains complicated logic).

    * Flows
        * A flow is a structure that links one or more tasks together in an ordered
    sequence. When a flow rolls back, it executes the rollback code for each of
    it's child tasks using whatever reverting mechanism the task has defined as
    applicable to reverting the logic it applied.

    * Patterns
        * Also known as: how you structure your work to be done (via tasks and flows) in
    a programmatic manner.
* Thoughts
    * TaskFlow is set to be a language/schema (similar to that of Chef &
    Puppet) but for task management with a stateful capability
    * It will be interesting to see how TaskFlow integrates with the core
    projects to handle, resolve and carry out actions that currently leave
    OpenStack in unknown states which require a Cloud Admin to resolve manually
* Convection
    * PROPOSAL ONLY: TaskSystem-as-a-Service
    * Convection is a proposal for a new open sourced TaskSystem-as-a-Service
    project for cloud workloads
    * Convection could be a public facing API service that provides task and
    state management capabilities, enabling OpenStack API consumers to build
    complex multi-step applications running on an OpenStack cloud which could
    be a public cloud, private cloud, or a hybrid cloud
    * TaskFlow-as-a-Service is not Orchestration
        * Orchestration (the purpose of project Heat), is not the same as Task Flow
        management.
        * A project such as Heat could leverage a Task Flow service or
        code Library.
        * A Task Flow service could leverage Heat in that one task of a
        meta-task-flow could be to call Heat to spin up a stack.
        * Task Flow is concerned with "task state management and "storing of "rules and order" for
        task execution. The task system may or may not actually take responsibility
        for executing the tasks.
        * Orchestration is concerned with intelligently
        creating, organizing, connecting, and coordinating cloud based
        resources, which may involve creating a task flow and/or executing
        tasks.
* Mistral
    * Mistral is a new OpenStack service designed for task flow control,
    scheduling, and execution. The project will implement the Convection
    proposal. The project will allow integration with the existing task flow
    library


## Community Information
* Use OpenStack infrastructure
  * gerrit code reviews
  * code base lives in github
  * weekly irc meetings
      * irc channel - #openstack-state-management

## Rackspace Involvement
Almost 50% of core contributors are Rackers

* Adrian Otto (Rackspace)
* Keith Bray (Rackspace)
* Jessica Lucci (Rackspace)
* Kevin Chen (Rackspace)

## Links
* [Wiki](https://wiki.openstack.org/wiki/TaskFlow)
* [Convection](https://wiki.openstack.org/wiki/Convection)
* [Libray Usage Examples](https://github.com/stackforge/taskflow/tree/master/taskflow/examples)
* [Launchpad](https://launchpad.net/taskflow)
* [Mistral Announcement](http://www.mirantis.com/blog/announcing-mistral-task-flow-as-a-service/)

## Code Repositories
* [Source](http://github.com/stackforge/taskflow)
* [Pypi Package](https://pypi.python.org/pypi/taskflow/0.1.1)
