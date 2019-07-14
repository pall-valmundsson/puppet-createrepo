require 'spec_helper_acceptance'

FUTURE_PARSER = ENV['FUTURE_PARSER'] == 'yes'

describe 'createrepo define:', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'basic usage:' do
    it 'should work with no errors' do
      pp = <<-EOS
        file { '/var/yumrepos': ensure => directory, }
        file { '/var/cache/yumrepos': ensure => directory, }
        createrepo { 'test-repo': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true, :future_parser => FUTURE_PARSER).exit_code).to be_zero
    end

    describe file('/var/yumrepos/test-repo/repodata') do
      it { should be_directory }
    end

    describe cron do
      it { should have_entry('*/10 * * * * /usr/local/bin/createrepo-update-test-repo').with_user('root') }
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

  if fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') == '7'
    context 'with createrepo_c package:' do
      it 'should work with no errors' do
        pp = <<-EOS
          file { '/var/yumrepos': ensure => directory, }
          file { '/var/cache/yumrepos': ensure => directory, }
          createrepo { 'test-repo': createrepo_package => 'createrepo_c', createrepo_cmd => '/usr/bin/createrepo_c', }
        EOS

        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true, :future_parser => FUTURE_PARSER).exit_code).to be_zero
      end

      describe file('/usr/local/bin/createrepo-update-test-repo') do
        it { should be_file }
        it { should be_mode '755' }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should contain '/usr/bin/createrepo_c --cachedir /var/cache/yumrepos/test-repo --changelog-limit 5 --update /var/yumrepos/test-repo' }
      end
    end
  end

  context 'with slash in repo name:' do
    it 'should work with no errors' do
      pp = <<-EOS
        file { '/var/yumrepos': ensure => directory, }
        file { '/var/yumrepos/el6': ensure => directory, }
        file { '/var/cache/yumrepos': ensure => directory, }
        file { '/var/cache/yumrepos/el6': ensure => directory, }
        createrepo { 'el6/test-repo': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true, :future_parser => FUTURE_PARSER).exit_code).to be_zero
    end

    describe file('/var/yumrepos/el6/test-repo/repodata') do
      it { should be_directory }
    end

    describe cron do
      it { should have_entry('*/10 * * * * /usr/local/bin/createrepo-update-el6-test-repo').with_user('root') }
    end

    describe file('/usr/local/bin/createrepo-update-el6-test-repo') do
      it { should be_file }
      it { should be_mode '755' }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      if fact('osfamily') != 'RedHat'
        it { should contain '/usr/bin/createrepo --cachedir /var/cache/yumrepos/el6/test-repo --update /var/yumrepos/el6/test-repo' }
      else
        it { should contain '/usr/bin/createrepo --cachedir /var/cache/yumrepos/el6/test-repo --changelog-limit 5 --update /var/yumrepos/el6/test-repo' }
      end
    end
  end

  context 'with mixed owner/group and recurse set and ignore on repodata directory' do
    it 'should not affect the repodata directory' do
      pp = <<-EOS
        file { '/var/yumrepos': ensure => directory, }
        file { '/var/cache/yumrepos': ensure => directory, }
        createrepo { 'test-repo-ignore':
          repo_owner => 'root',
          repo_group => 'daemon',
          repo_recurse => true,
          repo_ignore => ['repodata'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true, :future_parser => FUTURE_PARSER).exit_code).to be_zero
      shell('ls -l /var/yumrepos/test-repo-ignore') # will only show in debug
      # Run createrepo as root, this will change the group of repodata to root
      shell('/usr/local/bin/createrepo-update-test-repo-ignore')
      shell('ls -l /var/yumrepos/test-repo-ignore') # will only show in debug
      # Running the manifest again to ensure idempotency with recurse as we're ignoring the repodata directory
      expect(apply_manifest(pp, :catch_failures => true, :future_parser => FUTURE_PARSER).exit_code).to be_zero
      shell('ls -l /var/yumrepos/test-repo-ignore') # will only show in debug
    end

    describe file('/var/yumrepos/test-repo-ignore/repodata') do
      it { should be_directory }
      it { should be_owned_by 'root' }
      # Initially the repodata directory will be owned by wheel
      # but when updating the repo the group of repodata will
      # become root and as the repo_ignore parameter is set
      # to ignore it the repo_recurse parameter will not affect
      # the group of the directory
      it { should be_grouped_into 'root' }
    end

  end
end
