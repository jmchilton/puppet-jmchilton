
class galaxy(
    $id_secret,
    $master_api_key,
) {

    file { "/usr/share/galaxy":
        ensure => "directory",
    }

    file { "/usr/share/galaxy/site_wsgi.ini":
        content => template('galaxy/site_properties.ini.erb'),
    }

}