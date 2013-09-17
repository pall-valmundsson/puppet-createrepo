require 'spec_helper_system'

describe "basic tests:" do
  context 'make sure the module is installed' do
    context shell 'ls /etc/puppet/modules/createrepo' do
      its(:stdout) { should =~ /Modulefile/ }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end
end
