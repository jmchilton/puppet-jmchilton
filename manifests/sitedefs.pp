
class dev_machine {
  include debian_base

  package { 'git':

  }

  package { 'mercurial':

  }

  package { 'subversion':
  }

  package { 'sqlite3':
  }

  # Packages needed for RVM.
  package {['libbison-dev', 'ncurses-dev', 'automake', 'libtool', 'bison', 'libgdbm-dev', 'libffi-dev', 'libsqlite3-dev' ]:
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