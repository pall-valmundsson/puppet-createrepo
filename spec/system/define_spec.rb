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

    describe file('/var/yumrepos/test-repo/repodata') do
      it { should be_directory }
    end

    describe cron do
      if node.facts['osfamily'] != 'RedHat'
        it { should have_entry('*/1 * * * * /usr/bin/createrepo --cachedir /var/cache/yumrepos/test-repo --update /var/yumrepos/test-repo').with_user('root') }
      else
        it { should have_entry('*/1 * * * * /usr/bin/createrepo --cachedir /var/cache/yumrepos/test-repo --changelog-limit 5 --update /var/yumrepos/test-repo').with_user('root') }
      end
    end

  end
end
