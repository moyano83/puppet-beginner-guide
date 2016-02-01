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
The erb (which is the puppet inline template derived from ruby) file would contain placehorlders for the parameters in the form `<%= @site_name %>;` It is also possible to pass inline templates by defining the content as:
`content => inline_template("Six by nine is <%= 6 * 9 %>.\n")`
*Facts*
Puppet has a companion tool named facter that provides information such as IP Address, OS type, and so on. To see the list of facts available we can type ` ~$ facter`. We can include this parameters in a template like explained before, for example `source => inline_template("The fully qualified domain name is <%= @fqdn %>")`. It is possible to use also ruby expressions and ruby methods, i.e:
`$vagrant_vm = inline_template("<%= FileTest.exists?('/tmp/vagrant-puppet') ? 'true' : 'false' %>")`

# Chapter 7
It is possible to define groups of resources in arrays to simplify the declaration:
```
package{['php5-cli','php5-fpm','php5-pear']:
	ensure => installed,
	require => [Package['ntp'],File['/var/temp/conf.cfg']],
}
```
*Definitions*
With the `define` keyword, we can create resource types that can be used in puppet:
```
define script_job($hour, $minute) {
     file { "/usr/local/bin/${name}":
       source => "puppet:///modules/scripts/${name}",
       mode   => '0755',
     }
     cron { "Run ${name}":
       command => "/usr/local/bin/${name}",
       hour    => '${hour}',
       minute  => '${minute}',
     } 
}
```
After this, we can create a resource of type _script_job_ like this: 
```
script_job(30,00){'script_name':
<param> => '<value>',
...
}
```
To define optional parameters, we can assign them an initial value on the type definition.
*classes*
This syntax can also be applied to classes, that can have parameters in its definition, as well as default values for optional parameters.
```
class hadoop($role = 'node') {
     ...
}
```
If you use `require` instead of `import` in the node definition, it will behave just like include, except it specifies that everything in the required class must be applied immediately
Classes are singletons; that is, Puppet only allows one instance of a parameterized class to exist on a node at a time, definitions are not restricted in number.

# Chapter 8
*If statements*
``
if <expression>{
<secuence>
}elif <expression>{
<secuence>
}else{
<secuence>
}
``
In puppet, we also have the `unless` conditional, which is the negate version of if.

*Case expressions*
```
case EXPRESSION {
     CASE1 { BLOCK1 }
     CASE2 { BLOCK2 }
     CASE3 { BLOCK3 }
     ...
     default : { ... }
}
```
In this situation, `case` applies the first expression it matches. It is advised to have a default case, if nothing matches and it is supposed to, we can signal an error with the `fail` function. To match more cases in a single line:
```
'case1','case2'{...}
```
*Selectors*
Similar to case, but returns a value when it matches:
```
 $os_type = $::operatingsystem ? {
     'Ubuntu' => 'Debianlike',
     'RedHat' => 'Redhatlike',
     default => 'Unknown',
}
```
*Expressions*
Puppet logic operators `'==', '!=', '>', '<', '>=', '<=', 'if <value> in <value2>'`
*Operators*
 Puppet aritmetic operators `'+', '-', '/', '*'`
Bitwise operators `'<<'` which multiplies the number by 2 and `'>>'` which divides it by 2. 
*Regular expressions*
To test for a regular expression, we enclose the expression with `/` and the regex match operator is `=~`. The regex non match is `!~`. The regex language is the same as ruby, and they can be used in case matching. The captured expression is available in the variable $0, and if we enclose part of the expression in parenteses, the expression in parenteses can be captured as $1...$n where n is the number of parenteses included in the regex.
*Substitutios*
The function `regsubst(STRING, REGEX, REPLACEMENT` substitutes the captured `REGEX` in the `STRING` with the value `REPLACEMENT`. You can also use capture variables, as in conditional statements. Here, the contents of successive capture variables are named \1, \2, and so on.
*Arrays*
An array element can be recover onwards `<array>[<position>]` and backwards, being -1 the last element of the array. The operator `in` can be used to test membership.
*Hashes*
A hash is a set of paired elements, the first is the key and the second the value:
```
$<name>={
<key1> => <value1>
<key2> => <value2>
}
```
And recover elements by `$<name>[<key>]`. The key must be an String, but value can be any type. The `in` operator can be used to test membership.
wget $cloudera_tarball -O ./puppet/hadoop/files/hadoop.tar.gz

# Chapter 9
*Reporting*
To enable reporting in puppet, pass the flag `--summarize` to `puppet apply`, you can check the default value of this flag in `/etc/puppet/puppet.conf`: 
```
[main]
   report=true
```
or by executing `sudo puppet config print report`. The report files are writen in `/var/lib/puppet/` by default.
*Debug*
The debug flag `--debug` gives you more information than with the normal `puppet apply` execution.
*noop*
The `--noop` flag set the execution in dry-run-mode, which means that puppet won't change any change on the system. 
*Syntax checking*
Puppet has a tool to validate the syntax, that is available with the command `puppet parser validate <filename>`.
*Notify resources*
The notify resource prints out its name to the console when you run Puppet:
`notify{'<text to print in the screen>'}`
*Exec output*
The _exec_ resource has a property _logoutput_ that can be set to true to output the result of a command even if it is successful. It has also a property to specify the exit status of the command: _returns_ (0 for successful execution, or any other numerical value).
*Monitoring*
A common technique to monitor the status of the servers managed by puppet is to write a file in each of the servers (for example the timestamp in /tmp), so it can be checked by alert systems like nagios. 
*Errors*
There is two type of errors, compilation errors (which are specified on the screen) and errors from commands executed by _exec_. 

# Chapter 10
*Puppet Style*
Good practices on writing puppet manifests:
- Break your code into modules of independent chunks of functionality.
- Refactor common code into definitions.
- Keep node declarations simple, business logic should be in modules.
- Use `puppet-lint` tool to checks your manifest to make sure it conforms to the Puppet Labs official style guidelines.
*Useful learning resources*
- [Puppet Type Reference](http://docs.puppetlabs.com/references/latest/type.html)
- [Puppet Language Reference](http://docs.puppetlabs.com/puppet/3/reference/lang_summary.html)
- [Core Facts Reference](http://docs.puppetlabs.com/facter/latest/core_facts.html)
- [Puppet style](http://docs.puppetlabs.com/guides/style_guide.html)
- [Puppet Forge](http://forge.puppetlabs.com/) Community repository for puppet code.
