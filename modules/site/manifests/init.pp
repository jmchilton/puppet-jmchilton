
class site(
) {

  user { "jmchilton":
    ensure => present,
    comment => "www user for jmchilton.net",
    gid => "jmchilton",
    membership => minimum,
    shell => "/bin/bash",
    home => "/usr/share/jmchilton",
  }

  exec { "jmchilton homedir":
    command => "/bin/cp -R /etc/skel /usr/share/jmchilton; /bin/chown -R jmchilton:jmchilton /usr/share/jmchilton",
    creates => "/usr/share/jmchilton",
    require => User["jmchilton"],
  }

  vcsrepo { "/usr/share/jmchilton/site":
    ensure => present,
    provider => git,
    source => "git://github.com/jmchilton/jmchilton.net.git",
    user => 'jmchilton',
    require => User['jmchilton'],
  }

}