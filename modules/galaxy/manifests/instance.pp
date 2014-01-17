
define galaxy::instance (
    $port,
    $source      = "git://github.com/jmchilton/galaxy-central.git",
) {
  if ! defined(Class['galaxy']) {
    fail('You must include the galaxy base class before creating any galaxy instances')
  }

  $base_dir    = "/usr/share/galaxy/$name"
  $home_dir    = $base_dir
  $project_dir = "${base_dir}/galaxy-central"
  $web_dir     = "${base_dir}/web"
  $conf_dir    = "${base_dir}/config"


  vcsrepo { "$project_dir":
    ensure => present,
    provider => git,
    source => $source,
    user => $name,
    require => User[ $name ],
  }

  user { "$name":
    ensure => present,
    comment => "www user for galaxy instance $name",
    membership => minimum,
    shell => "/bin/bash",
    home => "$base_dir",
  }

  exec { "$name user homedir":
    command => "/bin/cp -R /etc/skel $base_dir; /bin/chown -R $name $base_dir",
    creates => $base_dir,
    require => [
        User["$name"],
        File["/usr/share/galaxy"],
    ],
  }

  file { "$conf_dir":
    ensure => directory,
    require => [
        File[$base_dir],
    ],
  }

  file { "$conf_dir/000_universe_wsgi.DEFAULT.ini":
    ensure => 'link',
    target => "$project_dir/universe_wsgi.ini.sample",
    require => [
        File[$conf_dir],
    ],
  }

  file { "$conf_dir/200_puppet_instance_wsgi.ini":
    content => template('galaxy/instance_properties.ini.erb'),
    require => [
        File[$conf_dir],
    ],
  }

  file { "$conf_dir/100_puppet_site_wsgi.ini":
    ensure => 'link',
    target => "/usr/share/galaxy/site_wsgi.ini"
  }

  file { $web_dir:
    ensure => directory,
    require => [
        File[$base_dir],
    ]
  }

  file { "$web_dir/htaccess":
    content => template('galaxy/htaccess.erb'),
    require => [ File[$web_dir] ],
    mode    => 744,
  }

  apache::vhost { "${name}.jmchilton.net":
    port           => '80',
    docroot        => "$web_dir",
    require        => File[ "$web_dir/htaccess" ],
  }

  file { "$base_dir/run.sh":
    content => template('galaxy/run_wrapper.sh.erb'),
    require => [ File[$base_dir] ],
    mode    => 744,
  }

}