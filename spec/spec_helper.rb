require 'puppet'
require 'rspec'
require 'rspec-puppet'

def verify_contents(subject, title, expected_lines)
  content = subject.resource('file', title).send(:parameters)[:content]
  (content.split("\n") & expected_lines).should == expected_lines
end

PARENT_DIR=File.join(File.dirname(__FILE__), "..")
RSpec.configure do |c|
  c.module_path = File.expand_path(File.join(PARENT_DIR, "modules"))
  c.manifest_dir = File.expand_path(File.join(PARENT_DIR, "manifests"))
  c.manifest = c.manifest_dir + "/" + "site.pp"
end
