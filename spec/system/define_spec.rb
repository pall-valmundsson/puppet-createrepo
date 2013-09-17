require 'spec_helper_system'

describe 'createrepo define:' do
  context 'basic usage:' do
    pp = <<-EOS
      file { '/var/yumrepos': ensure => directory, }
      file { '/var/cache/yumrepos': ensure => directory, }
      createrepo { 'test-repo': }
    EOS

    context puppet_apply(pp) do
      its(:stderr) { should be_empty }
      its(:exit_code) { should_not == 1 }
      its(:refresh) { should be_nil }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end
end
