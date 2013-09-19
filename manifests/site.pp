$extlookup_datadir = "/data/puppet"
$extlookup_precedence = [$environment, 'credentials']

node 'jmchilton' {

  class { 'puppet::master':
  }

  class { 'puppet':
    certname => 'jmchilton',
  }

  class { 'linode':
  }

  # Not working on Puppet 2.7.1 and Ubuntu 10.10.
  
  #class { 'jenkins':    
  #}

  #class { 'mysql::server':
  #  config_hash => { 'root_password' => extlookup('mysql_root_password') }
  #}

  #apache::vhost { 'www.jmchilton.net':
  #  port    => '80',
  #  docroot => '/var/www/',
  #}


}
