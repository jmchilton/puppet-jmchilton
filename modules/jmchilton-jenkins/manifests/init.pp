# Setup link for /var/lib/jenkins/.m2/settings.xml -> /data/java_config/settings.xml

class jmchilton-jenkins() {
  $jenkins_port = '9000'


  class { 'jenkins': 
    config_hash => { 'HTTP_PORT' => { 'value' => $jenkins_port } },
  }

  apache::vhost { 'jenkins.jmchilton.org':
    port           => '80',
    #proxy_dest     => "http://localhost:$jenkins_port",
    docroot        => $web_dir,
  }

  concat::fragment { "jenkins.jmchilton.org-proxy":
    target  => '25-jenkins.jmchilton.org.conf',
    order => 11,
    content => '  ## Proxy rules
  ProxyRequests Off
  ProxyPass          / http://localhost:9000/ nocanon
  ProxyPassReverse / http://localhost:9000/
  AllowEncodedSlashes NoDecode'
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

  # Probably don't need this anymore.
  #package { "openjdk-7-jdk":
  #}

}