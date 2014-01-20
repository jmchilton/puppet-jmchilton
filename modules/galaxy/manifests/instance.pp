
define galaxy::instance (
    $port,
    $source      = "git://github.com/jmchilton/galaxy-central.git",
    $branch      = "master",
    $users       = [],
    $admin_users = undef,
    $brand       = undef,
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
    revision => $branch,
    require  => File["$base_dir" ],
  }

  file { "$project_dir/static/${name}_welcome.html":
    content => template('galaxy/welcome.html.erb'),  
    owner   => $name,
    require => Vcsrepo["$project_dir"],
  }

  file { "$project_dir/job_conf.xml":
    content => template("galaxy/job_conf.xml.erb"),
    owner   => $name,
    require => Vcsrepo["$project_dir"],
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
    require => Vcsrepo[$project_dir],
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
    before => Exec["${name}_config"],
  }

  file { "$conf_dir/200_puppet_instance_wsgi.ini":
    content => template('galaxy/instance_properties.ini.erb'),
    owner   => "$name",
    require => [
        File[$conf_dir],
    ],
    before  => Exec["${name}_config"],
  }

  file { "$conf_dir/100_puppet_site_wsgi.ini":
    ensure  => 'link',
    target  => "/usr/share/galaxy/site_wsgi.ini",
    owner   => "$name",
    require => File["/usr/share/galaxy/site_wsgi.ini"],
    before  => Exec["${name}_config"],
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
    docroot        => $web_dir,
    directories    => $apache_directories,
    require        => File[ "$web_dir/.htaccess" ],
    custom_fragment => template("galaxy/galaxy_instance_fragment.erb"),
  }

  file { "$base_dir/run.sh":
    content => template('galaxy/run_wrapper.sh.erb'),
    owner   => "$name",
    require => [ File[$base_dir] ],
    mode    => 744,
  }

  exec { "${name}_config":
    command => "/usr/bin/python $project_dir/scripts/build_universe_config.py $conf_dir",
    cwd     => "$project_dir",
    creates => "$project_dir/universe_wsgi.ini",
    require => [
        User["$name"],
        File["/usr/share/galaxy"],
    ],
    user    => "$name"
  }

  exec { "${name}_fetch_eggs":
    command => "/usr/bin/python scripts/fetch_eggs.py",
    cwd     => "$project_dir",
    require => Exec["${name}_config"],
    user    => "$name"
  }

  exec { "${name}_create_db":
    command => "/bin/sh create_db.sh",
    cwd     => "$project_dir",
    require => Exec["${name}_fetch_eggs"],
    user    => "$name"
  }

  exec { "${name}_seed_db":
    command => "/usr/bin/python seed.py",
    cwd     => "$project_dir",
    require => Exec["${name}_create_db"],
    user    => "$name"
  }

}