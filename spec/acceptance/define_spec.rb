require 'spec_helper_acceptance'

describe 'createrepo define:', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'basic usage:' do
    it 'should work with no errors' do
      pp = <<-EOS
        file { '/var/yumrepos': ensure => directory, }
        file { '/var/cache/yumrepos': ensure => directory, }
        createrepo { 'test-repo': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/var/yumrepos/test-repo/repodata') do
      it { should be_directory }
    end

    describe cron do
      if fact('osfamily') != 'RedHat'
        it { should have_entry('*/10 * * * * /usr/bin/createrepo --cachedir /var/cache/yumrepos/test-repo --update /var/yumrepos/test-repo').with_user('root') }
      else
        it { should have_entry('*/10 * * * * /usr/bin/createrepo --cachedir /var/cache/yumrepos/test-repo --changelog-limit 5 --update /var/yumrepos/test-repo').with_user('root') }
      end
    end

    describe file('/usr/local/bin/createrepo-update-test-repo') do
      it { should be_file }
      it { should be_mode '755' }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      if fact('osfamily') != 'RedHat'
        it { should contain '/usr/bin/createrepo --cachedir /var/cache/yumrepos/test-repo --update /var/yumrepos/test-repo' }
      else
        it { should contain '/usr/bin/createrepo --cachedir /var/cache/yumrepos/test-repo --changelog-limit 5 --update /var/yumrepos/test-repo' }
      end
    end
  end

  context 'with apache configuration:' do
    it 'should work with no errors' do
      pp = <<-EOS
        file { '/var/yumrepos': ensure => directory, }
        file { '/var/cache/yumrepos': ensure => directory, }
        createrepo { 'test-repo':
          repository_dir => '/var/yumrepos/test-repo',
          repo_cache_dir => '/var/cache/yumrepos/test-repo',
        }
        include apache
        apache::vhost { 'yum':
          port          => 80,
          docroot       => '/var/yumrepos',
          docroot_owner => 'root',
          docroot_group => 'root',
          serveraliases => ['yum.foo.local'],
        }
        host { 'yum.foo.local': ip => '127.0.0.1', }
      EOS
        
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    it 'repodata should be accessible via http' do
      shell("/usr/bin/curl yum.foo.local:80/test-repo/repodata/") do |r|
        r.stdout.should =~ /primary.xml/
        r.exit_code.should == 0
      end
    end
  end
end
