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
# Chapter 4 
Git allows to distribute puppet files among different severs and have them update their configuration automatically. 

# Chapter 5
Puppet allows you to create and manage users, to do this define a user in a node as follows:
```
node '<nodename>'{
	user{'<username>':
	ensure => present,
	home => '<path to users home>'
	managehome => true, #this attribute tells puppet to create the dir
	password => '<userpassword>' #Althought this is not recommended, use ssh. To disable password login put a * in this field
	}
}
```
To define an ssh key resource, you define the type ssh_authorized_key:
```
ssh_authorized_key { '<name_key>':
        user => '<username>',
        type => '<encoding type>',
	key => '<the rsa public key without the ssh-keygen beginning or the  <user>@<host> end>' #To disable a user ssh, leave this property blank
}
```

# Chapter 6
*commands*
Commands can be executed with the `exec` command. Puppet executes the commands with the `exec` resource in linux, full paths to command is advised.
```
exec{'<name>':
command => '<the command to run>'
cwd => '<The path from where to run the command>'
creates => '<full path to a file, if file exists the command is not executed>'
unless => '<command to run, if exit code=0 command is not executed>'
ifonly => '<command to run, if exit code=0, command is executed>'
refreshonly => '[true/false]#command is triggered by subscribe/notify from other resource'
subscribe => '<path to file that if changes and refreshonly=true, would trigger the execution of this command>'
require => '<dependencies. i.e: Exec[<exec_name>]>'
path => '<paths to search for commands to avoid putting the full path>'
} 

If you want to specify a set of default search paths for all exec resources, you can put this in your main _site.pp_ file, in this case, the format will be:
```
#Note the capital E
Exec{#No exec name
path => '<paths>'
}
```
*cronjobs*
It is possible to schedule jobs for execution by using the cron resource type like this:
```
cron{'<name>':
command => '<command>',
hour => '<hours from 0 to 23>',
minute =>'<minutes from 0 to 59>',
weekday => '<week of the day>',
month => '<Month>',
monthday => '<day of the month>',
user => '<user to add the cron to, defaults to root>'
}
```
Any cron attribute not specified, defaults to *. 
A file can be copied recursively by adding the attribute `recurse => true` 
*templates*
It is possible to parameterize puppet files to create templates:
```
$site_name = 'cat-pictures'
$site_domain = 'cat-pictures.com'
file { '/etc/nginx/sites-enabled/cat-pictures.conf':
	content => template('nginx/vhost.conf.erb'),
        notify  => Service['nginx'],
}
```
The erb file would contain placehorlders for the parameters in the form `<%= @site_name %>;` It is also possible to pass inline templates by defining the content as:
`content => inline_template("Six by nine is <%= 6 * 9 %>.\n")`
*Facts*
Puppet has a companion tool named facter that provides information such as IP Address, OS type, and so on. To see the list of facts available we can type ` ~$ facter`.
