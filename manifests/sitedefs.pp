
class dev_machine {
  include debian_base

  package { 'git':

  }

  package { 'mercurial':

  }

}

class debian_base {
  include base

  package { 'emacs24-nox':

  }

  package { 'wajig':

  }

}

class base {
  
  class { 'sudo': }

  sudo::conf { 'john':
    content => 'john    ALL=(ALL:ALL) ALL',
  }

}