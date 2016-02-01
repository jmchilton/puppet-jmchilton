class puppet(
  $certname,
  $puppet_server = "puppet.jmchilton.org"
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

  # Allow anyone (jenkins) to refresh puppet and apply configuration.
  sudo::conf { 'update_puppet_sudo':
    content => 'ALL  ALL = (puppet) NOPASSWD: /usr/local/bin/update_puppet.bash'
  }

  sudo::conf { 'run_puppet_sudo':
    content => 'ALL  ALL = (ALL:ALL) NOPASSWD: /usr/bin/puppet agent -t'
  }


}
