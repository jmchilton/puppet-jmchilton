$extlookup_datadir = "/data/puppet"
$extlookup_precedence = [$environment, 'credentials']

$data_dir = '/data'
$web_dir = '/usr/share/www'


node 'jmchilton' {

  class { 'puppet::master':
  }

  class { 'puppet':
    certname => 'jmchilton',
  }

  class { 'linode':
  }

  # Not working on Puppet 2.7.1 and Ubuntu 10.10.
  
  class { 'jenkins':    
  }

  class { 'mysql::server':
    config_hash => { 'root_password' => extlookup('mysql_root_password', 'defaultPass') }
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
    {alias => 'sqlinject', path => "$data_dir/sqlinject"},
    {alias => 'blog', path => "$data_dir/blog"}
  ]

  $root_apache_directories = [
    {path => "$data_dir/sqlinject"},
    {path => "$data_dir/blog"}
  ]

  class { 'apache': 
  }

  apache::vhost { 'jmchilton.net':
    port           => '80',
    docroot        => $web_dir,
    aliases        => $root_apache_aliases,
    directories    => $root_apache_directories,
    default_vhost  => true,
    require        => File["$web_dir/.htaccess"],
  }

  apache::mod { 'rewrite': }
  apache::mod { 'proxy': }
  apache::mod { 'proxy_html': }

}
