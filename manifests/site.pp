
node 'jmchilton' {

  class { 'puppet::master':
  }

  class { 'puppet':
    certname => 'jmchilton',
  }

  class { 'linode':
  }

  class { 'jenkins':
    
  }

}
