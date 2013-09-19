require 'spec_helper'

describe 'jmchilton' do
  let(:facts) { 
    { :operatingsystem => 'Ubuntu', 
      :osfamily => 'Debian', 
      :kernel => 'Linux', 
      :puppetversion => '2.6.1'} 
    }
  
  it { should include_class('puppet') }
  it { should include_class('puppet::master') } 
  
  it "should configure puppet properly" do
    verify_contents(subject, '/etc/puppet/puppet.conf',
                    ['certname=jmchilton'])
  end

  it { should include_class('jenkins') }

end
