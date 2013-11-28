
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

  package { 'curl':
  }

  package { 'libcurl4-openssl-dev':
  }

  exec {
    'download git-remote-hg':
      command => '/usr/bin/wget https://raw.github.com/felipec/git/fc/master/git-remote-hg.py -O git-remote-hg',
      cwd     => '/usr/local/bin',
      creates => '/usr/local/bin/git-remote-hg',
      ;

    'make git-remote-hg executable':
      command => '/bin/chmod +x /usr/local/bin/git-remote-hg',
      require => Exec['download git-remote-hg'],
      ;
  }

  package { 'libssl-dev':
  }

  package { 'virtualenv':
  }

  package { 'python3':
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

  user { 'john':
    ensure  => 'present',
    shell   => '/bin/zsh',
    home    => '/home/john',
    require => Group['john'],
  }

  group { 'john':
    ensure  => 'present'
  }

  exec { 'john homedir':
    command => "/bin/cp -R /etc/skel /home/john; /bin/chown -R john:john /home/john",
    creates => "/home/john",
    require => User["john"],
  }

  sudo::conf { 'john':
    content => 'john    ALL=(ALL:ALL) ALL',
  }

}