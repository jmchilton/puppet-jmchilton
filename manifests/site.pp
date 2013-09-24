import "sitedefs.pp"
$extlookup_datadir = "/data/puppet"
$extlookup_precedence = [$environment, 'credentials']

$data_dir = '/data'
$web_dir = '/usr/share/www'
$jenkins_port = '9000'

node 'jmchilton' {
  # TODO: Create a john user.
  # TODO: /data/msyql  needs to be owned by mysql, may not be if gid/uid is changed.
  # TODO: Init script for clojure webapp.
  # TODO: fstab+mounts handling (https://github.com/AlexCline/puppet-mounts)
  # TODO: Migrate jenkins database+jobs data to /data so it survives server rebuilds.
  # TODO: nagios configuration.
  # TODO: Artifactory configuration.

  include dev_machine

  class { 'puppet::master':
  }

  class { 'puppet':
    certname => 'jmchilton',
  }

  class { 'linode':
  }

  class { 'jenkins': 
    config_hash => { 'HTTP_PORT' => { 'value' => $jenkins_port } },
  }

  apache::vhost { 'jenkins.jmchilton.net':
    port           => '80',
    proxy_dest     => "http://localhost:$jenkins_port",
    docroot        => $web_dir,
  }

  class { 'mysql::server':
    config_hash => { 'root_password' => extlookup('mysql_root_password', 'defaultPass'),
                     'datadir' => '/data/mysql' }
  }

  file { $web_dir:
    ensure => 'directory',
    mode    => 755,
  }

  file { "$web_dir/.htaccess":
    content => template('site/htaccess.erb'),
    require => [File[$web_dir]],
    mode    => 744,
  }

  $root_apache_aliases = [
    {alias => '/sqlinject', path => "$data_dir/sqlinject"},
    {alias => '/blog', path => "$data_dir/blog"}
  ]

  $root_apache_directories = [
    {path => "$data_dir/sqlinject"},
    {path => "$data_dir/blog"},
    {path => $web_dir, allow_override => "all"}
  ]

  class { 'apache': 
    default_vhost  => false,
    default_mods => false,
    mpm_module => 'prefork',
  }

  apache::vhost { 'jmchilton.net':
    port           => '80',
    docroot        => $web_dir,
    aliases        => $root_apache_aliases,
    directories    => $root_apache_directories,
    default_vhost  => true,
    require        => File["$web_dir/.htaccess"],
  }

  include apache::mod::rewrite
  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::proxy_html
  include apache::mod::mime
  include apache::mod::dir
  include apache::mod::alias

  include apache::mod::php

  package { 'php5':
  }

  # Needed by wordpress
  package { 'php5-mysql':
  }

  # Needed by sqlinject
  package{ 'php5-sqlite':
  }

  class { 'site':
  }

}
