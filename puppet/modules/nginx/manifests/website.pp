#Manage an Nginx virtual host
define nginx::website($site_domain){
include nginx
$site_name=$name
file { "/etc/nginx/sites-enabled/${site_name}.conf":
           content => template('nginx/vhost.conf.erb'),
           notify  => Service['nginx'],
     }
}
