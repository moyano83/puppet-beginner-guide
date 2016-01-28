node 'demo' {
	include nginx
	include git
	cron{'scheduled exec':
	command =>'/usr/bin/rsync -az /var/www/cat-pictures/ /cat-pictures-backup/',
	hour => '16',
	minute => '20',
	}
	file{'/var/www/cat-pictures':
	ensure => directory,
	}
	file{'/var/www/cat-pictures/img':
	source => 'puppet:///modules/cat-pictures/img',
	recurse => true,
	require => File['/var/www/cat-pictures'],
	}
}
