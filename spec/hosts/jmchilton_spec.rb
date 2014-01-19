require 'spec_helper'

describe 'jmchilton' do
  let(:facts) { 
    { :operatingsystem => 'Ubuntu', 
      :operatingsystemrelease => '12.04',
      :osfamily => 'Debian', 
      :kernel => 'Linux', 
      :puppetversion => '2.6.1',
      :concat_basedir => '.',  # Seems kindof hacky.
    } 
  }
  
  it { should include_class('puppet') }
  it { should include_class('puppet::master') } 
  
  it "should configure puppet properly" do
    verify_contents(subject, '/etc/puppet/puppet.conf',
                    ['certname=jmchilton'])
  end

  it "should set up blog alias" do
    verify_contents(subject, '10-jmchilton.net.conf',
        ['  Alias /blog /data/blog',
         '  Alias /sqlinject /data/sqlinject'
        ]
    )
  end

  it "should set proxy pass for apache to jenkins" do
    verify_contents(subject, '25-jenkins.jmchilton.net.conf',
      ['  ProxyPass        / http://localhost:9000/',
       '  ProxyPassReverse / http://localhost:9000/',
      ]
    )
  end

  it "should proxy to clojure on 8080 properly" do
    verify_contents(subject, '/usr/share/www/.htaccess',
        ['RewriteEngine On',
        'RewriteRule ^$ http://localhost:8080/index.html [P]',
        'RewriteRule ^(.*)$ http://localhost:8080/$1 [P]']
    )
  end

  it { should include_class('jenkins') }

  it { should include_class('galaxy') }
  it { should contain_file('/usr/share/galaxy') }
  it { should contain_file('/usr/share/galaxy/gx1/web') }
  it { should contain_user('gx1').with( {
    'home' => '/usr/share/galaxy/gx1',
  } ) }
  it { should contain_file('/usr/share/galaxy/gx1/config')
  }

end
