# This repo was created to code the examples and exercises from the book Puppet 3 Beginner's Guide
##KEY CONCEPTS
- Puppet is a declarative language, not procedural. The puppet language defines units called resources, each of which describes some aspect of the system: users, files, software packages, and so on.
- A resource is a bit of configuration that can be managed by puppet: files, users, packages...
- A node is the Puppet term for an individual machine that has a Puppet configuration
- A package installs, updates, or removes a package for you, using the system native package management tools (apt, yum, zypp...)
- A service resources manage daemons, or background processes, on the server.

# Chapter 2
*Manifests*
The declaration of a resource is as follows:
`RESOURCE { NAME: ATTRIBUTE => VALUE, ...}`
The declaration of a node is similar:
```
node NODENAME{
RESOURCE
RESOURCE}
```
By convention, the top-level puppet file is called site.pp

# Chapter 3
It is possible to define a module and apply them to a group of nodes. To add a module create the folder structure `<puppet_folder>/modules/<module_name>/manifests/` and add a manifest file called `init.pp` inside. You can import it into the module by placing `include <module_name>` inside the node declaration. When invoking the `puppet apply` command, we should provide the parameter `--modulepath=<absolute_path_to_modules>`.

To define a service:
```
service {'<service_name>':
	require => Package['<package_name>'],
	ensure => running # This tells puppet what the state of the service should be
	enable => true # Specifies if the service should be started at boot time
	hasstatus => false # this check the status of the service by the ps command, not the status argument 
	pattern => '<pattern to use in case the service name doesn't appear in the process list'
	status => '<command to run that will return an appropriate exit status 0=running, any other=not running>'
	[start | stop | restart | reload] => '<command to perform the operation>'
}
```
*File Replacement*
We can replace the contents of a file by specifying the attribute `source`. The file defined in the name would be replaced by the source file.
```
file { '<name>':
     source => 'puppet:///modules/MODULENAME/FILENAME', # this is translated to modules/MODULENAME/ files/FILENAME
     notify => Service['<service_name>'], # restart this service if the file changes
}
```
