class puppet(
  $certname,
  $puppet_server = "puppet.jmchilton.net"
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

  file { '/usr/local/bin/update_puppet.bash':
    content => template('puppet/update_puppet.bash.erb'),
    mode    => 755,
  }

  sudo::conf { 'update_puppet_sudo':
    content => 'ALL  ALL = (puppet) NOPASSWD: /usr/local/bin/update_puppet.bash'
  }

}
