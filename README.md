# Demo of External Cookbooks through Chef Automate

## Purpose

The default behavior of [delivery-truck](https://github.com/chef-cookbooks/delivery-truck) is to use Berkshelf to evaluate cookbook dependencies, and upload those to the Chef Server.  While this is delightful because it _just works(tm)_, it introduces several problems as well.

Note that as a Chef Automate customer, there's a good chance that you have talked to the Chef Customer Success team.  If so, you probably have a model implemented that at least partially shields you from these issues.

1. All Code Should be Code Reviewed
First and foremost, all code running inside your network should be code reviewed by people within your organization.  You are responsible for your Company's security.  We default to a state of trust, but should always verify that trust.  Therefore, we should be code-reviewing any external code we're bringing into our environment prior to ever executing it.

2. It violates the [Principle of Least Astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment) (Also referred to as The Principle of Least Surprises)
Users of Chef Automate expect that any cookbook running in any given environment is controlled by the pipeline.  Berkshelf in its default configuration pulls cookbooks from the public supermarket and publishes them untested to the Chef Server.  Because these cookbooks reach the Chef server outside the scope of the pipeline, they are _not pinned_ to any environment by default.

Let that sync in for a minute.

Thought about it for a minute?  Good.  This means that any changes to community cookbooks that are resolved from Berkshelf will immediately run in every environment connected to your Automate Chef Server, as soon as they are published.  Of course, there are ways to prevent that (such as using Berkshelf to control your environment pinnings), but these patterns are hard to implement across large teams.

3. It is not repeatable
Having a Testable, Promotable artifact relies on repeatable builds.  You can check-in your Berksfile to control dependent versions being uploaded, but this has no impact on the versions running on your system.  This means it's hard to repeat a build that includes community cookbooks.

There are several workarounds to this, including the [Environment Cookbook Pattern](http://blog.vialstudios.com/the-environment-cookbook-pattern/), or using Berkshelf to introduce environment pinnings.

4. Dependency Solving is Hard
Dependency solving is hard, and it gets harder as the graph grows.  The way you combat this (unless you have unlimited hardware resources), is to reduce the size of the graph.  If you pin _every_ cookbook running on any node, then dependency solving is easy - there's one possible combination.  This is hard to do by hand because Dependency Solving is Hard.  The [Environment Cookbook Pattern](http://blog.vialstudios.com/the-environment-cookbook-pattern/) is a great way to do this, as are Policyfiles.  Or, you know, have your CI/CD tool do it for you.  By ensuring _every_ cookbook that runs in any environment runs through your pipeline, you get pinned good, _tested_ releases pinned to every environment.  This means dependency solving is no longer a problem.
