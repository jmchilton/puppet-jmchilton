
class jmchilton-jenkins() {
  $jenkins_port = '9000'


  class { 'jenkins': 
    config_hash => { 'HTTP_PORT' => { 'value' => $jenkins_port } },
  }

  apache::vhost { 'jenkins.jmchilton.net':
    port           => '80',
    proxy_dest     => "http://localhost:$jenkins_port",
    docroot        => $web_dir,
  }

  # Required for legacy tracking of galaxy-central at github.com/jmchilton/galaxy-central
  # newer version of git-export-hg produces different hashes.
  file { "/opt/jenkins-legacy":
    ensure => 'directory',
  }

  file { "/opt/jenkins-legacy/git-remote-hg":
    source => "puppet:///modules/jmchilton-jenkins/legacy-git-remote-hg",
    mode   => 0755,
  }

}