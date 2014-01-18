
define galaxy::instance (
    $port,
    $source      = "git://github.com/jmchilton/galaxy-central.git",
    $users       = [],
    $admin_users = undef,
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
    ensure   => present,
    provider => git,
    source   => $source,
    user     => $name,
    require  => [ File["$base_dir" ] ],
  }

  user { "$name":
    ensure     => present,
    comment    => "www user for galaxy instance $name",
    membership => minimum,
    shell      => "/bin/bash",
    home       => "$base_dir",
  }

  exec { "$name user homedir":
    command => "/bin/cp -R /etc/skel $base_dir; /bin/chown -R $name $base_dir",
    creates => $base_dir,
    require => [
        User["$name"],
        File["/usr/share/galaxy"],
    ],
  }

  file { "$base_dir":
    ensure  => present,
    owner   => "$name",
    require => [Exec["$name user homedir"]],
  }

  file { "$project_dir/seed.py":
    content => template('galaxy/seed.py.erb'),
    owner   => $name,    
    require => Vcsrepo[$project_dir]
  }

  file { "$conf_dir":
    ensure  => directory,
    owner   => "$name",
    require => [
        File[$base_dir],
    ],
  }

  file { "$conf_dir/000_universe_wsgi.DEFAULT.ini":
    ensure => 'link',
    owner   => "$name",
    target => "$project_dir/universe_wsgi.ini.sample",
    require => [
        File[$conf_dir],
    ],
    before => Exec["$name_config"],
  }

  file { "$conf_dir/200_puppet_instance_wsgi.ini":
    content => template('galaxy/instance_properties.ini.erb'),
    owner   => "$name",
    require => [
        File[$conf_dir],
    ],
    before  => Exec["$name_config"],
  }

  file { "$conf_dir/100_puppet_site_wsgi.ini":
    ensure  => 'link',
    target  => "/usr/share/galaxy/site_wsgi.ini",
    owner   => "$name",
    require => File["/usr/share/galaxy/site_wsgi.ini"],
    before  => Exec["$name_config"],
  }

  file { $web_dir:
    ensure  => directory,
    owner   => "$name",
    require => [
        File[$base_dir],
    ]
  }

  file { "$web_dir/.htaccess":
    content => template('galaxy/htaccess.erb'),
    owner   => "$name",
    require => [ File[$web_dir] ],
    mode    => 744,
  }

  $apache_directories = [
    {path => $web_dir, allow_override => "all"},
  ]

  apache::vhost { "${name}.jmchilton.net":
    port           => '80',
    docroot        => "$web_dir",
    directories    => $apache_directories,
    require        => File[ "$web_dir/.htaccess" ],
  }

  file { "$base_dir/run.sh":
    content => template('galaxy/run_wrapper.sh.erb'),
    owner   => "$name",
    require => [ File[$base_dir] ],
    mode    => 744,
  }

  exec { "${name}_config":
    command => "python $project_dir/scripts/build_universe_config.py $conf_dir",
    cwd     => "$project_dir",
    creates => "$project_dir/universe_wsgi.ini",
    require => [
        User["$name"],
        File["/usr/share/galaxy"],
    ],
  }

  exec { "${name}_fetch_eggs":
    command => "python scripts/fetch_eggs.py",
    cwd     => "$project_dir",
    require => Exec["${name}_config"],
  }

  exec { "${name}_create_db":
    command => "sh create_db.sh",
    cwd     => "$project_dir",
    require => Exec["${name}_fetch_eggs"],
  }

  exec { "${name}_seed_db":
    command => "python seed.py",
    cwd     => "$project_dir",
    require => Exec["${name}_create_db"],
  }

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
}