node 'demo' {
	include git
	cron{'scheduled exec':
	command =>'/usr/bin/rsync -az /var/www/cat-pictures/ /cat-pictures-backup/',
	hour => '16',
	minute => '20',
	}
	nginx::website { 'adorable-animals':
        site_domain => 'adorable-animals.com',
        }
	file{'/var/www/cat-pictures':
	ensure => directory,
	}
	file{'/var/www/cat-pictures/img':
	source => 'puppet:///modules/cat-pictures/img',
	recurse => true,
	require => File['/var/www/cat-pictures'],
	}
class { 'ntp':
           server => 'us.pool.ntp.org',
         }
	file{'/tmp/test':
           content => 'Zaphod Beeblebrox, this is a very large drink',
         }
}
