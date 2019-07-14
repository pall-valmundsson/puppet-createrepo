require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

UNSUPPORTED_PLATFORMS = [ 'Windows', 'Solaris', 'AIX' ]

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
    hosts.each do |host|
        if host.is_pe?
            install_pe
        else
            install_puppet
            on host, "mkdir -p #{host['distmoduledir']}"
        end
    end
end

RSpec.configure do |c|
    # Project root
    proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

    # Enable color
    #c.tty = true

    c.formatter = :documentation

    # This is where we 'setup' the nodes before running our tests
    c.before :suite do
        # Install module
        puppet_module_install(:source => proj_root, :module_name => 'createrepo')
        hosts.each do |host|
            # Workaround for https://tickets.puppetlabs.com/browse/MODULES-4559
            if fact('operatingsystemmajrelease') == '6'
                on host, puppet('module','install','puppetlabs-stdlib', '--version', '4.15.0'), { :acceptable_exit_codes => [0,1] }
            else
                on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
            end
            # Debian docker image doesn't contain cron
            apply_manifest_on host, 'package { "anacron": ensure => installed }' if fact('osfamily') == 'Debian'
        end
    end
end
