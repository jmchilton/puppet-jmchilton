[![Build Status](http://jenkins.jmchilton.net/job/jmchilton_puppet/badge/icon)](http://jenkins.jmchilton.net/job/jmchilton_puppet/)

John Chilton's puppet repository powering jmchilton.net and related
sites and servers.

Testing:

gem install puppetlabs_spec_helper rspec-puppet puppet


Boot Strapping A Server:

Client:
sudo puppet agent --certname jmchilton --server puppet.jmchilton.net --waitforcert 60 --test

Server:
sudo puppet cert --sign jmchilton  

Client:
sudo puppet agent --certname jmchilton --server puppet.jmchilton.net --waitforcert 60 --test
