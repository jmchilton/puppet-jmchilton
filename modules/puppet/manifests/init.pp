class puppet(
  $certname,
  $puppet_server = "puppet.jmchilton.net",
) {

  file { '/etc/default/puppet' : 
    content => 'START=yes\nDAEMON_OPTS=""'
  }

  service { 'puppet':
    ensure => 'running',
  }

  file { '/etc/puppet/puppet.conf':
    content => template('puppet/puppet.conf.erb'),
  }

}
