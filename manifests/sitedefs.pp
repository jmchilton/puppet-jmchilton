
class dev_machine {
  include base

  package {'git':
  }

  package {'mercurial':
  }

}

class base {
  
  class { 'sudo': }

  sudo::conf { 'john':
    content => 'john    ALL=(ALL:ALL) ALL',
  }

}