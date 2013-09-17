require 'rspec-system/spec_helper'

require 'rspec-system-puppet/helpers'
include RSpecSystemPuppet::Helpers

#require 'rspec-system-serverspec/helpers'
#include Serverspec::Helper::RSpecSystem
#include Serverspec::Helper::DetectOS

RSpec.configure do |c|
    # Project root
    proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

    # Enable color
    c.tty = true

    c.include RSpecSystemPuppet::Helpers

    # This is where we 'setup' the nodes before running our tests
    c.before :suite do
        # Install puppet
        puppet_install

        # Replace mymodule with your module name
        puppet_module_install(:source => proj_root, :module_name => 'createrepo')
    end
end
