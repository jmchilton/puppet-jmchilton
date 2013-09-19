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

  #class { 'jenkins':    
  #}

  class { 'mysql::server':
    config_hash => { 'root_password' => extlookup('mysql_root_password') }
  }

}
