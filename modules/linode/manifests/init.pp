
class linode {

  file { '/etc/fstab':
    content => template('linode/fstab.erb'),
  }

}
